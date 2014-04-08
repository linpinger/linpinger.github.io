/*
#NoEnv
; -----��ע:
^esc::reload
+esc::Edit
!esc::ExitApp
F1::
	NowDBPath := "D:\bin\SQlite\FoxBook\FoxBook.db3"
	NowPicDir := "D:\bin\SQlite\FoxBook\FoxPic"
	NowBookID := 5
	oDB := new SQLiteDB
	oDB.OpenDB(NowDBPath)
	oDB.GetTable("select Name,Content,CharCount from page where bookid = " . NowBookID, oTable)
	oDB.CloseDB()
	
	sTime := A_TickCount
	oPDF := new FoxPDF("͵��")

	ChapterCount := oTable.RowCount
	loop, %ChapterCount%
	{
		ToolTip, ���� �� %A_index% / %ChapterCount% ��
		NowTitle := oTable.rows[A_index][1] , NowContent := oTable.rows[A_index][2]
		If ( oTable.rows[A_index][3] > 1000 ) {
			hFirstPage := oPDF.AddTxtChapter(NowContent, NowTitle)
		} else { ; ͼƬ�½�
			GIFPathArray := [] , GIFCount := 0
			loop, parse, NowContent, `n, `r
			{
				If ( A_loopfield = "" )
					continue
				FF_1 := ""
				regexmatch(A_loopfield, "Ui)^(.*\.gif)\|", FF_)
				If ( FF_1 = "" )
					continue
				NowGIFPath = %NowPicDir%\%NowBookID%\%FF_1%
				IfNotExist, %NowGIFPath%
					continue
				++GIFCount
				GIFPathArray[GIFCount] := NowGIFPath
			}
			hFirstPage := oPDF.AddPNGChapter(GIFPathArray, NowTitle) ; GIFPathArray Ϊ GIF�ļ�·�� ����
		}
	}
	tooltip

	FileDelete, C:\xxx.pdf
	oPDF.SaveTo("C:\xxx.pdf")

	eTime := A_TickCount - sTime
	IfExist, C:\xxx.pdf
		TrayTip, ��ʱ:, %eTime% ms
	else
		TrayTip, ����:, δ����pdf�ļ�
return
#include <SQLiteDB_Class>
*/

