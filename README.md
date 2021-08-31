# MSX-USB
## Some history
In the 80's the MSX standard was created by Kazuhiko Nishi. He envisioned a simple yet powerful home computer based on standard hardware, software (BIOS/MSX DOS) and connectivity. From 1983 to 1990 manufacturers, like Philips, Sony, Yamaha, Sharp, Canon and many more, made computers according to this standard.

Because of the fact that extensibility was part of the standard people could design cartridges that would add synthesizer sound, memory, modems, rom-based games, or combinations of the above.

Cartridges were connected via a standard 50pin connector that remained the same accross 4 generations of MSX (1/2/2+/TurboR). BIOS and MSX-DOS were designed in a way to discover these via rom-based drivers, software hooks, extended bios.

Standardisation offers a big advantage because everything that adheres to the standard can connect to it.

## USB
USB was designed in the 90's to do something similar. To standardize the connection of peripherals to personal computers, both to communicate with and to supply electric power. It has now largely replaced interfaces such as serial ports and parallel ports, and has become commonplace on a wide range of devices. Like USB flash drives, keyboards, mice, wifi, serial, camera's, etc.

What if the MSX would have an USB connection? And if the BIOS/MSX DOS would automatically recognize devices connected to it?

## Meet MSX-USB
Inspired by the work of Xavirompe and his [RookieDrive](http://rookiedrive.com/en/) I set out to do exactly this. And since I'm a big believer of open standards and open source I'm opening up my work to everyone.

On this GitHub page you can find:
* Schematics (KiCAD), that interfaces a cheap USB CH376s board to the MSX cartridge port.
* Drivers, currently Flash drives on Nextor and HID keyboards are supported.
* Debugging tools, to connect a test board to your PC/MAC and assist in debugging.

On my GitHub I also have forks of OpenMSX and CocoaMSX that either emulate or connect to a test board via serial to assist in development and debugging.

## Schematics
This connects the CH376s board you can find on eBay or AliExpress for around 4 Euro to the MSX. 

Circuitry is added to correctly handle the _BUSDIR signal. Make sure you select parallel by setting the jumper on the CH376s board correctly.

The CH376s board will be visible on port 10h and 11h on the MSX. Port 11h is the command port and 10h is the data port. Specifics on how to program for the CH376s are scattered around the Internet:
* https://www.mpja.com/download/ch376ds1.pdf
* https://arduinobasics.blogspot.com/2015/05/ch376s-usb-readwrite-module.html

Most information is available on how to use the higher-order API for flash drives. 

If you want to use other USB devices you have to go low-level. As it turns out Konamiman already did some work there and after some researching I got USB HID Keyboards, Ethernet, Serial working as well. Check out my source-code or these great pages for more information:
* http://www.usbmadesimple.co.uk/index.html
* https://www.beyondlogic.org/usbnutshell/usb1.shtml

## UNAPI USB
I wrote a UNAPI USB specification and implemented the Usb Host driver according to this. The next version of this Host driver will also implement the Usb Hub specification and enumerate and initialise all devices connected.

## USB HID Keyboard
The Usb Keyboard driver connects to Unapi Usb driver and hooks itself to H.CHGE. From that moment on it replaces your trusted MSX keyboard by a shiny new USB Keyboard. Or a wireless one if you have inserted the appropriate Logitech receiver.

## USB CDC ECM Ethernet
The USB CDC ECM Ethernet driver is finished. It uses the Unapi USB and conforms to the Unapi Ethernet standard. Internestor Lite can now connect and use your USB Ethernet device. Please note that currently we only support USB CDC ECM. Make sure your Ethernet device supports this.

All USB Ethernet devices built around the **RTL8153** chipset support USB CDC ECM. They usually cost around 20 euro.

## USB Storage
A low level USB driver is created to connect to storage devices like thumb drives, portable hard disks, etc. 

## USB Hub
The USB Hub driver will interrogate an USB Hub and all devices connected to it.

# Installation instructions
Check [this page](INSTALL.md) for installation instructions and links to the various binaries that have been developed.

# Build your own (DIY)
Check [this page](DIY.md) for information on how to make the PCB, program the CPLD device, flash the ROM, etc.

# Collaboration
Do you want to help with the development of MSX USB? Write drivers for other devices? Or contribute in other ways?

Please drop me line on sourceror at neximus.nl or meet me on the msx.org forum.

