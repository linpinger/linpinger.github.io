; 2014-7-8
; L�� ���С˵��վ������

; ��ȡ���¸����б�
qreader_getupdate(aNU) ; in:[name,url]
{
	qreader_PageSpliter := "#"

	hh := {}
	PostData := "{""books"":["
	loop, % aNU.MaxIndex()
	{
		xx_1 := ""
		RegExMatch(aNU[A_index, 2], "i)bid=([0-9]+)", xx_)
		if (xx_1 = "")
			continue
		hh[xx_1] := aNU[A_index, 1]
		PostData .= "{""t"":0,""i"":" . xx_1 "},"
	}
	StringTrimRight, PostData, PostData, 1
	PostData .= "]}"
	StringReplace, PostData, PostData, ", `\", A

; {"books":[{"t":1404758734,"i":1119690},{"t":1404776764,"i":1273510},{"t":1404767792,"i":1260154}]}

	runwait, wget "http://m.qreader.me/update_books.php" --post-data="%PostData%" -O "C:\qreader_update.json", C:\, min
	fileread, iJson, C:\qreader_update.json
	filedelete, C:\qreader_update.json
	
	iJson := GeneralW_JsonuXXXX2CN(iJson)
	StringReplace, iJson, iJson, {, `n{, A

	oRet := [] ; �������ݶ���: 1:���� 2:������ 3:����URL 4: ��������
	CountRet := 0
	loop, parse, iJson, `n
	{
		; {"id":1119690,"status":0,"img":1,"catalog_t":1404758734,"chapter_c":422,"chapter_i":422,"chapter_n":"������  ʤ�ߵ�Ȩ��"}
		FF_1 := "" , FF_2 := "" , FF_3 := ""
		regexmatch(A_loopfield, "i)""id"":([0-9]+),.*""catalog_t"":([0-9]+),.*""chapter_i"":([0-9]+),""chapter_n"":""(.+)""", FF_)
		if ( FF_1 = "" )
			continue
		++CountRet
		oRet[CountRet,1] := hh[FF_1]
		oRet[CountRet,2] := FF_4
		oRet[CountRet,3] := qreader_PageSpliter . FF_3
		oRet[CountRet,4] := FF_2
	}
	return, oRet
}

; ��ȡ����ҳ
qreader_GetContent(PgURL) ; "http://m.qreader.me/query_catalog.php?bid=1119690#222"
{
	qreader_PageSpliter := "#"
	RegExMatch(PgURL, "i)bid=([0-9]+)" . qreader_PageSpliter . "([0-9]+)", xx_)
	nowBookID := xx_1
	nowPageID := xx_2

	runwait, wget "http://chapter.qreader.me/download_chapter.php" --post-data="{\"id\":%nowBookID%`,\"cid\":%nowPageID%}" -O "C:\qreader_content.json", C:\, min
	fileread, iJson, C:\qreader_content.json
	filedelete, C:\qreader_content.json

	StringReplace, iJson, iJson, ����, , A
	return, iJson
}

; ��ȡĿ¼����[url,name]
qreader_GetIndex(IdxURL) ; "http://m.qreader.me/query_catalog.php?bid=1119690"
{
	qreader_PageSpliter := "#"

	RegExMatch(idxURL, "i)bid=([0-9]+)", xx_)
	nowBookID := xx_1

	runwait, wget "http://m.qreader.me/query_catalog.php" --post-data="{\"id\":%nowBookID%}" -O "C:\qreader_Index.json", C:\, min
	fileread, iJson, C:\qreader_Index.json
	filedelete, C:\qreader_Index.json

	iJson := GeneralW_JsonuXXXX2CN(iJson)
	cc := []
	ccCount := 0
	StringReplace, iJson, iJson, {, `n{, A
	loop, parse, iJson, `n, `r
	{
		xx_1 := "" , xx_2 := ""
		RegExMatch(A_loopfield, "i)""i"":([0-9]+),""n"":""(.+)""", xx_)
		if ( "" = xx_1 )
			continue
		++ccCount
		outstr .= xx_1 . "`t" . xx_2 . "`n"
		cc[ccCount,1] := qreader_PageSpliter . xx_1
		cc[ccCount,2] := xx_2
	}
	return, cc
}

; �����鼮������url
qreader_Search(iBookName) {	; ����Ŀ¼ҳ��ַ
	uXXXX := GeneralW_CN2uXXXX(iBookName)

	runwait, wget "http://m.qreader.me/search_books.php" --post-data="{\"key\":\"%uXXXX%\"}" -O "C:\qreader_search.json", C:\, min
	fileread, iJson, C:\qreader_search.json
	filedelete, C:\qreader_search.json

	RegExMatch(iJson, "Ui)""id"":([0-9]+),", FF_)
	If ( FF_1 != "" )
		return, "http://m.qreader.me/query_catalog.php?bid=" FF_1
	else
		return, "δ�ҵ�"
}
