; path:
;	where to search, drive or fully specified folder, for example C:\folder
; regex:
;	search for file names that match regex, only file name is matched, default is none
; delim:
;	filelist delimiter, default is newline `n
; showprogress:
;	show minimal progressbar in screen center, default is true
; num:
;	variable that receives number of files returned or error status when trying to obtain:
;	-1,-2: root folder handle or info, -3,-4: path handle or info, -5,-6: volume handle or info,
;	-7: USN journal handle
; plainSearchTimeout: (ms)
;	if greater than 0 (default), plain folder enumeration is used for no more than specified time.
;
; RETURN VALUE:
;	filelist or empty string if error occured (also see 'num' parameter)

ListMFTfiles( path, regex="", delim="`n", showProgress=true, byref num=0, plainSearchTimeout=0 )
{
;=== init
	t0:=A_TickCount
	drive:=substr(path,1,2)
	path:=(substr(path,0)="\") ? path : path "\"

	OPEN_EXISTING:=3
	FILE_FLAG_BACKUP_SEMANTICS:=0x2000000
	SHARE_RW:=3 ;FILE_SHARE_READ | FILE_SHARE_WRITE
	GENERIC_RW:=0xC0000000 ;GENERIC_READ | GENERIC_WRITE

;=== if path can be enumerated within specified time, return filelist at once
	if( plainSearchTimeout>0 )
	{
		num:=0
		bUsePath:=true
		VarSetCapacity(filelist,1000*200) ; 1000 filepaths of ~100 widechars
		loop,%path%*,1,1 ;folders too, with recursion
			if( A_TickCount-t0>plainSearchTimeout )
			{
				bUsePath:=false
				break
			}
			else if( regex="" || regExMatch(A_LoopFileName,regex) )
			{
				filelist.=A_LoopFileLongPath delim
				num++
			}
		if( bUsePath )
		{
			VarSetCapacity(filelist,-1)
			Sort,filelist,D%delim%
			return filelist
		}
	}

;=== get root folder ("\") refnumber

	hRoot:=dllCall("CreateFile","wstr","\\.\" drive "\", "uint",0, "uint",SHARE_RW, "uint",0
					, "uint",OPEN_EXISTING, "uint",FILE_FLAG_BACKUP_SEMANTICS, "uint",0)
	if( hRoot=-1 )
	{
		num:=-1
		return
	}
	;BY_HANDLE_FILE_INFORMATION
	;	0	DWORD dwFileAttributes;
	;	4	FILETIME ftCreationTime;
	;	12	FILETIME ftLastAccessTime;
	;	20	FILETIME ftLastWriteTime;
	;	28	DWORD dwVolumeSerialNumber;
	;	32	DWORD nFileSizeHigh;
	;	36	DWORD nFileSizeLow;
	;	40	DWORD nNumberOfLinks;
	;	44	DWORD nFileIndexHigh;
	;	48	DWORD nFileIndexLow;
	VarSetCapacity(fi,52,0)
	ok:=dllCall("GetFileInformationByHandle", "uint",hRoot, "uint",&fi)
	dllCall("CloseHandle", "uint",hRoot)
	if( ok=0 )
	{
		num:=-2
		return
	}
	dirdict:={}
	ref:=((numget(fi,44)<<32)+numget(fi,48)) ;nFileIndex
	dirdict[ref]:={"name":drive, "parent":"0", "files":{}}

;=== open volume

	hJRoot:=dllCall("CreateFile", "wstr","\\.\" drive, "uint",GENERIC_RW, "uint",SHARE_RW, "uint",0
				, "uint",OPEN_EXISTING, "uint",FILE_FLAG_SEQUENTIAL_SCAN:=0x08000000, "uint",0)
	if( hJRoot=-1 )
	{
		num:=-5
		return
	}

;=== open USN journal

	VarSetCapacity(cujd,16) ;CREATE_USN_JOURNAL_DATA
	numput(0x800000,cujd,0,"uint64")
	numput(0x100000,cujd,8,"uint64")
	ok:=dllCall("DeviceIoControl", "uint",hJRoot, "uint",FSCTL_CREATE_USN_JOURNAL:=0x000900e7
				, "uint",&cujd, "uint",16, "uint",0, "uint",0, "uintp",cb, "uint",0)
	if( ok=0 )
	{
		dllCall("CloseHandle", "uint",hJRoot)
		num:=-6
		return
	}

;=== estimate overall number of files

	;NTFS_VOLUME_DATA_BUFFER
	;	0	LARGE_INTEGER VolumeSerialNumber;
	;	8	LARGE_INTEGER NumberSectors;
	;	16	LARGE_INTEGER TotalClusters;
	;	24	LARGE_INTEGER FreeClusters;
	;	32	LARGE_INTEGER TotalReserved;
	;	40	DWORD		 BytesPerSector;
	;	44	DWORD		 BytesPerCluster;
	;	48	DWORD		 BytesPerFileRecordSegment;
	;	52	DWORD		 ClustersPerFileRecordSegment;
	;	56	LARGE_INTEGER MftValidDataLength;
	;	64	LARGE_INTEGER MftStartLcn;
	;	72	LARGE_INTEGER Mft2StartLcn;
	;	80	LARGE_INTEGER MftZoneStart;
	;	88	LARGE_INTEGER MftZoneEnd;
	VarSetCapacity(voldata,96,0)
	mftFiles:=0
	mftFilesMax:=0
	if( dllCall("DeviceIoControl", "uint",hJRoot, "uint",FSCTL_GET_NTFS_VOLUME_DATA:=0x00090064, "uint",0, "uint",0, "uint",&voldata, "uint",96, "uintp",cb, "uint",0) && cb=96 )
		if( i:=numget(voldata,48) )
			mftFilesMax:=numget(voldata,56,"uint64")//i ;MftValidDataLength/BytesPerFileRecordSegment

;=== query USN journal

	;USN_JOURNAL_DATA
	;	0	DWORDLONG UsnJournalID;
	;	8	USN FirstUsn;
	;	16	USN NextUsn;
	;	24	USN LowestValidUsn;
	;	32	USN MaxUsn;
	;	40	DWORDLONG MaximumSize;
	;	48	DWORDLONG AllocationDelta;
	VarSetCapacity(ujd,56,0)
	if( dllCall("DeviceIoControl", "uint",hJRoot, "uint",FSCTL_QUERY_USN_JOURNAL:=0x000900f4, "uint",0, "uint",0, "uint",&ujd, "uint",56, "uintp",cb, "uint",0)=0 )
	{
		dllCall("CloseHandle", "uint",hJRoot)
		num:=-7
		return
	}
	JournalMaxSize:=numget(ujd,40,"uint64")+numget(ujd,48,"uint64") ;MaximumSize+AllocationDelta
	JournalChunkSize:=0x10000 ;1MB chunk, ~10-20 read ops for 150k files
	if( mftFilesMax=0 )
		mftFilesMax:=JournalMaxSize/JournalChunkSize

	t1:=A_TickCount
	if showprogress
		Progress,b p0

;=== enumerate USN journal

	cb:=0
	num:=0
	numD:=0
	VarSetCapacity(pData,8+JournalChunkSize,0)
	dirdict.SetCapacity(JournalMaxSize//(128*50)) ;average file name ~64 widechars, dircount is ~1/50 of filecount

	;MFT_ENUM_DATA
	;	0	DWORDLONG StartFileReferenceNumber;
	;	8	USN LowUsn;
	;	16	USN HighUsn;
	VarSetCapacity(med,24,0)
	numput(numget(ujd,16,"uint64"),med,16,"uint64") ;med.HighUsn=ujd.NextUsn

	while( dllCall("DeviceIoControl", "uint",hJRoot, "uint",FSCTL_ENUM_USN_DATA:=0x000900b3, "uint",&med, "uint",24, "uint",&pData, "uint",8+JournalChunkSize, "uintp",cb, "uint",0) )
	{
		t1a:=A_TickCount
		if showprogress
			Progress,% (mftFiles*80)//mftFilesMax

		pUSN:=&pData+8
		while( cb>8 )
		{
			mftFiles++
			;USN_RECORD
			;	0	DWORD RecordLength;
			;	4	WORD   MajorVersion;
			;	6	WORD   MinorVersion;
			;	8	DWORDLONG FileReferenceNumber;
			;	16	DWORDLONG ParentFileReferenceNumber;
			;	24	USN Usn;
			;	32	LARGE_INTEGER TimeStamp;
			;	40	DWORD Reason;
			;	44	DWORD SourceInfo;
			;	48	DWORD SecurityId;
			;	52	DWORD FileAttributes;
			;	56	WORD   FileNameLength;
			;	58	WORD   FileNameOffset;
			;	60	WCHAR FileName[1];
			fnsize:=numget(pUSN+56,"ushort")
			fname:=strget(pUSN+60,fnsize//2,"UTF-16")
			isdir:=numget(pUSN+52) & 0x10 ;USN.FileAttributes & FILE_ATTRIBUTE_DIRECTORY
			ref:=numget(pUSN+8,"uint64") ;USN.FileReferenceNumber
			refparent:=numget(pUSN+16,"uint64") ;USN.ParentFileReferenceNumber

			if( isdir )
			{
				v:=dirdict[ref]
				if( v="" )
					v:={}, v.files:={}
				v.setCapacity(4) ;4th value 'dir' is created later in resolveFolder()
				v.setCapacity("name",fnsize), v.name:=fname
				v.setCapacity("parent",strlen(refparent)<<1), v.parent:=refparent
				dirdict[ref]:=v
				numD++
			}
			else if( regex="" || regExMatch(fname,regex) )
			{
				v:=dirdict[refparent]
				if( v )
					v:=v.files
				else
					v:={}, dirdict[refparent]:={"files":v}
				v.SetCapacity(ref,fnsize), v[ref]:=fname
				num++
			}

			i:=numget(pUSN+0) ;USN.RecordLength
			pUSN += i
			cb -= i
		}

		nextUSN:=numget(pData,"uint64")
		numput(nextUSN,med,"uint64")

		t1b+=A_TickCount-t1a
	}

	dllCall("CloseHandle", "uint",hJRoot)

	t2:=A_TickCount
	if showprogress
		Progress,80

;=== connect files to parent folders & build new cache
	VarSetCapacity(filelist,num*200) ;average full filepath ~100 widechars
	bPathFilter:=strlen(path)>3 && instr(FileExist(path),"D")>0
	num:=0
	for dk,dv in dirdict
		if( dv.files.getCapacity() )
		{
			dir:=_ListMFTfiles_resolveFolder(dirdict,dk)
			if( !bPathFilter || instr(dir,path)=1 )
				for k,v in dv.files
					filelist.=dir v delim, num++
		}

	dirdict=
	VarSetCapacity(filelist,-1)

	t3:=A_TickCount
	if showprogress
		Progress,85

;=== sort
	Sort,filelist,D%delim%

	t4:=A_TickCount
	if showprogress
		Progress,OFF

	;msgbox % "init`tenum`twinapi`tconnect`tsort`ttotal, ms`n" (t1-t0) "`t" t1b "`t" (t2-t1-t1b) "`t" (t3-t2) "`t" (t4-t3) "`t" (t4-t0) "`n`ndirs:`t" numD "`nfiles:`t" num
	return filelist
}

_ListMFTfiles_resolveFolder( byref dirdict, byref ddref )
{
	p:=dirdict[ddref], pd:=p.dir
	if( !pd )
	{
		pd:=(p.parent ? _ListMFTfiles_resolveFolder(dirdict,p.parent) : "") p.name "\"
		p.setCapacity("dir",strlen(pd)*2)
		p.dir:=pd
	}
	return pd
}

