@echo off
:: Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )
:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
del "%temp%\getadmin.vbs"
exit /B
:gotAdmin


@echo off
title TCP Auto-Tuning Toggle

:: --- Admin check ---
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo This script must be run as Administrator.
    pause
    exit /b
)

:MENU
cls
echo ================================
echo   TCP Auto-Tuning Toggle
echo ================================
echo.
echo 1. Disable Auto-Tuning (Low Ping Mode)
echo 2. Enable Auto-Tuning  (High Bandwidth)
echo 3. Exit
echo.
set /p choice=Select an option (1-3): 

if "%choice%"=="1" goto DISABLE
if "%choice%"=="2" goto ENABLE
if "%choice%"=="3" exit /b

echo.
echo Invalid choice.
pause
goto MENU

:DISABLE
echo.
echo Disabling TCP Auto-Tuning...
netsh int tcp set global autotuninglevel=disabled
echo.
echo TCP Auto-Tuning is now DISABLED (Low Ping Mode).
pause
goto MENU

:ENABLE
echo.
echo Enabling TCP Auto-Tuning...
netsh int tcp set global autotuninglevel=normal
echo.
echo TCP Auto-Tuning is now ENABLED (High Bandwidth).
pause
goto MENU
