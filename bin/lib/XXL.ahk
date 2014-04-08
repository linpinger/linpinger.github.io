; 修改日期: 2011-12-6
; 适应版本: AHK Unicode 1.1.5.4

XXL_new(url="", option="") ; 生成空白IE, 返回 chuangkouid, pweb, [document]
{
	global chuangkouid, pweb, document
	pweb := ComObjCreate("InternetExplorer.Application")
	pweb.Visible := true
	chuangkouid := pweb.HWND

	if (option = "M")
		WinMaxiMize, ahk_id %chuangkouid%
	if url {
		XXL_Nav(url)
		document := pweb.document
	}
}

XXL_Nav(URL="", timeout=30) ; [跳转,并]等待载入完毕
{
	global pweb

	if URL
		pweb.navigate2(URL)

	Loop %timeout% {
		Sleep 1000
		if ( (pweb.readyState = 4) && (pweb.Busy = 0) ) 
			Break 
  	}
	pweb.stop()
}


XXL_attach() ; IE Attach :返回: pweb document
{
	global chuangkouid, pweb, document
	if ! chuangkouid
		chuangkouid := winexist("A")
	loop { ; ----- 等待IE控件初始化完毕
		sleep 500
		ControlGet, hIESvr, Hwnd, , Internet Explorer_Server1, ahk_id %chuangkouid% 
		IfEqual, ErrorLevel, 0, break
	}

	; ----- 初始化COM
;	IID_IHTMLWindow2 := "{332C4427-26CB-11D0-B483-00C04FD90119}" 
	IID_IWebBrowserApp := "{0002DF05-0000-0000-C000-000000000046}"
	DllCall("SendMessageTimeout", "Uint", hIESvr, "Uint", DllCall("RegisterWindowMessage", "str", "WM_HTML_GETOBJECT"), "Uint", 0, "Uint", 0, "Uint", 2, "Uint", 1000, "UintP", lResult) 
	DllCall("oleacc\ObjectFromLresult", "Uint", lResult, "Uint", Query_Guid4String(IID_IHTMLDocument2,"{332C4425-26CB-11D0-B483-00C04FD90119}"), "int", 0, "UintP", pdoc) 
	document := ComObjEnwrap(pdoc)
	pweb := Query_Service(document,IID_IWebBrowserApp,IID_IWebBrowserApp)
}

/*

XXL_GUI_new(url="", option="") ; 生成GUI(IE)，并返回:chuangkouid pctn pweb document
{
	global chuangkouid, pctn, pweb, document
	GUi, +LastFound +Resize ; 创建 GUI
;	http://l.autohotkey.net/docs/commands/GuiControls.htm#ActiveX
	Gui, Add, ActiveX, w510 h600 x0 y0 vPWEB hwndPCTN, Shell.Explorer
;	Atl_Init()
;	pweb := Atl_AxGetControl(pctn:=Atl_AxCreateContainer(chuangkouid:=WinExist(),0,0,555,400,"Shell.Explorer"))
	gui,show, w555 h400, 狐狸的窗口 ; 显示 GUI

	if ( option = "M" )
		WinMaxiMize, ahk_id %chuangkouid%
	if url 
	{
		XXL_Nav(url)
		document := pweb.document
	}
	; WinSetTitle, ahk_id %chuangkouid%, ,  登录中
}


; ---------------------------------------------------- 窗口事件: 针对XXL_GUI
GuiSize:
	WinMove, % "ahk_id " . pctn, , 0,0, A_GuiWidth, A_GuiHeight ; 改变IE控件窗口大小
return

GuiEscape:
	pweb.Stop() ; 按退出键，停止载入页面
return

GuiClose:
	Gui, Destroy ; 关闭窗口
return
*/

; ########################################################################################### 


;------------------------------------------------------------------------------
; Acc.ahk Standard Library
; by Sean
; *Note: Modified ComObjEnwrap params from (9,pacc) --> (9,pacc,1)
; *Note: Changed ComObjUnwrap to ComObjValue in order to avoid AddRef
;------------------------------------------------------------------------------

Acc_Init()
{
	Static	h
	If Not	h
		h:=DllCall("LoadLibrary","Str","oleacc","Ptr")
}

Acc_Children(pacc, cChildren, ByRef varChildren)
{
	Acc_Init()
	If	DllCall("oleacc\AccessibleChildren", "Ptr", IsObject(pacc)?ComObjValue(pacc):pacc, "Int", 0, "Int", cChildren, "Ptr", VarSetCapacity(varChildren,cChildren*(8+2*A_PtrSize),0)*0+&varChildren, "Int*", cChildren)=0
	Return	cChildren
}

Acc_ObjectFromEvent(ByRef _idChild_, hWnd, idObject, idChild)
{
	Acc_Init()
	If	DllCall("oleacc\AccessibleObjectFromEvent", "Ptr", hWnd, "UInt", idObject, "UInt", idChild, "Ptr*", pacc, "Ptr", VarSetCapacity(varChild,8+2*A_PtrSize,0)*0+&varChild)=0
	Return	ComObjEnwrap(9,pacc,1), _idChild_:=NumGet(varChild,8,"UInt")
}

Acc_ObjectFromPoint(ByRef _idChild_ = "", x = "", y = "")
{
	Acc_Init()
	If	DllCall("oleacc\AccessibleObjectFromPoint", "Int64", x==""||y==""?0*DllCall("GetCursorPos","Int64*",pt)+pt:x&0xFFFFFFFF|y<<32, "Ptr*", pacc, "Ptr", VarSetCapacity(varChild,8+2*A_PtrSize,0)*0+&varChild)=0
	Return	ComObjEnwrap(9,pacc,1), _idChild_:=NumGet(varChild,8,"UInt")
}

