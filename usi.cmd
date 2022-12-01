::         Name: Universal Symlink Installer v1.5j
::       Author: wvzxn // https://github.com/wvzxn/
::  Description: Simple script that will help you speed up the Symlink creation process on Windows.
::               It acts as both installer and uninstaller.
::               Learn how to use at https://github.com/wvzxn/universal-symlink-installer#usage

@echo off
net session >nul 2>&1
if %errorLevel% NEQ 0 ( echo Run as Administrator required. & pause & exit )
setlocal EnableDelayedExpansion
cd /d "%~dp0"
set "f0=%~f0"
set "_=[=============================================================]"
for %%A in (.) do ( for /f "usebackq delims=" %%I in (` powershell "'%%~nA'.ToUpper()" `) do set "n=%%I" )

echo !_!
call:centerText Universal Symlink Installer
call:centerText !n!
echo !_!
echo.
if not exist .usi ( call:usiSet ) else ( call:usiDel )
pause
exit

:usiSet
call:centerText Press ^[Y^] to Install
call:userPrompt Y
echo.
for /f "usebackq delims=" %%A in (` findstr /b /c:"::: " "!f0!" `) do (
    set "i=%%A"
    set i=!i:~4!
    set par=!i:~0,2!
    for /f "usebackq delims=" %%I in (` powershell "if('!par!' -match '(/.?)|(C\\)'){echo 1}else{echo 2}" `) do (
        if %%I EQU 2 ( !i! ) else (
            if "!par!"=="//" ( echo !i:~3!>> .usi ) else (
                if "!par!"=="C\" (
                    set "source=!i!"
                    if exist "%~dp0!source!\*" ( set "par=/d " ) else ( set "par=" )
                ) else (
                    set source=!i:~3!
                    set "par=!par! "
                )
                set "link=C:\!source:~2!"
                set link=!link:^(Name^)=%username%!
                set "source=%~dp0!source!"
                for /f "usebackq delims=" %%J in (` powershell "Split-Path '!link!' -Parent" `) do if not exist "%%J" ( md "%%J" )
                if exist "!link!" ( echo !link! exists ) else (
                    mklink !par!"!link!" "!source!"
                    echo !link!>> .usi
                )
            )
        )
    )
)
if exist .usi ( attrib +r +h "%~dp0.usi" >nul 2>&1 & icacls "%~dp0.usi" /deny *S-1-1-0:F >nul 2>&1 )
exit /b

:usiDel
call:centerText Press ^[Enter^] to Uninstall
call:userPrompt Enter
echo.
icacls "%~dp0.usi" /reset >nul 2>&1 & attrib -r -h "%~dp0.usi" >nul 2>&1
for /f "tokens=*" %%A in (.usi) do (
    set "par=%%A"
    if "!par:~0,2!"=="C:" (
        echo - %%A
        if exist "%%A\*" ( rd /q "%%A" ) else ( del /q "%%A" )
    ) else ( %%A )
)
del /q /f .usi
exit /b

:centerText
powershell "$a='%*'.length;$l=(63-$a)/2;for($i=1;$i -le $l;$i++){Write-Host -nonewline ' '}"
echo %*
exit /b

:userPrompt
for /f "usebackq delims=" %%K in (` powershell "[Console]::ReadKey($true).Key" `) do if not "%%K"=="%*" ( exit )
exit /b

:::: [-------------------------------------------------------------] ::::
:::: [           ↓ Specify the commands to process below ↓         ] ::::
:::: [-------------------------------------------------------------] ::::

::: cls
::: echo !_!
::: powershell "gc '!f0!'|%{if($_ -match '(^^::\s\s)(.*)'){echo $_}}"
::: echo !_!
::: pause
::: start https://github.com/wvzxn/universal-symlink-installer#usage
::: exit