;	��;: ������ ����vhdϵͳ
;	����: Dism++��bcdboot.exe(������Dism++��)��BootICE.exe���Ǳ�Ҫ:DiskGenius.exe
;	����: ϵͳ�Դ�: reg.exe diskpart.exe
#NoEnv
	verDate := "2022-06-16 public"

	vhdDir := "D:\etc\vhd" ; VHD���dir
	vhdSizeG := 0 ; �г�ʱ�����ļ����Ƽ���С
	vhdType := "expandable"

	; �������������ļ��У����޸�
	EnvGet, oldPATH, PATH
	EnvSet, PATH, D:\bin\bootTools`;D:\bin\Dism++`;D:\bin\Dism++\Config\x86`;%oldPATH%

	wDir := A_WorkingDir
	SetWorkingDir, %wDir%

	gosub, MenuInit
	gosub, GuiInit

	gosub, FindRegDrives
	gosub, FindVHD
	gosub, ShowHelp  ; 1.��
return

GuiInit:
	Gui, Add, Radio, x12  y10 w70 h20 cBlue vRD1 gShowHelp checked, &1.��
	Gui, Add, Radio, x82  y10 w70 h20 cBlue vRD2 gShowCreateVHD, &2.VHD
	Gui, Add, Radio, x152 y10 w70 h20 cBlue vRD3 gShowSettings, &3.ע���
	Gui, Add, Radio, x222 y10 w70 h20 cBlue vRD4 gShowBins, &4.����

	Gui, Add, ComboBox, x382 y10 w200 h10 R9 choose1 vVHDPath gChangeVHDPath
	Gui, Add, ComboBox, x592 y10 w60  h20 R9 choose1 vDriveLetter, V

	Gui, Add, ListView, x12 y40 w640 R15 -ReadOnly vFoxLV gClickLV, ֵ��F2�༭��|��ע|T
		LV_ModifyCol(1, 220), LV_ModifyCol(2, 340), LV_ModifyCol(3, 40)

	Gui, Add, StatusBar, gClickSB, Hello
	; Generated using SmartGUI Creator 4.0
	Gui, Show, y100 h333 w666, VHD Helper  Ver:%verDate%
Return

BCDbootAddItem: ; bcdboot����bcd��Ŀ
	GuiControlGet, DriveLetter
	tmpPath := DriveLetter . ":\windows"
	IfExist, %tmpPath%
	{
		msgbox,260,, �Ƿ�������ӵ�BCD��`n%tmpPath%
		ifmsgbox,yes
		{
			runwait, bcdboot.exe %tmpPath% /l zh-cn
			run, BOOTICE.exe /edit_bcd /easymode
		}
	} else {
		tip("����: ������: " tmpPath)
	}
return

ShowSettings: ; ע����Ż�
	LV_Delete()
	LV_Add()
	LV_Add("", "< ����ע����ļ�", "�������Ͻ��̷����system,software��HKLM\0,HKLM\1", "reg")
	LV_Add()
	LV_Add("", "HKLM_0_��̬vhd��ռ�����ռ�", "ʹ��̬��СVHD��ռ�÷����ȫ���ռ�", "reg")
	LV_Add()
	LV_Add("", "HKLM_1_SoftWare_�ƶ��洢�豸��ֹд", "����ԣ���������á�����ģ�桷ϵͳ�����ƶ��洢����", "reg")
	LV_Add()
	LV_Add("", "[��ѡ]�������̷����Ƶ�HKLM\0", "����HKLM\SYSTEM\MountedDevices�µ�DosDevices��HKLM\0\MountedDevices", "reg")
	LV_Add()
	LV_Add("", "> ж��ע����ļ�", "ж��HKLM\0,HKLM\1", "reg")
	LV_Add()
	LV_Add("", "4. ���BCD��Ŀ", "bcdboot�Զ����", "info")
	tip("�ȹ��أ����Ż�����ж��")
return

