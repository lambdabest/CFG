@echo off
setlocal EnableExtensions
title Restart Active Network Adapter - CS 1.6 Tools

set "SELF=%~f0"

:: ------------------------------------------------------------
:: Administrator check
:: ------------------------------------------------------------
fltmc >nul 2>&1
if errorlevel 1 (
    echo Requesting Administrator privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath $env:SELF -Verb RunAs"
    exit /b
)

:: ------------------------------------------------------------
:: Detect the active interface by IPv4 default gateway.
:: Get-NetIPConfiguration returns connected non-virtual interfaces by default.
:: We only capture InterfaceIndex here to avoid blank/whitespace adapter names.
:: ------------------------------------------------------------
set "IFINDEX="

for /f "delims=" %%I in ('powershell -NoProfile -Command "$c=Get-NetIPConfiguration ^| Where-Object { $_.IPv4DefaultGateway -ne $null -and $_.NetAdapter.Status -eq 'Up' } ^| Sort-Object { $_.NetIPv4Interface.InterfaceMetric } ^| Select-Object -First 1; if($c){[Console]::Write($c.InterfaceIndex)}"') do (
    if not defined IFINDEX set "IFINDEX=%%I"
)

:: Fallback for an isolated LAN with no default gateway:
:: pick the first UP physical adapter.
if not defined IFINDEX (
    for /f "delims=" %%I in ('powershell -NoProfile -Command "$a=Get-NetAdapter -Physical -ErrorAction SilentlyContinue ^| Where-Object { $_.Status -eq 'Up' } ^| Sort-Object InterfaceIndex ^| Select-Object -First 1; if($a){[Console]::Write($a.InterfaceIndex)}"') do (
        if not defined IFINDEX set "IFINDEX=%%I"
    )
)

:: Validate InterfaceIndex as numeric.
if defined IFINDEX (
    echo(%IFINDEX%| findstr /r /x "[0-9][0-9]*" >nul
    if errorlevel 1 set "IFINDEX="
)

:: ------------------------------------------------------------
:: Resolve the exact adapter name from the validated index.
:: ------------------------------------------------------------
set "ADAPTER="

if defined IFINDEX (
    for /f "delims=" %%A in ('powershell -NoProfile -Command "$a=Get-NetAdapter -InterfaceIndex %IFINDEX% -ErrorAction SilentlyContinue; if($a){[Console]::Write($a.Name)}"') do (
        if not defined ADAPTER set "ADAPTER=%%A"
    )
)

:: ------------------------------------------------------------
:: Manual fallback if automatic detection fails.
:: ------------------------------------------------------------
if not defined ADAPTER (
    cls
    echo ============================================================
    echo  ACTIVE NETWORK ADAPTERS
    echo ============================================================
    echo.
    netsh interface show interface
    echo.
    set /p "ADAPTER=Type the exact interface name to restart: "
)

if not defined ADAPTER goto :FAIL_DETECT

:: Verify that the interface really exists before touching it.
netsh interface show interface name="%ADAPTER%" >nul 2>&1
if errorlevel 1 goto :FAIL_DETECT

cls
echo ============================================================
echo  RESTART ACTIVE NETWORK ADAPTER
echo ============================================================
echo.
echo Interface index : %IFINDEX%
echo Adapter selected:
echo   "%ADAPTER%"
echo.
netsh interface show interface name="%ADAPTER%"
echo.
echo This will disconnect networking for a few seconds.
choice /c YN /n /m "Restart this adapter? [Y/N]: "
if errorlevel 2 goto :END

echo.
echo [1/3] Disabling "%ADAPTER%"...

:: Use NETSH intentionally instead of Disable-NetAdapter.
:: This avoids failures from the NetAdapter CIM provider such as 0x800106d9.
netsh interface set interface name="%ADAPTER%" admin=DISABLED >nul 2>&1
if errorlevel 1 goto :FAIL_DISABLE

timeout /t 3 /nobreak >nul

echo [2/3] Enabling "%ADAPTER%"...
netsh interface set interface name="%ADAPTER%" admin=ENABLED >nul 2>&1

if errorlevel 1 (
    echo First enable attempt failed. Retrying...
    timeout /t 2 /nobreak >nul
    netsh interface set interface name="%ADAPTER%" admin=ENABLED >nul 2>&1
)

if errorlevel 1 goto :FAIL_ENABLE

echo [3/3] Waiting for link...
timeout /t 3 /nobreak >nul

echo.
echo Current adapter state:
netsh interface show interface name="%ADAPTER%"
echo.
echo Restart completed.
goto :END

:FAIL_DETECT
echo.
echo ERROR: A valid network adapter could not be detected.
echo.
echo Available interfaces:
netsh interface show interface
echo.
echo No adapter was modified.
goto :END

:FAIL_DISABLE
echo.
echo ERROR: Windows could not disable "%ADAPTER%".
echo No further changes were made.
goto :END

:FAIL_ENABLE
echo.
echo WARNING: Windows could not re-enable "%ADAPTER%" automatically.
echo.
echo Trying one final recovery command...
netsh interface set interface name="%ADAPTER%" admin=ENABLED
echo.
echo If the interface remains disabled, enable it manually from:
echo Control Panel ^> Network Connections
goto :END

:END
echo.
pause
endlocal
