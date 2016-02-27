
SetCompressor /solid lzma

!define PRODUCT_NAME "Particle CLI"
!define SHORT_NAME "ParticleCLI"

; The name of the installer
Name "${PRODUCT_NAME}"
!include 'LogicLib.nsh'
!include 'Sections.nsh'
!include 'TextFunc.nsh'
!include "DotNetChecker.nsh"
!include 'x64.nsh'
!insertmacro VersionCompare
!insertmacro ConfigWrite
!define REG_PATH "Software\${SHORT_NAME}"

;FileExists is already part of LogicLib, but returns true for directories as well as files
!macro _FileExists2 _a _b _t _f
	!insertmacro _LOGICLIB_TEMP
	StrCpy $_LOGICLIB_TEMP "0"
	StrCmp `${_b}` `` +4 0 ;if path is not blank, continue to next check
	IfFileExists `${_b}` `0` +3 ;if path exists, continue to next check (IfFileExists returns true if this is a directory)
	IfFileExists `${_b}\*.*` +2 0 ;if path is not a directory, continue to confirm exists
	StrCpy $_LOGICLIB_TEMP "1" ;file exists
	;now we have a definitive value - the file exists or it does not
	StrCmp $_LOGICLIB_TEMP "1" `${_t}` `${_f}`
!macroend
!undef FileExists
!define FileExists `"" FileExists2`
!macro _DirExists _a _b _t _f
	!insertmacro _LOGICLIB_TEMP
	StrCpy $_LOGICLIB_TEMP "0"	
	StrCmp `${_b}` `` +3 0 ;if path is not blank, continue to next check
	IfFileExists `${_b}\*.*` 0 +2 ;if directory exists, continue to confirm exists
	StrCpy $_LOGICLIB_TEMP "1"
	StrCmp $_LOGICLIB_TEMP "1" `${_t}` `${_f}`
!macroend
!define DirExists `"" DirExists`

!macro IfKeyExists ROOT MAIN_KEY KEY
  Push $R0
  Push $R1
  Push $R2
 
  # XXX bug if ${ROOT}, ${MAIN_KEY} or ${KEY} use $R0 or $R1
 
  StrCpy $R1 "0" # loop index
  StrCpy $R2 "0" # not found
 
  ${Do}
    EnumRegKey $R0 ${ROOT} "${MAIN_KEY}" "$R1"
    ${If} $R0 == "${KEY}"
      StrCpy $R2 "1" # found
      ${Break}
    ${EndIf}
    IntOp $R1 $R1 + 1
  ${LoopWhile} $R0 != ""
 
  ClearErrors
 
  Exch 2
  Pop $R0
  Pop $R1
  Exch $R2
!macroend
 

!macro _StrReplaceConstructor ORIGINAL_STRING TO_REPLACE REPLACE_BY
  Push "${ORIGINAL_STRING}"
  Push "${TO_REPLACE}"
  Push "${REPLACE_BY}"
  Call StrRep
  Pop $0
!macroend
 
!define StrReplace '!insertmacro "_StrReplaceConstructor"'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!define JSON_ADDRESS "https://raw.githubusercontent.com/mumblepins/Particle-CLI-Installer/master/sources.json"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ShowInstDetails show

; The file to write
OutFile "${SHORT_NAME}.exe"

XPStyle on
InstallColors /windows

