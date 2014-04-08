/*
; ����: 2012-3-29
; Author: linpinger
; URL : http://www.autohotkey.net/~linpinger/index.html

; Below Is An Example

^esc::reload
+esc::Edit
!esc::ExitApp
F1::
	SrcImgPath := A_ScriptDir . "\1.gif"
	TarImgPath := A_ScriptDir . "\2.png"
	IfExist, %TarImgPath%
		FileDelete, %TarImgPath%
	sTime := A_tickcount	
	FreeImage_FoxInit(True) ; Load Dll

	hImage := FreeImage_Load(SrcImgPath) ; load image ����ͼ��
;	hImage := FreeImage_Load(GeneralW_StrToGBK(ImgPath)) ; L������ͼ��
	ImgWidth := FreeImage_GetWidth(hImage) , ImgHeight := FreeImage_GetHeight(hImage)  ; get width / height ��ȡ�ߴ�
	AA := FreeImage_GetVersion() ; Get Dll Version

;	------ ����ͼƬ����gif��ɫ����������Ϊ70��͸��ɫ�滻Ϊ��ɫ
	FreeImage_FoxPalleteIndex70White(hImage) ; Fox:������͸��Gif��ɫ����ɫ�滻Ϊ��ɫ
	hPartImage := FreeImage_Copy(hImage, 0, 0, ImgWidth, 500) ; ��ȡ��ͼ��, �൱�ڸ��Ƹ�ͼ���һ�����ο��е�ͼ��Ϊһ����ͼ��
	FreeImage_SetTransparent(hPartImage, 0) ; ����͸��(Ҳ�����Ұ�οһ��)
	FreeImage_Save(hPartImage, TarImgPath) ; д��ͼ��
	FreeImage_UnLoad(hPartImage) ; �ͷž��

;	hImageWhite := FreeImage_ColorQuantize(FreeImage_Composite(hImage, False, "255:255:255:0", False), 0) ; 391 ; ��׷�����: ����
;	------ ����

;	FreeImage_Save(hImage, TarImgPath) ; Save Image д��ͼ��
	FreeImage_UnLoad(hImage) ; Unload Image �ͷž��

	FreeImage_FoxInit(False) ; Unload Dll
	eTime := A_tickcount - sTime
	Traytip, ��ʱ: %etime% ms, %ImgWidth%:%ImgHeight%`n%AA%
	IfExist, %TarImgPath%
		run, %TarImgPath%
return

GeneralW_StrToGBK(inStr) { ; L�����ú���
	VarSetCapacity(GBK, StrPut(inStr, "CP936"), 0)
	StrPut(inStr, &GBK, "CP936")
	Return GBK
}

*/

