; ����: L��
; ����: С˵���ú�������_��ͷ��ʾ˽�к�����һ�����治��Ҫ����
/*
FoxNovel_getTOC(html) ; [{"pageurl", "pagename", "urllen", "urlpos"}] ; ��ȡĿ¼ҳ���ӣ�����: �����б�Ӧ���ǳ��ȼ�����(�������һλ)��
FoxNovel_Compare2GetNewPages(linkArrayInHtmlTOC, AllList="") ; return=���½�����[{Keyͬ��}] ; linkArrayInHtmlTOC=[{"pageurl", "pagename", "urllen", "urlpos"}] ; AllList=DB:DelURL+Page.Name|Page.URL
FoxNovel_getContent(html) ; ��ȡͨ��С˵��ҳ�������ı�
FoxNovel_Html2Txt(html) ; ͨ��txt Page���ݴ���
_MinTag(html)  ; ��</div>�ָ�Ϊ��
_getMaxLine(html) ; ��ȡ�����
_getBody(html) ; ȡ��������
*/

FoxNovel_getTOC(html) ; [{"pageurl", "pagename", "urllen", "urlpos"}] ; ��ȡĿ¼ҳ���ӣ�����: �����б�Ӧ���ǳ��ȼ�����(�������һλ)��
{	; ����FoxBook: _GetBookNewPages(
	; html Ԥ����
	stringreplace, html, html, `r, , A
	stringreplace, html, html, `n, , A
	html := RegExReplace(html, "Ui)<!--[^>]+-->", "") ; ɾ��Ŀ¼�е�ע�� ��� niepo
	html := RegExReplace(html, "Ui)<span[^>]+>", "") ; ɾ�� span��ǩ qidian
	stringreplace, html, html, </span>, , A
	stringreplace, html, html, <a, `n<a, A
	stringreplace, html, html, </a>, </a>`n, A
	stringreplace, html, html, ����, %A_space%%A_space%%A_space%%A_space%, A

	cList := ":"
	jj := []  ; [{"pageurl", "pagename", "urllen", "urlpos"}] : ����, ����, ���ӳ���, ����λ��
	cJJ := 0

;	stringreplace, html, html, </a>, </a>`n, A
	loop, parse, html, `n, `r
	{
		if ! instr(A_LoopField, "</a>")
			continue
		xx_1 := "" , xx_2 := ""
		regexmatch(A_LoopField, "i)href *= *[""']?([^>""']+)[^>]*> *([^<]+)<", xx_)
		nowlen := strlen(xx_1)
;		if ( nowlen < 4 ) ; ���ӳ���С��4�Ĺ��˵�
;			continue
;		if instr(xx_1, "javascript:")
;			continue
		++cJJ
		jj.Push( { "pageurl":xx_1, "pagename":xx_2, "urllen":nowlen, "urlpos":cJJ } )
		clist .= nowlen . ":"
	}
	
	uList := clist
	sort, uList, D: U  ; Ψһ�б�
	
	; ��ȡ������ӳ�����ͬ�ĳ���
	nCount := 0
	loop, parse, uList, :
	{
		if (A_LoopField = "" )
			continue
		stringreplace, fksd, clist, :%A_LoopField%:, , UseErrorLevel
		if ( ErrorLevel > nCount ) {
			nCount := ErrorLevel
			nMax := A_LoopField
		}
	}
	uList := "" , clist := ""

; { �������µĹ��˷�ʽ��ʼ
	minLen := nMax - 2        ;- ��С����ֵ�����ֵ���Ե���
	maxLen := nMax + 2        ;- ��󳤶�ֵ�����ֵ���Ե���
	startDelRowNum := 0       ;- ��ʼɾ������
	endDelRowNum := 9 + cJJ   ;- ����ɾ������
	; �ҿ�ʼ
	halfPoint := floor(cjj/2)
	loop, %halfPoint%
	{
		j := A_index
		nowLen := jj[j].urllen
		if ( nowLen > maxLen or nowLen < minLen ) {
			startDelRowNum := j
		} else {
			if ( ( (jj[j+1].urllen - nowLen) > 1 ) or ( (jj[j+1].urllen - nowLen) < 0) ) {
				startDelRowNum := j
			}
		}
	}
	; �ҽ���
	cJJa := cJJ + 1
	loop, %halfPoint%
	{
		j := cJJa - A_index
		nowLen := jj[j].urllen
		if ( nowLen > maxLen or nowLen < minLen ) {
			endDelRowNum := j
		} else {
			if ( ( ( nowLen - jj[j-1].urllen ) > 1 ) or ( ( nowLen - jj[j-1].urllen ) < 0) ) {
				endDelRowNum := j
			}
		}

	}
;	TrayTip, ��ʾ:, %cJJ%`n%startDelRowNum% -- %endDelRowNum%
	; �Ӻ�����ǰɾԪ��
	if ( endDelRowNum <= cJJ ) {
		jj.RemoveAt(endDelRowNum, cJJ - endDelRowNum + 1)
	}
	if ( startDelRowNum > 1 ) {
		jj.RemoveAt(1, startDelRowNum)
	}
return jj
; } �������µĹ��˷�ʽ����
/*
; { �����ǾɵĹ��˷�ʽ��ʼ
	nLeft := nMax - 1  ; ���ܳ���Сһλ ; ����
	nRight := nMax + 1 ; ���ܳ��ȴ�һλ ; ���� ���������

	; ���˳��� nMax+-1��Χ�ڵĳ��ȵ�����
	kk := []  ; ����, ����
	loop, %cJJ%
	{
		; ���Ȳ��� nMax+-1��Χ�ڵģ����˵�
		xx := jj[A_index].urllen
		if xx not in %nLeft%,%nMax%,%nRight%
			continue
		kk.Push( { "pageurl": jj[A_index].pageurl, "pagename": jj[A_index].pagename } )
	}
	; ���滹�����: ���˳�����������ֵ��Χ�ڵ����� ���˳��Ȳ��ǵ���������
	; Ŀǰ�ķ�����: ����ͷ�������½�
	return, kk ; [����, ����]
; } �����ǾɵĹ��˷�ʽ����
*/
}