; The default installation directory
Function .onInit
    StrCpy "$INSTDIR" "$WINDIR" 2
    StrCpy "$INSTDIR" "$INSTDIR\Particle"
    
    Var /GLOBAL TempFile
    Var /GLOBAL TempString
    
    Var /GLOBAL GCC_ARM_ADDRESS
    Var /GLOBAL MAKE_BINARY_ADDRESS
    Var /GLOBAL MAKE_DEPEND_ADDRESS
    Var /GLOBAL MINGW_ADDRESS
    Var /GLOBAL GIT_ADDRESS
    Var /GLOBAL NETBEANS_ADDRESS
    Var /GLOBAL JDK_ADDRESS
    Var /GLOBAL JDK64_ADDRESS
    Var /GLOBAL CYGWIN_ADDR
    Var /GLOBAL CYGWIN64_ADDR
    Var /GLOBAL NODE_ADDR
    Var /GLOBAL NODE64_ADDR
    Var /GLOBAL PYTHON_ADDR
    Var /GLOBAL PYTHON64_ADDR
    Var /GLOBAL MSBUILD_ADDR
    Var /GLOBAL VSEXP_ADDR
    
    
    Var /GLOBAL GCC_ARM_VER
    Var /GLOBAL MAKE_BINARY_VER
    Var /GLOBAL MAKE_DEPEND_VER
    Var /GLOBAL MINGW_VER
    Var /GLOBAL GIT_VER
    Var /GLOBAL NETBEANS_VER
    Var /GLOBAL JDK_VER
    Var /GLOBAL JDK64_VER
    Var /GLOBAL CYGWIN_VER
    Var /GLOBAL CYGWIN64_VER
    Var /GLOBAL NODE_VER
    Var /GLOBAL NODE64_VER
    Var /GLOBAL PYTHON_VER
    Var /GLOBAL PYTHON64_VER
    Var /GLOBAL MSBUILD_VER
	Var /GLOBAL VSEXP_VER
    
    StrCpy "$TempFile" "$TEMP\release_info.json"
    inetc::get /QUESTION "" /BANNER "Downloading Installation Info"  /CAPTION "Downloading..." /RESUME "" "${JSON_ADDRESS}" "$TempFile" /END
    nsJSON::Set /file "$TempFile"
    ClearErrors
    nsJSON::Get /noexpand `GCC` `url` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$GCC_ARM_ADDRESS" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `MAKE_BIN` `url` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$MAKE_BINARY_ADDRESS" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `MAKE_DEP` `url` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$MAKE_DEPEND_ADDRESS" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `MINGW` `url` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$MINGW_ADDRESS" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `GIT` `url` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$GIT_ADDRESS" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `NETBEANS` `url` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$NETBEANS_ADDRESS" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `JDK` `url` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$JDK_ADDRESS" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `JDK64` `url` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$JDK64_ADDRESS" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `CYGWIN_X86` `url` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$CYGWIN_ADDR" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `CYGWIN_X86_64` `url` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$CYGWIN64_ADDR" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `NODEJS` `url` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$NODE_ADDR" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `NODEJS_64` `url` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$NODE64_ADDR" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `PYTHON` `url` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$PYTHON_ADDR" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `PYTHON64` `url` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$PYTHON64_ADDR" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `MS_BUILD` `url` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$MSBUILD_ADDR" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `VS_EXPRESS` `url` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$VSEXP_ADDR" "$R0"
    ${EndIf}
    
    
    
    
    ClearErrors
    nsJSON::Get /noexpand `GCC` `ver` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$GCC_ARM_VER" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `MAKE_BIN` `ver` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$MAKE_BINARY_VER" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `MAKE_DEP` `ver` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$MAKE_DEPEND_VER" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `MINGW` `ver` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$MINGW_VER" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `GIT` `ver` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$GIT_VER" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `NETBEANS` `ver` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$NETBEANS_VER" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `JDK` `ver` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$JDK_VER" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `JDK64` `ver` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$JDK64_VER" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `CYGWIN_X86` `ver` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$CYGWIN_VER" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `CYGWIN_X86_64` `ver` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$CYGWIN64_VER" "$R0"
    ${EndIf}
    
     ClearErrors
    nsJSON::Get /noexpand `NODEJS` `ver` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$NODE_VER" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `NODEJS_64` `ver` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$NODE64_VER" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `PYTHON` `ver` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$PYTHON_VER" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `PYTHON64` `ver` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$PYTHON64_VER" "$R0"
    ${EndIf}
     
    ClearErrors
    nsJSON::Get /noexpand `MS_BUILD` `ver` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$MSBUILD_VER" "$R0"
    ${EndIf}
    
    ClearErrors
    nsJSON::Get /noexpand `VS_EXPRESS` `ver` /end
    ${IfNot} ${Errors}
        Pop $R0
        StrCpy "$VSEXP_VER" "$R0"
    ${EndIf}
