# USB Flash Drive
Once flashed Nextor ROM will automatically find the driver and initialise the CH376s.
Then it searches the file identified by TXT_NEXTOR_DSK and mounts it. 
It then continuous to boot. 
* If there is NEXTOR.SYS and COMMAND2.COM on the mounted disk it will start NEXTOR.
* If there is MSXDOS2.SYS and COMMAND2.COM on the mounted disk it will start MSXDOS2.x
* If there is MSXDOS.SYS and COMMAND.COM it will start MSXDOS1.x
* Otherwise it goes to MSX BASIC

In MSX Basic you have the following commands:
* CALL USBFILES - list all files in the current directory of the FAT32 formatted flash drive
* CALL USBCD - change to another directory of the flash drive
* CALL INSERTDISK ("filename.ext") - load another disk image and mount it
* CALL EJECTDISK - eject the current mounted disk image

