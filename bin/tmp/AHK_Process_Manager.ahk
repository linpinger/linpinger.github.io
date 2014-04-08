; 功能: 管理AHK脚本进程

GuiInit:  ; 创建GUI
	Gui, Add, ListView, x6 y10 w690 h160 , PID|命令行参数|创建时间
	LV_ModifyCol(1, 50), LV_ModifyCol(2, 400), LV_ModifyCol(3, 80)

	GUI, add, StatusBar, , F5:刷新  Alt+E:结束
	SB_SetParts(465,100)
	Gui, Show, h194 w555, AHK 脚本进程管理
	gosub, GetProcessInfo  ; 获取AHK进程信息
return

GuiClose:
GuiEscape:
	ExitApp
return

GetProcessInfo: ; 获取AHK进程信息
	LV_Delete() ; 清空列表

	COM_Init()  ; 初始化
	psvc := COM_GetObject("winmgmts:{impersonationLevel=impersonate}!" . "\\.\root\cimv2")

	pset := COM_Invoke(psvc, "ExecQuery",  "SELECT * FROM Win32_Process WHERE Name=""Autohotkey.exe""") ; 很像SQL查询语句哦
	penm := COM_Invoke(pset, "_NewEnum") ; 新枚举
	Loop, % COM_Invoke(pset, "Count")    ; 一个个的来
		If ( COM_Enumerate(penm,pobj) = 0 )
		{
			PID := COM_Invoke(pobj, "ProcessId")           ; 获取进程PID
			CMDLine := COM_Invoke(pobj, "CommandLine")     ; 获取进程命令行
			cDate := COM_Invoke(pobj, "CreationDate")      ; 获取创建时间(瞎翻译的)
			regexmatch(CMDLine, "Ui) ""([^""]+)""", ff_)   ; 正则匹配命令行参数
			regexmatch(cDate, "Ui)^[0-9]{8}([0-9]{2})([0-9]{2})([0-9]{2})\..+$", dd_) ; 正则匹配时间

			LV_Add("", PID, ff_1, dd_1 . ":" . dd_2 . ":" . dd_3) ; 添加记录
			COM_Release(pobj)
		}
	COM_Release(penm) , COM_Release(pset) ; 收尾工作

	COM_Release(psvc) , COM_Term() ; 收尾工作
	LV_ModifyCol(2, "Sort")
	SB_SetText(A_Hour . ":" . A_Min . ":" . A_Sec, 2)
return

; -----备注:
^esc::reload
+esc::Edit
!esc::ExitApp
#IfWinActive, ahk_class AutoHotkeyGUI
!E::
	Loop { ; 获取选定的列表
		RowNumber := LV_GetNext(RowNumber)
		if ! RowNumber
			break
		LV_GetText(NowPID, RowNumber, 1)
		Process, close, %NowPID%            ; 调用AHK本身功能结束进程
	}
	TrayTip, 提示:, 已结束选定的进程
	sleep 2000
	Gosub, GetProcessInfo
return
F5:: gosub, GetProcessInfo ; 刷新
#IfWinActive

;runwait, wmic process where name="Autohotkey.exe" get CommandLine

