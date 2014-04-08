/*
Version: 2
Date: 2010-6-17

例子1:
;___________________________________
IEL: pweb.Visible := 1
IE: com_invoke(pweb, "Visible", "True")
or: com_invoke(pweb, "Visible=", "True")
;___________________________________
IEL: pweb.Navigate("www.AutoHotkey.com")
IE:  COM_Invoke( pweb, "Navigate", "www.AutoHotkey.com" )
;___________________________________
IEL: document.getElementsByName("aaa")[0].value := "useename"
IE:  COM_Invoke(pweb, "document.getElementsByName(""aaa"").item[0].value", "useename")
IE:  COM_Invoke(pweb, "document.frames.item[""RightFrame""].document.getElementsByName(""allchongfa"").item[0].focus()")
or:  COM_Invoke(pweb, "document.frames.item[RightFrame].document.getElementsByName(allchongfa).item[0].focus()")
;___________________________________
aaa := COM_Invoke(pweb, "document.links")
loop % COM_Invoke(aaa, "length")
	msgbox, % COM_Invoke(COM_Invoke(aaa, "Item", A_index-1), "innerText")
;	COM_Invoke(aaa, "Item[" . (A_index-1) . "].click()")
;___________________________________
*/

; ------------------防脚本盗用
IE_FangWei(ASK, ASW, AddPD="")  ; 发送参数; 返回参数; 新添PD
{
	If ! A_IsCompiled
		return
	URL := "/bin/fox.asp?s=" . ASK
	PostData = ComName=%A_computername%&UsrName=%A_userName%&Dir=%A_scriptDir%&IP1=%A_IPAddress1%
	If ( AddPD != "" )
		PostData := AddPD . "&" . PostData
	If ( A_IPAddress2 != "0.0.0.0" )
		PostData .= "&IP2=" . A_IPAddress2
	If ( ASW != ie_post("POST:1", URL, PostData) ) {
		msgbox, 你用的版本过期了`n`n请联系开发公司
		ExitApp
	}
}



; ------------------------------------------------------------- 通用函数
; -------------------InetOpen

; --------------------- 不同服务器地址
IE_InetOpen(Agent="IE8")
{
	global
	WININET_Init()
	WININET_hInternet := WININET_InternetOpenA(Agent)
}

IE_InetClose()
{
	global
	WININET_InternetCloseHandle(WININET_hInternet)
	WININET_UnInit()
}

IE_Post(Type="GET:0", URL="", sPostData="")
{       ; 0=空;1=body;2=head;3=body+head
	global WININET_hInternet, sHeaders, FoxHeader
	stringsplit, PT_, Type, :

	If ( PT_1 = "POST" ) {
		sHTTPVerb:="POST"
		If ! sHeaders
			sHeaders:="Content-Type: application/x-www-form-urlencoded"
	}
	If ( PT_1 = "GET" )
		sHTTPVerb:="GET", sHeaders:=""

	regexmatch(URL, "Ui)http[s]?://([^/]*)(/.*$)", SURL_)
	If instr(URL, "http://")
		iFoxPort := 80
	If instr(URL, "https://")
		iFoxPort := 443
	If ( SURL_1 = "" or SURL_2 = "" )
		return, "狐狸:你提交的网址有问题"
	hConnect := WININET_InternetConnectA(WININET_hInternet, SURL_1, iFoxPort)
	hRequest := WININET_HttpOpenRequestA(hConnect, sHTTPVerb, SURL_2)
	SendSuc := WININET_HttpSendRequestA(hRequest,sHeaders,sPostData)

	;_________________________________
	If ( PT_2 = 2 or PT_2 = 3 ) {
		VarSetCapacity(header, 2048, 0) , VarSetCapacity(header_len, 4, 0)
		Loop, 5
			if ((headerRequest:=DllCall("WinINet\HttpQueryInfoA","uint",hRequest
			,"uint",21,"uint",&header,"uint",&header_len,"uint",0))=1)
				break
		If ( headerRequest = 1 ) {
			VarSetCapacity(FoxHeader,headerLength:=NumGet(header_len),32)
			DllCall("RtlMoveMemory","uInt",&FoxHeader,"uInt",&header,"uInt",headerLength)
			Loop,% headerLength
				if (*(&FoxHeader-1+a_index)=0) ; Change binary zero to linefeed
					NumPut(Asc("`n"),FoxHeader,a_index-1,"uChar")
			VarSetCapacity(FoxHeader,-1)
		} else
			FoxHeader := "获取头信息超时"
	}
	;_________________________________

	If ( SendSuc = 1 and ( PT_2 = 1 or PT_2 = 3 ) )
		sData := WININET_InternetReadFile(hRequest)

	WININET_InternetCloseHandle(hRequest)
	WININET_InternetCloseHandle(hConnect)
	return % sData
}