FunctionEnd



; Registry key to check for directory (so if you install again, it will
; overwrite the old one automatically)
InstallDirRegKey HKLM "${REG_PATH}" "Install_Dir"

; Request application privileges for Windows Vista
RequestExecutionLevel admin

;--------------------------------

; Pages

Page components
Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

InstType "Full"


;--------------------------------

; The stuff to install



Section "Particle CLI"
	SectionIn 1 RO
	AddSize 123801
	Call InstallParticleCLI
SectionEnd

Section "DFU Util"
	SectionIn 1 3
	
	SetOutPath "$INSTDIR\Tools\DFU-util"
	File dfu*.exe
	File libusb*.dll
	DetailPrint "Adding Path"
	Push "$INSTDIR\Tools\DFU-util"
	Call AddToPath
SectionEnd

Section
    ; Write the installation path into the registry
    WriteRegStr HKLM ${REG_PATH} "Install_Dir" "$INSTDIR"

    ; Write the uninstall keys for Windows
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SHORT_NAME}" "DisplayName" "${PRODUCT_NAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SHORT_NAME}" "UninstallString" '"$INSTDIR\uninstall.exe"'
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SHORT_NAME}" "NoModify" 1
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SHORT_NAME}" "NoRepair" 1
    WriteUninstaller "uninstall.exe"
SectionEnd


;--------------------------------

; Uninstaller

Section "Uninstall"

    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${SHORT_NAME}"
    DeleteRegKey HKLM ${REG_PATH} 

	RMDir /r /REBOOTOK "$INSTDir\Tools\DFU-util"
	
    Delete $INSTDIR\uninstall.exe

   
    RMDir "$INSTDIR"
    Push "$INSTDIR\Tools\DFU-util"
	Call un.RemoveFromPath
     
SectionEnd





Function InstallParticleCLI


	;; Install NodeJS
	DetailPrint "Checking NodeJs Version Installed"
	ClearErrors
	ReadRegStr $0 HKLM "${REG_PATH}" "NodeJs_Version"
	IfErrors 0 CheckNodeJS_Ver
	call  InstallNodeJS
	CheckNodeJS_Ver:
	${VersionCompare} $0 "$NODE_VER" $R0
    ${If} $R0 = 2
        DetailPrint "Need to update NodeJS"
        call InstallNodeJS
	${Else}
		goto CheckCLI
    ${EndIf}
	
	
	CheckCLI:
	  ;; set path
    ReadEnvStr $R0 "PATH"
	StrCpy $R0 "$R0;$INSTDIR\Tools\NodeJS;$APPDATA\npm"
    System::Call 'Kernel32::SetEnvironmentVariable(t, t) i("PATH", R0).r0'
    ReadEnvStr $R0 "PATH"
    DetailPrint $R0
     
    ;; check if particle-cli installed
    SetOutPath "$APPDATA\npm"
    nsExec::ExecToLog "$INSTDIR\Tools\NodeJS\npm.cmd ls particle-cli --parseable true"
    Pop $0
    DetailPrint $0
    ${If} $0 = 0 ; particle-cli seems to be installed, let's just run an update
		DetailPrint "Updating Particle CLI"
		SetOutPath "$INSTDIR\TOOLS\NodeJS"
		nsExec::ExecToLog 'npm update particle-cli'
	${else}
		; let's try this 
		DetailPrint "Installing Particle CLI"
		SetOutPath "$INSTDIR\TOOLS\NodeJS"
		;File install-particle-cli.bat
	   ; nsExec::ExecToLog 'install-particle-cli.bat'
		nsExec::ExecToLog "$INSTDIR\Tools\NodeJS\npm.cmd install -g particle-cli"
		Pop $0
		DetailPrint $0
		${If} $0 = 0
			; sucecess!! Let's just go to the end of the function
			goto EndFunc
		${Else}
			;; didn't install.  Let's install prerequisities and try again
			;call InstallDotNet
			;call InstallMSBuildTools
			MessageBox MB_YESNO|MB_ICONEXCLAMATION "Particle CLI didn't install properly. Shall we try installing Python and Visual Studio Express 2015 (recommended)? This should fix the issue." /SD IDYES IDNO EndFunc
			call InstallVSExpress
			call InstallPython
			SetOutPath "$TEMP"
			File ParticleInstall.bat
			nsExec::ExecToLog "ParticleInstall.bat"
			Pop $0
			Delete ParticleInstall.bat
			DetailPrint $0
			${If} $0 = 0
				;; this time we had success
				goto EndFunc
			${Else}
				;; still no success, throw a message at the user
				MessageBox MB_OK|MB_ICONEXCLAMATION 'particle-cli failed to install. Once the installer exits, try opening a command window and running "npm install -g particle-cli"' /SD IDOK
				goto EndFunc
			${EndIf}
		${EndIf}
		;Delete install-particle-cli.bat
    ${endif}
	
	EndFunc:
FunctionEnd

Function InstallNodeJS
    SetOutPath "$InstDir"
	DetailPrint "Downloading NodeJS"
    StrCpy "$TempFile" "$TEMP\node_setup.msi"
    Download:
    ${If} ${RunningX64}
        ; 64 bit code
        inetc::get /QUESTION "" /RESUME "" /USERAGENT "Wget/1.9.1" "$NODE64_ADDR" "$TempFile" /END
    ${Else}
        ; 32 bit code
        inetc::get /QUESTION "" /RESUME "" /USERAGENT "Wget/1.9.1" "$NODE_ADDR" "$TempFile" /END
    ${EndIf}
    Pop $0
    StrCmp $0 "OK" dlok
    SetDetailsView show
    DetailPrint "Error: $0"
    MessageBox MB_RETRYCANCEL|MB_ICONEXCLAMATION "Download error, Retry?" /SD IDCANCEL IDRETRY Download
    Abort
    dlok:
    DetailPrint "Installing NodeJS"
    ;SetDetailsPrint none
    ExecWait 'msiexec /i "$TempFile" INSTALLDIR="$INSTDIR\Tools\NodeJS" /passive'
    SetDetailsPrint both
    Delete "$TempFile"
    WriteRegStr HKLM "${REG_PATH}" "NodeJs_Version" "$NODE_VER"
FunctionEnd


Function InstallVSExpress
	DetailPrint "Downloading VS Express"
    StrCpy "$TempFile" "$TEMP\vsexpress_setup.exe"
    Download:
	inetc::get /QUESTION "" /RESUME "" /USERAGENT "Wget/1.9.1" "$VSEXP_ADDR" "$TempFile" /END
  
    Pop $0
    StrCmp $0 "OK" dlok2
    SetDetailsView show
    DetailPrint "Error: $0"
    MessageBox MB_RETRYCANCEL|MB_ICONEXCLAMATION "Download error, Retry?" /SD IDCANCEL IDRETRY Download
    Abort
    dlok2:
    DetailPrint "Installing Visual Studio Express"
    ExecWait '$TempFile /Passive /NoRestart'
    Delete "$TempFile"
FunctionEnd

