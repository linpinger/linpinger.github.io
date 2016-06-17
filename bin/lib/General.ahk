; ����: ͨ�ú���
; ����: ԭ�� L��
; ����: 2016-03-23

; �汾 ����
; 5.1 Microsoft Windows XP
; 5.2 Microsoft Windows Server 2003
; 6.0 vista / server 2008
; 6.1 server2008 r2/ win7
; 6.2 win8
; 6.3 Windows 10 Enterprise ; JAVASE6 ��ʾ���� Windows 8 �� 6.2
General_getOSVersion(isName=false) {
	if ( isName )
		RegRead, retVar, HKLM, SOFTWARE\Microsoft\Windows NT\CurrentVersion, ProductName
	else
		RegRead, retVar, HKLM, SOFTWARE\Microsoft\Windows NT\CurrentVersion, CurrentVersion
	return retVar
}

; ͨ���޸�host�ļ�������DNS
General_setDNS(iHost="www.biquge.com.tw", iIP="119.147.134.202")
{
	fileread, hh, %A_WinDir%\system32\drivers\etc\hosts
	if ( ! instr(hh, iHost) ) {
		fileappend, %iIP%  %iHost%`r`n, %A_WinDir%\system32\drivers\etc\hosts
	} else {
		newHost := ""
		loop, parse, hh, `n, `r
		{
			if ( instr(A_LoopField, iHost) ) {
				if ( "" = iIP ) ; iIPΪ�գ�ɾ����¼
					Continue
				newHost .= iIP . A_Space . A_Space . iHost . "`r`n"
			} else {
				newHost .= A_LoopField . "`r`n"
			}
		}
		StringReplace, newHost, newHost, `r`n`r`n`r`n, `r`n`r`n, A
		fileappend, %newHost%, %A_WinDir%\system32\drivers\etc\hosts.new
		FileMove, %A_WinDir%\system32\drivers\etc\hosts.new, %A_WinDir%\system32\drivers\etc\hosts, 1
	}
}

General_uXXXX2CN(uXXXX) ; in: "\u7231\u5c14\u5170\u4e4b\u72d0"  out: "������֮��"
{
	StringReplace, uXXXX, uXXXX, \u, #, A
	cCount := StrLen(uXXXX) / 5
	VarSetCapacity(UUU, cCount * 2, 0)
	cCount := 0
	loop, parse, uXXXX, #
	{
		if ( "" = A_LoopField )
			continue
		NumPut("0x" . A_LoopField, &UUU+0, cCount)
		cCount += 2
	}
	if ( A_IsUnicode ) {
		return, UUU
	} else {
		GeneralA_Unicode2Ansi(UUU, rUUU, 0)
		return, rUUU
	}
}

; {-- �ļ�
General_GetFilePath(NowFileName="FreeImage.dll", DirList="C:\bin\bin32|D:\bin\bin32|C:\Program Files|D:\Program Files") { ; ��ȡ�ļ�·��
	static LastDir
	if ( LastDir != "" )
		ifExist, %LastDir%\%NowFileName%
			return, LastDir . "\" . NowFileName
	loop, parse, DirList, |
		IfExist, %A_LoopField%\%NowFileName%
		{
			LastDir := A_LoopField
			Break
		}
	if ( LastDir = "" ) { ; δ�ڸ���·�����ҵ�,ȥ����������Ѱ��
		EnvGet, PosSysDirs, Path
		loop, parse, PosSysDirs, `;, %A_space%
			IfExist, %A_LoopField%\%NowFileName%
			{
				LastDir := A_LoopField
				Break
			}
	}
	if ( LastDir != "" )
		TarPath := LastDir . "\" . NowFileName
	return, TarPath
}
; }-- �ļ�


; {-- �ӽ���
General_UUID(c = false) { ; http://www.autohotkey.net/~polyethene/#uuid
	static n = 0, l, i
	f := A_FormatInteger, t := A_Now, s := "-"
	SetFormat, Integer, H
	t -= 1970, s
	t := (t . A_MSec) * 10000 + 122192928000000000
	If !i and c {
		Loop, HKLM, System\MountedDevices
		If i := A_LoopRegName
			Break
		StringGetPos, c, i, %s%, R2
		StringMid, i, i, c + 2, 17
	} Else {
		Random, x, 0x100, 0xfff
		Random, y, 0x10000, 0xfffff
		Random, z, 0x100000, 0xffffff
		x := 9 . SubStr(x, 3) . s . 1 . SubStr(y, 3) . SubStr(z, 3)
	} t += n += l = A_Now, l := A_Now
	SetFormat, Integer, %f%
	Return, SubStr(t, 10) . s . SubStr(t, 6, 4) . s . 1 . SubStr(t, 3, 3) . s . (c ? i : x)
}
; }-- �ӽ���


; {-- GUI��չ

General_MenuBarRightJustify(hGUI, MenuPos=0)  ; hGUI: GUI��HWND , MenuPos: �˵���ı��(����0)
{	; �����MenuBar֮��GUI��ʾ֮ǰ
	hMenu :=DllCall("GetMenu", "Uint", hGUI)
	VarSetCapacity(mii, 48, 0)
	NumPut(48, mii, 0) , NumPut(0x100, mii, 4) , numput(0x4000, mii, 8)
	DllCall("SetMenuItemInfo", "uint", hMenu, "uint", MenuPos, "uint", 1, "uint", &mii)
	; http://msdn.microsoft.com/en-us/library/windows/desktop/ms648001(v=vs.85).aspx
}

; }-- GUI��չ

; {-- ʹ�� GDI+ ���� ��ɫ���� ImageList
General_CreateImageListFromGDIP(ImageListID, ARGBList="0xFFFC9A35:0xFFC4C2C4:0xFFFCFE9C")
{	; ���� GDIP.ahk
	pToken := Gdip_Startup()
	pBitmap := Gdip_CreateBitmap(16, 16)
	G1 := Gdip_GraphicsFromImage(pBitmap)
	loop, parse, ARGBList, :
	{
		Gdip_GraphicsClear(G1, A_LoopField) ; ������� ARGB

		/* ; ���Բ
		pBrush := Gdip_BrushCreateSolid(A_LoopField)
		Gdip_FillEllipse(G1, pBrush, 0, 0, 11, 11)
		Gdip_DeleteBrush(pBrush)
		*/

		DllCall("comctl32.dll\ImageList_Add", "uint", ImageListID, "uint", Gdip_CreateHBITMAPFromBitmap(pBitmap), "uint", "")
	}
	Gdip_DeleteGraphics(G1)
	Gdip_DisposeImage(pBitmap)
	Gdip_Shutdown(pToken)
}
; }-- ʹ�� GDI+ ���� ��ɫ���� ImageList