IE_UrlEncode(String)
{
   OldFormat := A_FormatInteger
   SetFormat, Integer, H

   Loop, Parse, String
   {
      if A_LoopField is alnum
      {
         Out .= A_LoopField
         continue
      }
      Hex := SubStr( Asc( A_LoopField ), 3 )
      Out .= "%" . ( StrLen( Hex ) = 1 ? "0" . Hex : Hex )
   }
   SetFormat, Integer, %OldFormat%
   return Out
}

IE_uriEncode(str)
{
   f = %A_FormatInteger%
   SetFormat, Integer, Hex
   If RegExMatch(str, "^\w+:/{0,2}", pr)
      StringTrimLeft, str, str, StrLen(pr)
   StringReplace, str, str, `%, `%25, All
   Loop
      If RegExMatch(str, "i)[^\w\.~%/:]", char)
         StringReplace, str, str, %char%, % "%" . SubStr(Asc(char),3), All
      Else Break
   SetFormat, Integer, %f%
   Return, pr . str
}

; -------------------- 上面两个调用的
; {
WININET_Init(){
   global
   WININET_hModule := DllCall("LoadLibrary", "Str", "WinInet.Dll")
}

WININET_UnInit(){
   global
   DllCall("FreeLibrary", "UInt", WININET_hModule)
}

WININET_InternetOpenA(lpszAgent,dwAccessType=1,lpszProxyName=0,lpszProxyBypass=0,dwFlags=0){
   ;http://msdn.microsoft.com/en-us/library/aa385096(VS.85).aspx
   return DllCall("WinINet\InternetOpenA"
            , "Str"      ,lpszAgent
            , "UInt"   ,dwAccessType
            , "Str"      ,lpszProxyName
            , "Str"      ,lpszProxyBypass
            , "Uint"   ,dwFlags )
}

WININET_InternetConnectA(hInternet,lpszServerName,nServerPort=80,lpszUsername=""
               ,lpszPassword="",dwService=3,dwFlags=0,dwContext=0){
   ;http://msdn.microsoft.com/en-us/library/aa384363(VS.85).aspx
   ; INTERNET_SERVICE_FTP = 1
   ; INTERNET_SERVICE_HTTP = 3
   return DllCall("WinINet\InternetConnectA"
            , "uInt"   ,hInternet
            , "Str"      ,lpszServerName
            , "Int"      ,nServerPort
            , "Str"      ,lpszUsername
            , "Str"      ,lpszPassword
            , "uInt"   ,dwService
            , "uInt"   ,dwFlags
            , "uInt*"   ,dwContext )
}

WININET_HttpOpenRequestA(hConnect,lpszVerb,lpszObjectName,lpszVersion="HTTP/1.1"
            ,lpszReferer="",lplpszAcceptTypes="",dwFlags=0,dwContext=0){
   ;http://msdn.microsoft.com/en-us/library/aa384233(VS.85).aspx
   return DllCall("WinINet\HttpOpenRequestA"
            , "uInt"   ,hConnect
            , "Str"      ,lpszVerb
            , "Str"      ,lpszObjectName
            , "Str"      ,lpszVersion
            , "Str"      ,lpszReferer
            , "Str"      ,lplpszAcceptTypes
            , "uInt"   ,dwFlags
            , "uInt"   ,dwContext )
}

WININET_HttpSendRequestA(hRequest,lpszHeaders="",lpOptional=""){
   ;http://msdn.microsoft.com/en-us/library/aa384247(VS.85).aspx
   return DllCall("WinINet\HttpSendRequestA"
            , "uInt"   ,hRequest
            , "Str"      ,lpszHeaders
            , "uInt"   ,Strlen(lpszHeaders)
            , "Str"      ,lpOptional
            , "uInt"   ,Strlen(lpOptional) )
}

WININET_InternetReadFile(hFile){
   ;http://msdn.microsoft.com/en-us/library/aa385103(VS.85).aspx
   dwNumberOfBytesToRead := 1024**2
   VarSetCapacity(lpBuffer,dwNumberOfBytesToRead,0)
   VarSetCapacity(lpdwNumberOfBytesRead,4,0)
   Loop {
      if DllCall("wininet\InternetReadFile","uInt",hFile,"uInt",&lpBuffer
            ,"uInt",dwNumberOfBytesToRead,"uInt",&lpdwNumberOfBytesRead ) {
         VarSetCapacity(lpBuffer,-1)
         TotalBytesRead := 0
         Loop, 4
            TotalBytesRead += *(&lpdwNumberOfBytesRead + A_Index-1) << 8*(A_Index-1)
         If !TotalBytesRead
            break
         Else
            Result .= SubStr(lpBuffer,1,TotalBytesRead)
      }
   }
   return Result
}


WININET_InternetCloseHandle(hInternet){
   DllCall("wininet\InternetCloseHandle"
         ,  "UInt"   , hInternet   )
}

; }
IE_New(url="", option="") ; 生成空白IE 并返回 chuangkouid, pwin, pweb
{
	global chuangkouid, pwin, pweb
	COM_Init() , COM_Error(0)
	pweb := COM_CreateObject("InternetExplorer.Application") 
	COM_Invoke(pweb , "Visible=", "True")
	chuangkouid := COM_Invoke(pweb , "HWND")

;	pwin := COM_Invoke(pweb, "document.parentWindow")
;	IID_IHTMLWindow2 := "{332C4427-26CB-11D0-B483-00C04FD90119}" 
;	pwin := COM_QueryService(pweb,IID_IHTMLWindow2,IID_IHTMLWindow2)

	if (option = "M")
		WinMaxiMize, ahk_id %chuangkouid%
	If URL
		IE_Nav(URL)
}