Function InstallPython
	;; Install Python
    DetailPrint "Checking Python Version Installed"
	ClearErrors
	ReadRegStr $0 HKLM "${REG_PATH}" "Python_Version"
	IfErrors 0 CheckPython_Ver
	goto  InstallPy
	CheckPython_Ver:
	${VersionCompare} $0 "$PYTHON_VER" $R0
    ${If} $R0 == 2
        DetailPrint "Need to update Python"
        goto InstallPy
	${Else}
		goto PythonInstalled
    ${EndIf}
	
	InstallPy:
	DetailPrint "Downloading Python"
    StrCpy "$TempFile" "$TEMP\python_setup.msi"
    Download:
    ${If} ${RunningX64}
        ; 64 bit code
        inetc::get /QUESTION "" /RESUME "" /USERAGENT "Wget/1.9.1" "$PYTHON64_ADDR" "$TempFile" /END
    ${Else}
        ; 32 bit code
        inetc::get /QUESTION "" /RESUME "" /USERAGENT "Wget/1.9.1" "$PYTHON_ADDR" "$TempFile" /END
    ${EndIf}
    Pop $0
    StrCmp $0 "OK" dlok2
    SetDetailsView show
    DetailPrint "Error: $0"
    MessageBox MB_RETRYCANCEL|MB_ICONEXCLAMATION "Download error, Retry?" /SD IDCANCEL IDRETRY Download
    Abort
    dlok2:
    DetailPrint "Installing Python"
    ExecWait 'msiexec /i "$TempFile" ALLUSERS=1 TARGETDIR="$INSTDIR\Tools\Python27" /passive ADDLOCAL=ALL'
    Delete "$TempFile"
    ;Push "$INSTDIR\Tools\Python27"
    ;Call AddToPath
    WriteRegStr HKLM "${REG_PATH}" "Python_Version" "$PYTHON_VER"
    goto EndFunc
    
    PythonInstalled:
    DetailPrint "Python Already Installed"
    
    EndFunc:
FunctionEnd
;--------------------------------------------------------------------
; Path functions
;
; Based on example from:
; http://nsis.sourceforge.net/Path_Manipulation
;


!include "WinMessages.nsh"

; Registry Entry for environment (NT4,2000,XP)
; All users:
;!define Environ 'HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"'
; Current user only:
!define Environ 'HKCU "Environment"'


; AddToPath - Appends dir to PATH
;   (does not work on Win9x/ME)
;
; Usage:
;   Push "dir"
;   Call AddToPath

Function AddToPath
    Exch $0
    Push $1
    Push $2
    Push $3
    Push $4

    ; NSIS ReadRegStr returns empty string on string overflow
    ; Native calls are used here to check actual length of PATH

    ; $4 = RegOpenKey(HKEY_CURRENT_USER, "Environment", &$3)
    System::Call "advapi32::RegOpenKey(i 0x80000001, t'Environment', *i.r3) i.r4"
    IntCmp $4 0 0 done done
    ; $4 = RegQueryValueEx($3, "PATH", (DWORD*)0, (DWORD*)0, &$1, ($2=NSIS_MAX_STRLEN, &$2))
    ; RegCloseKey($3)
    System::Call "advapi32::RegQueryValueEx(i $3, t'PATH', i 0, i 0, t.r1, *i ${NSIS_MAX_STRLEN} r2) i.r4"
    System::Call "advapi32::RegCloseKey(i $3)"

    IntCmp $4 234 0 +4 +4 ; $4 == ERROR_MORE_DATA
    DetailPrint "AddToPath: original length $2 > ${NSIS_MAX_STRLEN}"
    MessageBox MB_OK "PATH not updated, original length $2 > ${NSIS_MAX_STRLEN}"
    Goto done

    IntCmp $4 0 +5 ; $4 != NO_ERROR
    IntCmp $4 2 +3 ; $4 != ERROR_FILE_NOT_FOUND
    DetailPrint "AddToPath: unexpected error code $4"
    Goto done
    StrCpy $1 ""

    ; Check if already in PATH
    Push "$1;"
    Push "$0;"
    Call StrStr
    Pop $2
    StrCmp $2 "" 0 done
    Push "$1;"
    Push "$0\;"
    Call StrStr
    Pop $2
    StrCmp $2 "" 0 done

    ; Prevent NSIS string overflow
    StrLen $2 $0
    StrLen $3 $1
    IntOp $2 $2 + $3
    IntOp $2 $2 + 2 ; $2 = strlen(dir) + strlen(PATH) + sizeof(";")
    IntCmp $2 ${NSIS_MAX_STRLEN} +4 +4 0
    DetailPrint "AddToPath: new length $2 > ${NSIS_MAX_STRLEN}"
    MessageBox MB_OK "PATH not updated, new length $2 > ${NSIS_MAX_STRLEN}."
    Goto done

    ; Append dir to PATH
    DetailPrint "Add to PATH: $0"
    StrCpy $2 $1 1 -1
    StrCmp $2 ";" 0 +2
    StrCpy $1 $1 -1 ; remove trailing ';'
    StrCmp $1 "" +2   ; no leading ';'
    StrCpy $0 "$1;$0"
    WriteRegExpandStr ${Environ} "PATH" $0
    SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

    done:
    Pop $4
    Pop $3
    Pop $2
    Pop $1
    Pop $0
