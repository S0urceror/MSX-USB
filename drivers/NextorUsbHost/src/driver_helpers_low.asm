
	STRUCT _SCSI_DEVINFO
BASE:				; Offset to the base of the data structure
TAG					db
MAX_LUNS			db
BUFFER:    			ds 0x24 ; longest response (inquiry) we want to absorb during init
CSW:				ds _SCSI_COMMAND_STATUS_WRAPPER
VENDORID:			ds 8 ;UINT8	VendorIdStr[8];				/* 08H */
					db 0
PRODUCTID:			ds 16 ;UINT8 ProductIdStr[16];			/* 10H */
					db 0
PRODUCTREV:			ds 8 ;UINT8	ProductRevStr[4];			/* 20H */ 
					db 0
	ENDS

	STRUCT _USB_DEVICE_INFO
BASE:
DEVICE_ADDRESS					DB
INTERFACE_ID					DB
CONFIG_ID						DB
MAX_PACKET_SIZE					DB
DATA_BULK_IN_ENDPOINT_ID		DB
DATA_BULK_OUT_ENDPOINT_ID		DB
DATA_BULK_IN_ENDPOINT_TOGGLE	DB
DATA_BULK_OUT_ENDPOINT_TOGGLE	DB
	ENDS

	STRUCT _HUB_DEVICE_INFO
HUB_PORTS						DB
HUB_PORT_STATUS					DS 4
	ENDS

	STRUCT _SEARCH_DEVICE_INFO
NUM_CONFIGS						DB
NUM_INTERFACES					DB
NUM_ENDPOINTS					DB
WANTED_CLASS					DB
WANTED_SUB_CLASS				DB
WANTED_PROTOCOL					DB
	ENDS

	STRUCT WRKAREA
BASE:					; Offset to the base of the data structure 
STATUS:					db ; bit 0 = CH376s present, bit 1 = initialised, bit 2 = USB device present, bit 3 = USB device mounted, bit 5 = DSK changed, bit 7 = Flash disk present
MAX_DEVICE_ADDRESS:		db 0
USB_DEVICE_INFO:		_USB_DEVICE_INFO
STORAGE_DEVICE_INFO:	_USB_DEVICE_INFO
SEARCH_DEVICE_INFO		_SEARCH_DEVICE_INFO
HUB_DEVICE_INFO			_HUB_DEVICE_INFO
SCSI_DEVICE_INFO:		_SCSI_DEVINFO
USB_DESCRIPTOR			ds 140 ; ** memory area to hold the usb device+config descriptor of the current interrogated device
USB_DESCRIPTORS			ds USB_DESCRIPTORS_END - USB_DESCRIPTORS_START ; **
FLASH_READ				ds FLASH_READ_END - FLASH_READ_START ; routine that swaps in the right segment, reads, and swaps back
NXT_DIRECT				ds NXT_DIRECT_END - NXT_DIRECT_START
	ENDS

	DISPLAY "WRKAREA bytes: ",/D,WRKAREA

	IFDEF __ROOKIEDRIVE
TXT_START:              db "MSXUSB-RD v0.8 (c) Sourceror\r\n"
	ENDIF
	IFDEF __MISTERSPI
TXT_START:              db "MSXUSB-MST v0.8 (c)Sourceror\r\n"	
	ENDIF
	IFDEF __MSXUSBCARTv1
TXT_START:              db "MSXUSB v0.8  (c) Sourceror\r\n"
	ENDIF
						db "GNU General Public License\r\n"
						db "=============================\r\n\r\n",0
TXT_FOUND:              db "+MSXUSB cartridge found\r\n",0
TXT_IC_VERSION:			db "+CH376s version: ",0
TXT_NOT_FOUND:          db "-Insert MSXUSB cartridge\r\n",0
TXT_NEWLINE				db "\r\n",0
TXT_DEVICE_CHECK_OK:	db " device(s) connected\r\n",0
TXT_DEVICE_CHECK_NOK:	db "-No USB device connected\r\n",0
TXT_STORAGE_CHECK_NOK:	db "-No USB storage\r\n",0
TXT_STORAGE_CHECK_OK:	db "+Found USB Storage:",0
TXT_INQUIRY_OK:			db "\r\n ",0
TXT_INQUIRY_NOK:		db "\r\n-Error (Inquiry)\r\n",0
TXT_TEST_START:			db "\r\n+Testing storage device",0
TXT_TEST_OK:			db "\r\n+All systems go!\r\n",0
TXT_FLASHDISK_OK:		db "+ROM disk detected\r\n",0

RD_MANUFACTURER:		db "S0urceror",0
RD_DEVICE_NAME:			db "Flash ROM Disk",0
RD_SERIAL:				db "v0.1",0