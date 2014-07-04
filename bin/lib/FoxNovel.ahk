; ����: L��
; ����: С˵���ú�������_��ͷ��ʾ˽�к�����һ�����治��Ҫ����

FoxNovel_getHrefList(html) ; ��ȡĿ¼ҳ���ӣ�����: �����б�Ӧ���ǳ��ȼ�����(�������һλ)��
{	; ����FoxBook: _GetBookNewPages(
	cList := ":"
	jj := []  ; ���ӳ���, ����λ��, ����, ����
	cJJ := 0

	loop, parse, html, `n, `r
	{
		if ! instr(A_LoopField, "</a>")
			continue
		xx_1 := "" , xx_2 := ""
		regexmatch(A_LoopField, "i)href *= *[""']?([^>""']+)[^>]*> *([^<]+)<", xx_)
		nowlen := strlen(xx_1)
		if ( nowlen < 4 ) ; ���ӳ���С��4�Ĺ��˵�
			continue
		++cJJ
		jj[cJJ,1] := nowlen
		jj[cJJ,2] := A_index
		jj[cJJ,3] := xx_1
		jj[cJJ,4] := xx_2
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
	nLeft := nMax - 1  ; ���ܳ���Сһλ ; ����
	nRight := nMax + 1 ; ���ܳ��ȴ�һλ ; ���� ���������
	uList := "" , clist := ""

	; ���˳��� nMax+-1��Χ�ڵĳ��ȵ�����
	kk := []  ; ���ӳ���, ����λ��, ����, ����
	cKK := 0
	loop, %cJJ%
	{
		; ���Ȳ��� nMax+-1��Χ�ڵģ����˵�
		xx := jj[A_index,1]
		if xx not in %nLeft%,%nMax%,%nRight%
			continue
		++cKK
		kk[cKK,1] := jj[A_index,1]
		kk[cKK,2] := jj[A_index,2]
		kk[cKK,3] := jj[A_index,3]
		kk[cKK,4] := jj[A_index,4]
	;	Blist .= kk[cKK,1] . "@" . kk[ckk,2] . "=" . kk[cKK,3] . ">" . kk[cKK,4] . "`n"
	}
	; ���滹�����: ���˳�����������ֵ��Χ�ڵ����� ���˳��Ȳ��ǵ���������
	; Ŀǰ�ķ�����: ����ͷ�������½�
	return, kk
;	return, nMax . "`n`n" . uList . "`n`n" . clist . "`n`n" . alist
}

FoxNovel_getPageText(html) ; ��ȡͨ��С˵��ҳ�������ı�
{
	; ���� novel Ӧ������<div>�����ŵ������
	html := _getBody(html) ; ȡ��������
	html := _MinTag(html)  ; ��</div>�ָ�Ϊ��
	html := _getMaxLine(html) ; ��ȡ�����

	html := FoxNovel_Html2Txt(html)

	; ���������е�<img��ǩ�����Խ�������������������:�޴�

	; ������վ������Է�������
	; stringreplace, html, html, <144, ��144, A ; 144��Ժ������ᵼ��������������Ҳɾ���ˣ���ʹ�������޸�
	html := RegExReplace(html, "smUi)<span[^>]*>.*</span>", "")  ; ɾ��<span>�����ǻ����ַ���; ��� �ݺ����Ļ����ַ����Լ���Ҷ���β��ǩ��һ�㶼û��span��ǩ

	html := RegExReplace(html, "Ui)<[^<>]+>", "") ; �������һ��������ʱ����ע��: ɾ�� html��ǩ,�Ľ��ͣ���ֹ�����в��ɶԵ�<
	return, html
}

; { ; ͨ��txt Page���ݴ��� Add: 2014-2-21
FoxNovel_Html2Txt(html)
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

