# Latency / Mouse diagnostics

## Included

### Latency & Polling Rate Checking Tool.exe
Existing local tool preserved in this repository for quick testing.

## Complementary tools reviewed

### ClickSyncMouseTester
Current release checked: v0.6.1.

Useful for:
- Raw Input report rate
- report interval/jitter
- button timing
- motion analysis
- sensitivity matching
- sensor angle calibration

It measures what Windows Raw Input delivers to a normal user-mode application.
It is not a hardware USB analyzer.

Official releases:
https://github.com/Nuitfanee/ClickSyncMouseTester/releases

### LatencyMon
Current version checked: 7.31.

Useful for:
- DPC execution times
- ISR execution times
- hard pagefaults
- identifying drivers/processes associated with system latency

LatencyMon is complementary to mouse polling tools. It does not measure
mouse-to-photon latency.

Official download:
https://www.resplendence.com/latencymon

### MouseTester by microe1
Classic Raw Input interval/polling analysis tool.

Release:
https://github.com/microe1/MouseTester/releases/tag/MouseTester_v1.4
