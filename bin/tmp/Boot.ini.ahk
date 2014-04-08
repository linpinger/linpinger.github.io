DriveGet, tmp_fksd, List, FIXED
loop, parse, tmp_fksd
	IfExist, %A_loopField%:\boot.ini
		PathIniList .= A_loopField . ":\boot.ini|"

GuiInit:
	Gui, Add, GroupBox, x6 y10 w120 h50 cBlue, Boot.ini 路径
	Gui, Add, DropDownList, x16 y30 w100 h20 R10 vPathini gChangeIniPath, %PathIniList%

	Gui, Add, GroupBox, x136 y10 w120 h50 cBlue, TimeOut(s)
	Gui, Add, Edit, x146 y30 w40 h20 vTimeout gSetTimeOut, 0
	Gui, Add, Button, x196 y30 w20 h20 vT1 gSetTimeout2, &1
	Gui, Add, Button, x226 y30 w20 h20 vT5 gSetTimeout2, &5

	Gui, Add, GroupBox, x6 y70 w300 h90 cBlue, 设置默认引导项
	Gui, Add, ListBox, x16 y90 w280 h70 vFoxList gSetDefault

	Gui, Add, Button, x266 y10 w40 h60 vAddG4D gAddG4D, 添加Grub&4Dos

	Gui, Add, StatusBar, , 欢迎使用哈
	; Generated using SmartGUI Creator 4.0
	Gui, Show, y30 h190 w313, boot.ini修改工具 作者Q:308639546(爱尔兰之狐)

	GuiControl, choosestring, PathIni, % GetSysBootIniPath()
	gosub, ChangeIniPath

;	gosub, ReadBootIni
	GUIControl, Focus, AddG4D
Return

GuiClose:
GuiEscape:
	ExitApp
return

ChangeIniPath:
	GuiControlGet, aaa, , ChangeIniPath
	gosub, ReadBootini
return

AddG4D:
	inipath := GetBootIniPath()
	stringleft, sitls, inipath, 1
	FileSetAttrib, -R, %inipath%
	IniWrite, Grub4Dos, %inipath%, operating systems, %sitls%:\grldr
	Filecopy, %A_scriptdir%\grldr, %sitls%:\grldr, 1
	gosub, ReadBootIni
	SB_SetText("已添加条目: " . sitls . ":\grldr")
return

SetDefault:
	If ( A_GuiEvent = "DoubleClick" ) {
		GuiControlGet, aaa, , FoxList
		SetSecBootLoader("default", aaa)
		SB_SetText("当前 Default: " . aaa)
	}
return

SetTimeOut:
	GuiControlGet, aaa, , Timeout
	SetSecBootLoader("timeout", aaa)
	SB_SetText("当前 Timeout: " . aaa)
return

SetTimeOut2:
	If ( A_guicontrol = "T1" )
		GuiControl, , Timeout, 1
	If ( A_guicontrol = "T5" )
		GuiControl, , Timeout, 5
	gosub, SetTimeOut
return

ReadBootIni:
	NowTimeout := GetSecBootLoader("timeout")
	GuiControl, , Timeout, %NowTimeout%
	GuiControl, , FoxList, % ReadOS()
	GuiControl, ChooseString, FoxList, % GetSecBootLoader("default")
return

; -----备注:
^esc::reload
+esc::Edit
!esc::ExitApp

GetBootIniPath()
{
	GuiControlGet, aaa, , PathIni
	return aaa
}

GetSysBootIniPath()
{
	stringleft, SysDL, A_WinDir, 3 ; 系统所在盘的字母
	return SysDL . "boot.ini"
}

GetSecBootLoader(Name="timeout")
{
	inipath := GetBootIniPath()
	IniRead, OutputVar, %inipath%, boot loader, %Name%
	return OutputVar
}

ReadOS()
{
	fileread, nr, % GetBootIniPath()
	loop, parse, nr, `n, `r
	{
		aa = %A_loopfield%
		If ( aa = "" )
			continue
		If instr(aa, "[") and instr(aa, "]")
			continue
		If ! instr(aa, "=")
			continue
		If aa contains timeout=,default=
			continue
		stringsplit, ss_, aa, =, %A_space%
		list .= "|" . ss_1
	}
	return list
}

SetSecBootLoader(Name="timeout", Value="")
{
	inipath := GetBootIniPath()
	FileSetAttrib, -R, %inipath%
	IniWrite, %Value%, %inipath%, boot loader, %Name%
}



/*
[boot loader]
timeout=3
default=multi(0)disk(0)rdisk(0)partition(1)\WINDOWS
[operating systems]
multi(0)disk(0)rdisk(0)partition(1)\WINDOWS="Microsoft Windows XP Professional" /noexecute=optin /fastdetect
C:\grldr="Grub4Dos" 

*/
