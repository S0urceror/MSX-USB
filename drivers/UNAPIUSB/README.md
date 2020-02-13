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

Check if specialised USB hardware is present, like RookieDrive or MSXUSB cartridge.

## Connect

Input: A = 2

Connect the inserted USB device, reset it properly and prepare for communication.

## GetDescriptors

Input: A = 3

Return both the fixed length DEVICE_DESCRIPTOR followed by the variable length CONFIGURATION_DESCRIPTOR containing INTERFACE_DESCRIPTORS, ENDPOINT_DESCRIPTORS and specialised descriptors for HID, CDC ECM, etc.

## ExecuteControlTransfer 

Input: A = 4

## DataInTransfer

Input: A = 5

## DataOutTransfer

Input: A = 6

