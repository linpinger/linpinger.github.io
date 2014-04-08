; fox modify : 2009-12-5
; download_from: http://www.autohotkey.com/forum/viewtopic.php?t=30599
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;	Written by Tank
;;	Based on Seans most excelent work COM.ahk
;;	http://www.autohotkey.com/forum/viewtopic.php?t=22923
;;	some credit due to Lexikos for ideas arrived at from ScrollMomentum
;;	http://www.autohotkey.com/forum/viewtopic.php?t=24264
;;	1-17-2009
;;	Please use and distribute freely
;;	Please do not claim it as your own
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;~ CONSTANTS/PARAMETERS
{
	
}
;~ DIRECTIVES
{
	
	
	
}
;~ AUTOEXEC
{
	Gui, +AlwaysOnTop
	Gui, Add, GroupBox, x6 y0 w460 h80 , 信息
	Gui, Add, Text, x16 y20 w40 h20 , 标题：
	Gui, Add, Edit, x56 y20 w400 h20 vTitle, 
	Gui, Add, Text, x16 y50 w40 h20 , 地址：
	Gui, Add, Edit, x56 y50 w400 h20 vURLL, 

	Gui, Add, GroupBox, x6 y90 w460 h280 , Mouse Over :
	Gui, Add, Text, x16 y110 w30 h20 , Tag:
	Gui, Add, Edit, x46 y110 w70 h20 vHTMLTag, 
	Gui, Add, Text, x126 y110 w30 h20 , Name:
	Gui, Add, Edit, x156 y110 w130 h20 vEleName, 
	Gui, Add, Text, x296 y110 w30 h20 , ID:
	Gui, Add, Edit, x326 y110 w130 h20 vEleIDs, 
	Gui, Add, Text, x16 y140 w60 h20 , EleIndex:
	Gui, Add, Edit, x76 y140 w40 h20 vEleIndex, 
	Gui, Add, Text, x126 y140 w50 h20 , MouseX:
	Gui, Add, Edit, x176 y140 w40 h20 vMouseX, 
	Gui, Add, Text, x226 y140 w50 h20 , MouseY:
	Gui, Add, Edit, x276 y140 w40 h20 vMouseY, 

	Gui, Add, GroupBox, x16 y170 w440 h190 , Text Of Element
	Gui, Add, Edit, x26 y190 w420 h160 vhtml_text, 

	Gui, Add, GroupBox, x6 y370 w460 h90 , Frames
	Gui, Add, Edit, x10 y390 w440 h60 vtheFrame, 

	Gui, Show, h462 w479, 爱尔兰之狐修改的网页元素探测器

	COM_CoInitialize()
	COM_Error(0)
    GetWin:
	if paused
		return
	IE_HtmlElement()
	Goto,GetWin
	
	^/::
	paused:= paused ? 0 : 1
	Goto,GetWin
	Return
}

GuiClose:
GuiEscape:
COM_CoUninitialize()
ExitApp

IE_HtmlElement()
{
	CoordMode, Mouse
	MouseGetPos, xpos, ypos,, hCtl, 3
	WinGetClass, sClass, ahk_id %hCtl%
	If Not   sClass == "Internet Explorer_Server"
		|| Not   pdoc := IE_GetDocument(hCtl)
			Return
	
;~ 		ToolTip,runing
	GuiControl,Text,MouseX,%	xpos
	GuiControl,Text,MouseY,%	ypos
	If   pelt :=   COM_Invoke(pdoc, "elementFromPoint", xpos-xorg:=COM_Invoke(pdoc,"parentWindow.screenLeft"), ypos-yorg:=COM_Invoke(pdoc,"parentWindow.screenTop"))
	{
		While   (type:=COM_Invoke(pelt,"tagName"))="IFRAME" || type="FRAME"
		{
			selt .=   "[" type "]." A_Index "  [sourceIndex]=" sourceIndex:=COM_Invoke(pelt,"sourceindex") "  [name]= " COM_Invoke(pelt,"name") "  [id]= " COM_Invoke(pelt,"id") "`n"
			pwin :=   COM_QueryService(pbrt:=COM_Invoke(pelt,"contentWindow"), "{332C4427-26CB-11D0-B483-00C04FD90119}"), COM_Release(pbrt), COM_Release(pdoc)
			pdoc :=   COM_Invoke(pwin, "document"), COM_Release(pwin)
			pbrt :=   COM_Invoke(pdoc, "elementFromPoint", xpos-xorg+=COM_Invoke(pelt,"getBoundingClientRect.left"), ypos-yorg+=COM_Invoke(pelt,"getBoundingClientRect.top")), COM_Release(pelt), pelt:=pbrt
		}

		GuiControl,Text,theFrame,%	selt
		GuiControl,Text,EleIndex,%	COM_Invoke(pelt,"sourceindex")
		GuiControl,Text,EleName,%	COM_Invoke(pelt,"name")
		GuiControl,Text,EleIDs,%	COM_Invoke(pelt,"id")
		GuiControl,Text,html_text
		,%	inpt(pelt) "`n`n[outerHTML]=" COM_Invoke(pelt, "outerhtml")
		GuiControl,Text,HTMLTag,%	COM_Invoke(pelt,"tagName")
		IID_IWebBrowserApp := "{0002DF05-0000-0000-C000-000000000046}" 
		iWebBrowser2 := COM_QueryService(pdoc,IID_IWebBrowserApp,IID_IWebBrowserApp) 
		GuiControl,Text,Title,% COM_Invoke(iWebBrowser2,"LocationName") 
;		GuiControl,Text,Title,% COM_Invoke(pdoc,"title") 
		GuiControl,Text,URLL,% COM_Invoke(iWebBrowser2,"LocationURL")
		COM_Release(iWebBrowser2) 
		COM_Release(pbrt)
		COM_Release(pelt)
	}
	COM_Release(pdoc)
	Return
}

inpt(i)
{
;~ 			http://msdn.microsoft.com/en-us/library/ms534657(VS.85).aspx tagname property
	typ		:=	COM_Invoke(i,	"tagName")
	inpt	:=	"BUTTON,INPUT,OPTION,SELECT,TEXTAREA" ; these things all have value attribute and is likely what i need instead of innerHTML
	Loop,Parse,inpt,`,
		if (typ	=	A_LoopField	?	1	:	"")
			Return "[value]=" COM_Invoke(i,	"value")
	Return "[innertext]=" COM_Invoke(i,	"innertext")
}

IE_GetDocument(hWnd)
{
   Static 
   If Not   pfn
      pfn := DllCall("GetProcAddress", "Uint", DllCall("LoadLibrary", "str", "oleacc.dll"), "str", "ObjectFromLresult")
   ,   msg := DllCall("RegisterWindowMessage", "str", "WM_HTML_GETOBJECT")
   ,   COM_GUID4String(iid, "{00020400-0000-0000-C000-000000000046}")
   If   DllCall("SendMessageTimeout", "Uint", hWnd, "Uint", msg, "Uint", 0, "Uint", 0, "Uint", 2, "Uint", 1000, "UintP", lr:=0) && DllCall(pfn, "Uint", lr, "Uint", &iid, "Uint", 0, "UintP", pdoc:=0)=0
   Return   pdoc
}
