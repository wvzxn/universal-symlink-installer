::  Universal Symlink Installer v1.9
::  
::  [Author]
::    wvzxn | https://github.com/wvzxn/
::  
::  [Description]
::    Simple script that will help you create Symlinks faster.
::    It acts as both installer and uninstaller.
::    Learn how to use at:
::    https://github.com/wvzxn/universal-symlink-installer#usage

@echo off
rem # true/false
set "DEBUG=false"

rem #		CHECK
title %~nx0
call :testFolderName exit
setlocal EnableDelayedExpansion
call :setGlobalVar
echo !________!
call :intro
for /f "usebackq delims=" %%Q in (` powershell "'!folderName!'.ToUpper()"`) do call :centerText "%%Q"
echo !________!
call :UAC

rem #		START
if not exist .usi ( call :INSTALL) else ( call :UNINSTALL)
pause
exit

:testFolderName
for %%Q in (.) do set "a=%%~nQ"
set "a=%a:'=@%"
set "a=%a:!=@%"
set "a=%a:^=@%"
set "a=%a:&=@%"
set "a=%a:[=@%"
set "a=%a:]=@%"
setlocal EnableDelayedExpansion
set "a=!a:%%=@!"
for /f "usebackq delims=" %%Q in (` powershell "'!a!' -match '\@'"`) do set "b=%%Q"
setlocal DisableDelayedExpansion
if "%b%"=="True" (
	echo The folder name contains forbidden characters !@%%^^^&^[^]'
	pause
	%*
)
exit /b

:setGlobalVar
set "dp0=%~dp0"
set "f0=%~f0"
set "________=[=============================================================]"
cd /d "!dp0!"
for /f "usebackq delims=" %%Q in (` powershell "'!dp0!' -replace '.+\\(.+)\\$','$1'"`) do set "folderName=%%Q"
exit /b

:UAC
del /q /a:RH getadmin.vbs 2>nul
fsutil dirty query %SYSTEMDRIVE% >nul
if !ERRORLEVEL! EQU 0 ( exit /b )
echo Run as Administrator required.
pause
echo Set UAC = CreateObject^("Shell.Application"^) > getadmin.vbs
echo UAC.ShellExecute "!f0!", "", "", "runas", 1 >> getadmin.vbs
attrib +r +h getadmin.vbs >nul
getadmin.vbs
exit

:userPrompt
for /f "usebackq delims=" %%K in (` powershell "[Console]::ReadKey($true).Key" `) do if not "%%K"=="%~1" (%~2)
exit /b

:centerText
set "a=%~1"
set "b=!a:'=@!"
powershell "$l=(63-'!b!'.length)/2;for($i=1;$i -le $l;$i++){Write-Host -nonewline ' '}"
echo !a!
exit /b

:intro
if not "%*"=="full" ( set "INTRO=gc '!f0!'|select -first 1") else ( set "INTRO=gc '!f0!'|?{$_ -match '^\:\:\s\s'}|select -skip 2")
for /f "usebackq delims=" %%Q in (` powershell "!INTRO!" `) do (
    set "INTRO=%%Q"
    if not "%*"=="full" ( call :centerText "!INTRO:~4!") else ( echo. !INTRO:~4!)
)
exit /b

:INSTALL
call :centerText "Press [Y] to Install"
call :userPrompt "Y" "exit"
echo.
for /f "usebackq delims=" %%A in (` findstr /b /c:"::: " "!f0!" `) do (
    set "i=%%A"
    set "i=!i:~4!"
	call :job
)
if exist .usi ( attrib +r +h .usi >nul)
exit /b

:job
if "!i:~0,2!"=="//" (
	rem #	Save manual [// <code>] to .usi
	set "manual2del=!i:~3!"
    call :MAIN "MANUAL2DEL"
	goto :jobExit
)
if "!i:~0,2!"=="C\" ( goto :jobLink)
if not "!i:~0,1!"=="/" (
	rem #	Execute manual [<code>]
	set "manual=!i!"
	call :MAIN "MANUAL"
	goto :jobExit
)
if "!i:~0,2!"=="/r" (
	rem #	Automatically find paths and run mklink [/r <regex>]
	call :regex
	goto :jobExit
)
:jobLink
rem #	Run mklink [<code>]
if "!i:~0,2!"=="C\" (
	set "src=!i!"
	if exist "!dp0!!src!\*" ( set "par=/d ") else ( set "par=")
) else (
	set "src=!i:~3!"
	set "par=!i:~0,2! "
)
call :mklink
:jobExit
exit /b

:regex
if "!i:~0,4!"=="/r /" (
    set "par=!i:~3,3!"
    set "i=!i:~6!"
) else (
    set "par=/d "
    set "i=!i:~3!"
)
for /f "usebackq delims=" %%B in (` powershell "gci '!dp0!' -recurse|?{($_.PSisContainer) -and ($_.name -match '(!i!)') -and ($_.fullname -notmatch '\\C\\.*?(!i!).*?(!i!)')}|%%{$_.fullname -replace [regex]::escape('!dp0!'),''}|sort"`) do (
	set "src=%%B"
	call :mklink
)
exit /b

:mklink
set "dest=C:!src:~1!"
set "dest=!dest:(Name)=%USERNAME%!"
for /f "usebackq delims=" %%K in (` powershell "split-path '!dest!' -parent" `) do (
	set "dest_parent=%%K"
	call :junk
	call :MAIN "MD"
)
call :MAIN "MKLINK"
exit /b

