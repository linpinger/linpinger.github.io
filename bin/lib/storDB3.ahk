; ahk L版

; loadDB3(DB3Path)
; saveDB3(shelf, savePath)

#NoEnv

; shelf[].name  shelf[].pages[].url
loadDB3(DB3Path)
{
	oDB := new SQLiteDB
	oDB.OpenDB(DB3Path)

	shelf := []

	oDB.GetTable("select ID, Name, URL, QiDianID, isEnd, DelURL from book", oRSa)
	loop, % oRSa.rowcount
	{
		; bookname bookurl delurl statu qidianBookID author
		book := {}
		book.bookname   := oRSa.rows[A_index][2]
		book.bookurl    := oRSa.rows[A_index][3]
		book.delurl     := oRSa.rows[A_index][6]
		book.qidianBookID := oRSa.rows[A_index][4]
		book.author     := "noname"
		if ( "1" = oRSa.rows[A_index][5] )
			bookStatu := 1
		else
			bookStatu := 0
		book.statu      := bookStatu

		pages := []
		SQLstr := "select Name, URL, Content from page where bookid = " . oRSa.rows[A_index][1]
		oDB.GetTable(SQLstr, oRSb)
		loop, % oRSb.rowcount
		{
			; pagename pageurl content size
			page := {}
			page.pagename := oRSb.rows[A_index][1]
			page.pageurl  := oRSb.rows[A_index][2]
			page.content  := oRSb.rows[A_index][3]
			page.size     := strlen(oRSb.rows[A_index][3])
			pages.Push(page)
;			pages.Insert(page)
		}
		book.chapters := pages
		shelf.Push(book)
;		shelf.Insert(book)
	}

	oDB.CloseDB()
	return shelf
}

saveDB3(shelf, savePath) {
	isNewDB3 := true
	ifExist, %savePath%
	{
		FileCopy, %savePath%, %savePath%.old, 1
		isNewDB3 := false
	}

	oDB := new SQLiteDB
	oDB.OpenDB(savePath)
	if ( isNewDB3 ) {
		oDB.Exec("Create Table Book (ID integer primary key, Name Text, URL text, DelURL text, DisOrder integer, isEnd integer, QiDianID text, LastModified text)")
		oDB.Exec("Create Table Page (ID integer primary key, BookID integer, Name text, URL text, CharCount integer, Content text, DisOrder integer, DownTime integer, Mark text)")
		oDB.Exec("Create Table config (ID integer primary key, Site text, ListRangeRE text, ListDelStrList text, PageRangeRE text, PageDelStrList text, cookie text)")
	} else {
		oDB.Exec("delete from page")
		oDB.GetTable("select * from book", RS)
	}

	oDB.Exec("BEGIN;")
	for i, book in shelf {
		; bookname bookurl delurl statu qidianBookID author
		bookDelURL := book.delurl
		odb.EscapeStr(bookDelURL)
		if ( isNewDB3 ) {
			odb.Exec("insert into book(name, url, delurl, isEnd, QiDianID) values( '" . book.bookname . "','" . book.bookurl . "'," . bookDelURL . "," . book.statu . "," . book.qidianBookID . " );")
			oDB.LastInsertRowID(bookid)
		} else { ; 存在DB3，更新
			bookIDX := -1 ; book在
			loop, % RS.rowcount
			{
				if ( book.bookurl = RS.rows[A_index, 3] ) {
					bookIDX := A_index
					break
				}
			}
			if ( -1 = bookIDX ) { ; DB3中不存在的书
				odb.Exec("insert into book(name, url, delurl, isEnd, QiDianID) values( '" . book.bookname . "','" . book.bookurl . "'," . bookDelURL . "," . book.statu . "," . book.qidianBookID . " );")
				oDB.LastInsertRowID(bookid)
				Continue
			}
			bookid := RS.rows[bookIDX, 1]
			odb.Exec("update book set DelURL = " . bookDelURL . " where id = " . bookid) ; 更新DelList
		}

		for j, page in book.chapters {
			; pagename pageurl content size
			pageContent := page.content
			odb.EscapeStr(pageContent)
			odb.Exec("insert into page(bookid, name, url, charcount, content, downtime, mark) values( " . bookid . ",'" . page.pagename . "','" . page.pageurl . "'," . page.size . "," . pageContent . ", 20161225122500, 'text' );")
		}
	}
	oDB.Exec("COMMIT;")
	oDB.CloseDB()
}

#include *i <SQLiteDB_Class>

