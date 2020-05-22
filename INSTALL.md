# MSX-USB
## Installation instructions
You have to flash a new NEXTOR ROM image onto a MSX flash cartridge. The RookieDrive and other MSX USB initiatives have both Flash and the USB part combined in one cartridge so thats easy. In my prototype setup I have one cartridge with MSX USB and one modded SCC cartridge with flash and that works as well.

You can use the MSX USB cartridge in two modes.

### Use as disk drive
* Download [this](https://github.com/S0urceror/MSX-USB/raw/master/drivers/NextorUsbHost/dist/nextor.rom) ROM image
* Flash the image
* Reboot

The first time you need to boot up with a floppy disk with the NEXTOR.SYS and COMMAND2.COM files. 
Please insert a FAT32 formatted USB Flash Disk in the MSX USB cartridge.
For your convenience I have created a couple of FAT16 disk images that you can put on this USB Flash Disk.
The one named NEXTOR.DSK will be found and booted by default. You can change the default DSK file by creating an AUTOEXEC.DSK file with another filename in the first line of text.

* NEXTOR.DSK - A 720KB image with NEXTOR.SYS and COMMAND2.COM
* 128mb.DSK - You can have multiple of these on your Flash Disk when size permits. Nextor supports bigger FAT16 disks but 128mb is still fast. When it gets bigger Nextor will spend more time on housekeeping and calculating for example the free space.
* 720kb.DSK - An empty 720KB disk image.

Here the [link](https://github.com/S0urceror/MSX-USB/raw/master/drivers/flashdrive/dist/dsks.zip) to the disk images. Within Nextor and Disk Basic you can create subdirectories, format, repartition, etc.

There are also a couple of special instructions in BASIC at your disposal:
* CALL USBFILES - list all files in the current directory of the FAT32 formatted flash drive
* CALL USBCD - change to another directory of the flash drive
* CALL INSERTDISK ("filename.ext") - load another disk image and mount it
* CALL EJECTDISK - eject the current mounted disk image

P.S. if you want to use MSXUSB on the RookieDrive please use [this](https://github.com/S0urceror/MSX-USB/raw/master/drivers/NextorUsbHost/dist/nextorrd.rom) version of the ROM.

### Multi purpose USB port
The ROM image now also contains an UNAPI compatible USB Host driver.

You can do the following things:
* [APILIST.COM](https://github.com/S0urceror/MSX-USB/raw/master/drivers/UsbEthernet/dist/apilist.com) MSXUSB to check that the UNAPI driver is ready and works.
* [LSUSB.COM](https://github.com/S0urceror/MSX-USB/raw/master/drivers/UsbEthernet/dist/lsusb.com) to list all technical USB information from the connected USB device.
* [USBETHER.COM](https://github.com/S0urceror/MSX-USB/blob/master/drivers/UsbEthernet/dist/usbether.com) to install the USB Ethernet Driver. You can then subsequently run `INL i` to install Internestor Lite. When all goes well you can then run any TCP/IP applications like `TELNET`, `HUB`, `HGET`, `TFTP`, etc. More information about this you can find on [Konamiman's](https://www.konamiman.com/msx/msx-e.html#inl2) website.
* BLOAD ("[USBKEYBD.BIN](https://github.com/S0urceror/MSX-USB/raw/master/drivers/UsbKeyboard/dist/usbkeybd.bin)"),R to install the USB HID Keyboard driver. This will enable any connected USB HID compliant keyboard.

## Flashing the image
To flash the ROM's you need an appropriate flashing tool. For this I created a program called Flash. You can download it [here](https://github.com/S0urceror/MSX-USB/raw/master/software/dist/flash.com)

It is simple to use Flash. The following statement automatically finds the (mega-)flash cartridge and flashes image.rom.

`FLASH nextor.rom`
