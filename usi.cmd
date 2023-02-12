::  Universal Symlink Installer v1.8b
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
rem // true/false
set "DEBUG=false"

rem //      CHECK and SETUP
title %~nx0
call :testFolderName exit
setlocal EnableDelayedExpansion
call :setGlobalVar
echo !________!
call :intro
for /f "usebackq delims=" %%A in (` powershell "'!folderName!'.ToUpper()"`) do call :centerText "%%A"
echo !________!
call :UAC

rem //      START
if exist .usi ( call :usiDel) else ( call :usiSet)
pause
exit

:testFolderName
for %%A in (.) do set "a=%%~nA"
set "a=%a:'=@%"
set "a=%a:!=@%"
set "a=%a:^=@%"
set "a=%a:&=@%"
set "a=%a:[=@%"
set "a=%a:]=@%"
setlocal EnableDelayedExpansion
set "a=!a:%%=@!"
for /f "usebackq delims=" %%A in (` powershell "'!a!' -match '\@'"`) do set "b=%%A"
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
for %%A in (.) do set "folderName=%%~nA"
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

:getMklinkVariables
if "!par!"=="C\" (
    set "src=!i!"
    if exist "!dp0!!src!\*" ( set "par=/d ") else ( set "par=")
) else (
    set "src=!i:~3!"
    set "par=!par! "
)
call :mklink
exit /b

:getMklinkVariables_regex
if "!i:~0,4!"=="/r /" (
    set "par=!i:~3,3!"
    set "i=!i:~6!"
) else (
    set "par=/d "
    set "i=!i:~3!"
)
for /f "usebackq delims=" %%J in (` powershell "gci '!dp0!' -recurse|?{($_.PSisContainer) -and ($_.name -match '(!i!)') -and ($_.fullname -notmatch '\\C\\.*?(!i!).*?(!i!)')}|%%{$_.fullname -replace [regex]::escape('!dp0!'),''}|sort" `) do (
    set "src=%%J"
    call :mklink
)
exit /b

:mklink
set "dest=C:!src:~1!"
set "dest=!dest:(Name)=%USERNAME%!"
for /f "usebackq delims=" %%K in (` powershell "split-path '!dest!' -parent" `) do (
	set "dest_parent=%%K"
	rem call :MAIN "JUNK"
	call :MAIN "MD"
)
call :MAIN "MKLINK"
exit /b

:usiSet
call :centerText "Press [Y] to Install"
call :userPrompt "Y" "exit"
echo.
for /f "usebackq delims=" %%A in (` findstr /b /c:"::: " "!f0!" `) do (
    set "i=%%A"
    set "i=!i:~4!"
    set "par=!i:~0,2!"
    for /f "usebackq delims=" %%I in (` powershell "'!par!' -match '(\/.?)|(C\\)'" `) do (
        if "%%I"=="False" (
            rem // Run manual <code>
            set "manual=!i!"
            call :MAIN "MANUAL"
        ) else (
            if "!par!"=="//" (
                rem // Save manual [// <code>] to .usi
				set "manual2del=!i:~3!"
                call :MAIN "MANUAL2DEL"
            ) else (
                rem // Run mklink [/? <code>]
                if "!par!"=="/r" ( call :getMklinkVariables_regex) else ( call :getMklinkVariables)
            )
        )
    )
)
if exist .usi ( attrib +r +h .usi >nul)
exit /b

:usiDel
call :centerText "Press [Enter] to Uninstall"
call :userPrompt "Enter" "exit"
echo.
attrib -r -h .usi >nul 2>&1
for /f "tokens=*" %%A in (.usi) do (
    set "par=%%A"
    if "!par:~0,2!"=="C:" (
        rem // Delete created items (specified in .usi)
		set ".usi_remove_links=%%A"
        echo ^[-^] ^"!.usi_remove_links!^"
		call :MAIN ".USI_REMOVE_LINKS"
		rem // Delete parent folder (if empty)
        for /f "usebackq delims=" %%I in (` powershell "split-path '!.usi_remove_links!' -parent" `) do (
			set ".usi_parent=%%I"
			call :MAIN ".USI_PARENT"
		)
    ) else (
        rem // Run manual [// <code>] from .usi
		set ".usi_manual=%%A"
        call :MAIN ".USI_MANUAL"
    )
)
call :MAIN ".USI_DEL"
exit /b

:MAIN
if "%~1"=="MKLINK" (
	if "!DEBUG!"=="true" (
		echo mklink !par!^"!dest!^" ^"!dp0!!src!^"
	) else (
		mklink !par!"!dest!" "!dp0!!src!"
		if !ERRORLEVEL! EQU 0 ( !dest!>> .usi)
	)
)
if "%~1"=="JUNK" (
	if "!DEBUG!"=="true" (
		if exist "!dest!\*" ( echo rd /s /q ^"!dest!^")
		if exist "!dest!" ( echo del /q ^"!dest!^")
	) else (
		if exist "!dest!\*" ( rd /s /q "!dest!")
		if exist "!dest!" ( del /q "!dest!")
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

if "%~1"==".USI_REMOVE_LINKS" (
	if "!DEBUG!"=="true" (
		if exist "!.usi_remove_links!\*" ( echo rd /q ^"!.usi_remove_links!^") else ( echo del /q ^"!.usi_remove_links!^")
	) else (
		if exist "!.usi_remove_links!\*" ( rd /q "!.usi_remove_links!") else ( del /q "!.usi_remove_links!")
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

rem //      ↓ Specify the commands to process below ↓

::: cls
::: echo !________!
::: call:intro
::: echo !________!
::: call:intro full
::: echo !________!
::: pause
::: start https://github.com/wvzxn/universal-symlink-installer#usage
::: exit