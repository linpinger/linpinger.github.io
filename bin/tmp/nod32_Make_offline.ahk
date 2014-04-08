TheID = TRIAL-66536865:defubhv3rm
VerDate := "2012-5-21"
URLVer := "eset_upd/update.ver"     ; v3.x/v4.x
;URLVer := "eset_upd/v5/update.ver"  ; v5.x

OldVerPath := A_scriptdir . "\offline"
OldUpdateVerPath := OldVerPath . "\update.ver"
		GVIMPath := "c:\bin\Vim\vim72\gvim.exe"
TmpPath := "c:\etc"
NewUpdateVerPath := TmpPath . "\Tmp_New.ver"

GuiInit:
	Gui, Add, GroupBox, x6 y10 w370 h50 cBlue, 升级网站
	Gui, Add, ComboBox, x16 y30 w210 h10 R5 choose1 vSiteName, update.eset.com|93.184.71.27|90.183.101.10|um10.eset.com
	Gui, Add, Button, x236 y26 w130 h26 gDownUpdateVer, 下载升级列表(&S)

	Gui, Add, GroupBox, x386 y10 w380 h50 cBlue, 升级ID
	Gui, Add, Button, x396 y27 w140 h25 gGetUpdateIDs, 下载升级ID(&D)
	Gui, Add, ComboBox, x546 y30 w210 h20  R10 choose1 vPass, %TheID%

	Gui, Add, ListView, x6 y70 w760 h355 vFoxLV gClickLV, 段名|file|size|base|build|version|<>|version|build|base|size|file
	FWL := "90:60:60:43:43:105:25:105:43:43:60:60"
	loop, parse, FWL, :
		LV_ModifyCol(A_index, A_loopfield)
	Gui, Add, StatusBar, , 左键双击条目: 下载   右键双击条目: 保存
	; Generated using SmartGUI Creator 4.0
	Gui, Show, y42 w773 h450, Nod32制作离线包 %VerDate%
	Guicontrol, Focus, 下载升级列表(&S)
Return

ClickLV:
	Gui, Submit, nohide
		NowRowNum := A_EventInfo
		LV_GetText(NowSec, NowRowNum, 1)
		LV_GetText(OldPath, NowRowNum, 2)
		LV_GetText(NewPath, NowRowNum, 12)
	If ( A_GuiEvent = "DoubleClick" ) { ; 双击: 下载
		If ( OldPath = "xxx" ) {
			clipboard = wget http://%Pass%@%SiteName%%NewPath%
			run, wget http://%Pass%@%SiteName%%NewPath%, %TmpPath%
		} else {
			clipboard = wget -O %TmpPath%\%OldPath% http://%Pass%@%SiteName%%NewPath%
			run, wget -O %TmpPath%\%OldPath% http://%Pass%@%SiteName%%NewPath%, %TmpPath%
		}
	}

	If ( A_GuiEvent = "R" ) { ; 右键双击: 保存
		FileCopy, %OldUpdateVerPath%, %OldVerPath%\update_%A_Now%.ver, 1
		SaveSecList := "base:build:buildregname:category:date:group:level:platform:size:type:version:versionid"
		loop, parse, SaveSecList, :, %A_space%
		{
			IniRead, NewVar, %NewUpdateVerPath%, %NowSec%, %A_loopfield%, xxx
			If ( NewVar != "xxx" )
				IniWrite, %NewVar%, %OldUpdateVerPath%, %NowSec%, %A_loopfield% 
		}
		IniRead, OldVar, %OldUpdateVerPath%, %NowSec%, file, xxx
		If ( OldVar = "xxx" ) {
			IniRead, NewVar, %NewUpdateVerPath%, %NowSec%, file, xxx
			stringsplit, FF_, NewVar, / 
			NewfileName := FF_%FF_0%
			IniWrite, %NewfileName%, %OldUpdateVerPath%, %NowSec%, file
		}
		SB_SetText("段已保存为新版: " . NowSec)
		gosub, DownUpdateVer
	}
return

