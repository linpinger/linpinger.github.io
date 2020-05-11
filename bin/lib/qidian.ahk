; Ver: 2019-11-18 ; 目前适合所有版本的AHK
; 版本区分: Desk[67][_Ajax] Android7 Touch[67][_Ajax]
/*
qidian_getTOCURL_Desk7(bookid)
qidian_getTOCURL_Android7(bookid)
qidian_getTOCURL_Touch7(bookid)

; qidian_getContentURL_Desk6(pageid, bookid) ; 返回页面内容JS地址
qidian_getContentURL_Desk7_Ajax(pageid, bookid, authorid)
qidian_getContentURL_Android7(pageid, bookid) ; 返回页面内容JSon地址
qidian_getContentURL_Touch7(pageid, bookid)
qidian_getContentURL_Touch7_Ajax(pageid, bookid)

qidian_getContent_Desk6(jsStr="")
qidian_getContent_Desk7_Ajax(json="")
qidian_getContent_Android7(json="")
qidian_getContent_Touch7(html="") ; html中包含两份内容，可使用 qidian_getContent_Desk7_Ajax(html) 替代本函数
qidian_getContent_Touch7_Ajax(json="") ; 和 qidian_getContent_Desk7_Ajax一样

qidian_getBookID_FromURL(iURL="") ; 分析URL得到bookid

qidian_getBookInfoURL_Android7(bookid)

qidian_getSearchURL_Android7(utf8encodedbookname="") ; 返回: 搜索地址 参数:utf8经过encode后的编码
qidian_getSearchURL_Touch6(utf8encodedbookname="") ; 模拟手机浏览器浏览m.qidian.com得到的搜索地址,返回的是json
qidian_getSearchURL_Touch7(utf8encodedbookname="")
*/

; http://download.qidian.com/epub/1011924365.epub    ; + gzip head @ 2019-11-18

; bookid: 1939238
; return: http://book.qidian.com/info/1939238
qidian_getTOCURL_Desk7(bookid)
{
	return, "https://book.qidian.com/info/" . bookid
;	return, "http://read.qidian.com/BookReader/" . bookid . ".aspx"  ; 旧版地址
}
qidian_getTOCURL_Android7(bookid) ; bookid: 1939238 ; return: Android目录地址
{
	return, "http://druid.if.qidian.com/Atom.axd/Api/Book/GetChapterList?BookId=" . bookid . "&timeStamp=0&requestSource=0&md5Signature="
}
qidian_getTOCURL_Touch7(bookid)
{
	return, "https://m.qidian.com/book/" . bookid "/catalog"
}
qidian_getTOCURL_Touch7_Ajax(bookid) {
	return, "https://m.qidian.com/majax/book/category?bookId=" . bookid
	; https://m.qidian.com/majax/chapter/getAllFreeChapterList?bookId=1015209014     free page ids
	; https://m.qidian.com/majax/chapter/getFreeContentMulti
	; {"bookId":1015209014,"chapters":[462379605,462636481,462753627,462803131,462861268,462871451,462916356,463118304,463149196,463149344]}
}
qidian_getTOCURL_Desk7_Ajax(bookid)
{
	return, "https://read.qidian.com/ajax/book/category?bookId=" . bookid
}

; pageid: 53927617
; bookid: 1939238
; return: http://files.qidian.com/Author7/1939238/53927617.txt
; qidian_getContentURL_Desk6(pageid, bookid) ; 返回页面内容JS地址
; {
; 	return, "http://files.qidian.com/Author" . ( 1 + mod(bookid, 8) ) . "/" . bookid . "/" . pageid . ".txt"
; }
qidian_getContentURL_Desk7_Ajax(pageid, bookid, authorid)
{
	return, "https://read.qidian.com/ajax/chapter/chapterInfo?bookId=" . bookid . "&chapterId=" . pageid . "&authorId=" . authorid
}
qidian_getContentURL_Android7(pageid, bookid) ; 返回页面内容JSon地址
{
	return, "http://druid.if.qidian.com/Atom.axd/Api/Book/GetContent?BookId=" . bookid . "&ChapterId=" . pageid
}
qidian_getContentURL_Touch7(pageid, bookid)
{
	return, "https://m.qidian.com/book/" . bookid . "/" . pageid
}
qidian_getContentURL_Touch7_Ajax(pageid, bookid)
{
	return, "https://m.qidian.com/majax/chapter/getChapterInfo?bookId=" . bookid . "&chapterId=" . pageid
}

