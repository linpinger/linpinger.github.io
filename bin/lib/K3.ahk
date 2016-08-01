; -----备注: K3用 PDF Mobi 生成库
/*
F1::
	txtnr := "华夏FoxSaid~!@#$%^&*()_+|-=\境内，洪帮和青帮的总舵，还是那座山神庙后半山腰坪前的大树下，洪七和古青云被一起召集了过来。跃千愁看着山下青烟袅袅的山神庙，伸手摸着大树粗糙的表皮，缓缓说道：“古青云，你立刻派出一部分人手到海外寻找火山岛。洪七，你派出人手传我号令，召集整个人间会炼丹的修士在东极圣土集丵合……”（未完待续）！~！" ; 乱码测试字符串
	loop, 15
		nr .= txtnr . "`n------------`n"
	txtnr := nr , nr := ""
;	Fileread, txtnr, C:\etc\1.txt

	stime := A_TickCount
	K3_PDFInit() ; 初始化

	; 添加文字页
	hFont := K3_PDFGetFont(A_windir . "\Fonts\simhei.ttf")

	PageWidth := 260 , PageHeight := 335 , PageSpace := 5 
	FontSize := 9 , LineSpace := FontSize * 1.5
	Title := "第四百九十二章 哈哈(Linpinger)呵呵" , TitleFontSize := 12

	hPage := K3_PDFAddMixTextPage(Title, txtnr, PageWidth, PageHeight, PageSpace, FontSize, LineSpace, TitleFontSize)
	K3_PDFAddOutLine(hPage, "第1章")

;	hPage := K3_PDFAddPicPage("c:\etc\1.GIF", 0, 0, "图片章节标题") ; 添加图片页
;	K3_PDFAddOutLine(hPage, "第2章")

	K3_PDFTerm(A_scriptdir . "\0000.pdf") ; 保存，收尾
	eTime := A_TickCount - sTime
	IfExist, %A_scriptdir%\0000.pdf
	{
		TrayTip, 耗时:, %eTime% ms
		run, %A_scriptdir%\0000.pdf
	} else
		TrayTip, 错误:, 没有生成文件
return
*/

