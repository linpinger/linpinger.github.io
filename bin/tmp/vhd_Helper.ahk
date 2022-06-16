;	用途: 萌萌哒 制作vhd系统
;	依赖: Dism++，bcdboot.exe(包含在Dism++中)，BootICE.exe，非必要:DiskGenius.exe
;	依赖: 系统自带: reg.exe diskpart.exe
#NoEnv
	verDate := "2022-06-16 public"

	vhdDir := "D:\etc\vhd" ; VHD存放dir
	vhdSizeG := 0 ; 列出时根据文件名推荐大小
	vhdType := "expandable"

	; 依赖程序所在文件夹，需修改
	EnvGet, oldPATH, PATH
	EnvSet, PATH, D:\bin\bootTools`;D:\bin\Dism++`;D:\bin\Dism++\Config\x86`;%oldPATH%

	wDir := A_WorkingDir
	SetWorkingDir, %wDir%

	gosub, MenuInit
	gosub, GuiInit

	gosub, FindRegDrives
	gosub, FindVHD
	gosub, ShowHelp  ; 1.向导
return

GuiInit:
	Gui, Add, Radio, x12  y10 w70 h20 cBlue vRD1 gShowHelp checked, &1.向导
	Gui, Add, Radio, x82  y10 w70 h20 cBlue vRD2 gShowCreateVHD, &2.VHD
	Gui, Add, Radio, x152 y10 w70 h20 cBlue vRD3 gShowSettings, &3.注册表
	Gui, Add, Radio, x222 y10 w70 h20 cBlue vRD4 gShowBins, &4.工具

	Gui, Add, ComboBox, x382 y10 w200 h10 R9 choose1 vVHDPath gChangeVHDPath
	Gui, Add, ComboBox, x592 y10 w60  h20 R9 choose1 vDriveLetter, V

	Gui, Add, ListView, x12 y40 w640 R15 -ReadOnly vFoxLV gClickLV, 值（F2编辑）|备注|T
		LV_ModifyCol(1, 220), LV_ModifyCol(2, 340), LV_ModifyCol(3, 40)

	Gui, Add, StatusBar, gClickSB, Hello
	; Generated using SmartGUI Creator 4.0
	Gui, Show, y100 h333 w666, VHD Helper  Ver:%verDate%
Return

BCDbootAddItem: ; bcdboot生成bcd条目
	GuiControlGet, DriveLetter
	tmpPath := DriveLetter . ":\windows"
	IfExist, %tmpPath%
	{
		msgbox,260,, 是否将以下添加到BCD？`n%tmpPath%
		ifmsgbox,yes
		{
			runwait, bcdboot.exe %tmpPath% /l zh-cn
			run, BOOTICE.exe /edit_bcd /easymode
		}
	} else {
		tip("错误: 不存在: " tmpPath)
	}
return

ShowSettings: ; 注册表优化
	LV_Delete()
	LV_Add()
	LV_Add("", "< 挂载注册表文件", "挂载右上角盘符里的system,software到HKLM\0,HKLM\1", "reg")
	LV_Add()
	LV_Add("", "HKLM_0_动态vhd不占用最大空间", "使动态大小VHD不占用分配的全部空间", "reg")
	LV_Add()
	LV_Add("", "HKLM_1_SoftWare_移动存储设备禁止写", "组策略：计算机配置》管理模版》系统》可移动存储访问", "reg")
	LV_Add()
	LV_Add("", "[可选]将本机盘符复制到HKLM\0", "复制HKLM\SYSTEM\MountedDevices下的DosDevices到HKLM\0\MountedDevices", "reg")
	LV_Add()
	LV_Add("", "> 卸载注册表文件", "卸载HKLM\0,HKLM\1", "reg")
	LV_Add()
	LV_Add("", "4. 添加BCD条目", "bcdboot自动添加", "info")
	tip("先挂载，再优化，再卸载")
