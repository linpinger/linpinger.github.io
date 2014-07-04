; ����: ͨ�ú���
; ����: L��
; ����: 2014-05-29

; {-- ����
GeneralW_StrToGBK(StrIn) {
	VarSetCapacity(GBK, StrPut(StrIn, "CP936"), 0)
	StrPut(StrIn, &GBK, "CP936")
	Return GBK
}
GeneralW_StrToUTF8(StrIn) {
	VarSetCapacity(UTF8, StrPut(StrIn, "UTF-8"), 0)
	StrPut(StrIn, &UTF8, "UTF-8")
	Return UTF8
}
GeneralW_UTF8ToStr(UTF8) {
	Return StrGet(UTF8, "UTF-8")
}
; }-- ����

GeneralW_UTF8_UrlEncode(UTF8String)
{
	OldFormat := A_FormatInteger
	SetFormat, Integer, H

	Loop, Parse, UTF8String
	{
		if A_LoopField is alnum
		{
			Out .= A_LoopField
			continue
		}
		Hex := SubStr( Asc( A_LoopField ), 3 )
		; {����:1
		NewHex := RegExReplace(StrLen( Hex ) = 1 ? "0" . Hex : Hex, "(..)(..)", "%$2%$1")
		if instr(NewHex, "%")
			Out .= NewHex
		else
			Out .= "%" . NewHex
		; }����:1
		; {����:2
		/*
		if ( StrLen(Hex) = 4 ) {
			StringSplit, xx_, Hex
			out .= "%" . xx_3 . xx_4 . "%" . xx_1 . xx_2
		} else {
			Out .= "%" . ( StrLen( Hex ) = 1 ? "0" . Hex : Hex )
		}
		*/
		; }����:2
	}
	SetFormat, Integer, %OldFormat%
	return Out
}

; {
GeneralW_htmlUnGZip(inFileName, sCharSet="") ; ��ѹgzѹ����HTML,������ȷ�ı������� ������L�棬���� zlib1.dll
{
	nCount := GetunGZSize(inFileName)  ; Method 1

	VarSetCapacity(sInFileName, 1000)
	DllCall("WideCharToMultiByte", "Uint", 0, "Uint", 0, "str", infilename, "int", -1, "str", sInFileName, "int", 1000, "Uint", 0, "Uint", 0)
	infile := DllCall("zlib1\gzopen", "Str" , sInFileName , "Str", "rb", "Cdecl")
	if ( ! infile )
		return 0
	
	VarSetCapacity(buffer,nCount)  ; Method 1
	num_read := DllCall("zlib1\gzread", "UPtr", infile, "UPtr", &buffer, "UInt", nCount, "Cdecl")  ; Method 1

	; Method 2
	/*
	; ÿ�ζ�ȡ500K��Ԥ�ݻ�ȡ��С
	VarSetCapacity(buffer,512000)
	num_read := 0
	nCount := 0  ; ѹ��ǰ��С
	while ((num_read := DllCall("zlib1\gzread", "UPtr", infile, "UPtr", &buffer, "UInt", 512000, "Cdecl")) > 0)
		nCount += num_read
	
	if ( nCount > 512000 ) {
		; ��ȡָ��ص�ͷ��
		Dllcall("zlib1\gzrewind", "UPtr", infile, "Cdecl")
		VarSetCapacity(buffer,nCount)
		num_read := DllCall("zlib1\gzread", "UPtr", infile, "UPtr", &buffer, "UInt", nCount, "Cdecl")
	}
	*/
	; Method 2

	if ( sCharSet = "" ) {
		; Ĭ���ַ�������ΪGB2312���������ҳ charset��Ϊutf-8�������¶�ȡΪutf-8
		xx := strget(&buffer+0, nCount, "CP0")
		if instr(xx, "charset")
		{
			regexmatch(xx, "Ui)<meta[^>]+charset([^>]+)>", Encode_)
			If instr(Encode_1, "UTF-8")
				xx := strget(&buffer+0, nCount, "UTF-8")
		}
	} else {
		xx := strget(&buffer+0, nCount, sCharSet)
	}
	DllCall("zlib1\gzclose", "UPtr", infile, "Cdecl")
	infile.Close()
	VarSetCapacity(buffer, 0)
	return, xx
} ; http://www.autohotkey.com/forum/viewtopic.php?t=68170

GetunGZSize(gzPath) ; ��ȡgzip�ļ�δѹ��ǰ�Ĵ�С
{	; GZ�ļ��ĺ�4�ֽ�Ϊ�ļ�δѹ���Ĵ�С
	oFile := fileopen(gzPath, "r")
	gzID := oFile.ReadUShort()
	if ( gzID = 35615 ) { ; �����GZ�ļ�,ǰ�����ֽ���1F 8B
		oFile.Seek(-4, 2)
		ss := oFile.ReadUint()
	} else { ; �������gz�ļ�
		ss := oFile.Length
	}
	oFile.Close()
	if ( ss < 0  or ss > 10240000 ) ; 0<ss<10M
		ss := oFile.Length
	return, ss
}

; }

; { Hash

; https://github.com/jNizM/AutoHotkey_Scripts/blob/master/Functions/Checksums/MD5.ahk
GeneralW_MD5(string, encoding = "UTF-8")
{
    return CalcStringHash(string, 0x8003, encoding)
}

CalcStringHash(string, algid, encoding = "UTF-8", byref hash = 0, byref hashlength = 0)
{
    chrlength := (encoding = "CP1200" || encoding = "UTF-16") ? 2 : 1
    length := (StrPut(string, encoding) - 1) * chrlength
    VarSetCapacity(data, length, 0)
    StrPut(string, &data, floor(length / chrlength), encoding)
    return CalcAddrHash(&data, length, algid, hash, hashlength)
}

CalcAddrHash(addr, length, algid, byref hash = 0, byref hashlength = 0)
{
    static h := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, "a", "b", "c", "d", "e", "f"]
    static b := h.minIndex()
    hProv := hHash := o := ""
    if (DllCall("advapi32\CryptAcquireContext", "Ptr*", hProv, "Ptr", 0, "Ptr", 0, "UInt", 24, "UInt", 0xf0000000))
    {
        if (DllCall("advapi32\CryptCreateHash", "Ptr", hProv, "UInt", algid, "UInt", 0, "UInt", 0, "Ptr*", hHash))
        {
            if (DllCall("advapi32\CryptHashData", "Ptr", hHash, "Ptr", addr, "UInt", length, "UInt", 0))
            {
                if (DllCall("advapi32\CryptGetHashParam", "Ptr", hHash, "UInt", 2, "Ptr", 0, "UInt*", hashlength, "UInt", 0))
                {
                    VarSetCapacity(hash, hashlength, 0)
                    if (DllCall("advapi32\CryptGetHashParam", "Ptr", hHash, "UInt", 2, "Ptr", &hash, "UInt*", hashlength, "UInt", 0))
                    {
                        loop % hashlength
                        {
                            v := NumGet(hash, A_Index - 1, "UChar")
                            o .= h[(v >> 4) + b] h[(v & 0xf) + b]
                        }
                    }
                }
            }
            DllCall("advapi32\CryptDestroyHash", "Ptr", hHash)
        }
        DllCall("advapi32\CryptReleaseContext", "Ptr", hProv, "UInt", 0)
    }
    return o
}

; }
