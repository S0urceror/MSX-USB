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

# USB - UNAPI DRIVER
Below the specification of an UNAPI compliant USB driver. Other, more specialised, drivers can rely on this base driver to return the basic information and low-level routines.

## API Information Routine

Input: A = 0

Output:
* HL = Address of the implementation name string
* DE = API specification version supported. D=primary, E=secondary.
* BC = API implementation version. B=primary, C=secondary.

## Check

Input: A = 1
Output: Cy = 0, everything okay, Cy = 1, not connected

Check if specialised USB hardware is present, like RookieDrive or MSXUSB cartridge.

## Connect

Input: A = 2
Output: Cy = 0, everything okay, Cy = 1, something went wrong

Connect the inserted USB device, reset it properly and prepare for communication.

## GetDescriptors

Input: IX = buffer that will receive the desciptors
Output: (IX) = received contents, Cy = 0, everything okay, Cy = 1, something went wrong

Return both the fixed length DEVICE_DESCRIPTOR followed by the variable length CONFIGURATION_DESCRIPTOR containing INTERFACE_DESCRIPTORS, ENDPOINT_DESCRIPTORS and specialised descriptors for HID, CDC ECM, etc.

## ExecuteControlTransfer 

Input: A = 4

## DataInTransfer

Input: A = 5

## DataOutTransfer

Input: A = 6

