@echo off
setlocal
title hl.exe High Priority Check

echo ============================================================
echo  HL.EXE HIGH PRIORITY CHECK
echo ============================================================
echo.
echo Registry policy:
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\hl.exe\PerfOptions" /v CpuPriorityClass 2>nul
if errorlevel 1 (
    echo CpuPriorityClass is not configured.
) else (
    echo Expected value for HIGH: 0x3
)

echo.
echo Running process:
powershell -NoProfile -Command "$p=Get-Process hl -ErrorAction SilentlyContinue; if(-not $p){Write-Host 'hl.exe is not running.'; exit}; $p | Select-Object Id,ProcessName,PriorityClass,CPU | Format-Table -AutoSize"

echo.
echo Expected while CS 1.6 is running:
echo   PriorityClass = High
echo.
pause
endlocal
