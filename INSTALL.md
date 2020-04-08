# MSX-USB
## Installation instructions
First you need to decide how you want to use the MSX USB cartridge. Unfortunately it is not possible, at this stage, to have both.:
* Disk storage.
* or, a multi purpose USB port.

### Disk storage
You have to flash a new NEXTOR ROM image onto a MSX flash cartridge. The RookieDrive and other MSX USB initiatives have both Flash and the USB part combined in one cartridge so thats easy. In my prototype setup I have one cartridge with MSX USB and one modded SCC cartridge with flash and that works as well.

* Download [this](https://github.com/S0urceror/MSX-USB/raw/master/drivers/flashdrive/dist/nextor.rom) ROM image
* Flash the image
* Reboot

The first time you need to boot up with a floppy disk with the NEXTOR.SYS and COMMAND2.COM files. 
Please insert a FAT32 formatted USB Flash Disk in the MSX USB cartridge.
For your convenience I have created a couple of FAT16 disk images that you can put on this USB Flash Disk.
The one named NEXTOR.DSK will be found and booted by default.

* NEXTOR.DSK - A 720KB image with NEXTOR.SYS and COMMAND2.COM
* 128mb.DSK - You can have multiple of these on your Flash Disk when size permits. Nextor supports bigger FAT16 disks but 128mb is still fast. When it gets bigger Nextor will spend more time on housekeeping and calculating for example the free space.
* 720kb.DSK - An empty 720KB disk image.

Within Nextor and Disk Basic you can create subdirectories, format, repartition, etc.

There are also a couple of special instructions in BASIC at your disposal:
* CALL USBFILES - list all files in the current directory of the FAT32 formatted flash drive
* CALL USBCD - change to another directory of the flash drive
* CALL INSERTDISK ("filename.ext") - load another disk image and mount it
* CALL EJECTDISK - eject the current mounted disk image

### Multi purpose USB port
You have to flash the UNAPI MSX USB host driver onto a MSX flash cartridge.

* Download [this](https://github.com/S0urceror/MSX-USB/raw/master/drivers/UsbHost/dist/unapiusb.rom) ROM image
* Flash the image
* Reboot

When you boot up you will see the CH376s module is recognised and ready to roll.

You can do the following things:
* [APILIST.COM](https://github.com/S0urceror/MSX-USB/raw/master/drivers/UsbEthernet/dist/apilist.com) MSXUSB to check that the UNAPI driver is ready and works.
* [LSUSB.COM](https://github.com/S0urceror/MSX-USB/raw/master/drivers/UsbEthernet/dist/lsusb.com) to list all technical USB information from the connected USB device.
* [USBETHER.COM](https://github.com/S0urceror/MSX-USB/blob/master/drivers/UsbEthernet/dist/usbether.com) to install the USB Ethernet Driver. You can then subsequently run `INL i` to install Internestor Lite. When all goes well you can then run any TCP/IP applications like `TELNET`, `HUB`, `HGET`, `TFTP`, etc. More information about this you can find on [Konamiman's](https://www.konamiman.com/msx/msx-e.html#inl2) website.
* [USBKEYBD.COM](https://github.com/S0urceror/MSX-USB/raw/master/drivers/UsbKeyboard/dist/usbkeybd.bin) to install the USB HID Keyboard driver. This will enable any connected USB HID compliant keyboard.