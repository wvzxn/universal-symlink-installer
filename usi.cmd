:: Universal Symlink Installer
:: Author: wvzxn // https://github.com/wvzxn/universal-symlink-installer
@echo off
if not "%1"=="am_admin" ( powershell start -verb runas '%0' 'am_admin "%~1" "%~2"' & exit )
setlocal EnableDelayedExpansion
cd /d "%~dp0"
set "_line_=[=============================================================]"
for %%A in (.) do set "x=%%~nxA"
for /f "usebackq delims=" %%A in (` powershell "'%x%'.ToUpper()" `) do set "x=%%A"
echo !_line_!
powershell "$a='%x%'.length; $l=(57-$a)/2; $r=$l+((57-$a)%%2); Write-Host -nonewline ' --'; for($i=1; $i -le $l; $i++){Write-Host -nonewline ' '}; Write-Host -nonewline '%x%'; for($i=1; $i -le $r; $i++){Write-Host -nonewline ' '}" & echo --
echo  --               Universal Symlink Installer               --
echo !_line_!

if exist .usi ( goto:symlinkInstalled )
echo Press ^[Y^] to Install
for /f "usebackq delims=" %%A in (` powershell "[Console]::ReadKey($true).Key" `) do if not "%%A"=="Y" ( exit )
echo !_line_!
for /f "usebackq delims=" %%A in (` findstr /b ::: "%~f0" `) do (
    set "i=%%A"
    set i=!i:~4!
    set par=!i:~0,2!
    for /f "usebackq delims=" %%I in (` powershell "if ('!par!' -like '/*' -or '!par!' -like 'C\') {echo 1} else {echo 2}" `) do (
        if %%I EQU 2 ( !i! ) else (
            if "!par!"=="//" ( echo !i:~3!>> .usi ) else (
                if "!par!"=="C\" ( set "source=!i!" & set "par=" ) else ( set "source=!i:~3!" & set "par=!par! " )
                set "link=C:\!source:~2!"
                set link=!link:^(Name^)=%username%!
                set "source=%~dp0!source!"
                for /f "usebackq delims=" %%A in (` powershell "Split-Path '!link!' -Parent" `) do if not exist "%%A" ( md "%%A" )
                mklink !par!"!link!" "!source!"
                echo !link!>> .usi
            )
        )
    )
)
attrib +h .usi
icacls .usi /deny *S-1-1-0:F /Q 1>nul
echo !_line_!
goto:end

:symlinkInstalled
echo Press ^[Enter^] to Uninstall
for /f "usebackq delims=" %%A in (` powershell "[Console]::ReadKey($true).Key" `) do if not "%%A"=="Enter" ( exit )
echo !_line_!
icacls .usi /reset /Q 1>nul
attrib -h .usi
echo Removing...
for /f "tokens=*" %%A in (.usi) do (
    set "par=%%A" & set par=!par:~0,2!
    if not "!par!"=="C:" ( %%A ) else (
        echo %%A
        del /q "%%A"
        rd /s /q "%%A"
    )
)
del /q /f .usi
echo !_line_!

:end
setlocal DisableDelayedExpansion
echo Done!
pause

::: echo Please read https://github.com/wvzxn/universal-symlink-installer#usage
::: start "" https://github.com/wvzxn/universal-symlink-installer#usage