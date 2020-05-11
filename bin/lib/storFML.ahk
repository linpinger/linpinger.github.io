; ahk L∞Ê

; loadFML(FMLPath)
; saveFML(shelf, savePath)
; loadCookie(cookieXMLPath)

; shelf[].name  shelf[].pages[].url
loadFML(FMLPath)
{
	shelf := []
	FileRead, fml, *P65001 %FMLPath%	

	bPos := 0
	while ( bPos := RegExMatch(fml, "smUi)<novel>.*</novel>", bookStr, 1 + bPos) ) {
		; bookname bookurl delurl statu qidianBookID author
		book := {}
		book.bookname   := getValue(bookStr, "bookname")
		book.bookurl    := getValue(bookStr, "bookurl")
		book.delurl := getValue(bookStr, "delurl")
		book.statu  := getValue(bookStr, "statu")
		book.qidianBookID   := getValue(bookStr, "qidianBookID")
		book.author := getValue(bookStr, "author")

		pages := []
		pPos := 0
		while ( pPos := RegExMatch(bookStr, "smUi)<page>.*</page>", pageStr, 1 + pPos) ) {
			; pagename pageurl content size
			page := {}
			page.pagename    := getValue(pageStr, "pagename")
			page.pageurl     := getValue(pageStr, "pageurl")
			page.size    := getValue(pageStr, "size")
			page.content := getValue(pageStr, "content")
			pages.Push(page)
;			pages.Insert(page)
		}
		book.chapters := pages
		shelf.Push(book)
;		shelf.Insert(book)
	}
	return shelf
}

saveFML(shelf, savePath) {
	FML := "<?xml version=""1.0"" encoding=""utf-8""?>`n`n<shelf>`n`n"
	for i, book in shelf
	{
		bookStr := "<novel>`n"
		bookStr .= "`t<bookname>" . book.bookname . "</bookname>`n"
		bookStr .= "`t<bookurl>" . book.bookurl . "</bookurl>`n"
		bookStr .= "`t<delurl>" . book.delurl . "</delurl>`n"
		bookStr .= "`t<statu>" . book.statu . "</statu>`n"
		bookStr .= "`t<qidianBookID>" . book.qidianBookID . "</qidianBookID>`n"
		bookStr .= "`t<author>" . book.author . "</author>`n"
		bookStr .= "<chapters>`n"
		for j, page in book.chapters
		{
			pageStr := "<page>`n"
			pageStr .= "`t<pagename>" . page.pagename . "</pagename>`n"
			pageStr .= "`t<pageurl>" . page.pageurl . "</pageurl>`n"
			pageStr .= "`t<content>" . page.content . "</content>`n"
			pageStr .= "`t<size>" . page.size . "</size>`n"
			pageStr .= "</page>`n"
			bookStr .= pageStr
		}
		bookStr .= "</chapters>`n</novel>`n"

		FML .= bookStr . "`n"
	}
	FML .= "</shelf>`n"
	FileMove, %savePath%, %savePath%.old, 1
	fileappend, %FML%, *%savePath%, UTF-8-RAW
}

loadCookie(cookieXMLPath="D:\bin\sqlite\FoxBook\FoxBook.cookie")
{
	FileRead, xml, *P65001 %cookieXMLPath%	

	sList := [] ; ±Í«©¡–±Ì
	bPos := 0
	while ( bPos := RegExMatch(xml, "smUi)<([a-z0-9]+)>", mStr, 1 + bPos) ) {
		if ( mStr != "<cookies>" )
			sList.Push(mStr1)
	}

	cookie := {}
	for i, kName in sList
		cookie[kName] := getValue(xml, kName)
	return cookie
}

getValue(str, key="bookname") {
	RegExMatch(str, "smUi)<" . key . ">(.*)</" . key . ">", ff_)
	return ff_1
}

