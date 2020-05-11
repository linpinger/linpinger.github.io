; 2017-1-13 �ʺ� L ��AHK��������qidian.ahk��λ��ͬ����������ԭ�漰L��ʹ��
; �汾����: Desk7 Android7 Touch7
/*
qidianL_getTOC_Desk7(html="") ; ����: [{pageurl, pagename}] pageurl����: ; http://read.qidian.com/chapter/k8Ysqe1aqVAVDwQbBL_r1g2/LwKggaUrMLi2uJcMpdsVgA2
qidianL_getTOC_Android7(json="") ; ����: [{pageurl, pagename}]
qidianL_getTOC_Touch7(html) ; ����: [{pageurl, pagename}] ; pageURL Ϊ QidianPageID
*/

qidianL_getTOC_Desk7(html="") ; ����: [{pageurl, pagename}] pageurl����: ; http://read.qidian.com/chapter/k8Ysqe1aqVAVDwQbBL_r1g2/LwKggaUrMLi2uJcMpdsVgA2
{
	rLinkList := []
	bPos := 0
	while ( bPos := RegExMatch(html, "smUi)<a href=""(//read.qidian.com/[^""]+)"".*>([^<]+)</a>", bookStr, 1 + bPos) ) {
		if ( "" != bookStr1 ) {
			rLinkList.Push( { "pageurl": "http:" . bookStr1, "pagename": bookStr2 } )
			bookStr := "" , bookStr1 := "" , bookStr2 := ""
		}
	}
	return, rLinkList
}

qidianL_getTOC_Android7(json="") ; ����: [{pageurl, pagename}]
{
	StringReplace, json,json, `r,,A
	StringReplace, json,json, `n,,A
	StringReplace, json,json, {,`n{,A
	StringReplace, json,json, },}`n,A
	bid_1 := 0
	regexmatch(json, "i)""BookId"":([0-9]+),", bid_) ; ��ȡbookid
;	urlHead := "http://files.qidian.com/Author" . ( 1 + mod(bid_1, 8) ) . "/" . bid_1 . "/" ; . pageid . ".txt"
	urlHead := "GetContent?BookId=" . bid_1 . "&ChapterId=" ; . pageid
	RE = i)"c":([0-9]+),"n":"([^"]+)".*"v":([01]),

	rLinkList := []
	loop, parse, json, `n, `r
	{
		xx_1 := "", xx_2 := "", xx_3 := ""
		regexmatch(A_LoopField, RE, xx_)
		if( xx_1 = "" )
			continue
		if ( "1" = xx_3 )
			break
		rLinkList.Push( { "pageurl": urlHead . xx_1, "pagename": xx_2 } )
	}
	return, rLinkList
}

qidianL_getTOC_Touch7(html) ; ����: [{pageurl, pagename}] ; pageURL Ϊ QidianPageID
{
	RegExMatch(html, "smUi)g_data.volumes(.*)</script>", xx_) ; ����Ϊjson��ʽ
	rLinkList := []
	iPos := 0
	while ( iPos := RegExMatch(xx_, "smUi).*""cN"":""([^""]+)""[^\{\}]*""id"":([0-9]+),[^\{\}]*\}", itemStr, 1 + iPos) ) {
		if ( instr(itemStr, """sS"":1") ) { ; ֻ���ع����½�
			rLinkList.Push( { "pageurl": itemStr2, "pagename": itemStr1 } )
			itemStr := "" , itemStr1 := "" , itemStr2 := ""
		}
	}
	return, rLinkList
}

qidianL_getTOC_Touch7_Ajax(jsonStr) ; ����: [{pageurl, pagename}]
{
	; ,"bookId":"1016094175",
	regexmatch(jsonStr, "i)""bookId"":""([0-9]+)"",", bid_) ; ��ȡbookID := bid_1

	rLinkList := []
	iPos := 0
	while ( iPos := RegExMatch(jsonStr, "smUi)\{[^\{\}]*""cN"":""([^""]+)"".*""id"":([0-9]+),""sS"":[01]", itemStr, 1 + iPos) ) {
		if ( instr(itemStr, """sS"":1") ) { ; ֻ���ع����½�
			pageURL := "https://m.qidian.com/majax/chapter/getChapterInfo?bookId=" . bid_1 . "&chapterId=" . itemStr2
			rLinkList.Push( { "pageurl": pageURL, "pagename": itemStr1 } )
			itemStr := "" , itemStr1 := "" , itemStr2 := "", pageURL := ""
		}
	}
	return, rLinkList
}

; {"uuid":1,"cN":"001�Ϳ˵����","uT":"2019-09-06  14:05","cnt":2089,"cU":"","id":491020997,"sS":1},
; {"uuid":126,"cN":"��125�� �����ӵ�������ҽ","uT":"2019-10-18  12:12","cnt":3142,"cU":"","id":498495980,"sS":0},
; reLink, _ := regexp.Compile("(?mi)\"cN\":\"([^\"]+)\".*?\"id\":([0-9]+).*?\"sS\":([01])")