; {--------------0.0 FoxWriteFunction ����ĺ���
FreeImage_FoxInit(isInit=True) { ; load/unloadDll ����/ж��Dll
	Static hFIDll
	If isInit
		hFIDll := DllCall("LoadLibrary" , "Str", FreeImage_FoxGetDllPath())
	else
		DllCall("FreeLibrary", "UInt", hFIDll)
}

FreeImage_FoxGetDllPath(DllName="FreeImage.dll") { ; Get dll Path ��ȡdll·��
	DirList =
	(Join`n Ltrim
	%A_scriptdir%\bin32
	%A_scriptdir%
	D:\bin\bin32
	C:\bin\bin32
	)
	loop, parse, DirList, `n
		IfExist, %A_LoopField%\%DllName%
			DllPath := A_LoopField . "\" . DllName
	return, DllPath
}

FreeImage_FoxPalleteIndex70White(hImage) { ; gif transparent color to white (indexNum 70) ��Gif��ɫ���е�͸����ɫ������71(ƫ��70)����ɫ�滻Ϊ��ɫ
	hPalette := FreeImage_GetPalette(hImage)
	FreeImage_FoxSetRGBi(hPalette, 71, "R", 255) , FreeImage_FoxSetRGBi(hPalette, 71, "G", 255) , FreeImage_FoxSetRGBi(hPalette, 71, "B", 255)
}

FreeImage_FoxGetTransIndexNum(hImage) { ; Mark Num 1 For the first Color, not 0  ��1Ϊ������ʼ��
	hPalette := FreeImage_GetPalette(hImage)
	loop, 256 
		If ( FreeImage_FoxGetRGBi(hPalette, A_index, "G") >= 254 and FreeImage_FoxGetRGBi(hPalette, A_index, "R") < 254 and FreeImage_FoxGetRGBi(hPalette, A_index, "B") < 254 )
			return, A_index
}

FreeImage_FoxGetPallete(hImage) { ; GetPaletteList ��ȡ��ɫ������
	hPalette := FreeImage_GetPalette(hImage)
	loop, 256
		PalleteList .= FreeImage_FoxGetRGBi(hPalette, A_index, "R") . " "
			. FreeImage_FoxGetRGBi(hPalette, A_index, "G") . " "
			. FreeImage_FoxGetRGBi(hPalette, A_index, "B") . " "
			. FreeImage_FoxGetRGBi(hPalette, A_index, "i") . "`n"
	return, PalleteList
}

FreeImage_FoxGetRGBi(StartAdress=2222, ColorIndexNum=1, GetColor="R") { ; ������1Ϊ������ʼ��,��0
	If ( GetColor = "R" )
		return, Numget(StartAdress+0, 4*(ColorIndexNum-1)+0, "Uchar")
	If ( GetColor = "G" )
		return, Numget(StartAdress+0, 4*(ColorIndexNum-1)+1, "Uchar")
	If ( GetColor = "B" )
		return, Numget(StartAdress+0, 4*(ColorIndexNum-1)+2, "Uchar")
	If ( GetColor = "i" ) ; RGB or BGR �Ƿ�RGB
		return, Numget(StartAdress+0, 4*(ColorIndexNum-1)+3, "Uchar")
}

FreeImage_FoxSetRGBi(StartAdress=2222, ColorIndexNum=1, SetColor="R", Value=255) { ; ������1Ϊ������ʼ��,��0
	If ( SetColor = "R" )
		NumPut(Value, StartAdress+0, 4*(ColorIndexNum-1)+0, "Uchar")
	If ( SetColor = "G" )
		NumPut(Value, StartAdress+0, 4*(ColorIndexNum-1)+1, "Uchar")
	If ( SetColor = "B" )
		NumPut(Value, StartAdress+0, 4*(ColorIndexNum-1)+2, "Uchar")
	If ( SetColor = "i" )
		NumPut(Value, StartAdress+0, 4*(ColorIndexNum-1)+3, "Uchar")
}

; }--------------0.0 ����ĺ���

; {--------------2.1 ͨ�ú���
FreeImage_Initialise() {
	return, DllCall("FreeImage\_FreeImage_Initialise@4" , "Int", 0, "Int", 0)
}

FreeImage_DeInitialise() {
	return, DllCall("FreeImage\_FreeImage_DeInitialise@0")
}

FreeImage_GetVersion() {
	return, DllCall("FreeImage\_FreeImage_GetVersion@0", "Cdecl str")
}

FreeImage_GetCopyrightMessage() {
	return, DllCall("FreeImage\_FreeImage_GetCopyrightMessage@0", "Cdecl str")
}

; }--------------2.1 ͨ�ú���

; {--------------2.2 λͼ������
FreeImage_Allocate(width=100, height=100, bpp=32, red_mask=0xFF000000, green_mask=0x00FF0000, blue_mask=0x0000FF00) {
	return, DllCall("FreeImage\_FreeImage_Allocate@24", "int", width, "int", height, "int", bpp, "uint", red_mask, "uint", green_mask, "uint", blue_mask)
}

FreeImage_Load(ImPath) {
	return, DllCall("FreeImage\_FreeImage_Load@12", "Int", FreeImage_GetFileType(ImPath), "Str", ImPath, "int", 0)
}

FreeImage_Save(hImage, ImPath, OutExt=-1, ImgArg=0) {
	BMP := 0 , JPG := 2 , JPEG := 2 , PNG := 13 , TIF := 18 , TIFF := 18 , GIF := 25
	If ( OutExt = -1 )
		SplitPath, ImPath, , , OutExt
	return, DllCall("FreeImage\_FreeImage_Save@16", "Int", %OutExt% , "Int", hImage, "Str", ImPath, "int", ImgArg)
}

FreeImage_Clone(hImage) {
	return, DllCall("FreeImage\_FreeImage_Clone@4", "int", hImage)
}

FreeImage_UnLoad(hImage) {
	return, DllCall("FreeImage\_FreeImage_UnLoad@4", "Int", hImage)
}

; }--------------2.2 λͼ������

; {--------------2.3 λͼ��Ϣ����
FreeImage_GetImageType(hImage) {
	return, DllCall("FreeImage\_FreeImage_GetImageType@4" , "int", hImage)
}

FreeImage_GetColorsUsed(hImage) {
	return, DllCall("FreeImage\_FreeImage_GetColorsUsed@4" , "int", hImage)
}

FreeImage_GetBPP(hImage) {
	return, DllCall("FreeImage\_FreeImage_GetBPP@4" , "int", hImage)
}

FreeImage_GetWidth(hImage) {
	return, DllCall("FreeImage\_FreeImage_GetWidth@4" , "Int", hImage)
}

FreeImage_GetHeight(hImage) {
	return, DllCall("FreeImage\_FreeImage_GetHeight@4" , "Int", hImage)
}

FreeImage_GetLine(hImage) {
	return, DllCall("FreeImage\_FreeImage_GetLine@4" , "Int", hImage)
} ; Untested δ��֤

FreeImage_GetPitch(hImage) {
	return, DllCall("FreeImage\_FreeImage_GetPitch@4" , "Int", hImage)
}

FreeImage_GetDIBSize(hImage) {
	return, DllCall("FreeImage\_FreeImage_GetDIBSize@4" , "Int", hImage)
} ; Untested δ��֤

FreeImage_GetPalette(hImage) {
	return, DllCall("FreeImage\_FreeImage_GetPalette@4", "Int", hImage)
}

FreeImage_GetDotsPerMeterX(hImage) {
	return, DllCall("FreeImage\_FreeImage_GetDotsPerMeterX@4", "Int", hImage)
}

FreeImage_GetDotsPerMeterY(hImage) {
	return, DllCall("FreeImage\_FreeImage_GetDotsPerMeterY@4", "Int", hImage)
}

FreeImage_SetDotsPerMeterX(hImage, DPMx) {
	return, DllCall("FreeImage\_FreeImage_SetDotsPerMeterX@4", "Int", hImage)
}

FreeImage_SetDotsPerMeterY(hImage, DPMy) {
	return, DllCall("FreeImage\_FreeImage_SetDotsPerMeterY@4", "Int", hImage)
}

FreeImage_GetInfoHeader(hImage) {
	return, DllCall("FreeImage\_FreeImage_GetInfoHeader@4", "Int", hImage)
}

FreeImage_GetInfo(hImage) {
	return, DllCall("FreeImage\_FreeImage_GetInfo@4", "Int", hImage)
}

FreeImage_GetColorType(hImage) {
	return, DllCall("FreeImage\_FreeImage_GetColorType@4", "Int", hImage)
}

FreeImage_GetRedMask(hImage) {
	return, DllCall("FreeImage\_FreeImage_GetRedMask@4", "Int", hImage)
}

FreeImage_GetGreenMask(hImage) {
	return, DllCall("FreeImage\_FreeImage_GetGreenMask@4", "Int", hImage)
}

FreeImage_GetBlueMask(hImage) {
	return, DllCall("FreeImage\_FreeImage_GetBlueMask@4", "Int", hImage)
}

FreeImage_GetTransparencyCount(hImage) {
	return, DllCall("FreeImage\_FreeImage_GetTransparencyCount@4", "Int", hImage)
}

FreeImage_GetTransparencyTable(hImage) {
	return, DllCall("FreeImage\_FreeImage_GetTransparencyTable@4", "Int", hImage)
}

FreeImage_SetTransparencyTable(hImage, hTransTable, count=256) {
	return, DllCall("FreeImage\_FreeImage_SetTransparencyTable@12", "Int", hImage, "UintP", hTransTable, "Uint", count)
} ; Untested δ��֤

FreeImage_SetTransparent(hImage, isEnable=True) {
	return, DllCall("FreeImage\_FreeImage_SetTransparent@8" , "Int", hImage, "Int", isEnable)
}

FreeImage_IsTransparent(hImage) {
	return, DllCall("FreeImage\_FreeImage_IsTransparent@4", "Int", hImage)
}

FreeImage_HasBackgroundColor(hImage) {
	return, DllCall("FreeImage\_FreeImage_HasBackgroundColor@4", "Int", hImage)
}

FreeImage_GetBackgroundColor(hImage) {
	VarSetCapacity(RGB, 4)
	RetValue := DllCall("FreeImage\_FreeImage_GetBackgroundColor@8", "Int", hImage, "UInt", &RGB)
	If RetValue
		return, NumGet(RGB, 0, "UChar") . ":" . NumGet(RGB, 1, "UChar") . ":" . NumGet(RGB, 2, "UChar") . ":" . NumGet(RGB, 3, "UChar")
	else
		return, RetValue
}

FreeImage_SetBackgroundColor(hImage, RGBArray="255:255:255:0") {
	If ( RGBArray != "" ) {
		StringSplit, RGBA_, RGBArray, :, %A_space%
		VarSetCapacity(RGB, 4)
		NumPut(RGBA_1, RGB, 0, "UChar") , NumPut(RGBA_2, RGB, 1, "UChar") , NumPut(RGBA_3, RGB, 2, "UChar") , NumPut(RGBA_4, RGB, 3, "UChar")
	} else
		RGB := 0
	return, DllCall("FreeImage\_FreeImage_SetBackgroundColor@8", "Int", hImage, "UInt", &RGB)
}


; }--------------2.3 λͼ��Ϣ����

; {--------------2.4 �ļ����ͺ���
FreeImage_GetFileType(ImPath) {	; 0:BMP 2:JPG 13:PNG 18:TIF 25:GIF
	return, DllCall("FreeImage\_FreeImage_GetFileType@8" , "Str", ImPath , "Int", 0)
}

; }--------------2.4 �ļ����ͺ���

; {--------------2.5 ���ط��ʺ���
FreeImage_GetBits(hImage) {
	return, DllCall("FreeImage\_FreeImage_GetBits@4", "Int", hImage)
}

FreeImage_GetScanLine(hImage, iScanline) { ; ������ͼƬ���½�Ϊԭ��, Base 0
	return, DllCall("FreeImage\_FreeImage_GetScanLine@8", "Int", hImage, "Int", iScanline)
}

FreeImage_GetPixelIndex(hImage, xPos, yPos) { ; ������ͼƬ���½�Ϊԭ��, Base 0
	VarSetCapacity(IndexNum, 1)
	RetValue := DllCall("FreeImage\_FreeImage_GetPixelIndex@16" , "int", hImage, "Uint", xPos, "Uint", yPos, "Uint", &IndexNum)
	If RetValue
		return, Numget(IndexNum, 0, "Uchar")
	else
		return, RetValue
}
FreeImage_SetPixelIndex(hImage, xPos, yPos, nIndex) {
	VarSetCapacity(IndexNum, 1)
	NumPut(nIndex, IndexNum, 0, "Uchar")
	return, DllCall("FreeImage\_FreeImage_SetPixelIndex@16" , "int", hImage, "Uint", xPos, "Uint", yPos, "Uint", &IndexNum)
}

FreeImage_GetPixelColor(hImage, xPos, yPos) {
	VarSetCapacity(RGBQUAD, 4)
	RetValue := DllCall("FreeImage\_FreeImage_GetPixelColor@16" , "int", hImage, "Uint", xPos, "Uint", yPos, "Uint", &RGBQUAD)
	If RetValue
		return, Numget(RGBQUAD, 0, "Uchar") . ":" . Numget(RGBQUAD, 1, "Uchar") . ":" . Numget(RGBQUAD, 2, "Uchar") . ":" . Numget(RGBQUAD, 3, "Uchar")
	else
		return, RetValue
}

FreeImage_SetPixelColor(hImage, xPos, yPos, RGBArray="255:255:255:0") {
	StringSplit, RGBA_, RGBArray, :, %A_space%
	VarSetCapacity(RGBQUAD, 4)
	NumPut(RGBA_1, RGBQUAD, 0, "UChar") , NumPut(RGBA_2, RGBQUAD, 1, "UChar") , NumPut(RGBA_3, RGBQUAD, 2, "UChar") , NumPut(RGBA_4, RGBQUAD, 3, "UChar")
	return, DllCall("FreeImage\_FreeImage_SetPixelColor@16" , "int", hImage, "Uint", xPos, "Uint", yPos, "Uint", &RGBQUAD)
}
; }--------------2.5 ���ط��ʺ���

; {--------------2.6 ת������
FreeImage_ConvertTo4Bits(hImage) {
	return, DllCall("FreeImage\_FreeImage_ConvertTo4Bits@4" , "int", hImage)
}

FreeImage_ConvertTo8Bits(hImage) {
	return, DllCall("FreeImage\_FreeImage_ConvertTo8Bits@4" , "int", hImage)
}

FreeImage_ConvertToGreyscale(hImage) {
	return, DllCall("FreeImage\_FreeImage_ConvertToGreyscale@4" , "int", hImage)
}

FreeImage_ConvertToStandardType(hImage, bScaleLinear=True) {
	return, DllCall("FreeImage\_FreeImage_ConvertToStandardType@8" , "int", hImage, "int", bScaleLinear)
}

FreeImage_ColorQuantize(hImage, quantize=0) {
	return, DllCall("FreeImage\_FreeImage_ColorQuantize@8" , "int", hImage, "int", quantize)
}

FreeImage_Threshold(hImage, TT=0) { ; TT ����ȡֵ��Χ: 0 - 255
	return, DllCall("FreeImage\_FreeImage_Threshold@8" , "int", hImage, "int", TT)
}

; }--------------2.6 ת������

; {--------------2.11 �ڴ�����/�����
FreeImage_OpenMemory(hMemory, size) {
	return, DllCall("FreeImage\_FreeImage_OpenMemory@8" , "int", hMemory, "int", size)
}

FreeImage_CloseMemory(hMemory) {
	return, DllCall("FreeImage\_FreeImage_CloseMemory@4" , "int", hMemory, "int", size)
}

FreeImage_TellMemory(hMemory) {
	return, DllCall("FreeImage\_FreeImage_TellMemory@4" , "int", hMemory)
}
FreeImage_AcquireMemory(hMemory, byref BufAdr, byref BufSize) {
	DataAddr := 0 , DataSizeAddr := 0
	bSucess := DllCall("FreeImage\_FreeImage_AcquireMemory@12" , "int", hMemory, "Uint", &DataAddr, "Uint", &DataSizeAddr)
	BufAdr := numget(DataAddr, 0, "int") , BufSize := numget(DataSizeAddr, 0, "int")
	return, bSucess
}

FreeImage_SaveToMemory(FIF,hImage, hMemory, Flags) { ; 0:BMP 2:JPG 13:PNG 18:TIF 25:GIF
	return, DllCall("FreeImage\_FreeImage_SaveToMemory@16" , "int", FIF, "int", hImage, "int", hMemory, "int", Flags)
}
; }--------------2.11 �ڴ�����/�����

; {--------------4.1 ��ת�ͷ�ת
FreeImage_RotateClassic(hImage, angle) {
	return, DllCall("FreeImage\_FreeImage_RotateClassic@12", "Int", hImage, "Double", angle)
}

; }--------------4.1 ��ת�ͷ�ת

; {--------------4.5 ����/ճ��/�ϳ�����
FreeImage_Copy(hImage, nLeft, nTop, nRight, nBottom) { ; ������ͼ����
	return, DllCall("FreeImage\_FreeImage_Copy@20", "Int", hImage, "int", nLeft, "int", nTop, "int", nRight, "int", nBottom)
}

FreeImage_Paste(hImageDst, hImageSrc, nLeft, nTop, nAlpha) { ; ������ͼ����
	return, DllCall("FreeImage\_FreeImage_Paste@20", "Int", hImageDst, "int", hImageSrc, "int", nLeft, "int", nTop, "int", nAlpha)
}

FreeImage_Composite(hImage, useFileBkg=False, RGBArray="255:255:255:0", hImageBkg=False) {
	StringSplit, RGBA_, RGBArray, :, %A_space%
	VarSetCapacity(RGBQUAD, 4)
	NumPut(RGBA_1, RGBQUAD, 0, "UChar") , NumPut(RGBA_2, RGBQUAD, 1, "UChar") , NumPut(RGBA_3, RGBQUAD, 2, "UChar") , NumPut(RGBA_4, RGBQUAD, 3, "UChar")
	return, DllCall("FreeImage\_FreeImage_Composite@16", "int", hImage, "int", useFileBkg, "Uint", &RGBQUAD, "int", hImageBkg)
}

; }--------------4.5 ����/ճ��/�ϳ�����


