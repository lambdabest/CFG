@echo off
setlocal EnableExtensions
title Restart Active Network Adapter

set "SELF=%~f0"
fltmc >nul 2>&1
if errorlevel 1 (
    echo Requesting Administrator privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath $env:SELF -Verb RunAs"
    exit /b
)

set "ADAPTER="

for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "$r=Get-NetRoute -AddressFamily IPv4 -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue ^| Sort-Object RouteMetric,InterfaceMetric ^| Select-Object -First 1; if($r){$a=Get-NetAdapter -InterfaceIndex $r.InterfaceIndex -ErrorAction SilentlyContinue; if($a){$a.Name}}"`) do set "ADAPTER=%%A"

if not defined ADAPTER (
    echo.
    echo Could not auto-detect the active default-route adapter.
    echo.
    powershell -NoProfile -Command "Get-NetAdapter | Sort-Object Status,Name | Format-Table -Auto Name,Status,LinkSpeed,InterfaceDescription"
    echo.
    set /p "ADAPTER=Type the exact adapter name: "
)

if not defined ADAPTER goto :FAIL

echo.
echo Adapter selected:
echo   "%ADAPTER%"
echo.
echo This will disconnect networking for a few seconds.
choice /c YN /n /m "Restart this adapter? [Y/N]: "
if errorlevel 2 goto :END

echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$n=$env:ADAPTER; Disable-NetAdapter -Name $n -Confirm:$false -ErrorAction Stop; Start-Sleep -Seconds 3; Enable-NetAdapter -Name $n -Confirm:$false -ErrorAction Stop"

if errorlevel 1 goto :FAIL

echo.
echo Adapter restarted. Current state:
powershell -NoProfile -Command "Get-NetAdapter -Name $env:ADAPTER | Format-Table -Auto Name,Status,LinkSpeed"
goto :END

:FAIL
echo.
echo ERROR: The adapter could not be detected or restarted.

:END
echo.
pause
endlocal