FoxNovel_Compare2GetNewPages(linkArrayInHtmlTOC, AllList="") ; return=���½�����[{Keyͬ��}] ; linkArrayInHtmlTOC=[{"pageurl", "pagename", "urllen", "urlpos"}] ; AllList=DB:DelURL+Page.Name|Page.URL
{
	; ��AllListΪ�գ�����ԭ����
	if ! instr(AllList, "|")
		return linkArrayInHtmlTOC

	; ��ȡ AllList ��һ�е� URL : BaseLineURL
	loop, parse, AllList, `n, `r
	{
		if ( instr(A_LoopField, "|") ) {
			StringSplit, xx_, A_loopfield, |, %A_space%
			BaseLineURL := xx_1
			break
		}
	}

	; �鵽����linkArrayInHtmlTOC�е���BaseLineURL���кţ���ɾ��1�����кŵ�����Ԫ��
	EndIDX := 1
	arrMax := linkArrayInHtmlTOC.MaxIndex() ; 2019-09-04: �������
	loop, %arrMax% {
		nowIDX := arrMax - A_index + 1
		if ( BaseLineURL = linkArrayInHtmlTOC[nowIDX].pageurl) {
			EndIdx := nowIDX
			break
		}
	}
	/*
	for i, item in linkArrayInHtmlTOC {
		if ( BaseLineURL = item.pageurl) {
			EndIdx := i
			break
		}
	}
	*/
	linkArrayInHtmlTOC.RemoveAt(1, EndIdx)

	; �Ա�ʣ���linkArrayInHtmlTOC��AllList���õ��µ�aNewRet������
	aNewRet := []
	for i, item in linkArrayInHtmlTOC {
		if ( ! instr(AllList, "`n" . item.pageurl . "|") ) {
			aNewRet.Push( item )
		}
	}
	return aNewRet
}

