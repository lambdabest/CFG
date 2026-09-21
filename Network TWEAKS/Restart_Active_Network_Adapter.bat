@echo off
setlocal EnableExtensions
title Restart Active Network Adapter - CS 1.6 Tools

set "SELF=%~f0"

:: ============================================================
:: Administrator check
:: ============================================================
fltmc >nul 2>&1
if errorlevel 1 (
    echo Requesting Administrator privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath $env:SELF -Verb RunAs"
    exit /b
)

cls
echo ============================================================
echo  RESTART ACTIVE NETWORK ADAPTER
echo ============================================================
echo.
echo Detection order:
echo   1. Win32_NetworkAdapter + IP configuration
echo   2. Connected/enabled Win32_NetworkAdapter
echo   3. Plug-and-Play NET devices
echo.
echo Restart method:
echo   PnPUtil /restart-device
echo   WMI Disable/Enable only as fallback
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"$ErrorActionPreference='Stop';" ^
"function Header($s){Write-Host ''; Write-Host ('='*60); Write-Host (' '+$s); Write-Host ('='*60)};" ^
"$selected=$null; $instanceId=$null; $displayName=$null; $wmiDeviceId=$null;" ^
"try {" ^
"  $adapters=@(Get-CimInstance -Namespace root/CIMV2 -ClassName Win32_NetworkAdapter -ErrorAction Stop | Where-Object { $_.PNPDeviceID });" ^
"  $configs=@(Get-CimInstance -Namespace root/CIMV2 -ClassName Win32_NetworkAdapterConfiguration -ErrorAction Stop | Where-Object { $_.IPEnabled -eq $true });" ^
"  foreach($cfg in $configs){" ^
"    $a=$adapters | Where-Object { $_.Index -eq $cfg.Index } | Select-Object -First 1;" ^
"    if($a -and $cfg.DefaultIPGateway -and $a.NetEnabled -eq $true){$selected=$a; break}" ^
"  };" ^
"  if(-not $selected){" ^
"    $selected=$adapters | Where-Object { $_.NetEnabled -eq $true -and $_.NetConnectionStatus -eq 2 } | Sort-Object @{Expression='PhysicalAdapter';Descending=$true},Index | Select-Object -First 1" ^
"  };" ^
"  if(-not $selected){" ^
"    $selected=$adapters | Where-Object { $_.NetEnabled -eq $true } | Sort-Object @{Expression='PhysicalAdapter';Descending=$true},Index | Select-Object -First 1" ^
"  };" ^
"} catch { Write-Host ('Win32_NetworkAdapter detection failed: '+$_.Exception.Message) -ForegroundColor Yellow };" ^
"if($selected){" ^
"  $instanceId=$selected.PNPDeviceID; $displayName=if($selected.NetConnectionID){$selected.NetConnectionID}else{$selected.Name}; $wmiDeviceId=$selected.DeviceID;" ^
"  Header 'DETECTED ADAPTER';" ^
"  $selected | Select-Object DeviceID,Index,NetConnectionID,Name,PhysicalAdapter,NetEnabled,NetConnectionStatus,PNPDeviceID | Format-List" ^
"} else {" ^
"  Header 'WMI DID NOT IDENTIFY AN ACTIVE ADAPTER';" ^
"  Write-Host 'Trying Plug-and-Play enumeration...' -ForegroundColor Yellow;" ^
"  try {" ^
"    $pnp=@(Get-PnpDevice -Class Net -PresentOnly -ErrorAction Stop | Where-Object { $_.Status -eq 'OK' -and $_.InstanceId -match '^(PCI|USB)\\' });" ^
"  } catch { $pnp=@() };" ^
"  if($pnp.Count -eq 0){" ^
"    Write-Host '';" ^
"    Write-Host 'No usable NET devices were returned by WMI or PnP.' -ForegroundColor Red;" ^
"    Write-Host '';" ^
"    Write-Host 'Relevant Windows services:';" ^
"    Get-Service Winmgmt,Nsi,Netman,NetProfm -ErrorAction SilentlyContinue | Select-Object Name,Status,StartType | Format-Table -AutoSize;" ^
"    Write-Host 'The script did not modify any device.';" ^
"    exit 20" ^
"  };" ^
"  for($i=0;$i -lt $pnp.Count;$i++){Write-Host ('[{0}] {1}' -f ($i+1),$pnp[$i].FriendlyName); Write-Host ('    '+$pnp[$i].InstanceId)};" ^
"  Write-Host '';" ^
"  $choice=Read-Host 'Select the network adapter number';" ^
"  $n=0; if(-not [int]::TryParse($choice,[ref]$n) -or $n -lt 1 -or $n -gt $pnp.Count){Write-Host 'Invalid selection.' -ForegroundColor Red; exit 21};" ^
"  $dev=$pnp[$n-1]; $instanceId=$dev.InstanceId; $displayName=$dev.FriendlyName;" ^
"};" ^
"if([string]::IsNullOrWhiteSpace($instanceId)){Write-Host 'ERROR: Empty PnP Instance ID.' -ForegroundColor Red; exit 22};" ^
"Header 'CONFIRM';" ^
"Write-Host ('Adapter : '+$displayName);" ^
"Write-Host ('PnP ID  : '+$instanceId);" ^
"Write-Host '';" ^
"$confirm=Read-Host 'Restart this device? Type Y to continue';" ^
"if($confirm -notmatch '^[Yy]$'){Write-Host 'Cancelled. No adapter was modified.'; exit 0};" ^
"Header 'RESTARTING';" ^
"$pnputil=Join-Path $env:SystemRoot 'System32\pnputil.exe';" ^
"& $pnputil /restart-device $instanceId;" ^
"$code=$LASTEXITCODE;" ^
"if($code -eq 0){" ^
"  Write-Host '';" ^
"  Write-Host 'PnP restart completed successfully.' -ForegroundColor Green;" ^
"  Start-Sleep -Seconds 3;" ^
"  exit 0" ^
"};" ^
"Write-Host '';" ^
"Write-Host ('PnPUtil returned exit code '+$code+'.') -ForegroundColor Yellow;" ^
"if($selected -and $null -ne $wmiDeviceId){" ^
"  Write-Host 'Trying Win32_NetworkAdapter Disable/Enable fallback...' -ForegroundColor Yellow;" ^
"  try {" ^
"    $a=Get-CimInstance -Namespace root/CIMV2 -ClassName Win32_NetworkAdapter -Filter ('DeviceID='''+$wmiDeviceId+'''');" ^
"    $r=Invoke-CimMethod -InputObject $a -MethodName Disable -ErrorAction Stop;" ^
"    if($r.ReturnValue -ne 0){throw ('Disable returned '+$r.ReturnValue)};" ^
"    Start-Sleep -Seconds 3;" ^
"    $a=Get-CimInstance -Namespace root/CIMV2 -ClassName Win32_NetworkAdapter -Filter ('DeviceID='''+$wmiDeviceId+'''');" ^
"    $r=Invoke-CimMethod -InputObject $a -MethodName Enable -ErrorAction Stop;" ^
"    if($r.ReturnValue -ne 0){throw ('Enable returned '+$r.ReturnValue)};" ^
"    Write-Host 'WMI fallback completed successfully.' -ForegroundColor Green;" ^
"    exit 0" ^
"  } catch {" ^
"    Write-Host ('WMI fallback also failed: '+$_.Exception.Message) -ForegroundColor Red" ^
"  }" ^
"};" ^
"Write-Host '';" ^
"Write-Host 'ERROR: Windows could not restart the selected network device.' -ForegroundColor Red;" ^
"Write-Host 'No additional network tweaks were applied.';" ^
"exit 30"

set "RC=%ERRORLEVEL%"

echo.
if "%RC%"=="0" (
    echo Operation finished.
) else (
    echo Diagnostic exit code: %RC%
)

echo.
pause
endlocal
