## Usage
This is a Nextor driver programmed in C. It mounts the USB disk connected to the MSXUSB cartridge. Other devices and USB hubs are not supported by this driver.

### Disk formats supported
1. FAT32
    - Format in Windows, MacOS, Linux with master boot record. 
    - Place .DSK floppy images in the root folder or subfolders. 
    - Select the right DSK file during MSX boot.
2. FAT16
    - Format in Windows, MacOS, Linux with master boot record. 
    - Place .DSK floppy images in the root folder or subfolders. 
    - Select the right DSK file during MSX boot. 
    - **NEXTOR can also mount the whole USB drive in FAT16 mode**
3. FAT12
    - Format in MacOS, Linux or by DD-ing a DSK file to the USB drive. 
    - You will waste a lot of space because now the USB drive can only contain 720kb.

### MSX compatibility
On MSX 1 you can only mount FAT12 720kb DSK images. On MSX 2 and higher you can mount FAT16 DSK images of various sizes or the whole USB disk when formatted in FAT16.

### AUTOEXEC.DSK
Place a disk image called AUTOEXEC.DSK in the root of the USB drive to mount this image automatically. If your press ESCape within 3 seconds it will show the normal boot menu.

### CALL MOUNTDSK
In MSX Basic you can use the _MOUNTDSK or CALL MOUNTDSK command to show the boot menu again and change to another DSK image. Just like changing a floppy would.
