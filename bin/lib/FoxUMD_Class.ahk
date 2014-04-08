/*
; -----��ע:
^esc::reload
+esc::Edit
!esc::ExitApp
F1::
	sTime := A_TickCount
	oUMD := New FoxUMD("͵��")
	oUMD.AddChapter("�½�1", "����1`n������������")
	oUMD.SaveTo()
	eTime := A_TickCount - sTime
	TrayTip, ��ʱ:, %eTime% ms
return
*/

Class FoxUMD {
	DllPath := "" , hDll := "" , hUMD := ""
	__New(BookName) { ; ���� umd.dll zlib.dll http://code.google.com/p/umd-builder/
sPathList =
(Ltrim Join`n
D:\bin\bin32\umd.dll
C:\bin\bin32\umd.dll
%A_scriptdir%\bin32\umd.dll
%A_scriptdir%\umd.dll
)
		loop, parse, sPathList, `n, `r
			IfExist, %A_loopfield%
				This.DllPath := A_loopfield

		This.hDll := DllCall("LoadLibrary", "Str", This.DllPath)
		This.hUMD := Dllcall("umd\umd_create", "Uint", 0)
		; 2:���� 3:���� 4:������� 5:�����·� 6:�������� 7:�鼮���� 8:������ 9:������
		Dllcall("umd\umd_set_field_w", "Uint", This.hUMD, "Uint", 2, "str", BookName)
		Dllcall("umd\umd_set_field_w", "Uint", This.hUMD, "Uint", 8, "str", "������֮��")
	}
	AddChapter(iTitle="�½���", iContent="����"){
		Dllcall("umd\umd_add_chapter_w", "Uint", This.hUMD, "str", iTitle, "str", iContent)
	}
	SaveTo(BookSavePath="C:\Fox.UMD") {
		Dllcall("umd\umd_build_file_w", "Uint", This.hUMD, "str", BookSavePath)
		Dllcall("umd\umd_destroy", "Uint", This.hUMD)
		DllCall("FreeLibrary", "Uint", This.hDll)
	}
}