FunctionEnd


; RemoveFromPath - Removes dir from PATH
;
; Usage:
;   Push "dir"
;   Call RemoveFromPath

Function un.RemoveFromPath
    Exch $0
    Push $1
    Push $2
    Push $3
    Push $4
    Push $5
    Push $6

    ReadRegStr $1 ${Environ} "PATH"
    StrCpy $5 $1 1 -1
    StrCmp $5 ";" +2
    StrCpy $1 "$1;" ; ensure trailing ';'
    Push $1
    Push "$0;"
    Call un.StrStr
    Pop $2 ; pos of our dir
    StrCmp $2 "" done

    DetailPrint "Remove from PATH: $0"
    StrLen $3 "$0;"
    StrLen $4 $2
    StrCpy $5 $1 -$4 ; $5 is now the part before the path to remove
    StrCpy $6 $2 "" $3 ; $6 is now the part after the path to remove
    StrCpy $3 "$5$6"
    StrCpy $5 $3 1 -1
    StrCmp $5 ";" 0 +2
    StrCpy $3 $3 -1 ; remove trailing ';'
    WriteRegExpandStr ${Environ} "PATH" $3
    SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

    done:
    Pop $6
    Pop $5
    Pop $4
    Pop $3
    Pop $2
    Pop $1
    Pop $0
FunctionEnd


; StrStr - find substring in a string
;
; Usage:
;   Push "this is some string"
;   Push "some"
;   Call StrStr
;   Pop $0 ; "some string"

!macro StrStr un
    Function ${un}StrStr
        Exch $R1 ; $R1=substring, stack=[old$R1,string,...]
        Exch     ;                stack=[string,old$R1,...]
        Exch $R2 ; $R2=string,    stack=[old$R2,old$R1,...]
        Push $R3
        Push $R4
        Push $R5
        StrLen $R3 $R1
        StrCpy $R4 0
        ; $R1=substring, $R2=string, $R3=strlen(substring)
        ; $R4=count, $R5=tmp
        loop:
        StrCpy $R5 $R2 $R3 $R4
        StrCmp $R5 $R1 done
        StrCmp $R5 "" done
        IntOp $R4 $R4 + 1
        Goto loop
        done:
        StrCpy $R1 $R2 "" $R4
        Pop $R5
        Pop $R4
        Pop $R3
        Pop $R2
        Exch $R1 ; $R1=old$R1, stack=[result,...]
    FunctionEnd
!macroend
!insertmacro StrStr ""
!insertmacro StrStr "un."