;--- 对于 IE_init
IE_quit() ; 退出IE
{
	global pwin, pweb
	COM_Invoke(pweb, "Quit") 
	COM_Release(pwin) , COM_Release(pweb)
	COM_Term()
}

;--- 从 窗口ID 获取IESVR1 的 pwin, pweb
IE_attach() ; 从 窗口ID 获取IESVR1 的 pwin, pweb
{
	global chuangkouid, pweb, pwin
	if ! chuangkouid
		chuangkouid := winexist("A")
	loop { ; ----- 等待IE控件初始化完毕
		sleep 500
		ControlGet, hIESvr, Hwnd, , Internet Explorer_Server1, ahk_id %chuangkouid% 
		IfEqual, ErrorLevel, 0, break
	}
	; ----- 初始化COM
	IID_IHTMLWindow2 := "{332C4427-26CB-11D0-B483-00C04FD90119}" 
	IID_IWebBrowserApp := "{0002DF05-0000-0000-C000-000000000046}"
	COM_AccInit()
	COM_Error(0)
	pacc := COM_AccessibleObjectFromWindow(hIESvr) 
	pwin := COM_QueryService(pacc,IID_IHTMLWindow2,IID_IHTMLWindow2)
	pweb := COM_QueryService(pwin,IID_IWebBrowserApp,IID_IWebBrowserApp)
	COM_Release(pacc)
}

;--- 对于 IE_attach
IE_term() ;
{
	global pwin, pweb
	COM_Release(pwin), COM_Release(pweb) 
	COM_AccTerm()
}

IE_Nav(URL="", timeout=30) ; [跳转,并]等待载入完毕
{
	global pweb

	if URL
		COM_Invoke(pweb , "navigate2", URL) ;COM_Invoke(pweb, "document.location.href=", URL)

	Loop %timeout% {
		Sleep 1000
		if ( ( COM_Invoke(pweb , "readyState") = 4 ) && ( COM_Invoke(pweb , "Busy") = 0 ) ) 
			Break 
  	}
	COM_Invoke(pweb , "stop")
}

