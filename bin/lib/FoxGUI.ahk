
; {-- GUI扩展

FoxGUI_MenuBarRightJustify(hGUI, MenuPos=0)  ; hGUI: GUI的HWND , MenuPos: 菜单项的编号(基于0)
{	; 最好在MenuBar之后，GUI显示之前
	hMenu :=DllCall("GetMenu", "Uint", hGUI)
	VarSetCapacity(mii, 48, 0)
	NumPut(48, mii, 0) , NumPut(0x100, mii, 4) , numput(0x4000, mii, 8)
	DllCall("SetMenuItemInfo", "uint", hMenu, "uint", MenuPos, "uint", 1, "uint", &mii)
	; http://msdn.microsoft.com/en-us/library/windows/desktop/ms648001(v=vs.85).aspx
}

; }-- GUI扩展

; {-- 使用 GDI+ 生成 纯色方块 ImageList
FoxGUI_CreateImageListFromGDIP(ImageListID, ARGBList="0xFFFC9A35:0xFFC4C2C4:0xFFFCFE9C")
{	; 依赖 GDIP.ahk
	pToken := Gdip_Startup()
	pBitmap := Gdip_CreateBitmap(16, 16)
	G1 := Gdip_GraphicsFromImage(pBitmap)
	loop, parse, ARGBList, :
	{
		Gdip_GraphicsClear(G1, A_LoopField) ; 背景填充 ARGB

		/* ; 填充圆
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
; }-- 使用 GDI+ 生成 纯色方块 ImageList

