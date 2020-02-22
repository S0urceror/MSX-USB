# USB-HID-MSX - MSX driver for USB HID keyboards

USB-HID uses low level execute-command sequences for all common USB and USB HID communication via CH376.

Load the current version via BLOAD "driver.bin",r

It will find the connected USB HID keyboard, activate it's BOOT protocol, and installs the H.CHGE hook. After this the normal keyboard won't work anymore. The HID keyboard takes over. 

When you press ALT+Q the hook is deinstalled and the MSX keyboard works again.

## Limitations
* special keys like STOP and GRAPH not yet implemented
* should automatically start with the computer from ROM
* work in progress...

