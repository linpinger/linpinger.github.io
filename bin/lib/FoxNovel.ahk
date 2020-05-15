; 适用: L版
; 本库: 小说常用函数，以_开头表示私有函数，一般外面不需要调用
/*
FoxNovel_getTOC(html) ; [{"pageurl", "pagename", "urllen", "urlpos"}] ; 获取目录页链接，理论: 链接列表应该是长度极近似(最多增加一位)的
FoxNovel_Compare2GetNewPages(linkArrayInHtmlTOC, AllList="") ; return=新章节数组[{Key同右}] ; linkArrayInHtmlTOC=[{"pageurl", "pagename", "urllen", "urlpos"}] ; AllList=DB:DelURL+Page.Name|Page.URL
FoxNovel_getContent(html) ; 获取通用小说网页的正文文本
FoxNovel_Html2Txt(html) ; 通用txt Page内容处理
_MinTag(html)  ; 以</div>分割为行
_getMaxLine(html) ; 获取最长的行
_getBody(html) ; 取正文内容
*/

FoxNovel_getTOCLast(html, count=50) { ; 2020-05-11: 获取最后50个链接(实际比这个少)，适用于在追的书
	jj := []  ; [{"pageurl", "pagename"}] : 链接, 文字
	bPos := 0
	while ( bPos := RegExMatch(html, "smi)href *= *[""']?([^>""']+)[^>]*> *([^<]+)<", xx_, 1 + bPos) ) { ; url, name
		jj.Push( { "pageurl":xx_1, "pagename":xx_2 } )
	}

	jjCount := jj.MaxIndex()
	startPos := jjCount - count
	firstUrlLen := strlen( jj[startPos].pageurl )

	kk := []
	for i, lk in jj {
		if ( i < startPos )
			continue
		if ( strlen(lk.pageurl) != firstUrlLen )
			break
		kk.Push(lk)
	}
;	msgbox, % count ">" kk.MaxIndex() "`n" kk[1].pagename "`n" kk[13].pagename
	return kk ; [{"pageurl", "pagename"}] : 链接, 文字
}

FoxNovel_getTOC(html) ; [{"pageurl", "pagename", "urllen", "urlpos"}] ; 获取目录页链接，理论: 链接列表应该是长度极近似(最多增加一位)的
{	; 搜索FoxBook: _GetBookNewPages(
	; html 预处理
	stringreplace, html, html, `r, , A
	stringreplace, html, html, `n, , A
	html := RegExReplace(html, "Ui)<!--[^>]+-->", "") ; 删除目录中的注释 针对 niepo
	html := RegExReplace(html, "Ui)<span[^>]+>", "") ; 删除 span标签 qidian
	stringreplace, html, html, </span>, , A
	stringreplace, html, html, <a, `n<a, A
	stringreplace, html, html, </a>, </a>`n, A
	stringreplace, html, html, 　　, %A_space%%A_space%%A_space%%A_space%, A

	cList := ":"
	jj := []  ; [{"pageurl", "pagename", "urllen", "urlpos"}] : 链接, 文字, 链接长度, 链接位置
	cJJ := 0

;	stringreplace, html, html, </a>, </a>`n, A
	loop, parse, html, `n, `r
	{
		if ! instr(A_LoopField, "</a>")
			continue
		xx_1 := "" , xx_2 := ""
		regexmatch(A_LoopField, "i)href *= *[""']?([^>""']+)[^>]*> *([^<]+)<", xx_)
		nowlen := strlen(xx_1)
;		if ( nowlen < 4 ) ; 链接长度小于4的过滤掉
;			continue
;		if instr(xx_1, "javascript:")
;			continue
		++cJJ
		jj.Push( { "pageurl":xx_1, "pagename":xx_2, "urllen":nowlen, "urlpos":cJJ } )
		clist .= nowlen . ":"
	}
	
	uList := clist
	sort, uList, D: U  ; 唯一列表
	
	; 获取最多链接长度相同的长度
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

; { 这里是新的过滤方式开始
	minLen := nMax - 2        ;- 最小长度值，这个值可以调节
	maxLen := nMax + 2        ;- 最大长度值，这个值可以调节
	startDelRowNum := 0       ;- 开始删除的行
	endDelRowNum := 9 + cJJ   ;- 结束删除的行
	; 找开始
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
	; 找结束
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
;	TrayTip, 提示:, %cJJ%`n%startDelRowNum% -- %endDelRowNum%
	; 从后面往前删元素
	if ( endDelRowNum <= cJJ ) {
		jj.RemoveAt(endDelRowNum, cJJ - endDelRowNum + 1)
	}
	if ( startDelRowNum > 1 ) {
		jj.RemoveAt(1, startDelRowNum)
	}
return jj
; } 这里是新的过滤方式结束
/*
; { 这里是旧的过滤方式开始
	nLeft := nMax - 1  ; 可能长度小一位 ; 较少
	nRight := nMax + 1 ; 可能长度大一位 ; 极少 可能新书或

	; 过滤出在 nMax+-1范围内的长度的链接
	kk := []  ; 链接, 文字
	loop, %cJJ%
	{
		; 长度不在 nMax+-1范围内的，过滤掉
		xx := jj[A_index].urllen
		if xx not in %nLeft%,%nMax%,%nRight%
			continue
		kk.Push( { "pageurl": jj[A_index].pageurl, "pagename": jj[A_index].pagename } )
	}
	; 后面还可以深化: 过滤出不在相邻域值范围内的链接 过滤长度不是递增的区间
	; 目前的方案是: 过滤头部多少章节
	return, kk ; [链接, 文字]
; } 这里是旧的过滤方式结束
*/
}

