MOUSEFIX - CURRENT CS 1.6 SETUP
================================

Recommended Windows fallback:
- Pointer speed: 6/11
- Enhance Pointer Precision: OFF
- Display scaling: 100%

Apply:
Windows_Mouse_1-to-1_6-of-11_EPP-OFF.reg

CS 1.6:
m_rawinput "1"
m_filter "0"
m_customaccel "0"
sensitivity "0.346875"
m_yaw "0.022"
m_pitch "0.022"

IMPORTANT
---------
Changing Windows from 3/11 to 6/11 does NOT require changing the CS 1.6
sensitivity while m_rawinput 1 is active.

Current sensitivity:
1600 DPI x 0.346875 = 555 eDPI
Approx. 74.9 cm/360
Approx. 0.00763125 degrees per mouse count

The @3-of-11 MarkC profile is preserved for legacy/testing.
The @6-of-11 MarkC file is the standard 100% / 1-to-1 profile.
Windows_10+8.x_Default.reg restores the default Windows curves.
