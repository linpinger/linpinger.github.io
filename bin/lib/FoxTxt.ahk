; {---------------------------------����ı�����
FoxTxt_QiDianTxtPrepProcess(Byref SrcStr="", Byref TarStr="", Mode="") ; Mode: Add2LV(PageCount|Title)
{	; <BookName>����</BookName><Title1>����</Title1><Part1>����</Part1><PartCount>212</PartCount>
	stringsplit, Line_, SrcStr, `n, `r
;	SrcStr := ""

	TarStr := "<BookName>" . Line_1 . "</BookName>`n"
	PartCount := 1
	loop, %Line_0% {
		NextLineNum := A_index + 1 , PrevPartCount := PartCount - 1
		; ����ʱ��2008-9-7 23:50:29  ������605
		If instr(Line_%NextLineNum%, "����ʱ��") And instr(Line_%NextLineNum%, "������")
		{ ; ��ǰΪ��������
			If ( PartCount = 1 )
				TarStr .= "<Title" . PartCount . ">" . Line_%A_index% . "</Title" . PartCount . ">`n"
			else {
				TarStr .= "<Part" . PrevPartCount . ">`n" . TmpPart . "</Part" . PrevPartCount . ">`n"
					. "<Title" . PartCount . ">" . Line_%A_index% . "</Title" . PartCount . ">`n"
				TmpPart := ""
			}
			Line_%NextLineNum% := ""
If ( Mode = "Add2LV" )
	LV_Add("", PartCount, Line_%A_index%)
			++PartCount
		} else { ; ��ǰΪ���Ǳ�����
			If ( A_index = 1 or Line_%A_index% = "" ) 
				continue
			If instr(Line_%A_index%, "��ӭ������ѹ����Ķ������¡���졢����������Ʒ�������ԭ����")
				continue
			TmpPart .= Line_%A_index% . "`n"
		}
	}
	TarStr .= "<Part" . PrevPartCount . ">" . TmpPart . "</Part" . PrevPartCount . ">`n<PartCount>" . PrevPartCount . "</PartCount>`n"
}

FoxTxt_QiDianGetSec(byref SrcStr, LableName="Title55")
{
	RegExMatch(SrcStr, "smUi)<" . LableName . ">(.*)</" . LableName . ">", out_)
	return, out_1
}

; }---------------------------------����ı�����

