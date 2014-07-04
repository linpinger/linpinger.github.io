; Ver: 2014-5-28
; Ŀǰ�ʺ����а汾��AHK

; iURL: http://readbook.qidian.com/bookreader/3059077.html
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

; pageid: 53927617
; bookid: 1939238
; return: http://files.qidian.com/Author7/1939238/53927617.txt
qidian_getPageURL(pageid, bookid) ; ����ҳ������JS��ַ
{
	return, "http://files.qidian.com/Author" . ( 1 + mod(bookid, 8) ) . "/" . bookid . "/" . pageid . ".txt"
}

; bookid: 1939238
; return: http://readbook.qidian.com/bookreader/1939238.html
qidian_getIndexURL_Desk(bookid)
{
	return, "http://readbook.qidian.com/bookreader/" . bookid . ".html"
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

; jsStr: http://files.qidian.com/Author7/1939238/53927617.txt �е�����
; return: �ı�����ֱ��д�����ݿ�
qidian_getTextFromPageJS(jsStr="")
{
	stringreplace, jsStr, jsStr, document.write(', , A
	stringreplace, jsStr, jsStr, <a>�ֻ��û��뵽m.qidian.com�Ķ���</a>, , A
	stringreplace, jsStr, jsStr, <a href=http://www.qidian.com>��������� www.qidian.com ��ӭ������ѹ����Ķ������¡���졢����������Ʒ�������ԭ����</a>, , A
	stringreplace, jsStr, jsStr, ')`;, , A
	stringreplace, jsStr, jsStr, <p>, `n, A
	stringreplace, jsStr, jsStr, ����, , A
	return, jsStr
}

; {

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