Class FoxPDF {
	ScreenWidth := 530 , ScreenHeight := 700  ; �и�ͼƬҳ�ߴ� K3:530*700  s5570:270*360
	TextPageWidth := 250 , TextPageHeight := 330 , TextTitleFontsize := 12 , BodyFontSize := 9.5 , BodyLineHeight := 12.5 , CalcedOnePageRowNum := 26 ; 26*26�� �ı�ҳ�ߴ� K3
	hDll := "" , hDoc := "" , hCNFont := "" , hENFont := "" , hPage := "" , nPageCount := 0
	BookName := "����"
	isAddOutLine := 1 , isInsertIndexpage := 1 ; ѡ��Ƿ� �������б�����Ŀ¼ҳ
	isInsertPageMod := 0 , hBeInsertPage := ""   ; ������ҳ����
		IndexItem := [] , IndexItemCount := 0  ; Ŀ¼ҳ��Ҫ
	__New(BookName){
		This.BookName := BookName
		
sPathList =
(Ltrim Join`n
%A_scriptdir%\bin32\libhpdf.dll
%A_scriptdir%\libhpdf.dll
D:\bin\bin32\libhpdf.dll
C:\bin\bin32\libhpdf.dll
)
		loop, parse, sPathList, `n, `r
			IfExist, %A_loopfield%
				LibHaruDllPath := A_loopfield

sPathList =
(Ltrim Join`n
%A_WinDir%\Fonts\simhei.ttf
%A_scriptdir%\��ͤ��_GBK.TTF
%A_scriptdir%\lantinghei.ttf
D:\etc\Font\��ͤ��_GBK.TTF
D:\etc\Font\lantinghei.ttf
)
		loop, parse, sPathList, `n, `r
			IfExist, %A_loopfield%
				FoxFontPath := A_loopfield

		this.hDll := HPDF_LoadDLL(LibHaruDllPath)
		this.hDoc := HPDF_New(0,0)
	
		HPDF_SetCompressionMode(This.hDoc, "ALL")
		HPDF_SetInfoAttr(This.hDoc, "AUTHOR", GeneralW_StrToGBK("Linpinger"))

		HPDF_UseCNSEncodings(This.hDoc)
		NowFontName := HPDF_LoadTTFontFromFile(This.hDoc, GeneralW_StrToGBK(FoxFontPath), 1)
		This.hCNFont := HPDF_GetFont2(This.hDoc, NowFontName, GeneralW_StrToGBK("GBK-EUC-H"))
		This.hENFont := HPDF_GetFont2(This.hDoc, NowFontName, GeneralW_StrToGBK("WinAnsiEncoding"))
	}
	SaveTo(PDFSavePath="C:\fox.pdf"){
		If This.isInsertIndexpage
			This.InsertIndexPage()
		HPDF_SaveToFile(This.hDoc, GeneralW_StrToGBK(PDFSavePath))
		HPDF_Free(This.hDoc)
		HPDF_UnloadDLL(This.hDll)
	}
	AddGIFChapterAndSplit(GIFPathArray, Title="") { ; GIFPathArray Ϊ GIF�ļ�·�� ���� , �и�ͼƬ��д�뻺�棬Ȼ������PDF
		If This.isInsertIndexpage
			This.AddIndexRow("ͼ", Title)

		FreeImage_FoxInit(True) ; Load Dll
		; {--����gifsplit�������ϲ�GIF���и�Ϊ��ͼƬ����������浽������
		VarSetCapacity(hImageArray, 1024, 0)
		gifPathCount := GifpathArray.MaxIndex()
		VarSetCapacity(gifpathlist, 2560, 0)
		loop, %gifPathCount%
			StrPut(GifpathArray[A_index], (&gifpathlist)+256*(A_Index-1), "CP936")

		hImageCount := dllcall("FreeImage.dll\gifsplit"
		, "AStr", "Write2Buf"
		, "Uint", &gifpathlist
		, "short", gifPathCount
		, "short", This.ScreenWidth
		, "short", This.ScreenHeight
		, "Uint", 1
		, "Uint", &hImageArray
		, "Cdecl int")
		; }--

		; {-- ���и��ͼƬ��ת����������
		hImageAHKArray := []
		loop, %hImageCount% {
			hFImage := NumGet(&hImageArray+0, (A_index-1)*4, "Uint")
			hMemory := FreeImage_OpenMemory(0, 0)
			FreeImage_SaveToMemory(13, hFImage, hMemory, 0) ; ת����PNG, ��д���ڴ�
			FreeImage_AcquireMemory(hMemory, BufAdr, BufSize)

			hImageAHKArray[A_index] := HPDF_LoadPngImageFromMem(This.hDoc, BufAdr, BufSize)
			FreeImage_UnLoad(hFImage) ; Unload Image �ͷž��
			FreeImage_CloseMemory(hMemory)
		}
		; }--
		FreeImage_FoxInit(False) ; unLoad Dll

		; {-- AHK��ͼƬ����
		iW := HPDF_Image_GetWidth(hImageAHKArray[1]) * 0.75
		iH := HPDF_Image_GetHeight(hImageAHKArray[1]) * 0.75
		nTitleFontSize := 16.5
		nPage := hImageAHKArray.MaxIndex()
		loop, %nPage% {
			++This.nPageCount
			If ( This.isInsertPageMod )
				This.hPage := HPDF_InsertPage(This.hDoc, This.hBeInsertPage)
			else
				This.hPage := HPDF_AddPage(This.hDoc)
			If ( This.isInsertIndexpage = 1 and This.nPageCount = 1 )  ; PDF��һҳΪ������ҳ
				This.hBeInsertPage := This.hPage
			HPDF_Page_SetWidth(This.hPage, iW)
			HPDF_Page_SetHeight(This.hPage, iH)
			AA := HPDF_Page_DrawImage(This.hPage, hImageAHKArray[A_index], 0, 0, iW, iH)
			If ( A_index = 1 ) {
				hFirstPage := This.hPage
				If ( Title != "" )
					This._ShowTitle(This.hPage, Title, nTitleFontSize)
			}
		}
		; }-- 

		If This.isAddOutLine
			This.AddOutLine(hFirstPage, Title)
		return, hFirstPage
	}
	AddPNGChapter(GIFPathArray, Title="") { ; GIFPathArray Ϊ GIF�ļ�·�� ����
		If This.isInsertIndexpage
			This.AddIndexRow("ͼ", Title)
		loop, % GIFPathArray.MaxIndex()
		{
			NowGIFPath := GIFPathArray[A_index]
;			SplitPath, NowGIFPath, OutFileName, OutDir, OutExt, OutNameNoExt, OutDrive

	FreeImage_FoxInit(True) ; Load Dll
;	
	hFImage := FreeImage_Load(GeneralW_StrToGBK(NowGIFPath)) ; load image ����ͼ��
	FreeImage_FoxPalleteIndex70White(hFImage) ; Fox:������͸��Gif��ɫ����ɫ�滻Ϊ��ɫ
	FreeImage_SetTransparent(hFImage, 0)

	hMemory := FreeImage_OpenMemory(0, 0)
	FreeImage_SaveToMemory(13, hFImage, hMemory, 0) ; ת����PNG, ��д���ڴ�
	FreeImage_AcquireMemory(hMemory, BufAdr, BufSize)
	FreeImage_UnLoad(hFImage) ; Unload Image �ͷž��
	
	hImage := HPDF_LoadPngImageFromMem(This.hDoc, BufAdr, BufSize)
	FreeImage_CloseMemory(hMemory)
/*
	VarSetCapacity(pBuffAddr, 4 0) , VarSetCapacity(pBuffLen, 4 0)
	hMemory := DllCall("FreeImage.dll\gif2png_bufopen", "Str", GeneralW_StrToGBK(NowGIFPath), "Uint", &pBuffAddr, "Uint", &pBuffLen, "Cdecl")
	BuffAddr := numget(&pBuffAddr+0, 0, "Uint") , BuffLen := numget(&pBuffLen+0, 0, "Uint")
	hImage := HPDF_LoadPngImageFromMem(This.hDoc, BuffAddr, BuffLen)
	DllCall("FreeImage.dll\gif2png_bufclose", "Uint", hMemory, "Cdecl")
*/
	FreeImage_FoxInit(False) ; unLoad Dll

			If ( A_index = 1 )
				hFirstPage := This._ShowPNGNextPage(hImage, Title)
			else
				This._ShowPNGNextPage(hImage, "")
		}
		If This.isAddOutLine
			This.AddOutLine(hFirstPage, Title)
		return, hFirstPage
	}
	_ShowPNGNextPage(hImage, Title="") {
		iW := HPDF_Image_GetWidth(hImage) * 0.75
		iH := HPDF_Image_GetHeight(hImage) * 0.75

		nTitleHeight := 30 , nTitleFontSize := 20
		iSpace := 20 * 0.75 , iK3GifMax := 4650 * 0.75 ; ��ȷ��ദ�� If ( ImgWidth = 700 ) ThePoint := 4650 else ThePoint := 4500
		nPage := Ceil(iH / (iK3GifMax - nTitleHeight - iSpace)) ; ҳ��
		iMain := iH / nPage

		loop, %nPage% {
			++This.nPageCount
			If ( This.isInsertPageMod )
				This.hPage := HPDF_InsertPage(This.hDoc, This.hBeInsertPage)
			else
				This.hPage := HPDF_AddPage(This.hDoc)
			If ( This.isInsertIndexpage = 1 and This.nPageCount = 1 )  ; PDF��һҳΪ������ҳ
				This.hBeInsertPage := This.hPage
			HPDF_Page_SetWidth(This.hPage, iW)
			If ( A_index = 1 ) {
				hFirstPage := This.hPage
				If ( ( iMain * A_index + iSpace ) > iH )
					AddSpace := 0
				else
					AddSpace := iSpace
				If ( Title = "" )
					nTitleHeight := 0
				iFirst := iMain + AddSpace + nTitleHeight
				HPDF_Page_SetHeight(This.hPage, iFirst)
				If ( Title != "" )
					This._ShowTitle(This.hPage, Title, nTitleFontSize)
				AA := HPDF_Page_DrawImage(This.hPage, hImage, 0, iMain+AddSpace-iH, iW, iH)
			} else {
				If ( ( iMain * A_index + iSpace ) > iH )
					AddSpace := 0
				else
					AddSpace := iSpace
				HPDF_Page_SetHeight(This.hPage, iMain + AddSpace)
				AA := HPDF_Page_DrawImage(This.hPage, hImage, 0, iMain*A_index+AddSpace-iH, iW, iH)
			}
		}
		return, hFirstPage
	}
	AddOutLine(hFirstPage, OutLineText="����", hOutLineRoot=0)
	{	; ������������
		NowEncoder := HPDF_GetEncoder(This.hDoc, GeneralW_StrToGBK("GBK-EUC-H"))
		hOutLine := HPDF_CreateOutline(This.hDoc, hOutLineRoot, GeneralW_StrToGBK(OutLineText), NowEncoder)
		hDest := HPDF_Page_CreateDestination(hFirstPage)
		HPDF_Outline_SetDestination(hOutLine, hDest)
	}
	AddTxtChapter(Content="", Title="") {
		If This.isInsertIndexpage
			This.AddIndexRow("��", Title)
		While ( Content != "" ) {
			If ( A_index = 1 )
				NowTitle := Title
			else
				NowTitle := ""
			nPageWriteChar := This._ShowTextNextPage(Content, NowTitle)
			StringTrimLeft, Content, Content, nPageWriteChar
			If ( A_index = 1 )
				hFirstPage := This.hPage
		}
		If This.isAddOutLine
			This.AddOutLine(hFirstPage, Title)
		return, hFirstPage
	}
	_ShowTextNextPage(Content="", Title="") {
		
		nPageWriteChar := 0
		++This.nPageCount
		If ( This.isInsertPageMod )
			This.hPage := HPDF_InsertPage(This.hDoc, This.hBeInsertPage)
		else
			This.hPage := HPDF_AddPage(This.hDoc)
		If ( This.isInsertIndexpage = 1 and This.nPageCount = 1 )  ; PDF��һҳΪ������ҳ
			This.hBeInsertPage := This.hPage

		HPDF_Page_SetWidth(This.hPage, This.TextPageWidth)
		HPDF_Page_SetHeight(This.hPage, This.TextPageHeight)

		If ( Title != "" ) { ; �б���ʱ, ��������⣬���ƶ�λ��
			This._ShowTitle(This.hPage, Title, This.TextTitleFontsize)
			nLeftLine := Floor(( This.TextPageHeight - This.TextTitleFontsize ) / This.BodyLineHeight)
			StartYPos := This.TextPageHeight - This.TextTitleFontsize
		} else { ; �ޱ��⣬ֱ���ƶ�λ�õ�ͷ��
			nLeftLine := Floor(This.TextPageHeight / This.BodyLineHeight)
			StartYPos := This.TextPageHeight
		}
		HPDF_Page_BeginText(This.hPage) ; ��ʼ���
		HPDF_Page_MoveTextPos(This.hPage, 0, StartYPos)
		loop, %nLeftLine% { ; ��ʾ����
			nLineWriteChar := This._ShowTextNextLine(This.hPage, Content, This.BodyFontSize, This.BodyLineHeight)
			nPageWriteChar += nLineWriteChar
			StringTrimLeft, Content, Content, nLineWriteChar
			If ( Content = "" )
				break
		}
		HPDF_Page_EndText(This.hPage) ; �������
		return, nPageWriteChar
	}
	_ShowTitle(hPage, Title="������֮���ı���", NowTitleFontsize=20) {
		PageWidth := HPDF_Page_GetWidth(hPage) , PageHeight := HPDF_Page_GetHeight(hPage)
		nTitleEnChar := 0
		loop, parse, Title
		{
			If ( Asc(A_loopfield) > 255 ) ; �����ַ�
				nTitleEnChar += 2
			else
				++nTitleEnChar
		}
		xTitlePos := PageWidth / 2 - nTitleEnChar * NowTitleFontsize / 4
		If ( xTitlePos <= 0 )
			xTitlePos := 0
		HPDF_Page_BeginText(hPage) ; ��ʼ���
		HPDF_Page_MoveTextPos(hPage, xTitlePos, PageHeight)
		This._ShowTextNextLine(hPage, Title, NowTitleFontsize, NowTitleFontsize)
		HPDF_Page_EndText(hPage) ; �������
	}
	_ShowTextNextLine(hPage, inText="", inFontSize=9.5, inLineHeight=12.5) {
		PageWidth := HPDF_Page_GetWidth(hPage) ; , PageHeight := HPDF_Page_GetHeight(hPage)
		BodyLineMaxEnChar := PageWidth / inFontSize * 2
		HPDF_Page_MoveTextPos(hPage, 0, -inLineHeight)
		nCharCount := 0 , nShowEnChar := 0
		loop, parse, inText
		{
			If ( nShowEnChar + 2 > BodyLineMaxEnChar )
				break
			NowASC := Asc(A_loopfield)
			++nCharCount
			If ( NowAsc > 255 ) { ; �����ַ�
				nShowEnChar += 2
				HPDF_Page_SetFontAndSize(hPage, This.hCNFont, inFontSize)
				HPDF_Page_ShowText(hPage, GeneralW_StrToGBK(A_loopfield))
			} else { ; Ӣ���ַ�
				If ( NowASC = 13 )
					continue
				If ( NowASC = 10 )
					break
				++nShowEnChar
				HPDF_Page_SetFontAndSize(hPage, This.hENFont, inFontSize)
				HPDF_Page_ShowText(hPage, GeneralW_StrToGBK(A_loopfield))
			}
		}
		return, nCharCount
	}
	AddIndexRow(ChapterType="ͼ", ChapterTitle="�����½���"){ ; ���Ŀ¼ҳ������Ŀ
		++This.IndexItemCount
		This.IndexItem[This.IndexItemCount,1] := ChapterType
		This.IndexItem[This.IndexItemCount,2] := This.nPageCount + 1
		This.IndexItem[This.IndexItemCount,3] := ChapterTitle
	}
	InsertIndexPage() {
		IndexContentRowNum := This.IndexItem.MaxIndex() ; Ŀ¼ҳ��������
		IndexPageNum := Ceil(( IndexContentRowNum + 1 ) / This.CalcedOnePageRowNum)  ; Ŀ¼ҳҳ��
		Content := ""
		loop, %IndexContentRowNum% {  ; ����ҳ����
			NowPageNum := This.IndexItem[A_index,2] + IndexPageNum
			NowNumText := "    " . NowPageNum
			StringRight, NowNumText, NowNumText, 4  ; ��ʽ��ҳ��
			NowTitle := This.IndexItem[A_index,3]
			StringLeft, NowTitle, NowTitle, 22  ; ��ʽ������
			Content .= This.IndexItem[A_index,1] . NowNumText . "��" . NowTitle . "`n"
		}

		IndexStartNum := This.nPageCount
		This.isInsertPageMod := 1
		This.AddTxtChapter(Content, This.BookName . "��Ŀ¼��")
		This.isInsertPageMod := 0
		TheTruePageNum := This.nPageCount - IndexStartNum
		If ( TheTruePageNum != IndexPageNum )
			TrayTip, ����:, % This.BookName . "`nĿ¼ҳ����Ԥ��ҳ������`n�������Ŀ¼��ҳ��������"
	}
}

