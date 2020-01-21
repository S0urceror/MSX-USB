# usb-hid
USB-HID uses low level execute-command sequences for all common USB and USB HID communication via CH376. 

The CH376s has higher level commands for GET_DESCRIPTOR, SET_ADDRESS but they are limited to 64 byte packet-size.
By using low-level command sequences we can read the larger  descriptors that are typical for HID devices. 
Particulary the Logitech USB Receivers that I intend to use.

Is currently able to discover attached keyboards and mice.

This simple C/C++ program is just a tester to move this functionality to a MSX driver. 
Yes, this illustrious computing system from the 80's finally gets USB connectivity.
