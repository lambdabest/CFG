@echo off
setlocal EnableExtensions
title CS 1.6 - Reset tempdecal.wad

call :FindCStrike "%~1"
if not defined CSTRIKE goto :FAILPATH

set "TARGET=%CSTRIKE%\tempdecal.wad"

echo.
echo CS 1.6 folder:
echo   "%CSTRIKE%"
echo.
echo Target:
echo   "%TARGET%"
echo.
echo NOTE: Do not use this script if you want to keep a custom spray.
echo.

if exist "%TARGET%" (
    attrib -r -h -s "%TARGET%" >nul 2>&1
    for %%F in ("%TARGET%") do (
        if %%~zF GTR 0 (
            copy /y "%TARGET%" "%TARGET%.bak" >nul
            echo Backup created: tempdecal.wad.bak
        )
    )
)

del /f /q "%TARGET%" >nul 2>&1
type nul > "%TARGET%" 2>nul

if errorlevel 1 (
    echo ERROR: Could not create tempdecal.wad.
    echo Try running this BAT as Administrator.
    goto :END
)

attrib +r "%TARGET%" >nul 2>&1

for %%F in ("%TARGET%") do (
    if "%%~zF"=="0" (
        echo OK: tempdecal.wad is 0 bytes and READ-ONLY.
    ) else (
        echo ERROR: tempdecal.wad is not empty.
    )
)

goto :END

:FindCStrike
set "CSTRIKE="
if not "%~1"=="" (
    if exist "%~1\" set "CSTRIKE=%~1"
    goto :eof
)

for /f "tokens=2,*" %%A in ('reg query "HKCU\Software\Valve\Steam" /v SteamPath 2^>nul ^| find /i "SteamPath"') do set "STEAMROOT=%%B"
if defined STEAMROOT (
    if exist "%STEAMROOT%\steamapps\common\Half-Life\cstrike\" (
        set "CSTRIKE=%STEAMROOT%\steamapps\common\Half-Life\cstrike"
        goto :eof
    )
)

if exist "%ProgramFiles(x86)%\Steam\steamapps\common\Half-Life\cstrike\" (
    set "CSTRIKE=%ProgramFiles(x86)%\Steam\steamapps\common\Half-Life\cstrike"
    goto :eof
)

if exist "%ProgramFiles%\Steam\steamapps\common\Half-Life\cstrike\" (
    set "CSTRIKE=%ProgramFiles%\Steam\steamapps\common\Half-Life\cstrike"
    goto :eof
)

set /p "CSTRIKE=Paste your cstrike folder path: "
if not exist "%CSTRIKE%\" set "CSTRIKE="
goto :eof

:FAILPATH
echo ERROR: Counter-Strike 1.6 cstrike folder was not found.
echo You can also run:
echo   %~nx0 "D:\SteamLibrary\steamapps\common\Half-Life\cstrike"

:END
echo.
pause
endlocal