/*
Gif2Png(SrcPath="C:\xxx.gif", TarPath="C:\xxx.png", Mode="gif2png")
{
	If ( Mode = "gif2png" ) {
		runwait, gif2png.exe -b FFFFFF %SrcPath%, %A_scriptdir%, Hide
		SplitPath, SrcPath, OutFileName, OutDir, OutExt, OutNameNoExt, OutDrive
		IfExist, %OutDir%\%OutNameNoExt%.png            ; ����ĳЩGIF�������ˣ��������Ȼ���Լ���-r�����޸�������Ч������
			return, OutDir . "\" . OutNameNoExt . ".png"
		else {
			Mode := "FreeImage"
		}
	}
	If ( Mode = "FreeImage" ) {
		FreeImage_FoxInit(True) ; Load Dll
		hImage := FreeImage_Load(GeneralW_StrToGBK(SrcPath)) ; load image ����ͼ��
		FreeImage_FoxPalleteIndex70White(hImage) ; Fox:������͸��Gif��ɫ����ɫ�滻Ϊ��ɫ
		FreeImage_SetTransparent(hImage, 0)
		FreeImage_Save(hImage, GeneralW_StrToGBK(TarPath), "PNG") ; Save Image д��ͼ��
		FreeImage_UnLoad(hImage) ; Unload Image �ͷž��
		FreeImage_FoxInit(False) ; Unload Dll
		return, TarPath
	}
}
*/