ClickLV: ; ���LV
	nRow := A_EventInfo
	if ( A_GuiEvent = "DoubleClick" ) { ; LV���˫��
		LV_GetText(xNewValue, nRow, 1)
		LV_GetText(xOldValue, nRow, 2)
		LV_GetText(xType, nRow, 3)
		if ( "reg" = xType ) { ; �޸�
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
			if ( InStr(xNewValue, "����ע����ļ�") ) {
				gosub, MountReg
			}
			if ( InStr(xNewValue, "ж��ע����ļ�") ) {
				gosub, UnMountReg
			}
			if ( InStr(xNewValue, "HKLM_0_��̬vhd��ռ�����ռ�") ) {
				tip( "дע������: " VirtualDiskExpandOnMount() )
			}
			if ( InStr(xNewValue, "HKLM_1_SoftWare_�ƶ��洢�豸��ֹд") ) {
				ret := SoftWare_Removeable_No_Write()
				if ( "" != ret )
					msgbox, % "����: " ret
				else
					tip("���óɹ�����:HKLM\1\Policies\Microsoft\Windows\RemovableStorageDevices")
			}
		}
		if ( "LM" = xType or "RM" = xType ) { ; ע����б��޸�
			if ( ! InStr(xOldValue, "\DosDevices\") ) {
				tip(A_TickCount " ��ע����������")
				return
			}
			if ( xNewValue = xOldValue ) {
				tip(A_TickCount " �¾�ֵ��ͬ��������")
				return
			}

			tip("�޸�: " xOldValue " -> " xNewValue)

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
		if ( "info" = xType ) { ; ��ʾ
			if ( InStr(xNewValue, "���� vhd") ) {
				GuiControl, , RD2, 1
				gosub, ShowCreateVHD
;				gosub, CreateVHD
;				gosub, MountVHD
			}
			if ( InStr(xNewValue, "װϵͳ��vhd") ) {
				run, Dism++x86.exe
				gosub, ResEsd
			}
			if ( InStr(xNewValue, "����ע����������") ) { ; ��ѡ����
				GuiControl, , RD3, 1
				gosub, ShowSettings
			}
			if ( InStr(xOldValue, "bcdboot�Զ����") ) {
				gosub, BCDbootAddItem
;				run, BOOTICE.exe /edit_bcd /easymode
			}
			if ( InStr(xNewValue, "ж�� vhd") ) {
				gosub, UnMountVHD
			}
			if ( InStr(xOldValue, "������ѡ��") ) {
				msgbox,260,,���Ҫ������
				ifmsgbox,yes
					shutdown, 2
			}
		}

		if ( "vhd" = xType ) { ; ��vhd
			if ( InStr(xOldValue, "�ļ���С����λ") ) {
				vhdSizeG := xNewValue
				gosub, ShowVHDConfig
			}
			if ( InStr(xOldValue, "��̬��С") ) {
				vhdType := xNewValue
				gosub, ShowVHDConfig
			}
			if ( InStr(xNewValue, "����vhd") ) {
				gosub, CreateVHD
			}
			if ( InStr(xNewValue, "�������vhd") ) {
				gosub, CreateSubVHD
			}
			if ( InStr(xNewValue, "ж��vhd") ) {
				gosub, UnMountVHD
			}
			if ( InStr(xNewValue, "����vhd") ) {
				gosub, MountVHD
			}
		}

		if ( "exe" = xType ) { ; ����
			run, %xNewValue%, %wDir%
		}
	}

	if ( A_GuiEvent = "R" ) { ; �Ҽ�˫��
		LV_GetText(xNewValue, nRow, 1)
		LV_GetText(xOldValue, nRow, 2)
		LV_GetText(xType, nRow, 3)
		if ( "LM" = xType or "RM" = xType ) { ; ����ע����б�ɾ��
			msgbox, 260, ȷ��, �Ƿ�ɾ��: %xOldValue%
			IfMsgBox, Yes
			{
				tip("ɾ��: " xOldValue)
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

ResEsd: ; 2022-06-16����: �����Զ�������������
	winactivate, ahk_class DismMainFrame
	WinWaitActive, ahk_class DismMainFrame

	send !R{down 4}{enter}

	winwait, �ͷ�ӳ�� ahk_class #32770
	winactivate, �ͷ�ӳ�� ahk_class #32770
	WinWaitActive, �ͷ�ӳ�� ahk_class #32770

	esdPath := findInstallEsd()
;	esdPath := "E:\sources\install.esd"
	if ( "" != esdPath ) {
		ControlSetText, Edit1, , �ͷ�ӳ�� ahk_class #32770
		Control, EditPaste, %esdPath%, Edit1, �ͷ�ӳ�� ahk_class #32770
	}

	GuiControlGet, DriveLetter
	ControlSetText, Edit2, , �ͷ�ӳ�� ahk_class #32770
	Control, EditPaste, %DriveLetter%:, Edit2, �ͷ�ӳ�� ahk_class #32770

	ControlFocus , ComboBox1, �ͷ�ӳ�� ahk_class #32770
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

	Menu, MyMenuBar, Add, ˢ��(&R), MenuAct
	Menu, MyMenuBar, Add, |, MenuAct
	Menu, MyMenuBar, Add, �����̷�(&N), MenuAct
	Menu, MyMenuBar, Add, �ѹ����̷�(&F), MenuAct
	Gui, Menu, MyMenuBar
return

MenuAct:
	if ( "�����̷�(&N)" = A_ThisMenuItem ) {
		gosub, ShowLocalList
	} else if ( "�ѹ����̷�(&F)" = A_ThisMenuItem ) {
		gosub, ShowMountedList
	} else if ( "ˢ��(&R)" = A_ThisMenuItem ) {
		gosub, FindRegDrives
		gosub, FindVHD
	} else if ( "xxxxxx" = A_ThisMenuItem ) {
	}
return

MountReg: ; ����DriveLetter�����system/software ��HKLM\0 / HKLM\1
	GuiControlGet, DriveLetter
	RegPath0 := DriveLetter ":\Windows\System32\config\system"
	RegPath1 := DriveLetter ":\Windows\System32\config\software"
	IfNotExist, %RegPath0%
	{
		tip("����: ������: " RegPath0)
		return
	}

	runwait, REG LOAD HKLM\0 %RegPath0%, , UseErrorLevel min
	ret0 := ErrorLevel
	runwait, REG LOAD HKLM\1 %RegPath1%, , UseErrorLevel min
	ret1 := ErrorLevel

	if ( 0 != ret0 or 0 != ret1 )
		tip(A_now " ����: ���ط���ֵ0, 1: " ret0 ", " ret1)
	else
		tip(A_now " �ɹ�����: HKLM\0 �� HKLM\1������: " ret0 ", " ret1)
return

UnMountReg:
	runwait, REG UnLOAD HKLM\0, , UseErrorLevel min
	ret0 := ErrorLevel
	runwait, REG UnLOAD HKLM\1, , UseErrorLevel min
	ret1 := ErrorLevel
	if ( 0 != ret0 or 0 != ret1 )
		tip(A_TickCount " ����: ж�ط���ֵ0, 1: " ret0 ", " ret1)
	else
		tip(A_now " �ɹ�ж��: HKLM\0 �� HKLM\1������: " ret0 ", " ret1)
return

FindRegDrives:  ; ˢ���������б��Ұ���ע������õ�Ԫ�ļ����̷�
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

ShowLocalList:  ; ��ʾ�����̷��б�
	gDrvType := "LM"
	gosub, ShowDriveList
return

ShowMountedList:  ; ��ʾ�ѹ����̷��б�
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
	tip("˵������Ŀ��F2�༭���޸ĺ�˫�����棬�Ҽ�˫��ɾ��")
return

GuiClose:
	ExitApp
return

ShowHelp:
	LV_Delete()
	LV_Add()
	LV_Add("", "1. ���� vhd �����أ���������ʽ��", "w7���25G��w10���50G����̬��չ������VHDX", "info")
	LV_Add()
	LV_Add("", "2. װϵͳ��vhd������ע������", "Dism++��ԭ���ҿ�ע����������winNTSetup��װ", "info")
	LV_Add()
	LV_Add("", "3. [��ѡ]����ע���������û���̷�", "�����Ż������������,���vhd����C��,�ø��̷�", "info")
	LV_Add()
	LV_Add("", "4. ���BCD��Ŀ", "bcdboot�Զ���ӻ�BootIce�ֶ����vhd����: \etc\vhd\xxx.vhd", "info")
	LV_Add()
	LV_Add("", "5. ж�� vhd", "�ǵ���ж���ѹ��ص�ע������õ�Ԫ��ر�Dism++", "info")
	LV_Add()
	LV_Add("", "6. ����", "������ѡ��vhd��Ŀ��ʼ��װϵͳ", "info")
	tip("��ʾ: ˫����Ŀ�����и���Ŀ��Ҫ�Ĺ���")
return

ShowCreateVHD:
	gosub, ShowVHDConfig

	LV_Delete()
	LV_Add("", vhdSizeG, "vhd(x)�ļ���С����λ:G��w7����25��w10����50", "vhd")
	LV_Add("", vhdType, "expandable=��̬��С��fixed=�̶���С", "vhd")
	LV_Add()
	LV_Add("", "----����Ϊ���ã�����Ϊ����----", "�༭�������ú�˫������Ŀ����Ч��˫��������Ŀִ��", "-")
	LV_Add()
	LV_Add("", "+ ����vhd", "˫������Ŀ��ʼ����vhd���Զ���������", "vhd")
	LV_Add()
	LV_Add("", "2. װϵͳ��vhd������ע������", "Dism++��ԭ���ҿ�ע����������winNTSetup��װ", "info")
	LV_Add()
	LV_Add("", "> ж��vhd", "˫������Ŀ��ʼж��vhd", "vhd")
	LV_Add()
	LV_Add("", "< ����vhd", "˫������Ŀ��ʼ����vhd", "vhd")
	LV_Add()
	LV_Add("", "+ �������vhd", "˫������Ŀ��ʼ�������vhd�����ݸ�vhd·������", "vhd")

	LV_Modify(6, "select")
return

ShowVHDConfig:
	GuiControlGet, VHDPath
	GuiControlGet, DriveLetter
	if ( 0 = vhdSizeG ) {
		SplitPath, VHDPath, , , , vhdNameNoExt
		if ( InStr(vhdNameNoExt, "7") ) { ; win7�Ƽ�25������50
			vhdSizeG := 25
		} else {
			vhdSizeG := 50
		}
	}
	tip("��ǰVHD: " VHDPath "������С: " vhdSizeG " G�����ͣ�" vhdType "�������̷���" DriveLetter)
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
----�����ǽ���·��
D:\etc\vhd\w7b.vhd
D:\etc\vhd\w7c.vhd
D:\etc\vhd\w10.vhdx
D:\etc\vhd\w11.vhdx
)
	GuiControl, , VHDPath, %posList%

	if ( "" = vhdList ) {
		vhdList .= posList
		Guicontrol, choose, VHDPath, 3 ; ѡw7c.vhd
	} else {
		Guicontrol, choose, VHDPath, 1 ; ѡ�ҵ��ĵ�һ��
	}

	if ( "" != VHDPath ) {
		if ( InStr(vhdList, VHDPath) ) {
			GuiControl, ChooseString, VHDPath, %VHDPath%
		} else {
			GuiControl, Text, VHDPath, %VHDPath%
		}
	}

return

ChangeVHDPath: ; VHDPath �޸�ʱ���ǵ�����vhdSizeG = 0
	VHDSizeG := 0
	gosub, ShowVHDConfig
return

CreateVHD:
	Gui, submit, nohide
	If ( "" = VHDPath ) {
		tip("����: VHDPathΪ��")
		return
	}
	IfExist, %VHDPath%
	{
		tip("����: �ļ��Ѵ���: " VHDPath)
		return
	}
	SplitPath, VHDPath, , nowVHDDir
	IfNotExist, %nowVHDDir%
		FileCreateDir, %nowVHDDir%
	IfNotExist, %nowVHDDir%
	{
		tip("����: ����Ŀ¼ʧ��: " nowVHDDir)
		return
	}
	DriveGet, driveList, List, FIXED
	if ( InStr(driveList, DriveLetter) ) {
		tip("����: �Ѵ����̷�: " DriveLetter)
		return
	}
	tmpSizeM := VHDSizeG * 1024
	
	tip("������...")
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
		tip("����: ����ʧ��: �������̷�: " DriveLetter)
	} else {
		tip("�ɹ�: ����: " VHDPath " ��������: " DriveLetter)
	}
return

CreateSubVHD:
	Gui, submit, nohide
	If ( "" = VHDPath ) {
		tip("����: VHDPathΪ��")
		return
	}
	IfNotExist, %VHDPath%
	{
		tip("����: �ļ�������: " VHDPath)
		return
	}
	nowSubVHDPath := getSubVHDPath(VHDPath)
	msgbox,260,, �Ƿ���ݣ�`n%VHDPath%`n������ӳ��->`n%nowSubVHDPath%
	ifmsgbox,yes
	{
		tip("������...")
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
			tip("�ɹ�: ���������Ƶ�������: " nowSubVHDPath)
		} else {
			tip("ʧ��: ����: " nowSubVHDPath)
		}
	}
return

MountVHD:
	GuiControlGet, VHDPath
	GuiControlGet, DriveLetter
	If ( "" = VHDPath ) {
		tip("����: VHDPathΪ��")
		return
	}
	IfNotExist, %VHDPath%
	{
		tip("����: �ļ�������: " VHDPath)
		return
	}
	DriveGet, driveList, List, FIXED
	if ( InStr(driveList, DriveLetter) ) {
		tip("����: �Ѵ����̷�: " DriveLetter)
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
		tip("����: ����ʧ��: �������̷�: " DriveLetter)
	} else {
		tip("�ɹ�: ����: " VHDPath " ��: " DriveLetter)
	}
return

UnMountVHD:
	GuiControlGet, VHDPath
	GuiControlGet, DriveLetter
	If ( "" = VHDPath ) {
		tip("����: VHDPathΪ��")
		return
	}
	IfNotExist, %VHDPath%
	{
		tip("����: �ļ�������: " VHDPath)
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
		tip("����: ж��ʧ��: �Դ����̷�: " DriveLetter)
	} else {
		tip("�ɹ�: ж��: " VHDPath)
	}
return

ShowBins:
	LV_Delete()
	LV_Add("", "BOOTICE.exe /edit_bcd /easymode", "�༭BCD", "exe")
	LV_Add("", "Dism++x86.exe", "�����ָ�ϵͳ��������", "exe")
	LV_Add("", "BOOTICE.exe", "�����޸�����", "exe")
	LV_Add("", "DiskGenius.exe", "������¡����", "exe")
	LV_Add("", "diskmgmt.msc", "���̹���", "exe")
	LV_Add("", "cmd.exe", "������", "exe")
	LV_Add("", "regedit.exe", "ע���", "exe")
	tip("˵����˫����Ŀ��")
return

^esc::reload
+esc::Edit
!esc::ExitApp

tip(iStr="") {
	SB_SetText(iStr)
}

getDriveLetter(iPath="") { ; ���� C
	if ( "" = iPath )
		iPath := A_WinDir
	return SubStr(iPath, 1, 1)
}

getSubVHDPath(iVHDPath) { ; ���ݸ�ӳ��·��xx.vhd�������²��ӳ��·��xx.N.vhd
	SplitPath, iVHDPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
	loop 9 {
		subVHDPath := OutDir "\" OutNameNoExt "." A_Index "." OutExtension
		IfNotExist, %subVHDPath%
			return subVHDPath
	}
}

VirtualDiskExpandOnMount(iValue=4) { ; HKLM_0_��̬vhd��ռ�����ռ�
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

