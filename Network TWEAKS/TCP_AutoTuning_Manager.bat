@echo off
setlocal EnableExtensions
title Windows TCP Auto-Tuning Manager

set "SELF=%~f0"
fltmc >nul 2>&1
if errorlevel 1 (
    echo Requesting Administrator privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath $env:SELF -Verb RunAs"
    exit /b
)

:MENU
cls
echo ============================================================
echo  Windows TCP Auto-Tuning Manager
echo ============================================================
echo.
echo This controls TCP receive-window auto-tuning system-wide.
echo It is NOT a Counter-Strike hit-registration or UDP latency tweak.
echo Microsoft normally recommends: autotuninglevel=normal
echo.
echo Current Windows TCP state:
echo ------------------------------------------------------------
netsh interface tcp show global
echo ------------------------------------------------------------
echo.
echo [1] Set NORMAL      ^(recommended/default^)
echo [2] Set DISABLED    ^(diagnostic/testing only^)
echo [3] Refresh status
echo [4] Exit
echo.

choice /c 1234 /n /m "Choose [1-4]: "

if errorlevel 4 goto :END
if errorlevel 3 goto :MENU
if errorlevel 2 goto :DISABLE
if errorlevel 1 goto :NORMAL

:NORMAL
echo.
netsh interface tcp set global autotuninglevel=normal
echo.
pause
goto :MENU

:DISABLE
echo.
echo WARNING: Disabling TCP Auto-Tuning is not a general low-ping optimization.
choice /c YN /n /m "Continue for diagnostic testing? [Y/N]: "
if errorlevel 2 goto :MENU
netsh interface tcp set global autotuninglevel=disabled
echo.
pause
goto :MENU

:END
endlocal
