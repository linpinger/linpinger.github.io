; Ver: 2014-8-5
; Ŀǰ�ʺ����а汾��AHK

; iURL: http://read.qidian.com/BookReader/3059077.aspx
; return: 3059077
qidian_getBookID_FromURL(iURL="")
{
	regexmatch(iURL, "Ui)\/([0-9]{2,9})\.", II_)
	return, II_1
}

; pageInfoURL: http://read.qidian.com/BookReader/1939238,53927617.aspx
; return: http://files.qidian.com/Author7/1939238/53927617.txt
qidian_toPageURL_FromPageInfoURL(pageInfoURL)
{
	regexmatch(pageInfoURL, "i)/([0-9]+),([0-9]+)\.aspx", qidian_)
	return, qidian_getPageURL(qidian_2, qidian_1)
}

; pageInfoURL: http://free.qidian.com/Free/ReadChapter.aspx?bookId=2124315&chapterId=34828403
; return: http://files.qidian.com/Author4/2124315/34828403.txt
qidian_free_toPageURL_FromPageInfoURL(pageInfoURL)
{
	regexmatch(pageInfoURL, "i)bookId=([0-9]+)&chapterId=([0-9]+)", qidian_)
	return, qidian_getPageURL(qidian_2, qidian_1)
}

; pageid: 53927617
; bookid: 1939238
; return: http://files.qidian.com/Author7/1939238/53927617.txt
qidian_getPageURL(pageid, bookid) ; ����ҳ������JS��ַ
{
	return, "http://files.qidian.com/Author" . ( 1 + mod(bookid, 8) ) . "/" . bookid . "/" . pageid . ".txt"
}

; bookid: 1939238
; return: http://read.qidian.com/BookReader/1939238.aspx
qidian_getIndexURL_Desk(bookid)
{
	return, "http://read.qidian.com/BookReader/" . bookid . ".aspx"
}

; bookid: 1939238
; lastPageID: 0|bookid
; return: Ŀ¼��ַ
qidian_getIndexURL_Mobile(bookid, lastPageID=0) ; ����������ȡlastPageID��ĸ��£�Ϊ0��ȡ����
{
	return, "http://3g.if.qidian.com/Client/IGetBookInfo.aspx?version=2&BookId=" . bookid . "&ChapterId=" . lastPageID
}

; utf8encodedbookname: utf8������encode����ִ�
; return: ���������ַ
qidian_getSearchURL_Mobile(utf8encodedbookname="") ; ����: ������ַ ����:utf8����encode��ı���
{
	return, "http://3g.if.qidian.com/api/SearchBooksRmt.ashx?key=" . utf8encodedbookname . "&p=0"
}
; bookinfo http://3g.if.qidian.com/BookStoreAPI/GetBookDetail.ashx?BookId=3008159&preview=1

/*
; bookname: ����
; return: BookID
; �ⲿ����: GeneralW.ahk JSON_Class.ahk(����RE����) wget.exe
qidian_bookName2BookId_Mobile(bookname) ; ���ÿͻ��������ӿڵ�ַ���������ص�json������õ��鼮��Ϣ
{
	searchURL := qidian_getSearchURL_Mobile(GeneralW_UTF8_UrlEncode(GeneralW_StrToUTF8(bookname))) ; ����: ������ַ ����:utf8����encode��ı���
	; http://3g.if.qidian.com/api/SearchBooksRmt.ashx?key=%E6%88%91%E6%84%8F%E9%80%8D%E9%81%A5&p=0
	runwait, wget "%searchURL%" -O "C:\QD_MSearch.json"
	fileread, html, *P65001 c:\QD_MSearch.json
	FileDelete, C:\QD_MSearch.json
	j := JSON.parse(html)
	xx := j.Data.ListSearchBooks.MaxIndex()
	loop, %xx%
	{
		nbookname := j.Data.ListSearchBooks[A_index].BookName
		if ( nbookname = bookname ) {
			BookId := j.Data.ListSearchBooks[A_index].BookId
			break
		}
	}
	return, BookId
}
*/

qidian_getSearchURL_MobBrowser(utf8encodedbookname="") ; ģ���ֻ���������m.qidian.com�õ���������ַ,���ص���json
{
	return, "http://m.qidian.com/ajax/top.ashx?ajaxMethod=getsearchbooks&pageindex=1&pagesize=20&isvip=-1&categoryid=-1&sort=0&action=-1&key=" . utf8encodedbookname . "&site=-1&again=0&range=-1"
}
; msgbox, % j.Data.search_response.books[1].bookid
; bookid, bookname, authorname, description, lastchaptername

; ���ٰ�������ַ: http://wap.m.qidian.com/search.aspx?key=%E4%B8%9C%E4%BA%AC%E9%81%93%E5%A3%AB
; http://wap.m.qidian.com/book/showbook.aspx?bookid=3347153&pageindex=2&order=desc
; http://wap.m.qidian.com/book/bookreader.aspx?bookid=3347153&chapterid=79700245&wordscnt=0