; jsStr: http://files.qidian.com/Author7/1939238/53927617.txt 中的内容
; return: 文本，可直接写入数据库
qidian_getContent_Desk6(jsStr="")
{
	stringreplace, jsStr, jsStr, &lt`;, <, A
	stringreplace, jsStr, jsStr, &gt`;, >, A
	stringreplace, jsStr, jsStr, document.write(', , A
	stringreplace, jsStr, jsStr, <a>手机用户请到m.qidian.com阅读。</a>, , A
	stringreplace, jsStr, jsStr, <a href=http://www.qidian.com>起点中文网www.qidian.com欢迎广大书友光临阅读，最新、最快、最火的连载作品尽在起点原创！</a>, , A
	stringreplace, jsStr, jsStr, <a href=http://www.qidian.com>起点中文网 www.qidian.com 欢迎广大书友光临阅读，最新、最快、最火的连载作品尽在起点原创！</a>, , A
	stringreplace, jsStr, jsStr, ')`;, , A
	stringreplace, jsStr, jsStr, <p>, `n, A
	stringreplace, jsStr, jsStr, 　　, , A
	return, jsStr
}

qidian_getContent_Desk7_Ajax(json="")
{
	retStr := ""
	RegExMatch(json, "smUi)""content"":""(.+)"",", xx_)
	if ( xx_1 != "" )
		retStr := xx_1
	else
		retStr := json
	StringReplace, retStr, retStr, <p>, `n, A
	StringReplace, retStr, retStr, 　　, , A
	return, retStr
}
qidian_getContent_Android7(json="")
{
	retStr := ""
	RegExMatch(json, "smUi)""Data"":""(.+)""", xx_)
	if ( xx_1 != "" )
		retStr := xx_1
	else
		retStr := json
	StringReplace, retStr, retStr, \r\n, `n, A
	StringReplace, retStr, retStr, 　　, , A
	return, retStr
}
qidian_getContent_Touch7(html="") ; html中包含两份内容，可使用 qidian_getContent_Desk7_Ajax(html) 替代本函数
{
	RegExMatch(html, "smUi)</h3>[ `r`n]*(.*)[ `r`n]*</section>", xx_)
	StringReplace, xx_1, xx_1, <p>, `n, A
	StringReplace, xx_1, xx_1, 　　, , A
	return, xx_1
}
qidian_getContent_Touch7_Ajax(json="") ; 和 qidian_getContent_Desk7_Ajax一样
{
	return, qidian_getContent_Desk7_Ajax(json)
}


; iURL: 3059077 | http://book.qidian.com/info/1003439264
; return: 3059077
qidian_getBookID_FromURL(iURL="") ; 分析URL得到bookid
{
	if ( instr(iURL, "http") ) {
		qd_1 := 0
		if ( instr(iURL, "book.qidian.com/info/") ) {
			RegExMatch(iURL, "i)/([0-9]+)", qd_) ; http://book.qidian.com/info/1003439264
		} else if ( instr(iURL, "m.qidian.com/book/") ) {
			RegExMatch(iURL, "i)/book/([0-9]+)/", qd_) ; m.qidian.com/book/3681640/catalog ; m.qidian.com/book/3681640/92159691
		} else if ( instr(iURL, "if.qidian.com") ) {
			RegExMatch(iURL, "i)BookID=([0-9]+)", qd_) ; http://druid.if.qidian.com/Atom.axd/Api/Book/GetChapterList?BookId=1003439264&timeStamp=0&requestSource=0&md5Signature=
		}
		QidianID := qd_1
	} else {
		if iURL is integer ; 直接就是起点数字ID
			QidianID = %iURL%
		else
			TrayTip, 错误:, 非QidianURL及QiDianID
	}
	return, QidianID
}

qidian_getBookInfoURL_Android7(bookid)
{
	return, "http://druid.if.qidian.com/Atom.axd/Api/Book/GetContent?BookId=" . bookid . "&ChapterId=-10000"
}

; utf8encodedbookname: utf8书名经encode后的字串
; return: 搜索结果地址
qidian_getSearchURL_Android7(utf8encodedbookname="") ; 返回: 搜索地址 参数:utf8经过encode后的编码
{
	return, "http://druid.if.qidian.com/druid/Api/Search/GetBookStoreWithBookList?type=-1&key=" . utf8encodedbookname
}

qidian_getSearchURL_Touch6(utf8encodedbookname="") ; 模拟手机浏览器浏览m.qidian.com得到的搜索地址,返回的是json
{
	return, "http://m.qidian.com/ajax/top.ashx?ajaxMethod=getsearchbooks&pageindex=1&pagesize=20&isvip=-1&categoryid=-1&sort=0&action=-1&key=" . utf8encodedbookname . "&site=-1&again=0&range=-1"
}
qidian_getSearchURL_Touch7(utf8encodedbookname="")
{
	return, "http://m.qidian.com/search?kw=" . utf8encodedbookname
}
; 极速版搜索地址: http://wap.m.qidian.com/search.aspx?key=%E4%B8%9C%E4%BA%AC%E9%81%93%E5%A3%AB
; http://wap.m.qidian.com/book/showbook.aspx?bookid=3347153&pageindex=2&order=desc
; http://wap.m.qidian.com/book/bookreader.aspx?bookid=3347153&chapterid=79700245&wordscnt=0

