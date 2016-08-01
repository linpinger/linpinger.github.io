; -----��ע: K3�� PDF Mobi ���ɿ�
/*
F1::
	txtnr := "����FoxSaid~!@#$%^&*()_+|-=\���ڣ����������ܶ棬��������ɽ������ɽ��ƺǰ�Ĵ����£����ߺ͹����Ʊ�һ���ټ��˹�����Ծǧ���ɽ������������ɽ�����������Ŵ����ֲڵı�Ƥ������˵�����������ƣ��������ɳ�һ�������ֵ�����Ѱ�һ�ɽ�������ߣ����ɳ����ִ��Һ���ټ������˼����������ʿ�ڶ���ʥ�����Q�ϡ�������δ���������~��" ; ��������ַ���
	loop, 15
		nr .= txtnr . "`n------------`n"
	txtnr := nr , nr := ""
;	Fileread, txtnr, C:\etc\1.txt

	stime := A_TickCount
	K3_PDFInit() ; ��ʼ��

	; �������ҳ
	hFont := K3_PDFGetFont(A_windir . "\Fonts\simhei.ttf")

	PageWidth := 260 , PageHeight := 335 , PageSpace := 5 
	FontSize := 9 , LineSpace := FontSize * 1.5
	Title := "���İپ�ʮ���� ����(Linpinger)�Ǻ�" , TitleFontSize := 12

	hPage := K3_PDFAddMixTextPage(Title, txtnr, PageWidth, PageHeight, PageSpace, FontSize, LineSpace, TitleFontSize)
	K3_PDFAddOutLine(hPage, "��1��")

;	hPage := K3_PDFAddPicPage("c:\etc\1.GIF", 0, 0, "ͼƬ�½ڱ���") ; ���ͼƬҳ
;	K3_PDFAddOutLine(hPage, "��2��")

	K3_PDFTerm(A_scriptdir . "\0000.pdf") ; ���棬��β
	eTime := A_TickCount - sTime
	IfExist, %A_scriptdir%\0000.pdf
	{
		TrayTip, ��ʱ:, %eTime% ms
		run, %A_scriptdir%\0000.pdf
	} else
		TrayTip, ����:, û�������ļ�
return
*/