Function StrRep
  Exch $R4 ; $R4 = Replacement String
  Exch
  Exch $R3 ; $R3 = String to replace (needle)
  Exch 2
  Exch $R1 ; $R1 = String to do replacement in (haystack)
  Push $R2 ; Replaced haystack
  Push $R5 ; Len (needle)
  Push $R6 ; len (haystack)
  Push $R7 ; Scratch reg
  StrCpy $R2 ""
  StrLen $R5 $R3
  StrLen $R6 $R1
loop:
  StrCpy $R7 $R1 $R5
  StrCmp $R7 $R3 found
  StrCpy $R7 $R1 1 ; - optimization can be removed if U know len needle=1
  StrCpy $R2 "$R2$R7"
  StrCpy $R1 $R1 $R6 1
  StrCmp $R1 "" done loop
found:
  StrCpy $R2 "$R2$R4"
  StrCpy $R1 $R1 $R6 $R5
  StrCmp $R1 "" done loop
done:
  StrCpy $R3 $R2
  Pop $R7
  Pop $R6
  Pop $R5
  Pop $R2
  Pop $R1
  Pop $R4
  Exch $R3
FunctionEnd

Function WriteToolchainProperties
	SetOverWrite off
    ; Writes the toolchain properties for netbeans.  Won't overwrite existing
    ; config file, so if Netbeans has already been installed, this will need to be set up manually
    SetOutPath "$APPDATA\NetBeans\$NETBEANS_VER\config\Preferences\org\netbeans\modules\cnd"
    
    SetShellVarContext current
    
    StrCpy "$TempFile" "$APPDATA\NetBeans\$NETBEANS_VER\config\Preferences\org\netbeans\modules\cnd\remote.properties"
    IfFileExists "$TempFile" continue 0
    File remote.properties
    
    continue: 
    StrCpy "$TempFile" "$APPDATA\NetBeans\$NETBEANS_VER\config\Preferences\org\netbeans\modules\cnd\toolchain.properties"
    
    IfFileExists "$TempFile" toolchainExists 0
    File toolchain.properties
     
    ;C:\\Particle\\Toolchain\\GCC-ARM
    StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM"
    ${StrReplace} '$TempString' '\' '\\'
    ${ConfigWrite} "$TempFile" `=csm.localhost.setDirectory.0` `$0` $R0
    
    ;C:\\Particle\\Toolchain\\GCC-ARM\\bin\\arm-none-eabi-gcc.exe
    StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\bin\arm-none-eabi-gcc.exe"
    ${StrReplace} '$TempString' '\' '\\'
    ${ConfigWrite} "$TempFile" `=csm.localhost.toolPath.0.0` `$0` $R0
    
    ;C:\\Particle\\Toolchain\\GCC-ARM\\bin\\arm-none-eabi-g++.exe
    StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\bin\arm-none-eabi-g++.exe"
    ${StrReplace} '$TempString' '\' '\\'
    ${ConfigWrite} "$TempFile" `=csm.localhost.toolPath.0.1` `$0` $R0
    
    ;C:\\Particle\\Toolchain\\GCC-ARM\\bin\\arm-none-eabi-as.exe
    StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\bin\arm-none-eabi-as.exe"
    ${StrReplace} '$TempString' '\' '\\'
    ${ConfigWrite} "$TempFile" `=csm.localhost.toolPath.0.3` `$0` $R0
    
    ;C:\\Particle\\Toolchain\\Make\\bin\\make.exe
    StrCpy "$TempString" "$INSTDIR\Toolchain\Make\bin\make.exe"
    ${StrReplace} '$TempString' '\' '\\'
    ${ConfigWrite} "$TempFile" `=csm.localhost.toolPath.0.4` `$0` $R0
      
    ;C:\\Particle\\Toolchain\\GCC-ARM\\lib\\gcc\\arm-none-eabi\\4.9.3\\include
    StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\lib\gcc\arm-none-eabi\4.9.3\include"
    ${StrReplace} '$TempString' '\' '\\'
    ${ConfigWrite} "$TempFile" `=csm.localhost.toolSettings.0.0.systemIncludes.0` `$0` $R0
    
    ;C:\\Particle\\Toolchain\\GCC-ARM\\lib\\gcc\\arm-none-eabi\\4.9.3\\include-fixed
    StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\lib\gcc\arm-none-eabi\4.9.3\include-fixed"
    ${StrReplace} '$TempString' '\' '\\'
    ${ConfigWrite} "$TempFile" `=csm.localhost.toolSettings.0.0.systemIncludes.1` `$0` $R0
    
    ;C:\\Particle\\Toolchain\\GCC-ARM\\arm-none-eabi\\include
    StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\arm-non-eabi\include"
    ${StrReplace}  '$TempString' '\' '\\'
    ${ConfigWrite} "$TempFile" `=csm.localhost.toolSettings.0.0.systemIncludes.2` `$0` $R0
    
        
    ;C:\\Particle\\Toolchain\\GCC-ARM\\arm-none-eabi\\include\\c++\\4.9.3
    StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\arm-non-eabi\include\c++\4.9.3"
    ${StrReplace}  '$TempString' '\' '\\'
    ${ConfigWrite} "$TempFile" `=csm.localhost.toolSettings.0.1.systemIncludes.0` `$0` $R0
    
    ;C:\\Particle\\Toolchain\\GCC-ARM\\arm-none-eabi\\include\\c++\\4.9.3\\arm-none-eabi
    StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\arm-non-eabi\include\c++\4.9.3\arm-non-eabi"
    ${StrReplace} '$TempString' '\' '\\'
    ${ConfigWrite} "$TempFile" `=csm.localhost.toolSettings.0.1.systemIncludes.1` `$0` $R0
    
    ;C:\\Particle\\Toolchain\\GCC-ARM\\arm-none-eabi\\include\\c++\\4.9.3\\backward
    StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\arm-non-eabi\include\c++\4.9.3\backward"
    ${StrReplace} '$TempString' '\' '\\'
    ${ConfigWrite} "$TempFile" `=csm.localhost.toolSettings.0.1.systemIncludes.2` `$0` $R0
    
    ;C:\\Particle\\Toolchain\\GCC-ARM\\lib\\gcc\\arm-none-eabi\\4.9.3\\include
    StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\lib\gcc\arm-non-eabi\4.9.3\include"
    ${StrReplace} '$TempString' '\' '\\'
    ${ConfigWrite} "$TempFile" `=csm.localhost.toolSettings.0.1.systemIncludes.3` `$0` $R0
    
    ;C:\\Particle\\Toolchain\\GCC-ARM\\lib\\gcc\\arm-none-eabi\\4.9.3\\include-fixed
    StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\lib\gcc\arm-non-eabi\4.9.3\include-fixed"
    ${StrReplace} '$TempString' '\' '\\'
    ${ConfigWrite} "$TempFile" `=csm.localhost.toolSettings.0.1.systemIncludes.4` `$0` $R0
    
    ;C:\\Particle\\Toolchain\\GCC-ARM\\arm-none-eabi\\include
    StrCpy "$TempString" "$INSTDIR\Toolchain\GCC-ARM\arm-non-eabi\include"
    ${StrReplace} '$TempString' '\' '\\'
    ${ConfigWrite} "$TempFile" `=csm.localhost.toolSettings.0.1.systemIncludes.5` `$0` $R0
    
    toolchainExists:
    SetOutPath "$APPDATA\NetBeans\$NETBEANS_VER\config\Preferences\org\netbeans\modules\cnd\modelimpl\RepositoryUpdater"
    StrCpy "$TempFile" "$APPDATA\NetBeans\$NETBEANS_VER\config\Preferences\org\netbeans\modules\cnd\modelimpl\RepositoryUpdater\cnd.properties"
    
    IfFileExists "$TempFile" endFunc 0
    File cnd.properties
    endFunc:
    
    SetOverwrite on
FunctionEnd
    
    
    
    

    
