# MSX-USB
## Some history
In the 80's the MSX standard was created by Kazuhiko Nishi. He envisioned a simple yet powerful home computer based on standard hardware, software (BIOS/MSX DOS) and connectivity. From 1983 to 1990 manufacturers, like Philips, Sony, Yamaha, Sharp, Canon and many more, made computers according to this standard.

Because of the fact that extensibility was part of the standard people could design cartridges that would add synthesizer sound, memory, modems, rom-based games, or combinations of the above.

Cartridges were connected via a standard 50pin connector that remained the same accross 4 generations of MSX (1/2/2+/TurboR). BIOS and MSX-DOS were designed in a way to discover these via rom-based drivers, software hooks, extended bios.

Standardisation offers a big advantage because everything that adheres to the standard can connect to it.

## USB
USB was designed in the 90's to something similar. To standardize the connection of peripherals to personal computers, both to communicate with and to supply electric power. It has now largely replaced interfaces such as serial ports and parallel ports, and has become commonplace on a wide range of devices. Like USB flash drives, keyboards, mice, wifi, serial, camera's, etc.

What if the MSX would have an USB connection? And if the BIOS/MSX DOS would automatically recognize devices connected to it?

## Meet MSX-USB
Inspired by the work of Xavirompe and his RookieDrive I set out to do exactly this. And since I'm a big believer of open standards and open source I'm opening up my work to everyone.

On this GitHub page you can find:
* Schematics (KiCAD), that interfaces a cheap USB CH376s board to the MSX cartridge port.
* Drivers, currently Flash drives on Nextor and HID keyboards are supported.
* Debugging tools, to connect a test board to your PC/MAC and assist in debugging.

On my GitHub I also have forks of OpenMSX and CocoaMSX that either emulate or connect to a test board via serial to assist in development and debugging.

## Schematics
This connects the CH376s board you can find on eBay or AliExpress for around 4 Euro to the MSX. 

Circuitry is added to correctly handle the _BUSDIR signal. Make sure you select parallel by setting the jumper on the CH376s board correctly.

The CH376s board will be visible on port 10h and 11h on the MSX. Port 11h is the command port and 10h is the data port. Specifics on how to program for the CH376s can be found here. 

Most information is available on how to use the higher-order API for flash drives. If you want to use other USB device you have to go low-level. As it turns out Konamiman already did some work there and after some researching I finally got USB HID keyboards working as well.

## Flash Drive
For the flash drive I created a NEXTOR driver that looks for a file called NEXTOR.DSK on the root of the flash drive at startup. I initially used 720Kb images but I discovered that I can use bigger FAT16 images as well. Now I'm using a 128Mb image and it works good. 

I created some routines in MSX-Basic to show the flash directory itself and to eject and insert images. Since the CH376s is capable of using FAT32 you can have multiple FAT16 images on one flash drive. I settled for 128Mb FAT16 because of cluster size and optimum storage use.

## USB HID Keyboard
I wrote a driver that you can start from BASIC and nestles itself in page 3. It then hooks itself to CHGET. It works good but I have to add special keys (STOP/GRAPH/CODE) and do more testing before I consider it final. I also want to turn it into a Nextor driver or UNAPI driver in the end.

# Collaboration
Do you want to help with the development of MSX USB? Write drivers for other devices? Or contribute in other ways?

Please drop me line on sourceror at neximus.nl or meet me on the msx.org forum.