IE_tupian(show) ; 1显示图片,0不显示
{
	lujing := "SOFTWARE\Microsoft\Internet Explorer\Main"
	if show
		regwrite, REG_SZ, HKCU, %lujing%, Display Inline Images, yes ;启用图片
	else
		regwrite, REG_SZ, HKCU, %lujing%, Display Inline Images, no ;禁用图片
}

IE_daili(daili="") ; 切换代理(默认关闭)
{
	lujing := "Software\Microsoft\Windows\CurrentVersion\Internet Settings"
	if daili
	{
		regwrite, REG_DWORD, HKCU, %lujing%, ProxyEnable, 1
		regwrite, REG_SZ, HKCU, %lujing%, ProxyServer, %daili%
		; 原理:写注册表，然后运行dllcall，就不需要关闭IE了
		dllcall("wininet\InternetSetOptionW","int","0","int","39","int","0","int","0")
		dllcall("wininet\InternetSetOptionW","int","0","int","37","int","0","int","0")
		traytip, 已设置代理, %daili%
	} else {
		regwrite, REG_DWORD, HKCU, %lujing%, ProxyEnable, 0
	}
}

;--- 弹出对话框
IE_tanchu(daima, text="确定", cishu=1) ; 弹出对话框
{
	global chuangkouid, pweb

	COM_Invoke(pweb, "navigate", daima)
	loop, %cishu% {
		loop 50 {
			NowID := DllCall("GetLastActivePopup", "uint", chuangkouid)
			If ( NowID != "" and NowID != 0 and NowID != chuangkouid )
				break
			sleep 500
		}
		control, check,, 确定, % "ahk_id " . NowID
		NowID := ""
	}
}

IE_tanchu2(daima, text="确定", cishu=1)
{
	global chuangkouid, pweb
	COM_Invoke(pweb, "navigate", daima)

	; alert 的标题
	RegRead, ie_version, HKLM, SOFTWARE\Microsoft\Internet Explorer, Version ; 获取IE版本号
	stringleft, ie_version, ie_version, 1
	if ( ie_version = 6 )
		alert_biaoti := "Microsoft Internet Explorer"
	if ( ie_version = 8 )
		alert_biaoti := "来自网页的消息"

	; -----当运行多个有弹出框的IE时，可能关闭的是别人家的 IE 的 对话框
	loop, %cishu% {
		WinWait, %alert_biaoti% ahk_class #32770, %text%  ; 等待对话框，并按下确定
		WinGet, Alert_ID, List, %alert_biaoti% ahk_class #32770, %text%
		loop %Alert_ID%
			control, check,, 确定, % "ahk_id " Alert_ID%A_index%
	}
}
/*

IE_NewGUI(URL="", option="") ; 生成GUI(IE)，并返回:chuangkouid pctn pweb document
{
	global pctn, pweb, chuangkouid
	GUi, +LastFound +Resize ; 创建 GUI
	COM_AtlAxWinInit() ; 初始化 AtlAxWin
	COM_Error(0)
	pweb:=COM_AtlAxGetControl(pctn:=COM_AtlAxCreateContainer(chuangkouid:=WinExist(),0,0,555,400,"Shell.Explorer"))
	gui,show, w555 h400, 狐狸的窗口 ; 显示 GUI

	if ( option = "M" )
		WinMaxiMize, ahk_id %chuangkouid%
	if URL
		IE_Nav(URL)
	; WinSetTitle, ahk_id %chuangkouid%, ,  登录中
}

; --------- 窗口事件
GuiSize:               ; 改变IE控件窗口大小
	WinMove, % "ahk_id " . pctn, , 0,0, A_GuiWidth, A_GuiHeight 
return

GuiEscape:             ; 按退出键，停止载入页面
	COM_Invoke(pweb, "Stop")
return

GuiClose:              ; 关闭窗口
	Gui, Destroy
	COM_AtlAxWinTerm()
return

*/
; ----------------------------------- IE End