; {---------------------------------LibHaru -> PDF
/*
libharu�汾�����ļ��Ƚ�:
	GDIP���Ʊ���(��ʱ ��С ����ɫ)	Irfan(��ʱ ��С ����ɫ)	GDIP�򵥴洢(��ʱ ��С ����ɫ)	jpgGDIPc	gif2png
2.0.8	5578ms 2.5M ��			3390ms 1.9M ��			2765ms 1.9M ��		3062ms 4.7M ��	3250ms 1.9M
2.1.0	6109ms 21.8M ��			3297ms 1.9M ��			3343ms 21.2M ��
2.2.0	ͬ 2.1.0 ��
�ۺ�������ʹ�� 2.0.8�� GDIP���Ʊ��� ��С��С���ٶȿ��Կ���(����irfan����)
*/


K3_PDFInit(LibHaruPath="") ; HPDF ��ʼ�� ȫ������
{
	If ( LibHaruPath = "" )
		LibHaruPath := K3_GetPath("D:\bin\bin32\libhpdf.dll")
	K3_Var("hDll", HPDF_LoadDLL(LibHaruPath))
	hDoc := HPDF_New("error","000") ; create new document in memory
	K3_Var("hDoc", hDoc)

	HPDF_SetCompressionMode(hDoc, "ALL") ; NONE TEXT IMAGE METADATA ALL
	HPDF_SetInfoAttr(hDoc, "AUTHOR", "Linpinger")
;	HPDF_SetPageMode(hDoc, "USE_OUTLINE")
	HPDF_UseCNSEncodings(hDoc) ; ʹ�ö��ֽڱ������ʹ����
}


K3_PDFTerm(PDFSavePath="FoxCreate.pdf") ; HPDF �����ĵ����ͷ���Դ
{
	hDoc := K3_Var("hDoc")
	StaA := HPDF_SaveToFile(hDoc, PDFSavePath)
	HPDF_Free(hDoc)
	HPDF_UnloadDLL(K3_Var("hDll")) ;unload dll
	K3_Var("hDoc", "")
	K3_TmpFileList("DelFoxFiles") ; ɾ���б�����ʱ�ļ�
	If ( StaA != 0 ) ; ���ɴ��󣬷���1
		return, 1
}

K3_PDFGetFont(FontNameorPath="C:\WINDOWS\Fonts\simhei.ttf")
{
	hDoc := K3_Var("hDoc")
	If instr(FontNameorPath, "\")
	{ ; ��Ƕ����
		SplitPath, FontNameorPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
		If ( OutExtension = "ttc" )
			font_name := HPDF_LoadTTFontFromFile2(hDoc, FontNameorPath, 0, 1)  ; ��Ƕ���� ; simsun.ttc
		else
			font_name := HPDF_LoadTTFontFromFile(hDoc, FontNameorPath, 1)  ; ��Ƕ���� ; simhei.ttf simkai.ttf simfang.ttf 

		hCNFont := HPDF_GetFont2(hDoc,font_name, "GBK-EUC-H") ; ���ı���: GBK-EUC-H ETen-B5-H  Ӣ�ı���: WinAnsiEncoding CP1252 [FontSpecific]
		hENFont := HPDF_GetFont2(hDoc,font_name, "WinAnsiEncoding") ; ���ı���: GBK-EUC-H ETen-B5-H  Ӣ�ı���: WinAnsiEncoding CP1252 [FontSpecific]
		K3_Var("hCNFont", hCNFont) , K3_Var("hENFont", hENFont)
		return, hCNFont
	} else { ; ����Ƕ����
		HPDF_UseCNSFonts(hDoc)
		hFont := HPDF_GetFont(hDoc, FontNameorPath, "GBK-EUC-H") ; SimSun , SimHei , SimKai ; ������
		return, hFont
	}
}

K3_PDFAddOutLine(hPage, OutLineText="����", hOutLineRoot=0)
{	; ������������
	hDoc := K3_Var("hDoc")
	NowEncoder := HPDF_GetEncoder(hDoc, "GBK-EUC-H")
	hOutLine := HPDF_CreateOutline(hDoc, hOutLineRoot, OutLineText, NowEncoder)
	hDest := HPDF_Page_CreateDestination(hPage)
	HPDF_Outline_SetDestination(hOutLine, hDest)
}

K3_PDFIndex(PageCount, PageType="��", PageTitle="ľ�б���")
{	; ��PDFβ����� Ŀ¼ҳ
	static LastNum, IndexContent
	If ( PageCount = -5 )  ; �������
		LastNum := "" , IndexContent := ""
	If ( PageCount = -9 ) ; �����б�
		return, IndexContent
	If ( PageCount > 0 ) { ; ����б�
		If ( LastNum = "" )
			LastNum := 1
		NumText := "     " . LastNum
		StringRight, NumText, NumText, 4  ; ������
		IndexContent .= PageType . NumText . "  " . PageTitle . "`n"
		LastNum += PageCount
	}
}
/*	; ʹ������
	K3_PDFIndex(-5, "��", "����б�")
	K3_PDFIndex(5, "��", "��1�� xxxxxxxxxx")
	K3_PDFIndex(4, "ͼ", "��2�� oooooooooo")
	K3_PDFIndex(1, "��", "ż��Ŀ¼ҳ")
	msgbox, % K3_PDFIndex(-9, "��", "�����б�")
*/

K3_PDFAddMixTextPage(Title="", byref sContent="", PageWidth=260, PageHeight=335, PageSpace=5, FontSize=9, LineSpace=13.5, TitleFontSize=12)
{	; ��ӱ��⣬���ģ���Ӣ���ҳ
	hDoc := K3_Var("hDoc")
	YeCount := K3_Var("YeCount")
	++YeCount
	K3_Var("YeCount", YeCount)
	K3_Msg("AddMsg", YeCount)

	hStartPage := hPage := HPDF_AddPage(hDoc) , HPDF_Page_SetWidth(hPage, PageWidth) , HPDF_Page_SetHeight(hPage, PageHeight)
	If ( Title = "" ) ; ����Ϊ��ʱ
		TitleFontSize := 0
	else 
		K3_PDFShowMixLineAtYRange(hPage, Title, 1, PageHeight-PageSpace, PageHeight-PageSpace-TitleFontSize, PageWidth, PageHeight, PageSpace, TitleFontSize, TitleFontSize*1.5, "����")

	If ( sContent = "" ) ; ������ʱ
		return, 0
	startPos := 1 , alllen := StrLen(sContent)
	aa := K3_PDFShowMixLineAtYRange(hPage, sContent, startPos, PageHeight-PageSpace-TitleFontSize, PageSpace, PageWidth, PageHeight, PageSpace, FontSize, LineSpace, "����")
	while ( startPos := startPos + aa ) <= alllen
	{
		++YeCount
		K3_Var("YeCount", YeCount)
		K3_Msg("AddMsg", YeCount)
		hPage := HPDF_AddPage(hDoc) , HPDF_Page_SetWidth(hPage, PageWidth) , HPDF_Page_SetHeight(hPage, PageHeight)
		aa := K3_PDFShowMixLineAtYRange(hPage, sContent, startPos, PageHeight-PageSpace, PageSpace, PageWidth, PageHeight, PageSpace, FontSize, LineSpace, "����")
	}
	return, hStartPage
}

K3_PDFShowMixLineAtYRange(hPage, byref SrcStr, StartStrPos=1, YTop=330, YBottom=5, PageWidth=260, PageHeight=335, PageSpace=5, FontSize=9, LineSpace=13.5, Align="����")
{	; ���������귶Χ����ʾ��Ӣ����ַ���
	hCNFont := K3_Var("hCNFont") , hENFont := K3_Var("hENFont")
	MarkStartStrPos := StartStrPos
	MaxEnCharNum := Floor((2 * PageWidth - 4 * PageSpace)/FontSize) ; �����Ӣ���ַ������ٶ����Ŀ��Ϊ�����С��Ӣ�Ŀ��Ϊ0.5�����С
	TextRange := YTop - YBottom , MaxLineNum := Floor(TextRange/FontSize) ; �������

	HPDF_Page_BeginText(hPage) ; ��ʼ���

	If ( MaxLineNum <= 1 ) { ; ������ʾ
		If ( MaxEnCharNum < ( OneLineStrLen := StrLen(SrcStr) ) )
			OneLineStrLen := MaxEnCharNum
		If ( Align = "����" )
			HPDF_Page_MoveTextPos(hPage, PageSpace, Ytop - FontSize)
		If ( Align = "����" )
			HPDF_Page_MoveTextPos(hPage, PageWidth/2-OneLineStrLen*FontSize/4, Ytop - FontSize)
		If ( Align = "����" )
			HPDF_Page_MoveTextPos(hPage, PageWidth-OneLineStrLen*FontSize/2-PageSpace, Ytop - FontSize)
		isNeedNewLine := 0
	} else { ; ������ʾ
		TrueMaxLineNum := Floor(TextRange/LineSpace)
		HPDF_Page_MoveTextPos(hPage, PageSpace, YTop)
		isNeedNewLine := 1
	}

	LineCount := 0 , NowLineEnCharNum := 0
	loop { ; ��
		If isNeedNewLine
			HPDF_Page_MoveTextPos(hPage, 0, -LineSpace)
		loop { ; �ַ�
			NowAscii := Asc(NowChar := SubStr(SrcStr, StartStrPos, 1)) ; ȡһ���ַ�
			If ( NowAscii > 128 ) { ; ����
				If ( NowLineEnCharNum + 2 <= MaxEnCharNum ) {
					HPDF_Page_SetFontAndSize(hPage, hCNFont, FontSize)
					, HPDF_Page_ShowText(hPage, SubStr(SrcStr, StartStrPos, 2))
					StartStrPos += 2 , NowLineEnCharNum += 2
					isNeedNewLine := 0
				} else
					isNeedNewLine := 1
			} else { ; Ӣ��
				If ( NowLineEnCharNum + 1 <= MaxEnCharNum ) {
					If ( NowAscii != 10 And NowAscii != 13 ) { ; �ǻس����з�
						HPDF_Page_SetFontAndSize(hPage, hENFont, FontSize)
						, HPDF_Page_ShowText(hPage, NowChar)
						isNeedNewLine := 0
					} else {
						If ( NowAscii = 10 )
							isNeedNewLine := 1
						else
							isNeedNewLine := 0
					}
					++StartStrPos , ++NowLineEnCharNum
				} else
					isNeedNewLine := 1
				If ( NowAscii = 0 )
					isNeedNewLine := 1
			}
			If isNeedNewLine
			{
				NowLineEnCharNum := 0
				break
			}
		} ; �ַ�����
		++LineCount
		If ( MaxLineNum <= 1 or LineCount >= TrueMaxLineNum ) ; ������ʾ
			break
	} ; �н���

	HPDF_Page_EndText(hPage) ; �������
	return, StartStrPos - MarkStartStrPos
}

K3_PDFAddPicPage(PicPath, iw=0, ih=0, GifTitle="") ; ֧��PNG �� JPG/JPEG, ������ʽת��Ϊpng
{	; HPDF: ���ͼƬҳ
	hDoc := K3_Var("hDoc")
	SplitPath, PicPath, OutFileName, OutDir, fExt, OutNameNoExt, OutDrive

		FreeImage_FoxInit(True) ; Load Dll
	hFImage := FreeImage_Load(PicPath) ; load image ����ͼ��
	FreeImage_FoxPalleteIndex70White(hFImage) ; Fox:������͸��Gif��ɫ����ɫ�滻Ϊ��ɫ
	FreeImage_SetTransparent(hFImage, 0)

	hMemory := FreeImage_OpenMemory(0, 0)
	FreeImage_SaveToMemory(13, hFImage, hMemory, 0) ; ת����PNG, ��д���ڴ�
	FreeImage_AcquireMemory(hMemory, BufAdr, BufSize)
	FreeImage_UnLoad(hFImage) ; Unload Image �ͷž��
	
	hImage := HPDF_LoadPngImageFromMem(hDoc, BufAdr, BufSize)
	FreeImage_CloseMemory(hMemory)
		FreeImage_FoxInit(False) ; Unload Dll
	If ( iw = 0 or ih = 0 )
		iw := HPDF_Image_GetWidth(hImage) , ih := HPDF_Image_GetHeight(hImage)
	return, K3_PDFShowPicInPages(hImage, iW, iH, GifTitle)
}
/*
old_K3_PDFAddPicPage(PicPath, iw=0, ih=0, GifTitle="") ; ֧��PNG �� JPG/JPEG, ������ʽת��Ϊpng
{	; HPDF: ���ͼƬҳ
	hDoc := K3_Var("hDoc")
	SplitPath, PicPath, OutFileName, OutDir, fExt, OutNameNoExt, OutDrive
	If ( fExt != "jpg" And fExt != "jpeg" And fExt != "png" ) { ; ��jpg/png��ʽ��ת��Ϊpng��ʽ
		OutExt := "png"
		TmpPicPath := "C:\" . OutNameNoExt . "_FoxTmp." . OutExt
		TmpPicPath := K3_PicConvert(PicPath, TmpPicPath)
		K3_TmpFileList(TmpPicPath) ; �����ʱ�ļ��б�
		fExt := OutExt
	} else
		TmpPicPath := PicPath
	If ( fExt = "jpg" or fExt = "jpeg" )
		hImage := HPDF_LoadJpegImageFromFile(hDoc, TmpPicPath)
	If ( fExt = "png")
		hImage := HPDF_LoadPngImageFromFile(hDoc, TmpPicPath)
	If ( iw = 0 or ih = 0 )
		iw := HPDF_Image_GetWidth(hImage) , ih := HPDF_Image_GetHeight(hImage)
	return, K3_PDFShowPicInPages(hImage, iW, iH, GifTitle)
}
*/

K3_PDFShowPicInPages(hImage, iW=0, iH=0, GifTitle="��xxx�� ����")
{	; �ָ���ʾPNG�����ȶ�������
	YeCount := K3_Var("YeCount")
	hDoc := K3_Var("hDoc")
	iW := iW * 0.75 , iH := iH * 0.75
	iHead := 30 , iSpace := 20 * 0.75 , iK3GifMax := 4650 * 0.75 ; ��ȷ��ദ�� If ( ImgWidth = 700 ) ThePoint := 4650 else ThePoint := 4500


	nPage := Ceil(iH / (iK3GifMax - iHead - iSpace)) ; ҳ��
	iMain := iH / nPage

	loop, %nPage% {
		++YeCount
		K3_Var("YeCount", YeCount)
		hPage := HPDF_AddPage(hDoc) , HPDF_Page_SetWidth(hPage, iW)
		If ( A_index = 1 ) {
			hStartPage := hPage
			If ( ( iMain * A_index + iSpace ) > iH )
				AddSpace := 0
			else
				AddSpace := iSpace
			If ( GifTitle = "" )
				iHead := 0
			iFirst := iMain + AddSpace + iHead
			HPDF_Page_SetHeight(hPage, iFirst)
			K3_PDFShowMixLineAtYRange(hPage, GifTitle, 1, iFirst-5, iFirst-25, iW, iFirst, 5, 20, 20*1.5, "����")
			AA := HPDF_Page_DrawImage(hPage, hImage, 0, iMain+AddSpace-iH, iW, iH)
		} else {
			If ( ( iMain * A_index + iSpace ) > iH )
				AddSpace := 0
			else
				AddSpace := iSpace
			HPDF_Page_SetHeight(hPage, iMain + AddSpace)
			AA := HPDF_Page_DrawImage(hPage, hImage, 0, iMain*A_index+AddSpace-iH, iW, iH)
		}
	}
	return, hStartPage
}


K3_PicConvert(SrcPath="C:\test.gif", TarPath="C:\test.png", Mode="gif2png") ; GDIPs GDIPc Irfan gif2png FreeImage
{	; ����GIF -> PNG, JPG��ת��
	static IrfanViewPath
	If ( Mode = "GdIPs" or Mode = "GDIPc" ) { ; s: �� c: ����
		pToken := Gdip_Startup()
		pBitmap := Gdip_CreateBitmapFromFile(SrcPath)
		If ( Mode = "GdIPc" ) {
			pBitmapAlpha := pBitmap
			ImgWidth := Gdip_GetImageWidth(pBitmapAlpha) , ImgHeight := Gdip_GetImageHeight(pBitmapAlpha)
			pBitmap := Gdip_CreateBitmap(ImgWidth, imgheight) , G1 := Gdip_GraphicsFromImage(pBitmap) ; ������BitMap
			Gdip_GraphicsClear(G1, 0xFFFFFFFF) ; �������
			Gdip_DrawImage(G1, pBitmapAlpha, 0, 0, ImgWidth, imgheight, 0, 0, ImgWidth, imgheight, 1) ; ��BitMapʹ��ԭͼ���
			Gdip_DisposeImage(pBitmapAlpha), Gdip_DeleteGraphics(G1)
		}
		Gdip_SaveBitmapToFile(pBitmap, TarPath) , Gdip_DisposeImage(pBitmap)
		Gdip_Shutdown(pToken)
		return, TarPath
	}
	If ( Mode = "Irfan" ) {
		If ( IrfanViewPath = "" )
			IrfanViewPath := K3_GetPath(":\bin\IrfanView\i_view32.exe")
;		IniWrite, 1, i_view32.ini, MultiGIF, UseSingleTrans  ; ͸����������ֵʹ͸��gif�������
;		IniWrite, 16777215, i_view32.ini, Viewing, BackColor ; ������ɫ
		runwait, %IrfanViewPath% "%SrcPath%" /convert="%TarPath%", %A_scriptdir%, Hide
		return, TarPath
	}
	If ( Mode = "gif2png" ) {
		runwait, gif2png.exe -b FFFFFF %SrcPath%, %A_scriptdir%, Hide
		SplitPath, SrcPath, OutFileName, OutDir, OutExt, OutNameNoExt, OutDrive
		IfExist, %OutDir%\%OutNameNoExt%.png            ; ����ĳЩGIF�������ˣ��������Ȼ���Լ���-r�����޸�������Ч������
			return, OutDir . "\" . OutNameNoExt . ".png"
		else
			Mode := "FreeImage"
	}
	If ( Mode = "FreeImage" ) {
		FreeImage_FoxInit(True) ; Load Dll
		hImage := FreeImage_Load(SrcPath) ; load image ����ͼ��
		FreeImage_FoxPalleteIndex70White(hImage) ; Fox:������͸��Gif��ɫ����ɫ�滻Ϊ��ɫ
		FreeImage_SetTransparent(hImage, 0)
		FreeImage_Save(hImage, TarPath) ; Save Image д��ͼ��
		FreeImage_UnLoad(hImage) ; Unload Image �ͷž��
		FreeImage_FoxInit(False) ; Unload Dll
		return, TarPath
	}
}


K3_TmpFileList(TmpFilePath="") ; ��ӣ�ɾ����ʱ�ļ��б�
{
	static TmpFileList := ""
	If ( TmpFilePath = "DelFoxFiles" ) { ; ������Ϊ DelFoxFiles ʱ��ɾ���б��е��ļ���������б�
		loop, parse, TmpFileList, `n
		{
			If ( A_loopfield = "" )
				continue
			IfExist, %A_loopfield%
				FileDelete, %A_loopfield%
		}
		TmpFileList := ""
		return
	}
	TmpFileList .= TmpFilePath . "`n"
}

K3_Msg(Action="AddMsg", Msg="")
{
	static ShowType, MsgHead, MsgTail
	If ( Action = "ShowType" )
		ShowType := Msg
	If ( Action = "SetHead" )
		MsgHead := Msg
	If ( Action = "SetTail" )
		MsgTail := Msg
	If ( Action = "AddMsg" ) {
		If ( ShowType = "" )
			SB_SetText(MsgHead . Msg . MsgTail)
		If ( ShowType = "Statubar2" )
			SB_SetText(MsgHead . Msg . MsgTail, 2)
	}
}

; }---------------------------------LibHaru -> PDF


; {----------------------K3 Mobi �ļ�����
/*
	K3_MobiCreateNCX("AddItem", "xxxxx.htm#toc", "Ŀ¼", "toc") ; SrcURL[,text,ID]
	K3_MobiCreateNCX("AddItem", "xxxxx.htm#vol1", "��һ��", "vol1") ; SrcURL[,text,ID]
	K3_MobiCreateNCX("AddItem", "xxxxx.htm#vol2", "�ڶ���", "vol2") ; SrcURL[,text,ID]
	K3_MobiCreateNCX("Create", "C:\xxxxx.ncx", "������������յ�") ; SavePath[,bookname]
	; ---------------------
	K3_MobiCreateOPF("TOCName", "FoxIndex") ; ��ʡ��
	K3_MobiCreateOPF("BookName", "�����������յ�")
	K3_MobiCreateOPF("HasNCX")
	K3_MobiCreateOPF("AddItem", "xxxxxxA.htm")
	K3_MobiCreateOPF("AddItem", "xxxxxxB.htm")
	K3_MobiCreateOPF("Create", "C:\xxxxxxxxxxx.opf")
*/

K3_getQidianXMLPart(byref FoxXML, LableName="Title55")
{
	RegExMatch(FoxXML, "smUi)<" . LableName . ">(.*)</" . LableName . ">", out_)
	return, out_1
}

; MarkedStr ���� qidian_txt2xml ���ɵ� XML�������Ǹ����Ǵ�xml��ȡ����Ԫ�ĺ���
K3_ProcessChapter2Mobi(Byref MarkedStr, StartPartNum=1, OutFileDir="")
{	; �����������½ڲ�����Mobi(��)
	TOCName := "FoxIndex"
	MainHTMLName := TOCName . ".htm" , NCXName := TOCName . ".ncx"
	OutMainHTMLPath :=  OutFileDir . "\" . MainHTMLName , OutNCXPath :=  OutFileDir . "\" . NCXName

	NowBookName := K3_getQidianXMLPart(MarkedStr, "BookName")
	NowAuthor := K3_getQidianXMLPart(MarkedStr, "AuthorName")
	NowQidianID := K3_getQidianXMLPart(MarkedStr, "QidianID")
	AllPartCount := K3_getQidianXMLPart(MarkedStr, "PartCount")
	if ( 0 = StartPartNum ) { ; ������ģʽ
		OutOPFPath := OutFileDir . "\qidiantxt.opf"
	} else {
		OutOPFPath := OutFileDir . "\" . NowBookName . ".opf"
	}

	; HTML ͷ��
	NewHead = 
	(join`n Ltrim
	<html><head>
	<meta http-equiv=Content-Type content="text/html; charset=utf-8">
	<style type="text/css">h2,h3,h4{text-align:center;}</style>
	<title>%NowBookName%</title></head><body>
	<a id="toc"></a>`n`n<h3>%NowBookName%</h3>`n����: %NowAuthor%  ���: %NowQidianID%<br><br>`n`n
	)
	NewTail .= "</body></html>`n"

	K3_MobiCreateNCX("AddItem", MainHTMLName . "#toc", "Ŀ¼", "toc")
	loop, % AllPartCount - StartPartNum + 1
	{
		NowPartNum := StartPartNum + A_index - 1
		NowTitle := K3_getQidianXMLPart(MarkedStr, "Title" . NowPartNum) , NowPart := K3_getQidianXMLPart(MarkedStr, "Part" . NowPartNum)
		K3_Msg("AddMsg", "����Mobi HTM ��: " . NowPartNum . " / " . AllPartCount)
		Stringreplace, NowPart, NowPart, `n, <br>`n, A

		K3_MobiCreateNCX("AddItem", MainHTMLName . "#" . NowPartNum, NowTitle, NowPartNum)
		NewTOC .= "<a href=""#" . NowPartNum . """>" . NowTitle . "</a><br>`n"
		NewTxt .= "<a id=""" . NowPartNum . """></a>`n`n<h4>" . NowTitle . "</h4>`n" . NowPart . "`n<mbp:pagebreak/>`n`n"
	}

	UTF8NR := GeneralA_Ansi2UTF8(NewHead . NewTOC . "`n<mbp:pagebreak/>`n`n<a id=""content""></a>`n`n" . NewTxt . NewTail)
	K3_Msg("AddMsg", "����Mobi�ļ�: " . NowBookName)

	FileAppend, %UTF8NR%, %OutMainHTMLPath%              ; ���ļ������foxopf�������ļ���һ��
	K3_MobiCreateNCX("Create", OutNCXPath, NowBookName, NowAuthor)

	K3_MobiCreateOPF("TOCName", TOCName) ; ��ʡ��
	K3_MobiCreateOPF("BookName", NowBookName)
	K3_MobiCreateOPF("Author", NowAuthor)
	K3_MobiCreateOPF("HasNCX")
	K3_MobiCreateOPF("Create", OutOPFPath)

	runwait, kindlegen.exe %OutOPFPath%, %OutFileDir%, Hide
	FileDelete, %OutOPFPath%
	FileDelete, %OutNCXPath%
	FileDelete, %OutMainHTMLPath%
}

K3_MobiCreateNCX(Action="AddItem", ArgA="", ArgB="", ArgC="") ; Create:SavePath[,bookname,AuthorName];AddItem:SrcURL[,text,ID]
{	 ; NCX�ļ�˵��: ��ʡ��:docTitle, docAuthor, Item��ID��ʡ��, Name���������ݣ��ظ�����ν, Playorder��Src�Ǳ����
	static NCXNR := "" , ShowNum := 0
	; { ----- AddItem
	If ( Action = "AddItem" ) {
		If ( ArgB = "" )
			ArgB := "Fox" ; Ĭ������
		If ( ArgC != "" )
			IDStr := " id=""" . ArgC . """"
		++ShowNum
		NCXNR .= "`t<navPoint" . IDStr . " playOrder=""" . ShowNum . """><navLabel><text>" . ArgB . "</text></navLabel><content src=""" . ArgA . """/></navPoint>`n"
	}
	; } ----- AddItem
	; { ----- Create
	If ( Action = "Create" ) {
		If ( ArgB != "" )
			TitleStr := "<docTitle><text>" . ArgB . "</text></docTitle>"
	NCXNR=
	(Join`n LTrim
	<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE ncx PUBLIC "-//NISO//DTD ncx 2005-1//EN"
		"http://www.daisy.org/z3986/2005/ncx-2005-1.dtd">
	<!-- For a detailed description of NCX usage please refer to: http://www.idpf.org/2007/opf/OPF_2.0_final_spec.html#Section2.4.1 -->

	<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1" xml:lang="zh-cn">
	<head>
	<meta name="dtb:uid" content=""/>
	<meta name="dtb:depth" content="-1"/>
	<meta name="dtb:totalPageCount" content="0"/>
	<meta name="dtb:maxPageNumber" content="0"/>
	</head>
	%TitleStr%
	<docAuthor><text>%ArgC%</text></docAuthor>
	<navMap>

	%NCXNR%
	</navMap></ncx>

	)
		IfExist, %ArgA%
			FileMove, %ArgA%, %ArgA%.%A_now%
		FileAppend, % GeneralA_Ansi2UTF8(NCXNR), %ArgA%
		NCXNR := "" , ShowNum := 0
	}
	; } ----- Create
}

K3_MobiCreateOPF(Action="AddItem", iStrA="") { ; Ĭ�� FoxIndex.htm#[content|toc] FoxIndex.ncx
	static TOCName := "FoxIndex" , BookName := "���������", AuthorName := "������֮��" , SpineHead := "<spine>" , ItemNCX := "" , FoxManifest := "`n" , FoxSpine := "`n" , ItemCount := 10

	If ( Action = "TOCName" ) ; FoxIndex.htm, FoxIndex.ncx
		TOCName := iStrA
	If ( Action = "BookName" )
		BookName := iStrA
	If ( Action = "Author" )
		AuthorName := iStrA
	If ( Action = "HasNCX" ) { ; Ĭ��NCX ID Ϊ FoxNCX
		SpineHead := "<spine toc=""FoxNCX"">"
		ItemNCX := "`t<item id=""FoxNCX"" media-type=""application/x-dtbncx+xml"" href=""" . TOCName . ".ncx""/>"
	}
	If ( Action = "AddItem" ) {
		++ItemCount
		FoxManifest .= "`t<item id=""Fox" . ItemCount . """ media-type=""application/xhtml+xml"" href=""" . iStrA . """/>`n"
		FoxSpine .= "`t<itemref idref=""Fox" . ItemCount . """/>`n"
	}
	; { ----- Create
	If ( Action = "Create" ) { ; ["Create",BookName,���ĵ�ַ,Ŀ¼��ַ,����ļ�·��]
		FoxNowUUID := General_UUID() ; ����ʱ��Ψһ��ID
		XML=
		(Join`n Ltrim
		<?xml version="1.0" encoding="utf-8"?>
		<package xmlns="http://www.idpf.org/2007/opf" version="2.0" unique-identifier="FoxUUID">
		<metadata xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:opf="http://www.idpf.org/2007/opf">
			`t<dc:identifier opf:scheme="uuid" id="FoxUUID">%FoxNowUUID%</dc:identifier>
			`t<dc:title>%BookName%</dc:title>
			`t<dc:language>zh-cn</dc:language>
			`t<dc:creator>%AuthorName%</dc:creator>
			`t<dc:publisher>%AuthorName%</dc:publisher>
			`t<x-metadata><output encoding="utf-8"></output></x-metadata>
		</metadata>

		<manifest>
		%ItemNCX%
		`t<item id="FoxTOC" media-type="application/xhtml+xml" href="%TOCName%.htm"/>
		%FoxManifest%
		</manifest>

		%SpineHead%
		`t<itemref idref="FoxTOC"/>
		%FoxSpine%
		</spine>

		<guide>
			`t<reference type="text" title="����" href="%TOCName%.htm#content"/>
			`t<reference type="toc" title="Ŀ¼" href="%TOCName%.htm#toc"/>
		</guide>`n</package>`n`n
		)
		IfExist, %iStrA%
			FileMove, %iStrA%, %iStrA%.%A_now%
		Fileappend, % GeneralA_Ansi2UTF8(XML), %iStrA%
		TOCName := "FoxIndex" , BookName := "���������" , SpineHead := "<spine>" , ItemNCX := "" , FoxManifest := "`n" , FoxSpine := "`n" , ItemCount := 10
	}
	; } ----- Create
}

; }----------------------K3 Mobi �ļ�����

; {----------------------K3 UMD �ļ�����
K3_UMD(Action="Add", iStrA="", iStrB="")
{	; ���� umd.dll zlib.dll http://code.google.com/p/umd-builder/
	static hModule , hUMD , UMDDllPath
	If ( UMDDllPath = "" )
		UMDDllPath := K3_GetPath("D:\bin\bin32\umd.dll")
	If ( Action = "New" ) {
		hModule := DllCall("LoadLibrary", "Str", UMDDllPath)
		hUMD := Dllcall("umd\umd_create", "Uint", 0)
		; 2:���� 3:���� 4:������� 5:�����·� 6:�������� 7:�鼮���� 8:������ 9:������
		Dllcall("umd\umd_set_field_a", "Uint", hUMD, "Uint", 2, "str", iStrA)
		Dllcall("umd\umd_set_field_a", "Uint", hUMD, "Uint", 8, "str", "������֮��")
	}
	If ( Action = "Add" )
		Dllcall("umd\umd_add_chapter_a", "Uint", hUMD, "str", iStrA, "str", iStrB)
	If ( Action = "Save" ) {
		Dllcall("umd\umd_build_file_a", "Uint", hUMD, "str", iStrA)
		Dllcall("umd\umd_destroy", "Uint", hUMD)
		DllCall("FreeLibrary", "Uint", hModule)
		hModule := "" , hUMD := ""
	}
}
; }----------------------K3 UMD �ļ�����

; ------------------��д����

K3_GetPath(FilePath="D:\etc\RamOSFiles.exe", FoxDrives="CD")
{	; �����ļ����ڷ�
	stringleft, Tmpsss, FilePath, 2
	If ( Tmpsss != ":\" )
		stringtrimleft, FilePath, FilePath, 1
	loop, parse, FoxDrives
	{
		NNCMD := A_LoopField . FilePath
		IfExist, %NNCMD%
			return, NNCMD
	}
}

K3_Var(iName="", iStr="get") ; iName Ϊstatic����ȥ��s�Ĳ���, iStr Ĭ��Ϊget��Ҳ��Ϊ���õ�ֵ
{
	static shDll, shDoc, shCNFont, shENFont, sYeCount
	If ( iStr = "get" )
		return, s%iName%
	else
		s%iName% := iStr
}

