
; {-- GUI��չ

FoxGUI_MenuBarRightJustify(hGUI, MenuPos=0)  ; hGUI: GUI��HWND , MenuPos: �˵���ı��(����0)
{	; �����MenuBar֮��GUI��ʾ֮ǰ
	hMenu :=DllCall("GetMenu", "Uint", hGUI)
	VarSetCapacity(mii, 48, 0)
	NumPut(48, mii, 0) , NumPut(0x100, mii, 4) , numput(0x4000, mii, 8)
	DllCall("SetMenuItemInfo", "uint", hMenu, "uint", MenuPos, "uint", 1, "uint", &mii)
	; http://msdn.microsoft.com/en-us/library/windows/desktop/ms648001(v=vs.85).aspx
}

; }-- GUI��չ

; {-- ʹ�� GDI+ ���� ��ɫ���� ImageList
FoxGUI_CreateImageListFromGDIP(ImageListID, ARGBList="0xFFFC9A35:0xFFC4C2C4:0xFFFCFE9C")
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