Acc_ObjectFromWindow(hWnd, idObject = -4)
{
	Acc_Init()
	If	DllCall("oleacc\AccessibleObjectFromWindow", "Ptr", hWnd, "UInt", idObject&=0xFFFFFFFF, "Ptr", -VarSetCapacity(IID,16)+NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81,NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0,IID,"Int64"),"Int64"), "Ptr*", pacc)=0
	Return	ComObjEnwrap(9,pacc,1)
}

Acc_WindowFromObject(pacc)
{
	If	DllCall("oleacc\WindowFromAccessibleObject", "Ptr", IsObject(pacc)?ComObjValue(pacc):pacc, "Ptr*", hWnd)=0
	Return	hWnd
}
;------------------------------------------------------------------------------
; Atl.ahk Standard Library
; by Sean
; *Note: Modification - Call ObjRelease(punk) after each ComObjEnwrap(punk)
; *Note: Changed ComObjUnwrap to ComObjValue in order to avoid AddRef
;------------------------------------------------------------------------------

Atl_Init()
{
	Static	h
	If Not	h
		h:=DllCall("LoadLibrary","Str","atl","Ptr"), DllCall("atl\AtlAxWinInit")
}

Atl_AxGetHost(hWnd)
{
	Atl_Init()
	If	DllCall("atl\AtlAxGetHost", "Ptr", hWnd, "Ptr*", punk)=0
	Return	ComObjEnwrap(punk), ObjRelease(punk)
}

Atl_AxGetControl(hWnd)
{
	Atl_Init()
	If	DllCall("atl\AtlAxGetControl", "Ptr", hWnd, "Ptr*", punk)=0
	Return	ComObjEnwrap(punk), ObjRelease(punk)
}

Atl_AxAttachControl(punk, hWnd)
{
	Atl_Init()
	If	DllCall("atl\AtlAxAttachControl", "Ptr", IsObject(punk)?ComObjValue(punk):punk, "Ptr", hWnd, "Ptr", 0)=0
	Return	IsObject(punk)?punk:(ComObjEnwrap(punk), ObjRelease(punk))
}

Atl_AxCreateControl(hWnd, Name)
{
	Atl_Init()
	If	DllCall("atl\AtlAxCreateControlEx", "WStr", Name, "Ptr", hWnd, "Ptr", 0, "Ptr", 0, "Ptr*", punk, "Ptr", VarSetCapacity(GUID,16,0)*0+&GUID, "Ptr", 0)=0
	Return	ComObjEnwrap(punk), ObjRelease(punk)
}

Atl_AxCreateContainer(hWnd, l, t, w, h, Name = "", ExStyle = 0, Style = 0x54000000)
{
	Atl_Init()
	Return	DllCall("CreateWindowEx", "UInt", ExStyle, "Str", "AtlAxWin", "Str", Name, "UInt", Style, "Int", l, "Int", t, "Int", w, "Int", h, "Ptr", hWnd, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr")
}
;------------------------------------------------------------------------------
; Query.ahk Standard Library
; by Sean
; *Note: Modified ComObjEnwrap params from (9,pobj) --> (9,pobj,1)
; *Note: Changed ComObjUnwrap to ComObjValue in order to avoid AddRef
;------------------------------------------------------------------------------

Query_Service(pobj, SID, IID = "!", bRaw = "")
{
	If	DllCall(NumGet(NumGet(0,!IsObject(pobj)?pobj:pobj:=ComObjValue(pobj))), "Ptr", pobj, "Ptr", -VarSetCapacity(PID,16)+NumPut(0xFA096000AA003480,NumPut(0x11CE74366D5140C1,PID,"UInt64"),"UInt64"), "Ptr*", psp)=0
	&&	DllCall(NumGet(NumGet(0,psp),A_PtrSize*3), "Ptr", psp, "Ptr", Query_Guid4String(SID,SID), "Ptr", IID=="!"?&SID:Query_Guid4String(IID,IID), "Ptr*", pobj:=0)+DllCall(NumGet(NumGet(0,psp),A_PtrSize*2), "Ptr", psp)*0=0
	Return	bRaw?pobj:ComObjEnwrap(9,pobj,1)
}

Query_Interface(pobj, IID = "", bRaw = "")
{
	If	DllCall(NumGet(NumGet(0,!IsObject(pobj)?pobj:pobj:=ComObjValue(pobj))), "Ptr", pobj+0, "Ptr", Query_Guid4String(IID,IID), "Ptr*", pobj:=0)=0
	Return	bRaw?pobj:ComObjEnwrap(9,pobj,1)
}

Query_Guid4String(ByRef GUID, sz = "")
{
	Return	DllCall("ole32\CLSIDFromString", "WStr", sz?sz:sz==""?"{00020400-0000-0000-C000-000000000046}":"{00000000-0000-0000-C000-000000000046}", "Ptr", VarSetCapacity(GUID,16,0)*0+&GUID)*0+&GUID
}

Query_String4Guid(pGUID)
{
	Return	DllCall("ole32\StringFromGUID2", "Ptr", pGUID, "WStr", sz:="{00000000-0000-0000-0000-000000000000}", "Int", 39)?sz:""
}