; {---------------------------------LibHaru -> PDF
/*
libharu版本生成文件比较:
	GDIP绘制背景(耗时 大小 背景色)	Irfan(耗时 大小 背景色)	GDIP简单存储(耗时 大小 背景色)	jpgGDIPc	gif2png
2.0.8	5578ms 2.5M 白			3390ms 1.9M 白			2765ms 1.9M 绿		3062ms 4.7M 白	3250ms 1.9M
2.1.0	6109ms 21.8M 白			3297ms 1.9M 白			3343ms 21.2M 白
2.2.0	同 2.1.0 版
综合来看，使用 2.0.8版 GDIP绘制背景 大小最小，速度可以考虑(可用irfan加速)
*/


K3_PDFInit(LibHaruPath="") ; HPDF 初始化 全局设置
{
	If ( LibHaruPath = "" )
		LibHaruPath := K3_GetPath("D:\bin\bin32\libhpdf.dll")
	K3_Var("hDll", HPDF_LoadDLL(LibHaruPath))
	hDoc := HPDF_New("error","000") ; create new document in memory
	K3_Var("hDoc", hDoc)

	HPDF_SetCompressionMode(hDoc, "ALL") ; NONE TEXT IMAGE METADATA ALL
	HPDF_SetInfoAttr(hDoc, "AUTHOR", "Linpinger")
;	HPDF_SetPageMode(hDoc, "USE_OUTLINE")
	HPDF_UseCNSEncodings(hDoc) ; 使用多字节编码必须使用它
}


K3_PDFTerm(PDFSavePath="FoxCreate.pdf") ; HPDF 保存文档，释放资源
{
	hDoc := K3_Var("hDoc")
	StaA := HPDF_SaveToFile(hDoc, PDFSavePath)
	HPDF_Free(hDoc)
	HPDF_UnloadDLL(K3_Var("hDll")) ;unload dll
	K3_Var("hDoc", "")
	K3_TmpFileList("DelFoxFiles") ; 删除列表中临时文件
	If ( StaA != 0 ) ; 生成错误，返回1
		return, 1
}

K3_PDFGetFont(FontNameorPath="C:\WINDOWS\Fonts\simhei.ttf")
{
	hDoc := K3_Var("hDoc")
	If instr(FontNameorPath, "\")
	{ ; 内嵌字体
		SplitPath, FontNameorPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
		If ( OutExtension = "ttc" )
			font_name := HPDF_LoadTTFontFromFile2(hDoc, FontNameorPath, 0, 1)  ; 内嵌字体 ; simsun.ttc
		else
			font_name := HPDF_LoadTTFontFromFile(hDoc, FontNameorPath, 1)  ; 内嵌字体 ; simhei.ttf simkai.ttf simfang.ttf 

		hCNFont := HPDF_GetFont2(hDoc,font_name, "GBK-EUC-H") ; 中文编码: GBK-EUC-H ETen-B5-H  英文编码: WinAnsiEncoding CP1252 [FontSpecific]
		hENFont := HPDF_GetFont2(hDoc,font_name, "WinAnsiEncoding") ; 中文编码: GBK-EUC-H ETen-B5-H  英文编码: WinAnsiEncoding CP1252 [FontSpecific]
		K3_Var("hCNFont", hCNFont) , K3_Var("hENFont", hENFont)
		return, hCNFont
	} else { ; 非内嵌字体
		HPDF_UseCNSFonts(hDoc)
		hFont := HPDF_GetFont(hDoc, FontNameorPath, "GBK-EUC-H") ; SimSun , SimHei , SimKai ; 非内置
		return, hFont
	}
}

K3_PDFAddOutLine(hPage, OutLineText="名称", hOutLineRoot=0)
{	; 添加左侧索引栏
	hDoc := K3_Var("hDoc")
	NowEncoder := HPDF_GetEncoder(hDoc, "GBK-EUC-H")
	hOutLine := HPDF_CreateOutline(hDoc, hOutLineRoot, OutLineText, NowEncoder)
	hDest := HPDF_Page_CreateDestination(hPage)
	HPDF_Outline_SetDestination(hOutLine, hDest)
}

K3_PDFIndex(PageCount, PageType="文", PageTitle="木有标题")
{	; 在PDF尾部添加 目录页
	static LastNum, IndexContent
	If ( PageCount = -5 )  ; 清空内容
		LastNum := "" , IndexContent := ""
	If ( PageCount = -9 ) ; 返回列表
		return, IndexContent
	If ( PageCount > 0 ) { ; 添加列表
		If ( LastNum = "" )
			LastNum := 1
		NumText := "     " . LastNum
		StringRight, NumText, NumText, 4  ; 间隔宽度
		IndexContent .= PageType . NumText . "  " . PageTitle . "`n"
		LastNum += PageCount
	}
}
/*	; 使用例子
	K3_PDFIndex(-5, "文", "清空列表")
	K3_PDFIndex(5, "文", "第1章 xxxxxxxxxx")
	K3_PDFIndex(4, "图", "第2章 oooooooooo")
	K3_PDFIndex(1, "★", "偶是目录页")
	msgbox, % K3_PDFIndex(-9, "文", "返回列表")
*/

K3_PDFAddMixTextPage(Title="", byref sContent="", PageWidth=260, PageHeight=335, PageSpace=5, FontSize=9, LineSpace=13.5, TitleFontSize=12)
{	; 添加标题，正文，中英混合页
	hDoc := K3_Var("hDoc")
	YeCount := K3_Var("YeCount")
	++YeCount
	K3_Var("YeCount", YeCount)
	K3_Msg("AddMsg", YeCount)

	hStartPage := hPage := HPDF_AddPage(hDoc) , HPDF_Page_SetWidth(hPage, PageWidth) , HPDF_Page_SetHeight(hPage, PageHeight)
	If ( Title = "" ) ; 标题为空时
		TitleFontSize := 0
	else 
		K3_PDFShowMixLineAtYRange(hPage, Title, 1, PageHeight-PageSpace, PageHeight-PageSpace-TitleFontSize, PageWidth, PageHeight, PageSpace, TitleFontSize, TitleFontSize*1.5, "居中")

	If ( sContent = "" ) ; 标题行时
		return, 0
	startPos := 1 , alllen := StrLen(sContent)
	aa := K3_PDFShowMixLineAtYRange(hPage, sContent, startPos, PageHeight-PageSpace-TitleFontSize, PageSpace, PageWidth, PageHeight, PageSpace, FontSize, LineSpace, "居左")
	while ( startPos := startPos + aa ) <= alllen
	{
		++YeCount
		K3_Var("YeCount", YeCount)
		K3_Msg("AddMsg", YeCount)
		hPage := HPDF_AddPage(hDoc) , HPDF_Page_SetWidth(hPage, PageWidth) , HPDF_Page_SetHeight(hPage, PageHeight)
		aa := K3_PDFShowMixLineAtYRange(hPage, sContent, startPos, PageHeight-PageSpace, PageSpace, PageWidth, PageHeight, PageSpace, FontSize, LineSpace, "居左")
	}
	return, hStartPage
}

K3_PDFShowMixLineAtYRange(hPage, byref SrcStr, StartStrPos=1, YTop=330, YBottom=5, PageWidth=260, PageHeight=335, PageSpace=5, FontSize=9, LineSpace=13.5, Align="居左")
{	; 在纵向坐标范围内显示中英混合字符串
	hCNFont := K3_Var("hCNFont") , hENFont := K3_Var("hENFont")
	MarkStartStrPos := StartStrPos
	MaxEnCharNum := Floor((2 * PageWidth - 4 * PageSpace)/FontSize) ; 最大行英文字符数，假定中文宽度为字体大小，英文宽度为0.5字体大小
	TextRange := YTop - YBottom , MaxLineNum := Floor(TextRange/FontSize) ; 最大列数

	HPDF_Page_BeginText(hPage) ; 开始输出

	If ( MaxLineNum <= 1 ) { ; 单行显示
		If ( MaxEnCharNum < ( OneLineStrLen := StrLen(SrcStr) ) )
			OneLineStrLen := MaxEnCharNum
		If ( Align = "居左" )
			HPDF_Page_MoveTextPos(hPage, PageSpace, Ytop - FontSize)
		If ( Align = "居中" )
			HPDF_Page_MoveTextPos(hPage, PageWidth/2-OneLineStrLen*FontSize/4, Ytop - FontSize)
		If ( Align = "居右" )
			HPDF_Page_MoveTextPos(hPage, PageWidth-OneLineStrLen*FontSize/2-PageSpace, Ytop - FontSize)
		isNeedNewLine := 0
	} else { ; 多行显示
		TrueMaxLineNum := Floor(TextRange/LineSpace)
		HPDF_Page_MoveTextPos(hPage, PageSpace, YTop)
		isNeedNewLine := 1
	}

	LineCount := 0 , NowLineEnCharNum := 0
	loop { ; 行
		If isNeedNewLine
			HPDF_Page_MoveTextPos(hPage, 0, -LineSpace)
		loop { ; 字符
			NowAscii := Asc(NowChar := SubStr(SrcStr, StartStrPos, 1)) ; 取一个字符
			If ( NowAscii > 128 ) { ; 中文
				If ( NowLineEnCharNum + 2 <= MaxEnCharNum ) {
					HPDF_Page_SetFontAndSize(hPage, hCNFont, FontSize)
					, HPDF_Page_ShowText(hPage, SubStr(SrcStr, StartStrPos, 2))
					StartStrPos += 2 , NowLineEnCharNum += 2
					isNeedNewLine := 0
				} else
					isNeedNewLine := 1
			} else { ; 英文
				If ( NowLineEnCharNum + 1 <= MaxEnCharNum ) {
					If ( NowAscii != 10 And NowAscii != 13 ) { ; 非回车换行符
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
		} ; 字符结束
		++LineCount
		If ( MaxLineNum <= 1 or LineCount >= TrueMaxLineNum ) ; 单行显示
			break
	} ; 行结束

	HPDF_Page_EndText(hPage) ; 结束输出
	return, StartStrPos - MarkStartStrPos
}

K3_PDFAddPicPage(PicPath, iw=0, ih=0, GifTitle="") ; 支持PNG 和 JPG/JPEG, 其他格式转换为png
{	; HPDF: 添加图片页
	hDoc := K3_Var("hDoc")
	SplitPath, PicPath, OutFileName, OutDir, fExt, OutNameNoExt, OutDrive

		FreeImage_FoxInit(True) ; Load Dll
	hFImage := FreeImage_Load(PicPath) ; load image 载入图像
	FreeImage_FoxPalleteIndex70White(hFImage) ; Fox:将索引透明Gif调色板颜色替换为白色
	FreeImage_SetTransparent(hFImage, 0)

	hMemory := FreeImage_OpenMemory(0, 0)
	FreeImage_SaveToMemory(13, hFImage, hMemory, 0) ; 转换到PNG, 并写入内存
	FreeImage_AcquireMemory(hMemory, BufAdr, BufSize)
	FreeImage_UnLoad(hFImage) ; Unload Image 释放句柄
	
	hImage := HPDF_LoadPngImageFromMem(hDoc, BufAdr, BufSize)
	FreeImage_CloseMemory(hMemory)
		FreeImage_FoxInit(False) ; Unload Dll
	If ( iw = 0 or ih = 0 )
		iw := HPDF_Image_GetWidth(hImage) , ih := HPDF_Image_GetHeight(hImage)
	return, K3_PDFShowPicInPages(hImage, iW, iH, GifTitle)
}
/*
old_K3_PDFAddPicPage(PicPath, iw=0, ih=0, GifTitle="") ; 支持PNG 和 JPG/JPEG, 其他格式转换为png
{	; HPDF: 添加图片页
	hDoc := K3_Var("hDoc")
	SplitPath, PicPath, OutFileName, OutDir, fExt, OutNameNoExt, OutDrive
	If ( fExt != "jpg" And fExt != "jpeg" And fExt != "png" ) { ; 非jpg/png格式，转化为png格式
		OutExt := "png"
		TmpPicPath := "C:\" . OutNameNoExt . "_FoxTmp." . OutExt
		TmpPicPath := K3_PicConvert(PicPath, TmpPicPath)
		K3_TmpFileList(TmpPicPath) ; 添加临时文件列表
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

K3_PDFShowPicInPages(hImage, iW=0, iH=0, GifTitle="第xxx章 哈哈")
{	; 分割显示PNG，需先定义字体
	YeCount := K3_Var("YeCount")
	hDoc := K3_Var("hDoc")
	iW := iW * 0.75 , iH := iH * 0.75
	iHead := 30 , iSpace := 20 * 0.75 , iK3GifMax := 4650 * 0.75 ; 宽度分类处理 If ( ImgWidth = 700 ) ThePoint := 4650 else ThePoint := 4500


	nPage := Ceil(iH / (iK3GifMax - iHead - iSpace)) ; 页数
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
			K3_PDFShowMixLineAtYRange(hPage, GifTitle, 1, iFirst-5, iFirst-25, iW, iFirst, 5, 20, 20*1.5, "居中")
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
{	; 索引GIF -> PNG, JPG不转换
	static IrfanViewPath
	If ( Mode = "GdIPs" or Mode = "GDIPc" ) { ; s: 简单 c: 复杂
		pToken := Gdip_Startup()
		pBitmap := Gdip_CreateBitmapFromFile(SrcPath)
		If ( Mode = "GdIPc" ) {
			pBitmapAlpha := pBitmap
			ImgWidth := Gdip_GetImageWidth(pBitmapAlpha) , ImgHeight := Gdip_GetImageHeight(pBitmapAlpha)
			pBitmap := Gdip_CreateBitmap(ImgWidth, imgheight) , G1 := Gdip_GraphicsFromImage(pBitmap) ; 创建新BitMap
			Gdip_GraphicsClear(G1, 0xFFFFFFFF) ; 背景填充
			Gdip_DrawImage(G1, pBitmapAlpha, 0, 0, ImgWidth, imgheight, 0, 0, ImgWidth, imgheight, 1) ; 新BitMap使用原图填充
			Gdip_DisposeImage(pBitmapAlpha), Gdip_DeleteGraphics(G1)
		}
		Gdip_SaveBitmapToFile(pBitmap, TarPath) , Gdip_DisposeImage(pBitmap)
		Gdip_Shutdown(pToken)
		return, TarPath
	}
	If ( Mode = "Irfan" ) {
		If ( IrfanViewPath = "" )
			IrfanViewPath := K3_GetPath(":\bin\IrfanView\i_view32.exe")
;		IniWrite, 1, i_view32.ini, MultiGIF, UseSingleTrans  ; 透明，这两个值使透明gif背景变白
;		IniWrite, 16777215, i_view32.ini, Viewing, BackColor ; 背景白色
		runwait, %IrfanViewPath% "%SrcPath%" /convert="%TarPath%", %A_scriptdir%, Hide
		return, TarPath
	}
	If ( Mode = "gif2png" ) {
		runwait, gif2png.exe -b FFFFFF %SrcPath%, %A_scriptdir%, Hide
		SplitPath, SrcPath, OutFileName, OutDir, OutExt, OutNameNoExt, OutDrive
		IfExist, %OutDir%\%OutNameNoExt%.png            ; 对于某些GIF它处理不了，会出错，虽然可以加入-r参数修复，不过效果不好
			return, OutDir . "\" . OutNameNoExt . ".png"
		else
			Mode := "FreeImage"
	}
	If ( Mode = "FreeImage" ) {
		FreeImage_FoxInit(True) ; Load Dll
		hImage := FreeImage_Load(SrcPath) ; load image 载入图像
		FreeImage_FoxPalleteIndex70White(hImage) ; Fox:将索引透明Gif调色板颜色替换为白色
		FreeImage_SetTransparent(hImage, 0)
		FreeImage_Save(hImage, TarPath) ; Save Image 写入图像
		FreeImage_UnLoad(hImage) ; Unload Image 释放句柄
		FreeImage_FoxInit(False) ; Unload Dll
		return, TarPath
	}
}


K3_TmpFileList(TmpFilePath="") ; 添加，删除临时文件列表
{
	static TmpFileList := ""
	If ( TmpFilePath = "DelFoxFiles" ) { ; 当参数为 DelFoxFiles 时，删除列表中的文件，并清空列表
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


; {----------------------K3 Mobi 文件处理
/*
	K3_MobiCreateNCX("AddItem", "xxxxx.htm#toc", "目录", "toc") ; SrcURL[,text,ID]
	K3_MobiCreateNCX("AddItem", "xxxxx.htm#vol1", "第一章", "vol1") ; SrcURL[,text,ID]
	K3_MobiCreateNCX("AddItem", "xxxxx.htm#vol2", "第二章", "vol2") ; SrcURL[,text,ID]
	K3_MobiCreateNCX("Create", "C:\xxxxx.ncx", "人生的起点与终点") ; SavePath[,bookname]
	; ---------------------
	K3_MobiCreateOPF("TOCName", "FoxIndex") ; 可省略
	K3_MobiCreateOPF("BookName", "人生的起点和终点")
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

; MarkedStr 是由 qidian_txt2xml 生成的 XML，上面那个就是从xml中取出单元的函数
K3_ProcessChapter2Mobi(Byref MarkedStr, StartPartNum=1, OutFileDir="")
{	; 处理起点多余章节并生成Mobi(单)
	TOCName := "FoxIndex"
	MainHTMLName := TOCName . ".htm" , NCXName := TOCName . ".ncx"
	OutMainHTMLPath :=  OutFileDir . "\" . MainHTMLName , OutNCXPath :=  OutFileDir . "\" . NCXName

	NowBookName := K3_getQidianXMLPart(MarkedStr, "BookName")
	NowAuthor := K3_getQidianXMLPart(MarkedStr, "AuthorName")
	NowQidianID := K3_getQidianXMLPart(MarkedStr, "QidianID")
	AllPartCount := K3_getQidianXMLPart(MarkedStr, "PartCount")
	if ( 0 = StartPartNum ) { ; 命令行模式
		OutOPFPath := OutFileDir . "\qidiantxt.opf"
	} else {
		OutOPFPath := OutFileDir . "\" . NowBookName . ".opf"
	}

	; HTML 头部
	NewHead = 
	(join`n Ltrim
	<html><head>
	<meta http-equiv=Content-Type content="text/html; charset=utf-8">
	<style type="text/css">h2,h3,h4{text-align:center;}</style>
	<title>%NowBookName%</title></head><body>
	<a id="toc"></a>`n`n<h3>%NowBookName%</h3>`n作者: %NowAuthor%  书号: %NowQidianID%<br><br>`n`n
	)
	NewTail .= "</body></html>`n"

	K3_MobiCreateNCX("AddItem", MainHTMLName . "#toc", "目录", "toc")
	loop, % AllPartCount - StartPartNum + 1
	{
		NowPartNum := StartPartNum + A_index - 1
		NowTitle := K3_getQidianXMLPart(MarkedStr, "Title" . NowPartNum) , NowPart := K3_getQidianXMLPart(MarkedStr, "Part" . NowPartNum)
		K3_Msg("AddMsg", "生成Mobi HTM 章: " . NowPartNum . " / " . AllPartCount)
		Stringreplace, NowPart, NowPart, `n, <br>`n, A

		K3_MobiCreateNCX("AddItem", MainHTMLName . "#" . NowPartNum, NowTitle, NowPartNum)
		NewTOC .= "<a href=""#" . NowPartNum . """>" . NowTitle . "</a><br>`n"
		NewTxt .= "<a id=""" . NowPartNum . """></a>`n`n<h4>" . NowTitle . "</h4>`n" . NowPart . "`n<mbp:pagebreak/>`n`n"
	}

	UTF8NR := GeneralA_Ansi2UTF8(NewHead . NewTOC . "`n<mbp:pagebreak/>`n`n<a id=""content""></a>`n`n" . NewTxt . NewTail)
	K3_Msg("AddMsg", "生成Mobi文件: " . NowBookName)

	FileAppend, %UTF8NR%, %OutMainHTMLPath%              ; 本文件名需和foxopf变量中文件名一致
	K3_MobiCreateNCX("Create", OutNCXPath, NowBookName, NowAuthor)

	K3_MobiCreateOPF("TOCName", TOCName) ; 可省略
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
{	 ; NCX文件说明: 可省略:docTitle, docAuthor, Item中ID可省略, Name必须有内容，重复无所谓, Playorder和Src是必须的
	static NCXNR := "" , ShowNum := 0
	; { ----- AddItem
	If ( Action = "AddItem" ) {
		If ( ArgB = "" )
			ArgB := "Fox" ; 默认文字
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

K3_MobiCreateOPF(Action="AddItem", iStrA="") { ; 默认 FoxIndex.htm#[content|toc] FoxIndex.ncx
	static TOCName := "FoxIndex" , BookName := "★无名书★", AuthorName := "爱尔兰之狐" , SpineHead := "<spine>" , ItemNCX := "" , FoxManifest := "`n" , FoxSpine := "`n" , ItemCount := 10

	If ( Action = "TOCName" ) ; FoxIndex.htm, FoxIndex.ncx
		TOCName := iStrA
	If ( Action = "BookName" )
		BookName := iStrA
	If ( Action = "Author" )
		AuthorName := iStrA
	If ( Action = "HasNCX" ) { ; 默认NCX ID 为 FoxNCX
		SpineHead := "<spine toc=""FoxNCX"">"
		ItemNCX := "`t<item id=""FoxNCX"" media-type=""application/x-dtbncx+xml"" href=""" . TOCName . ".ncx""/>"
	}
	If ( Action = "AddItem" ) {
		++ItemCount
		FoxManifest .= "`t<item id=""Fox" . ItemCount . """ media-type=""application/xhtml+xml"" href=""" . iStrA . """/>`n"
		FoxSpine .= "`t<itemref idref=""Fox" . ItemCount . """/>`n"
	}
	; { ----- Create
	If ( Action = "Create" ) { ; ["Create",BookName,正文地址,目录地址,输出文件路径]
		FoxNowUUID := General_UUID() ; 生成时间唯一的ID
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
			`t<reference type="text" title="正文" href="%TOCName%.htm#content"/>
			`t<reference type="toc" title="目录" href="%TOCName%.htm#toc"/>
		</guide>`n</package>`n`n
		)
		IfExist, %iStrA%
			FileMove, %iStrA%, %iStrA%.%A_now%
		Fileappend, % GeneralA_Ansi2UTF8(XML), %iStrA%
		TOCName := "FoxIndex" , BookName := "★无名书★" , SpineHead := "<spine>" , ItemNCX := "" , FoxManifest := "`n" , FoxSpine := "`n" , ItemCount := 10
	}
	; } ----- Create
}

; }----------------------K3 Mobi 文件处理

; {----------------------K3 UMD 文件处理
K3_UMD(Action="Add", iStrA="", iStrB="")
{	; 依赖 umd.dll zlib.dll http://code.google.com/p/umd-builder/
	static hModule , hUMD , UMDDllPath
	If ( UMDDllPath = "" )
		UMDDllPath := K3_GetPath("D:\bin\bin32\umd.dll")
	If ( Action = "New" ) {
		hModule := DllCall("LoadLibrary", "Str", UMDDllPath)
		hUMD := Dllcall("umd\umd_create", "Uint", 0)
		; 2:标题 3:作者 4:出版年份 5:出版月份 6:出版日子 7:书籍种类 8:出版人 9:销售人
		Dllcall("umd\umd_set_field_a", "Uint", hUMD, "Uint", 2, "str", iStrA)
		Dllcall("umd\umd_set_field_a", "Uint", hUMD, "Uint", 8, "str", "爱尔兰之狐")
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
; }----------------------K3 UMD 文件处理

; ------------------自写函数

K3_GetPath(FilePath="D:\etc\RamOSFiles.exe", FoxDrives="CD")
{	; 测试文件存在否
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

K3_Var(iName="", iStr="get") ; iName 为static变量去掉s的部分, iStr 默认为get，也可为设置的值
{
	static shDll, shDoc, shCNFont, shENFont, sYeCount
	If ( iStr = "get" )
		return, s%iName%
	else
		s%iName% := iStr
}