; jsStr: http://files.qidian.com/Author7/1939238/53927617.txt �е�����
; return: �ı�����ֱ��д�����ݿ�
qidian_getTextFromPageJS(jsStr="")
{
	stringreplace, jsStr, jsStr, &lt`;, <, A
	stringreplace, jsStr, jsStr, &gt`;, >, A
	stringreplace, jsStr, jsStr, document.write(', , A
	stringreplace, jsStr, jsStr, <a>�ֻ��û��뵽m.qidian.com�Ķ���</a>, , A
	stringreplace, jsStr, jsStr, <a href=http://www.qidian.com>���������www.qidian.com��ӭ������ѹ����Ķ������¡���졢����������Ʒ�������ԭ����</a>, , A
	stringreplace, jsStr, jsStr, <a href=http://www.qidian.com>��������� www.qidian.com ��ӭ������ѹ����Ķ������¡���졢����������Ʒ�������ԭ����</a>, , A
	stringreplace, jsStr, jsStr, ')`;, , A
	stringreplace, jsStr, jsStr, <p>, `n, A
	stringreplace, jsStr, jsStr, ����, , A
	return, jsStr
}

; {

/*
txt2txt(txtpath) ; ʹ��������ʽ��ȡtxt��������ݣ����ܱ�����ķ���Ҫ�죬ûʵ��
{
	fileread, txt, %txtpath%
	txt .= "`r`n<end>`r`n"
	startpos := 1
	loop {
		startpos := RegExMatch(txt, "mUiP)^([^\r\n]+)[\r\n]{1,2}����ʱ��.*$[\r\n]{2,4}([^\a]+)(?=(^([^\r\n]+)[\r\n]{1,2}����ʱ��)|^<end>$)", xx_, startpos)
		if ( 0 = startpos ) {
			break
		}
		startpos := xx_pos2 + xx_len2
		newTxt .= SubStr(txt, xx_pos1, xx_len1) . "`r`n" . SubStr(txt, xx_pos2, xx_len2)  . "`r`n`r`n"
;		msgbox, % startpos "`n" SubStr(txt, xx_pos1, xx_len1) "`n-------`n" SubStr(txt, xx_pos2, xx_len2)
	}
	fileappend, %newTxt%, %txtpath%.txt
}
*/

; QDTxt: ���txt��ʽ����
; bCleanSpace: ɾ�����еĿ�ͷ�հ��ַ���
; return:xml ����: <BookName>����</BookName><Title1>����</Title1><Part1>����</Part1><PartCount>212</PartCount>
qidian_txt2xml(QDTxt="", bCleanSpace=true) ; qidian txt -> FoxMark 
{
	if bCleanSpace
	{ ; ȥ�������ַ�
		stringreplace, QDTxt, QDTxt, ����, , A
		stringreplace, QDTxt, QDTxt, `r, , A
		stringreplace, QDTxt, QDTxt, `n`n, `n, A
	}

	stringsplit, Line_, QDTxt, `n, `r
	TarXML := "<BookName>" . Line_1 . "</BookName>`n"
	PartCount := 1
	loop, %Line_0% {
		NextLineNum := A_index + 1 , PrevPartCount := PartCount - 1
		; ����ʱ��2008-9-7 23:50:29  ������605
		If instr(Line_%NextLineNum%, "����ʱ��") And instr(Line_%NextLineNum%, "������")
		{ ; ��ǰΪ��������
			If ( PartCount = 1 )
				TarXML .= "<Title" . PartCount . ">" . Line_%A_index% . "</Title" . PartCount . ">`n"
			else {
				TarXML .= "<Part" . PrevPartCount . ">`n" . TmpPart . "</Part" . PrevPartCount . ">`n"
					. "<Title" . PartCount . ">" . Line_%A_index% . "</Title" . PartCount . ">`n"
				TmpPart := ""
			}
			Line_%NextLineNum% := ""
			++PartCount
		} else { ; ��ǰΪ���Ǳ�����
			If ( A_index = 1 or Line_%A_index% = "" ) 
				continue
			If instr(Line_%A_index%, "��ӭ������ѹ����Ķ������¡���졢����������Ʒ�������ԭ����")
				continue
			TmpPart .= Line_%A_index% . "`n"
		}
	}
	TarXML .= "<Part" . PrevPartCount . ">" . TmpPart . "</Part" . PrevPartCount . ">`n<PartCount>" . PrevPartCount . "</PartCount>`n"
	return, TarXML
}

; FoxXML: �����Ǹ��������ص����Ƹ�ʽ
; LableName: ������<>�еı�ǩ����
; return: ������ĳ��ǩ�ڵ���С����
qidian_getPart(byref FoxXML, LableName="Title55")
{
	RegExMatch(FoxXML, "smUi)<" . LableName . ">(.*)</" . LableName . ">", out_)
	return, out_1
}

; }