:junk
if exist "!dest!" (
	if exist "!dest!\*" (
		call :MAIN "JUNK" "rd /q"
		if exist "!dest!\*" (
			echo ^[?^] ^"!dest!^" already exists, it will be deleted
			pause
			call :MAIN "JUNK" "rd /s /q"
		)
	) else (
		call :MAIN "JUNK" "del /q"
	)
)
exit /b

:UNINSTALL
call :centerText "Press [Enter] to Uninstall"
call :userPrompt "Enter" "exit"
echo.
attrib -r -h .usi >nul 2>&1
for /f "tokens=*" %%A in (.usi) do (
    set "i=%%A"
	call :job2
)
call :MAIN ".USI_DEL"
exit /b

:job2
if "!i:~0,2!"=="/s" (
	rem #	Smart Delete .reg [// /s <path>]
	set "i=!i:~3!"
	for /f "usebackq delims=" %%B in (` powershell "(sls '^\[.+?\]' '!dp0!!i!').line|%%{$_ -replace '\[-(HKEY_.+?)\]','$1'}"`) do (
    	set "b=%%B"
    	set "b=!b:HKEY_CURRENT_USER=HKCU!"
    	set "b=!b:HKEY_LOCAL_MACHINE=HKLM!"
    	call :regSmartDel
    	echo.
	)
	goto :job2Exit
)
if "!i:~0,2!"=="C:" (
    rem #	Delete links [// <path>] + delete parent folder (if empty)
	set ".usi_remove_links=!i!"
    echo ^[-^] ^"!.usi_remove_links!^"
	call :MAIN ".USI_REMOVE_LINKS"
    for /f "usebackq delims=" %%B in (` powershell "split-path '!.usi_remove_links!' -parent"`) do (
		set ".usi_parent=%%B"
		call :MAIN ".USI_PARENT"
	)
	goto :job2Exit
)
rem #	Run manual [// <code>] from .usi
set ".usi_manual=!i!"
call :MAIN ".USI_MANUAL"
:job2Exit
exit /b

:regSmartDel
echo.
set "_a=!b!"
:loop
call :MAIN ".USI_REGSMARTDEL"
for /f "usebackq delims=" %%C in (` powershell "split-path '!_a!' -parent"`) do set "_a=%%C"
set _b=0
for /f "delims=" %%C in (' reg query "!_a!" 2^>nul') do set /a _b+=1
if !_b! EQU 0 ( goto:loop)
exit /b

:MAIN
if "%~1"=="MKLINK" (
	if "!DEBUG!"=="true" (
		echo mklink !par!^"!dest!^" ^"!dp0!!src!^"
		if !ERRORLEVEL! EQU 0 ( echo echo !dest!^>^> .usi)
	) else (
		mklink !par!"!dest!" "!dp0!!src!"
		if !ERRORLEVEL! EQU 0 ( echo !dest!>> .usi)
	)
)
if "%~1"=="JUNK" (
	if "!DEBUG!"=="true" (
		echo %~2 ^"!dest!^" 2^>nul
	) else (
		%~2 "!dest!" 2>nul
	)
)
if "%~1"=="MD" (
	if "!DEBUG!"=="true" (
		if not exist "!dest_parent!" ( echo md ^"!dest_parent!^")
	) else (
		if not exist "!dest_parent!" ( md "!dest_parent!")
	)
)
if "%~1"=="MANUAL" (
	if "!DEBUG!"=="true" (
		echo !manual!
	) else (
		!manual!
	)
)
if "%~1"=="MANUAL2DEL" (
	if "!DEBUG!"=="true" (
		echo !manual2del!^>^> .usi
	) else (
		echo !manual2del!>> .usi
	)
)

if "%~1"==".USI_REGSMARTDEL" (
	if "!DEBUG!"=="true" (
		echo reg delete ^"!_a!^" /f ^>nul 2^>^&1 ^&^& echo ^[-^] ^"!_a!^" ^|^| echo ^[?^] ^"!_a!^"
	) else (
		reg delete "!_a!" /f >nul 2>&1 && echo ^[-^] ^"!_a!^" || echo ^[?^] ^"!_a!^"
	)
)
if "%~1"==".USI_REMOVE_LINKS" (
	if "!DEBUG!"=="true" (
		if exist "!.usi_remove_links!\*" (
			echo rd /q ^"!.usi_remove_links!^"
		) else (
			echo del /q ^"!.usi_remove_links!^"
		)
	) else (
		if exist "!.usi_remove_links!\*" (
			rd /q "!.usi_remove_links!"
		) else (
			del /q "!.usi_remove_links!"
		)
	)
)
if "%~1"==".USI_PARENT" (
	if "!DEBUG!"=="true" (
		echo rd ^"!.usi_parent!^" 2^>nul ^&^& echo ^[-^] ^"!.usi_parent!^"
	) else (
		rd "!.usi_parent!" 2>nul && echo ^[-^] ^"!.usi_parent!^"
	)
)
if "%~1"==".USI_MANUAL" (
	if "!DEBUG!"=="true" (
		echo !.usi_manual!
	) else (
		!.usi_manual!
	)
)
if "%~1"==".USI_DEL" (
	if "!DEBUG!"=="true" (
		echo del /q .usi
	) else (
		del /q .usi
	)
)
exit /b

rem #		↓ Specify the commands to process below ↓

::: cls
::: echo !________!
::: call:intro
::: echo !________!
::: call:intro full
::: echo !________!
::: pause
::: start https://github.com/wvzxn/universal-symlink-installer#usage
::: exit