@echo off
setlocal
title hl.exe Priority Check

echo.
powershell -NoProfile -Command "$p=Get-Process hl -ErrorAction SilentlyContinue; if(-not $p){Write-Host 'hl.exe is not running.'; exit 1}; $p | Select-Object Id,ProcessName,PriorityClass,CPU | Format-Table -AutoSize"

echo.
echo Expected after HL_High_Priority.reg: High
echo Expected after HL_Above_Normal_Priority.reg: AboveNormal
echo.
pause
endlocal
