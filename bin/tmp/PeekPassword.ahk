/* �ǺŲ鿴.ahk    ���ߣ�wz520

        ����˵�ˣ����Ŵ�Ҷ�֪�����Ǹ���ġ�
        д��AHK�ű��ĺô�����������Ҫʱ���Բ���Ҫ��������ˡ�

        �÷�����Ҫ�鿴����ı༭���ϰ�Ctrl+�������������Ǻű����ġ�������Ӧ��ֻ֧�ֱ�׼��Edit��

        PS: XPϵͳ�²���ͨ��������ϵͳ��Ч��δ֪����

*/

; #define EM_GETPASSWORDCHAR 0x00D2
; #define EM_SETPASSWORDCHAR 0x00CC

^esc::reload
+esc::Edit
!esc::ExitApp
F1::
	MouseGetPos,,,,ctrlid,3 ;ȡ�����ָ���µĿؼ�ID
	SendMessage, 0x00D2,0,0,,ahk_id %ctrlid% ;ȡ�����ָ���¿ؼ��������ַ������Ǽ����������Ƿ��Ǵ��Ǻŵ�Edit�򣩡�
	If errorlevel in FAIL,0
		return ;������ʧ�ܻ�0��������Ͳ����ˡ���
	PostMessage, 0x00CC,0,0,,ahk_id %ctrlid% ;�������ַ���Ϊ0����ȡ���������ԣ�ʹ����ʾ���ġ�
	sleep, 50 ; ��Ϣһ�¡���
	ControlFocus,,ahk_id %ctrlid% ;�н���Ż���ʾ���ġ�
return