return

ClickLV: ; 点击LV
	nRow := A_EventInfo
	if ( A_GuiEvent = "DoubleClick" ) { ; LV左键双击
		LV_GetText(xNewValue, nRow, 1)
		LV_GetText(xOldValue, nRow, 2)
		LV_GetText(xType, nRow, 3)
		if ( "reg" = xType ) { ; 修改
			if ( InStr(xOldValue, "MountedDevices") ) {
				srcMD := "HKEY_LOCAL_MACHINE\SYSTEM\MountedDevices"
				tarMD := "HKEY_LOCAL_MACHINE\0\MountedDevices"
				Loop, Reg, %srcMD%, V
				{
					if ( InStr(A_LoopRegName, "\DosDevices\") ) {
						RegRead, nowHex
						RegWrite, REG_BINARY, %tarMD%, %A_LoopRegName%, %nowHex%
					}
				}
				gosub, ShowMountedList
			}
			if ( InStr(xNewValue, "挂载注册表文件") ) {
				gosub, MountReg
			}
			if ( InStr(xNewValue, "卸载注册表文件") ) {
				gosub, UnMountReg
			}
			if ( InStr(xNewValue, "HKLM_0_动态vhd不占用最大空间") ) {
				tip( "写注册表项返回: " VirtualDiskExpandOnMount() )
			}
			if ( InStr(xNewValue, "HKLM_1_SoftWare_移动存储设备禁止写") ) {
				ret := SoftWare_Removeable_No_Write()
				if ( "" != ret )
					msgbox, % "错误: " ret
				else
					tip("设置成功，见:HKLM\1\Policies\Microsoft\Windows\RemovableStorageDevices")
			}
		}
		if ( "LM" = xType or "RM" = xType ) { ; 注册表列表，修改
			if ( ! InStr(xOldValue, "\DosDevices\") ) {
				tip(A_TickCount " 非注册表项，不保存")
				return
			}
			if ( xNewValue = xOldValue ) {
				tip(A_TickCount " 新旧值相同，不保存")
				return
			}

			tip("修改: " xOldValue " -> " xNewValue)

			if ( "LM" = xType ) {
				RegRead, SrcValue, HKLM\SYSTEM\MountedDevices, %xOldValue%
				RegWrite, REG_BINARY, HKLM\SYSTEM\MountedDevices, %xNewValue%, %SrcValue%
				RegDelete, HKLM\SYSTEM\MountedDevices, %xOldValue%
			}
			if ( "RM" = xType ) {
				RegRead, SrcValue, HKLM\0\MountedDevices, %xOldValue%
				RegWrite, REG_BINARY, HKLM\0\MountedDevices, %xNewValue%, %SrcValue%
				RegDelete, HKLM\0\MountedDevices, %xOldValue%
			}

			gosub, ShowDriveList
		}
		if ( "info" = xType ) { ; 提示
			if ( InStr(xNewValue, "创建 vhd") ) {
				GuiControl, , RD2, 1
				gosub, ShowCreateVHD
;				gosub, CreateVHD
;				gosub, MountVHD
			}
			if ( InStr(xNewValue, "装系统到vhd") ) {
				run, Dism++x86.exe
				gosub, ResEsd
			}
			if ( InStr(xNewValue, "挂载注册表进行设置") ) { ; 可选设置
				GuiControl, , RD3, 1
				gosub, ShowSettings
			}
			if ( InStr(xOldValue, "bcdboot自动添加") ) {
				gosub, BCDbootAddItem
;				run, BOOTICE.exe /edit_bcd /easymode
			}
			if ( InStr(xNewValue, "卸载 vhd") ) {
				gosub, UnMountVHD
			}
			if ( InStr(xOldValue, "重启后选择") ) {
				msgbox,260,,真的要重启吗？
				ifmsgbox,yes
					shutdown, 2
			}
		}

		if ( "vhd" = xType ) { ; 建vhd
			if ( InStr(xOldValue, "文件大小，单位") ) {
				vhdSizeG := xNewValue
				gosub, ShowVHDConfig
			}
			if ( InStr(xOldValue, "动态大小") ) {
				vhdType := xNewValue
				gosub, ShowVHDConfig
			}
			if ( InStr(xNewValue, "创建vhd") ) {
				gosub, CreateVHD
			}
			if ( InStr(xNewValue, "创建差分vhd") ) {
				gosub, CreateSubVHD
			}
			if ( InStr(xNewValue, "卸载vhd") ) {
				gosub, UnMountVHD
			}
			if ( InStr(xNewValue, "挂载vhd") ) {
				gosub, MountVHD
			}
		}

		if ( "exe" = xType ) { ; 工具
			run, %xNewValue%, %wDir%
		}
	}

	if ( A_GuiEvent = "R" ) { ; 右键双击
		LV_GetText(xNewValue, nRow, 1)
		LV_GetText(xOldValue, nRow, 2)
		LV_GetText(xType, nRow, 3)
		if ( "LM" = xType or "RM" = xType ) { ; 本机注册表列表，删除
			msgbox, 260, 确认, 是否删除: %xOldValue%
			IfMsgBox, Yes
			{
				tip("删除: " xOldValue)
				if ( "LM" = xType ) {
					RegDelete, HKLM\SYSTEM\MountedDevices, %xOldValue%
				}
				if ( "RM" = xType ) {
					RegDelete, HKLM\0\MountedDevices, %xOldValue%
				}
				gosub, ShowDriveList
			}
		}
	}
return

ResEsd: ; 2022-06-16测试: 用来自动化填入驱动号
	winactivate, ahk_class DismMainFrame
	WinWaitActive, ahk_class DismMainFrame

	send !R{down 4}{enter}

	winwait, 释放映像 ahk_class #32770
	winactivate, 释放映像 ahk_class #32770
	WinWaitActive, 释放映像 ahk_class #32770

	esdPath := findInstallEsd()
;	esdPath := "E:\sources\install.esd"
	if ( "" != esdPath ) {
		ControlSetText, Edit1, , 释放映像 ahk_class #32770
		Control, EditPaste, %esdPath%, Edit1, 释放映像 ahk_class #32770
	}

	GuiControlGet, DriveLetter
	ControlSetText, Edit2, , 释放映像 ahk_class #32770
	Control, EditPaste, %DriveLetter%:, Edit2, 释放映像 ahk_class #32770

	ControlFocus , ComboBox1, 释放映像 ahk_class #32770
return

findInstallEsd() {
	DriveGet, drvs, List, CDROM
	loop, parse, drvs
	{
		esdPath := A_loopfield ":\sources\install.esd"
		ifExist, %esdPath%
			return esdPath
	}
}

ClickSB:
	if ( A_GuiEvent = "DoubleClick" ) {
		run, BOOTICE.exe /edit_bcd /easymode
	}
	if ( A_GuiEvent = "RightClick" ) {
		run, regedit
	}
return

MenuInit:

	Menu, MyMenuBar, Add, 刷新(&R), MenuAct
	Menu, MyMenuBar, Add, |, MenuAct
	Menu, MyMenuBar, Add, 本机盘符(&N), MenuAct
	Menu, MyMenuBar, Add, 已挂载盘符(&F), MenuAct
	Gui, Menu, MyMenuBar
return

MenuAct:
	if ( "本机盘符(&N)" = A_ThisMenuItem ) {
		gosub, ShowLocalList
	} else if ( "已挂载盘符(&F)" = A_ThisMenuItem ) {
		gosub, ShowMountedList
	} else if ( "刷新(&R)" = A_ThisMenuItem ) {
		gosub, FindRegDrives
		gosub, FindVHD
	} else if ( "xxxxxx" = A_ThisMenuItem ) {
	}
return

MountReg: ; 挂载DriveLetter里面的system/software 到HKLM\0 / HKLM\1
	GuiControlGet, DriveLetter
	RegPath0 := DriveLetter ":\Windows\System32\config\system"
	RegPath1 := DriveLetter ":\Windows\System32\config\software"
	IfNotExist, %RegPath0%
	{
		tip("错误: 不存在: " RegPath0)
		return
	}

	runwait, REG LOAD HKLM\0 %RegPath0%, , UseErrorLevel min
	ret0 := ErrorLevel
	runwait, REG LOAD HKLM\1 %RegPath1%, , UseErrorLevel min
	ret1 := ErrorLevel

	if ( 0 != ret0 or 0 != ret1 )
		tip(A_now " 错误: 挂载返回值0, 1: " ret0 ", " ret1)
	else
		tip(A_now " 成功挂载: HKLM\0 和 HKLM\1，返回: " ret0 ", " ret1)
return

UnMountReg:
	runwait, REG UnLOAD HKLM\0, , UseErrorLevel min
	ret0 := ErrorLevel
	runwait, REG UnLOAD HKLM\1, , UseErrorLevel min
	ret1 := ErrorLevel
	if ( 0 != ret0 or 0 != ret1 )
		tip(A_TickCount " 错误: 卸载返回值0, 1: " ret0 ", " ret1)
	else
		tip(A_now " 成功卸载: HKLM\0 和 HKLM\1，返回: " ret0 ", " ret1)
return

FindRegDrives:  ; 刷新驱动器列表，找包含注册表配置单元文件的盘符
	GuiControlGet, DriveLetter
	GuiControl, , DriveLetter, |%DriveLetter%
	GuiControl, ChooseString, DriveLetter, %DriveLetter%

	nowDriveLetter := getDriveLetter()
	DriveGet, driveList, List, FIXED
	loop, parse, driveList
	{
		if ( A_LoopField = nowDriveLetter )
			continue
		if ( A_LoopField = DriveLetter )
			continue
		IfExist, %A_LoopField%:\Windows\System32\config\system
		{
			GuiControl, , DriveLetter, %A_LoopField%
;			GuiControl, ChooseString, DriveLetter, %A_LoopField%
		}
	}
return

ShowLocalList:  ; 显示本机盘符列表
	gDrvType := "LM"
	gosub, ShowDriveList
return

ShowMountedList:  ; 显示已挂载盘符列表
	gDrvType := "RM"
	gosub, ShowDriveList
return

ShowDriveList:
	LV_Delete()
	if ( "LM" = gDrvType )
		gNowMD := "HKEY_LOCAL_MACHINE\SYSTEM\MountedDevices"
	if ( "RM" = gDrvType )
		gNowMD := "HKEY_LOCAL_MACHINE\0\MountedDevices"
	Loop, Reg, %gNowMD%, V
	{
		if ( InStr(A_LoopRegName, "\DosDevices\") ) {
			LV_Add("", A_LoopRegName, A_LoopRegName, gDrvType)
		}
	}
	LV_ModifyCol(1, "Sort")
	tip("说明：条目按F2编辑，修改后，双击保存，右键双击删除")
return

GuiClose:
	ExitApp
return

ShowHelp:
	LV_Delete()
	LV_Add()
	LV_Add("", "1. 创建 vhd 并挂载，分区，格式化", "w7大概25G，w10大概50G，动态扩展，优先VHDX", "info")
	LV_Add()
	LV_Add("", "2. 装系统到vhd，并可注入驱动", "Dism++还原，且可注入驱动，或winNTSetup安装", "info")
	LV_Add()
	LV_Add("", "3. [可选]挂载注册表进行设置或改盘符", "进行优化或添加启动项,如果vhd放在C盘,得改盘符", "info")
	LV_Add()
	LV_Add("", "4. 添加BCD条目", "bcdboot自动添加或BootIce手动添加vhd类型: \etc\vhd\xxx.vhd", "info")
	LV_Add()
	LV_Add("", "5. 卸载 vhd", "记得先卸载已挂载的注册表配置单元或关闭Dism++", "info")
	LV_Add()
	LV_Add("", "6. 重启", "重启后选择vhd条目开始安装系统", "info")
	tip("提示: 双击条目可运行该条目需要的工具")
return

ShowCreateVHD:
	gosub, ShowVHDConfig

	LV_Delete()
	LV_Add("", vhdSizeG, "vhd(x)文件大小，单位:G，w7建议25，w10后建议50", "vhd")
	LV_Add("", vhdType, "expandable=动态大小，fixed=固定大小", "vhd")
	LV_Add()
	LV_Add("", "----以上为设置；以下为动作----", "编辑以上设置后，双击该条目以生效；双击以下条目执行", "-")
	LV_Add()
	LV_Add("", "+ 创建vhd", "双击本条目开始创建vhd并自动分区挂载", "vhd")
	LV_Add()
	LV_Add("", "2. 装系统到vhd，并可注入驱动", "Dism++还原，且可注入驱动，或winNTSetup安装", "info")
	LV_Add()
	LV_Add("", "> 卸载vhd", "双击本条目开始卸载vhd", "vhd")
	LV_Add()
	LV_Add("", "< 挂载vhd", "双击本条目开始挂载vhd", "vhd")
	LV_Add()
	LV_Add("", "+ 创建差分vhd", "双击本条目开始创建差分vhd，根据父vhd路径生成", "vhd")

	LV_Modify(6, "select")
return

ShowVHDConfig:
	GuiControlGet, VHDPath
	GuiControlGet, DriveLetter
	if ( 0 = vhdSizeG ) {
		SplitPath, VHDPath, , , , vhdNameNoExt
		if ( InStr(vhdNameNoExt, "7") ) { ; win7推荐25，其他50
			vhdSizeG := 25
		} else {
			vhdSizeG := 50
		}
	}
	tip("当前VHD: " VHDPath "，最大大小: " vhdSizeG " G，类型：" vhdType "，挂载盘符：" DriveLetter)
return

FindVHD:
	GuiControlGet, VHDPath
	GuiControl, , VHDPath, |

	vhdList := ""
	loop, Files, %vhdDir%\*
	{
		if ( A_LoopFileExt = "vhd" or A_LoopFileExt = "vhdx" ) {
			GuiControl, , VHDPath, %A_LoopFileFullPath%
			vhdList .= A_LoopFileFullPath "|"
		}
	}

	posList =
(join|
----以下是建议路径
D:\etc\vhd\w7b.vhd
D:\etc\vhd\w7c.vhd
D:\etc\vhd\w10.vhdx
D:\etc\vhd\w11.vhdx
)
	GuiControl, , VHDPath, %posList%

	if ( "" = vhdList ) {
		vhdList .= posList
		Guicontrol, choose, VHDPath, 3 ; 选w7c.vhd
	} else {
		Guicontrol, choose, VHDPath, 1 ; 选找到的第一个
	}

	if ( "" != VHDPath ) {
		if ( InStr(vhdList, VHDPath) ) {
			GuiControl, ChooseString, VHDPath, %VHDPath%
		} else {
			GuiControl, Text, VHDPath, %VHDPath%
		}
	}

return

ChangeVHDPath: ; VHDPath 修改时，记得重置vhdSizeG = 0
	VHDSizeG := 0
	gosub, ShowVHDConfig
return

CreateVHD:
	Gui, submit, nohide
	If ( "" = VHDPath ) {
		tip("错误: VHDPath为空")
		return
	}
	IfExist, %VHDPath%
	{
		tip("错误: 文件已存在: " VHDPath)
		return
	}
	SplitPath, VHDPath, , nowVHDDir
	IfNotExist, %nowVHDDir%
		FileCreateDir, %nowVHDDir%
	IfNotExist, %nowVHDDir%
	{
		tip("错误: 创建目录失败: " nowVHDDir)
		return
	}
	DriveGet, driveList, List, FIXED
	if ( InStr(driveList, DriveLetter) ) {
		tip("错误: 已存在盘符: " DriveLetter)
		return
	}
	tmpSizeM := VHDSizeG * 1024
	
	tip("创建中...")
	tmpText := "create vdisk file=""" VHDPath """ maximum=" tmpSizeM " type=" vhdType "`r`nselect vdisk file=""" VHDPath """`r`nattach vdisk`r`ncreate partition primary`r`nactive`r`nformat fs=ntfs quick label=vhd`r`nassign letter=" DriveLetter "`r`n"
	tmpName := A_now "_diskpart.txt"
	FileAppend, %tmpText%, %wDir%\%tmpName%
	runwait, diskpart /s %tmpName%, %wDir%, hide
	loop {
		FileDelete, %wDir%\%tmpName%
		IfExist, %wDir%\%tmpName%
			sleep 500
		else
			break
	}
	DriveGet, driveList, List, FIXED
	if ( ! InStr(driveList, DriveLetter) ) {
		tip("错误: 创建失败: 不存在盘符: " DriveLetter)
	} else {
		tip("成功: 创建: " VHDPath " 并挂载在: " DriveLetter)
	}
return

CreateSubVHD:
	Gui, submit, nohide
	If ( "" = VHDPath ) {
		tip("错误: VHDPath为空")
		return
	}
	IfNotExist, %VHDPath%
	{
		tip("错误: 文件不存在: " VHDPath)
		return
	}
	nowSubVHDPath := getSubVHDPath(VHDPath)
	msgbox,260,, 是否根据：`n%VHDPath%`n创建子映像->`n%nowSubVHDPath%
	ifmsgbox,yes
	{
		tip("创建中...")
		tmpText := "create vdisk file=""" nowSubVHDPath """ parent=""" VHDPath """`r`n"
		tmpName := A_now "_diskpart.txt"
		FileAppend, %tmpText%, %wDir%\%tmpName%
		runwait, diskpart /s %tmpName%, %wDir%, hide
		loop {
			FileDelete, %wDir%\%tmpName%
			IfExist, %wDir%\%tmpName%
				sleep 500
			else
				break
		}
		IfExist, %nowSubVHDPath%
		{
			Clipboard := nowSubVHDPath
			tip("成功: 创建并复制到剪贴板: " nowSubVHDPath)
		} else {
			tip("失败: 创建: " nowSubVHDPath)
		}
	}
return

MountVHD:
	GuiControlGet, VHDPath
	GuiControlGet, DriveLetter
	If ( "" = VHDPath ) {
		tip("错误: VHDPath为空")
		return
	}
	IfNotExist, %VHDPath%
	{
		tip("错误: 文件不存在: " VHDPath)
		return
	}
	DriveGet, driveList, List, FIXED
	if ( InStr(driveList, DriveLetter) ) {
		tip("错误: 已存在盘符: " DriveLetter)
		return
	}
	tmpText := "select vdisk file=""" VHDPath """`r`nattach vdisk`r`nassign letter=" DriveLetter "`r`n"
	tmpName := A_now "_diskpart.txt"
	FileAppend, %tmpText%, %wDir%\%tmpName%
	runwait, diskpart /s %tmpName%, %wDir%, hide
	loop {
		FileDelete, %wDir%\%tmpName%
		IfExist, %wDir%\%tmpName%
			sleep 500
		else
			break
	}
	DriveGet, driveList, List, FIXED
	if ( ! InStr(driveList, DriveLetter) ) {
		tip("错误: 挂载失败: 不存在盘符: " DriveLetter)
	} else {
		tip("成功: 挂载: " VHDPath " 在: " DriveLetter)
	}
return

UnMountVHD:
	GuiControlGet, VHDPath
	GuiControlGet, DriveLetter
	If ( "" = VHDPath ) {
		tip("错误: VHDPath为空")
		return
	}
	IfNotExist, %VHDPath%
	{
		tip("错误: 文件不存在: " VHDPath)
		return
	}
	tmpText := "select vdisk file=""" VHDPath """`r`ndetach vdisk`r`n"
	tmpName := A_now "_diskpart.txt"
	FileAppend, %tmpText%, %wDir%\%tmpName%
	runwait, diskpart /s %tmpName%, %wDir%, hide
	loop {
		FileDelete, %wDir%\%tmpName%
		IfExist, %wDir%\%tmpName%
			sleep 500
		else
			break
	}
	loop 9 {
		DriveGet, driveList, List, FIXED
		if ( ! InStr(driveList, DriveLetter) ) {
			break
		} else {
			sleep 1000
		}
	}
	DriveGet, driveList, List, FIXED
	if ( InStr(driveList, DriveLetter) ) {
		tip("错误: 卸载失败: 仍存在盘符: " DriveLetter)
	} else {
		tip("成功: 卸载: " VHDPath)
	}
return

ShowBins:
	LV_Delete()
	LV_Add("", "BOOTICE.exe /edit_bcd /easymode", "编辑BCD", "exe")
	LV_Add("", "Dism++x86.exe", "用来恢复系统，打驱动", "exe")
	LV_Add("", "BOOTICE.exe", "用来修改启动", "exe")
	LV_Add("", "DiskGenius.exe", "用来克隆分区", "exe")
	LV_Add("", "diskmgmt.msc", "磁盘管理", "exe")
	LV_Add("", "cmd.exe", "命令行", "exe")
	LV_Add("", "regedit.exe", "注册表", "exe")
	tip("说明：双击条目打开")
return

^esc::reload
+esc::Edit
!esc::ExitApp

tip(iStr="") {
	SB_SetText(iStr)
}

getDriveLetter(iPath="") { ; 返回 C
	if ( "" = iPath )
		iPath := A_WinDir
	return SubStr(iPath, 1, 1)
}

getSubVHDPath(iVHDPath) { ; 根据父映像路径xx.vhd，返回新差分映像路径xx.N.vhd
	SplitPath, iVHDPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
	loop 9 {
		subVHDPath := OutDir "\" OutNameNoExt "." A_Index "." OutExtension
		IfNotExist, %subVHDPath%
			return subVHDPath
	}
}

VirtualDiskExpandOnMount(iValue=4) { ; HKLM_0_动态vhd不占用最大空间
	RegWrite, REG_DWORD, HKLM\0\ControlSet001\Services\FsDepends\Parameters, VirtualDiskExpandOnMount, %iValue%
	if ( 1 = ErrorLevel )
		return A_LastError
}


SoftWare_Removeable_No_Write(){
	IDS := ["{53f56311-b6bf-11d0-94f2-00a0c91efb8b}", "{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}", "{53f5630b-b6bf-11d0-94f2-00a0c91efb8b}", "{6AC27878-A6FA-4155-BA85-F98F491D4F33}", "{F33FDC04-D1AC-4E8E-9A30-19BBD4B108AE}"]
	for idx, UUID in IDS
	{
		RegWrite, REG_DWORD, HKLM\1\Policies\Microsoft\Windows\RemovableStorageDevices\%UUID%, Deny_Execute, 0
		RegWrite, REG_DWORD, HKLM\1\Policies\Microsoft\Windows\RemovableStorageDevices\%UUID%, Deny_Read, 0
		RegWrite, REG_DWORD, HKLM\1\Policies\Microsoft\Windows\RemovableStorageDevices\%UUID%, Deny_Write, 1
		if ( 1 = ErrorLevel )
			return A_LastError
	}
}

