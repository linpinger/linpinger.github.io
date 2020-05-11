; 适合 所有 版本的AHK
; 应该过时了
/*
qidianO_txt2xml(iQidianTxtPath, bCleanSpace=true, bAdd2LV=false) ; qidian txt -> FoxMark 
qidianO_getPart(byref FoxXML, LableName="Title55")
*/

; {

; QDTxt: 起点txt格式内容
; bCleanSpace: 删除其中的开头空白字符串 这个被 FoxBook.ahkL 使用
; bAdd2LV: Add2LV(PageCount|Title) 这个被 QiDianTxt2Mobi.ahk 处理Txt小说.ahk 使用
; return:xml 类似: <BookName>书名</BookName><Title1>标题</Title1><Part1>内容</Part1><PartCount>212</PartCount>
qidianO_txt2xml(iQidianTxtPath, bCleanSpace=true, bAdd2LV=false) ; qidian txt -> FoxMark 
{

	FileRead, txt, %iQidianTxtPath%
	If ( ! instr(txt, "更新时间") or ! instr(txt, "字数：") )  ; 说明不是起点txt
		return, ""
	if ( bCleanSpace ) { ; 去除多余字符
		stringreplace, txt, txt, 　　, , A
		stringreplace, txt, txt, `r, , A
		stringreplace, txt, txt, `n`n, `n, A
	}
	stringsplit, Line_, txt, `n, `r
	txt := ""

	XML := "<BookName>" . Line_1 . "</BookName>`n"
	RegExMatch(Line_2, "i)[ ]*作者：(.*)", Author_)
	if ( Author_1 != "" )
		XML .= "<AuthorName>" . Author_1 . "</AuthorName>`n"
	else
		XML .= "<AuthorName>爱尔兰之狐</AuthorName>`n"

	RegExMatch(iQidianTxtPath, "i)[\\]?([0-9]+)\.txt$", QidianID_)
	if ( QidianID_1 != "" )
		XML .= "<QidianID>" . QidianID_1 . "</QidianID>`n"
	
	PartCount := 1
	loop, %Line_0% {
		NextLineNum := A_index + 1 , PrevPartCount := PartCount - 1
		; 更新时间2008-9-7 23:50:29  字数：605
		If instr(Line_%NextLineNum%, "更新时间") And instr(Line_%NextLineNum%, "字数：")
		{ ; 当前为　标题行
			If ( PartCount = 1 )
				XML .= "<Title" . PartCount . ">" . Line_%A_index% . "</Title" . PartCount . ">`n"
			else {
				XML .= "<Part" . PrevPartCount . ">`n" . TmpPart . "</Part" . PrevPartCount . ">`n"
					. "<Title" . PartCount . ">" . Line_%A_index% . "</Title" . PartCount . ">`n"
				TmpPart := ""
			}
			Line_%NextLineNum% := ""
			If ( bAdd2LV )
				LV_Add("", PartCount, Line_%A_index%)
			++PartCount
		} else { ; 当前为　非标题行
			If ( A_index < 3 or Line_%A_index% = "" ) 
				continue
			If instr(Line_%A_index%, "欢迎广大书友光临阅读，最新、最快、最火的连载作品尽在起点原创！")
				continue
			If instr(Line_%A_index%, "手机阅读器、看书更方便。")
				continue

			if ( "" = TmpPart ) { ; 第一行只有一个中文空格
				TmpPart .= "　" . Line_%A_index% . "`n"
			} else {
				TmpPart .= Line_%A_index% . "`n"
			}
		}
	}
	XML .= "<Part" . PrevPartCount . ">" . TmpPart . "</Part" . PrevPartCount . ">`n<PartCount>" . PrevPartCount . "</PartCount>`n"
	return, XML
}

; FoxXML: 上面那个函数返回的类似格式
; LableName: 包含在<>中的标签对名
; return: 包含在某标签内的最小内容
qidianO_getPart(byref FoxXML, LableName="Title55")
{
	RegExMatch(FoxXML, "smUi)<" . LableName . ">(.*)</" . LableName . ">", out_)
	return, out_1
}

; }

