; ����: ����AHK�ű�����

GuiInit:  ; ����GUI
	Gui, Add, ListView, x6 y10 w690 h160 , PID|�����в���|����ʱ��
	LV_ModifyCol(1, 50), LV_ModifyCol(2, 400), LV_ModifyCol(3, 80)

	GUI, add, StatusBar, , F5:ˢ��  Alt+E:����
	SB_SetParts(465,100)
	Gui, Show, h194 w555, AHK �ű����̹���
	gosub, GetProcessInfo  ; ��ȡAHK������Ϣ
return

GuiClose:
GuiEscape:
	ExitApp
return

GetProcessInfo: ; ��ȡAHK������Ϣ
	LV_Delete() ; ����б�

	COM_Init()  ; ��ʼ��
	psvc := COM_GetObject("winmgmts:{impersonationLevel=impersonate}!" . "\\.\root\cimv2")

	pset := COM_Invoke(psvc, "ExecQuery",  "SELECT * FROM Win32_Process WHERE Name=""Autohotkey.exe""") ; ����SQL��ѯ���Ŷ
	penm := COM_Invoke(pset, "_NewEnum") ; ��ö��
	Loop, % COM_Invoke(pset, "Count")    ; һ��������
		If ( COM_Enumerate(penm,pobj) = 0 )
		{
			PID := COM_Invoke(pobj, "ProcessId")           ; ��ȡ����PID
			CMDLine := COM_Invoke(pobj, "CommandLine")     ; ��ȡ����������
			cDate := COM_Invoke(pobj, "CreationDate")      ; ��ȡ����ʱ��(Ϲ�����)
			regexmatch(CMDLine, "Ui) ""([^""]+)""", ff_)   ; ����ƥ�������в���
			regexmatch(cDate, "Ui)^[0-9]{8}([0-9]{2})([0-9]{2})([0-9]{2})\..+$", dd_) ; ����ƥ��ʱ��

			LV_Add("", PID, ff_1, dd_1 . ":" . dd_2 . ":" . dd_3) ; ��Ӽ�¼
			COM_Release(pobj)
		}
	COM_Release(penm) , COM_Release(pset) ; ��β����

	COM_Release(psvc) , COM_Term() ; ��β����
	LV_ModifyCol(2, "Sort")
	SB_SetText(A_Hour . ":" . A_Min . ":" . A_Sec, 2)
return

; -----��ע:
^esc::reload
+esc::Edit
!esc::ExitApp
#IfWinActive, ahk_class AutoHotkeyGUI
!E::
	Loop { ; ��ȡѡ�����б�
		RowNumber := LV_GetNext(RowNumber)
		if ! RowNumber
			break
		LV_GetText(NowPID, RowNumber, 1)
		Process, close, %NowPID%            ; ����AHK�����ܽ�������
	}
	TrayTip, ��ʾ:, �ѽ���ѡ���Ľ���
	sleep 2000
	Gosub, GetProcessInfo
return
F5:: gosub, GetProcessInfo ; ˢ��
#IfWinActive

;runwait, wmic process where name="Autohotkey.exe" get CommandLine