DownUpdateVer: ; 下载 Update.Ver 并修改文件名
	Gui, submit, nohide

	FileDelete, %TmpPath%\Tmp_up.rar
	FileDelete, %TmpPath%\update_empty.ver
	IfExist, %NewUpdateVerPath%
	{
		FileGetSize, NewSize, %NewUpdateVerPath%, K
		If ( NewSize < 30 )
			FileDelete, %NewUpdateVerPath%
	} else {
		runwait, wget -O %TmpPath%\Tmp_up.rar http://%SiteName%/%URLVer%
		runwait, unrar e %TmpPath%\Tmp_up.rar, %TmpPath%, , Hide
		Filemove, %TmpPath%\update.ver, %NewUpdateVerPath%
		FileDelete, %TmpPath%\Tmp_up.rar
	}
	; 比较列表
	IfExist, %NewUpdateVerPath%
	{
		CompList := getCompList(NewUpdateVerPath)
		LV_Delete()
		loop, parse, CompList, :, %A_space%
		{
			If ( A_loopfield = "" )
				continue
			AddOneSection(OldUpdateVerPath, NewUpdateVerPath, A_loopfield)
		}
	}

return

GetUpdateIDs: ; 获取升级ID
	IfNotExist, %TmpPath%\Tmp_htm.html
		Runwait, wget -O %TmpPath%\Tmp_htm.html http://www.nod32id.org/
;		Runwait, wget -O %TmpPath%\Tmp_htm.html http://www.126185.com/killsoftware/sdsoft/NOD32/nod32_id_2.htm
	Fileread, html, %TmpPath%\Tmp_htm.html
	idsss := NormalProcess(html)
	stringreplace, idsss, idsss, `r`n, |, A
	GuiControl, , Pass, |%idsss%
	GuiControl, Choose, Pass, 1
	FileDelete, %TmpPath%\Tmp_htm.html
return

GuiClose:
GuiEscape:
	FileDelete, %NewUpdateVerPath%
	ExitApp
return

; -----备注:
^esc::reload
+esc::Edit
!esc::ExitApp
F1::  ; 检查记录和实际文件大小是否相符
	RowNumber := 0
	NotComList := ""
	Loop % LV_GetCount()
	{
		LV_GetText(NowFileName, A_index, 2)
		LV_GetText(NowOldVersion, A_index, 6)
		IniRead, TrueVersion, %OldVerPath%\%NowFileName%, update_info, version, xxx
		if ( TrueVersion != NowOldVersion )
			NotComList .= NowFileName . "`t" . TrueVersion . ":" . NowOldVersion . "`n"
	}
	if ( NotComList != "" )
		msgbox, 下面的文件异常(文件名: 实际版本:旧记录):`n%NotComList%
	else
		TrayTip, 恭喜:, 正常`n无异常文件
return


AddOneSection(OldIniPath, NewIniPath, SectionName)
{
	KeyList := "file:size:base:build:version"
	
	loop, parse, KeyList, :
	{
		IniRead, OldVar, %OldIniPath%, %SectionName%, %A_loopfield%, xxx
		IniRead, NewVar, %NewIniPath%, %SectionName%, %A_loopfield%, xxx
		OO_%A_index% := OldVar
		NN_%A_index% := NewVar
	}
	If ( OO_4 = NN_4 )
		IsVarEqual := "="
	else
		IsVarEqual := "<>"
	LV_Add(""
	, SectionName
	, OO_1
	, OO_2
	, OO_3
	, OO_4
	, OO_5
	, IsVarEqual
	, NN_5
	, NN_4
	, NN_3
	, NN_2
	, NN_1)
}

NormalProcess(byref html, MYRE="Ui)((EAV|TRIAL)-[0-9]{8}).+([0-9A-Za-z]{10})")
{

	stringreplace, html, html, `r, , A
	stringreplace, html, html, `n, , A
	stringreplace, html, html, EAV-, `r`nEAV-, A
	stringreplace, html, html, TRIAL-, `r`nTRIAL-, A

	loop, parse, html, `n, `r
	{
		If A_loopField Not contains EAV-,TRIAL-
			continue
		regexmatch(A_loopField, MYRE, out_)
		If ( out_1 = "" or out_3 = "" )
			continue
		ret .= out_1 . ":" . out_3 . "`r`n"
	}
	sort, ret, U R
	html := ""
	return, % ret
}

getCompList(NewUpdateVerPath) {
	fileread, nr, %NewUpdateVerPath%
	ccc := 0
	loop, parse, nr, `n, `r
	{
		if A_loopfield not contains [,]
			continue
		if A_loopfield contains CONTINUOUS,WINNT,HOSTS,Expire,SETUP,PCUVER
			continue
		++ccc
		NewNR .= A_loopfield . ":"
	}
	StringTrimRight, NewNR, NewNR, 1
	stringreplace, NewNR, NewNR, [, , A
	stringreplace, NewNR, NewNR, ], , A
	SB_SetText("从服务器上找到条目数: " . ccc . "　　左键双击条目: 下载   右键双击条目: 保存")
	return, NewNR
}