FoxNovel_Compare2GetNewPages(linkArrayInHtmlTOC, AllList="") ; return=新章节数组[{Key同右}] ; linkArrayInHtmlTOC=[{"pageurl", "pagename", "urllen", "urlpos"}] ; AllList=DB:DelURL+Page.Name|Page.URL
{
	; 当AllList为空，返回原数组
	if ! instr(AllList, "|")
		return linkArrayInHtmlTOC

	; 获取 AllList 第一行的 URL : BaseLineURL
	loop, parse, AllList, `n, `r
	{
		if ( instr(A_LoopField, "|") ) {
			StringSplit, xx_, A_loopfield, |, %A_space%
			BaseLineURL := xx_1
			break
		}
	}

	; 查到数组linkArrayInHtmlTOC中等于BaseLineURL的行号，并删除1到该行号的所有元素
	EndIDX := 1
	arrMax := linkArrayInHtmlTOC.MaxIndex() ; 2019-09-04: 倒序查找
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

	; 对比剩余的linkArrayInHtmlTOC和AllList，得到新的aNewRet并返回
	aNewRet := []
	for i, item in linkArrayInHtmlTOC {
		if ( ! instr(AllList, "`n" . item.pageurl . "|") ) {
			aNewRet.Push( item )
		}
	}
	return aNewRet
}

FoxNovel_getContent(html) ; 获取通用小说网页的正文文本
{
	; 规律 novel 应该是由<div>包裹着的最长的行
	html := _getBody(html) ; 取正文内容
	html := _MinTag(html)  ; 以</div>分割为行
	html := _getMaxLine(html) ; 获取最长的行

	html := FoxNovel_Html2Txt(html)

	; 处理正文中的<img标签，可以将代码放在这里，典型例子:无错

	; 特殊网站处理可以放在这里
	; qidian桌面6:JS
	StringReplace, html, html, document.write(', , A
	StringReplace, html, html, <a>手机用户请到m.qidian.com阅读。</a>')`;, , A

	; stringreplace, html, html, <144, 《144, A ; 144书院的这个会导致下面正则将正文也删掉了，已使用正则修复
	html := RegExReplace(html, "smUi)<span[^>]*>.*</span>", "")  ; 删除<span>里面是混淆字符，; 针对 纵横中文混淆字符，以及大家读结尾标签，一般都没有span标签

	html := RegExReplace(html, "Ui)<[^<>]+>", "") ; 这是最后一步，调试时可先注释: 删除 html标签,改进型，防止正文有不成对的<
	html := LTrim(html, "`r`n 　") ; 删除头部多余的回车换行中英文空白
	return, html
}

; {
FoxNovel_Html2Txt(html) ; 通用txt Page内容处理
{	; 这个函数被另一个也调用了，别乱删哦
	stringreplace, html, html, `t, , A
	stringreplace, html, html, `v, , A
	stringreplace, html, html, `r, , A
	stringreplace, html, html, `n, , A
	stringreplace, html, html, &nbsp`;, , A
	stringreplace, html, html, 　　, , A
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

_MinTag(html)  ; 以</div>分割为行
{
	html := RegExReplace(html, "smUi)<script[^>]*>.*</script>", "") ; 脚本
	html := RegExReplace(html, "smUi)<!--[^>]+-->", "")             ; 注释 少见
	html := RegExReplace(html, "smUi)<iframe[^>]*>.*</iframe>", "") ; 框架 相当少见
	html := RegExReplace(html, "smUi)<h[1-9]?[^>]*>.*</h[1-9]?>", "") ; 标题 相当少见
	html := RegExReplace(html, "smUi)<meta[^>]*>", "")

	; 2选1,正文链接有文字，目前没见到这么变态的，所以删吧
	html := RegExReplace(html, "smUi)<a [^>]+>.*</a>", "") ; 删除链接及中间内容
;	html := RegExReplace(html, "smUi)<a[^>]*>", "<a>")   ; 替换链接为<a>

	; 将html代码缩短,便于区分正文与广告内容，可以按需添加
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

_getMaxLine(html) ; 获取最长的行
{
	maxnum := 1
	maxcount := 0
	stringsplit, ll_, html, `n, `r
	loop, %ll_0% {
;		nowlen := strlen(ll_%A_index%) ; L版认中文长度也是1
		nowlen := strput(ll_%A_index%, "UTF-8")  ; UTF-8中文算3个字节，最长行一定是中文最多的行
		if ( nowlen > maxcount ) {
			maxcount := nowlen
			maxnum := A_index
		}
	} ; msgbox, % maxnum
	return, ll_%maxnum%
}

_getBody(html) ; 取正文内容
{
	regexmatch(html, "smUi)<body[^>]*>(.*)</body>", xx_)
	if ( xx_1 = "" ) ; 真有 无<body 的变态网页
		xx_1 := html
	return, xx_1
}
; }