FoxNovel_getContent(html) ; ��ȡͨ��С˵��ҳ�������ı�
{
	; ���� novel Ӧ������<div>�����ŵ������
	html := _getBody(html) ; ȡ��������
	html := _MinTag(html)  ; ��</div>�ָ�Ϊ��
	html := _getMaxLine(html) ; ��ȡ�����

	html := FoxNovel_Html2Txt(html)

	; ���������е�<img��ǩ�����Խ�������������������:�޴�

	; ������վ������Է�������
	; qidian����6:JS
	StringReplace, html, html, document.write(', , A
	StringReplace, html, html, <a>�ֻ��û��뵽m.qidian.com�Ķ���</a>')`;, , A

	; stringreplace, html, html, <144, ��144, A ; 144��Ժ������ᵼ��������������Ҳɾ���ˣ���ʹ�������޸�
	html := RegExReplace(html, "smUi)<span[^>]*>.*</span>", "")  ; ɾ��<span>�����ǻ����ַ���; ��� �ݺ����Ļ����ַ����Լ���Ҷ���β��ǩ��һ�㶼û��span��ǩ

	html := RegExReplace(html, "Ui)<[^<>]+>", "") ; �������һ��������ʱ����ע��: ɾ�� html��ǩ,�Ľ��ͣ���ֹ�����в��ɶԵ�<
	html := LTrim(html, "`r`n ��") ; ɾ��ͷ������Ļس�������Ӣ�Ŀհ�
	return, html
}

; {
FoxNovel_Html2Txt(html) ; ͨ��txt Page���ݴ���
{	; �����������һ��Ҳ�����ˣ�����ɾŶ
	stringreplace, html, html, `t, , A
	stringreplace, html, html, `v, , A
	stringreplace, html, html, `r, , A
	stringreplace, html, html, `n, , A
	stringreplace, html, html, &nbsp`;, , A
	stringreplace, html, html, ����, , A
	stringreplace, html, html, <br>, `n, A
	stringreplace, html, html, </br>, `n, A
	stringreplace, html, html, <br/>, `n, A
	stringreplace, html, html, <br />, `n, A
	stringreplace, html, html, <p>, `n, A
	stringreplace, html, html, </p>, `n, A
;	stringreplace, html, html, <div>, `n, A
;	stringreplace, html, html, </div>, `n, A
	stringreplace, html, html, `n`n, `n, A

	return, html
}

_MinTag(html)  ; ��</div>�ָ�Ϊ��
{
	html := RegExReplace(html, "smUi)<script[^>]*>.*</script>", "") ; �ű�
	html := RegExReplace(html, "smUi)<!--[^>]+-->", "")             ; ע�� �ټ�
	html := RegExReplace(html, "smUi)<iframe[^>]*>.*</iframe>", "") ; ��� �൱�ټ�
	html := RegExReplace(html, "smUi)<h[1-9]?[^>]*>.*</h[1-9]?>", "") ; ���� �൱�ټ�
	html := RegExReplace(html, "smUi)<meta[^>]*>", "")

	; 2ѡ1,�������������֣�Ŀǰû������ô��̬�ģ�����ɾ��
	html := RegExReplace(html, "smUi)<a [^>]+>.*</a>", "") ; ɾ�����Ӽ��м�����
;	html := RegExReplace(html, "smUi)<a[^>]*>", "<a>")   ; �滻����Ϊ<a>

	; ��html��������,�������������������ݣ����԰������
	html := RegExReplace(html, "smUi)<div[^>]*>", "<div>")
	html := RegExReplace(html, "smUi)<font[^>]*>", "<font>")
	html := RegExReplace(html, "smUi)<table[^>]*>", "<table>")
	html := RegExReplace(html, "smUi)<td[^>]*>", "<td>")
	html := RegExReplace(html, "smUi)<ul[^>]*>", "<ul>")
	html := RegExReplace(html, "smUi)<dl[^>]*>", "<dl>")
	html := RegExReplace(html, "smUi)<span[^>]*>", "<span>")

	stringreplace, html, html, `r, , A
	stringreplace, html, html, `n, , A
	stringreplace, html, html, `t, , A
	stringreplace, html, html, </div>, </div>`n, A
	stringreplace, html, html, <div></div>, , A
	stringreplace, html, html, %A_space%%A_space%, , A
	return, html
}

_getMaxLine(html) ; ��ȡ�����
{
	maxnum := 1
	maxcount := 0
	stringsplit, ll_, html, `n, `r
	loop, %ll_0% {
;		nowlen := strlen(ll_%A_index%) ; L�������ĳ���Ҳ��1
		nowlen := strput(ll_%A_index%, "UTF-8")  ; UTF-8������3���ֽڣ����һ��������������
		if ( nowlen > maxcount ) {
			maxcount := nowlen
			maxnum := A_index
		}
	} ; msgbox, % maxnum
	return, ll_%maxnum%
}

_getBody(html) ; ȡ��������
{
	regexmatch(html, "smUi)<body[^>]*>(.*)</body>", xx_)
	if ( xx_1 = "" ) ; ���� ��<body �ı�̬��ҳ
		xx_1 := html
	return, xx_1
}
; }

