
	STRUCT DEVINFO		; Contains information about a specific device
BASE:				; Offset to the base of the data structure
DEVICE_TYPE: 		db ;UINT8	DeviceType;					/* 00H */
REMOVABLE_MEDIA:	db ;UINT8	RemovableMedia;				/* 01H */
VERSIONS:			db ;UINT8	Versions;					/* 02H */
DATA_FORMAT:		db ;UINT8	DataFormatAndEtc;			/* 03H */
ADD_LENGTH:			db ;UINT8	AdditionalLength;			/* 04H */
RESERVE1:			db ;UINT8	Reserved1;					/* 05H */
RESERVE2:			db ;UINT8	Reserved2;					/* 06H */
MISC:				db ;UINT8	MiscFlag;					/* 07H */
VENDORID:			ds 8 ;UINT8	VendorIdStr[8];				/* 08H */
PRODUCTID:			ds 16 ;UINT8 ProductIdStr[16];			/* 10H */
PRODUCTREV:			ds 8 ;UINT8	ProductRevStr[4];			/* 20H */ 
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
BASE:				; Offset to the base of the data structure 
STATUS:				db ; bit 0 = CH376s present, bit 1 = initialised, bit 2 = USB device present, bit 3 = USB device mounted, bit 4 = virtual DSK file inserted, bit 5 = DSK changed
DSK_NAME:			ds 13
DIR_NAME:			ds 9
MAX_DEVICE_ADDRESS:	db 0
DEVICE_INFO:		DEVINFO
USB_DEVICE_INFO:		_USB_DEVICE_INFO
STORAGE_DEVICE_INFO:	_USB_DEVICE_INFO
SEARCH_DEVICE_INFO		_SEARCH_DEVICE_INFO
HUB_DEVICE_INFO			_HUB_DEVICE_INFO
USB_DESCRIPTOR		ds 140 ; memory area to hold the usb device+config descriptor of the current interrogated device
IO_BUFFER:    		ds 040h
USB_DESCRIPTORS		ds USB_DESCRIPTORS_END - USB_DESCRIPTORS_START
NXT_DIRECT			ds NXT_DIRECT_END - NXT_DIRECT_START
JUMP_TABLE			ds JUMP_TABLE_END - JUMP_TABLE_START
	ENDS

TXT_START:              db "MSXUSB driver v0.5\r\nGNU General Public License\r\n=============================\r\n\r\n",0
TXT_FOUND:              db "+MSXUSB cartridge found\r\n",0
TXT_NOT_FOUND:          db "-Insert MSXUSB compatible cartridge\r\n",0
TXT_DEVICE_CONNECTED: 	db "+USB device connected\r\n",0
TXT_NO_DEVICE_CONNECTED: db "-USB device NOT connected\r\n",0
TXT_MODE_SET:           db "+USB mode set\r\n",0
TXT_MODE_NOT_SET:       db "+USB mode NOT set\r\n",0
TXT_DISK_CONNECTED:     db "+Disk connected\r\n",0
TXT_DISK_NOT_CONNECTED: db "-Disk NOT connected\r\n",0
TXT_DISK_MOUNTED:       db "+Disk mounted\r\n",0
TXT_DISK_NOT_MOUNTED:   db "-Disk NOT mounted\r\n",0
TXT_NO_MAKE_MODEL:      db "-Device name NOT read\r\n",0
TXT_MAKE_MODEL:         db "+Device name: ",0
TXT_DIR_OPENED:     	db "+Directory opened\r\n",0
TXT_DIR_NOT_OPENED: 	db "-Directory NOT opened\r\n",0
TXT_NO_DIR_ENTRY:       db "-Directory entry NOT read\r\n",0
TXT_CD_FAILED:          db "-Directory does NOT exist\r\n",0
TXT_SEC_LOCATE_FAILED:  db "-Cannot set file pointer to sector\r\n",0
TXT_SEC_READ_FAILED:    db "-Request sector failed\r\n",0
TXT_DISK_READ_FAILED:   db "-Disk read sector failed\r\n",0
TXT_CD_OKAY:            db "+Directory opened\r\n",0
TXT_FILEOPEN_OKAY:      db "+File opened: ",0
TXT_FILEOPEN_FAILED:    db "-File NOT opened\r\n",0
TXT_SEC_LOCATE_OKAY:    db "+File pointer set to sector\r\n",0
TXT_SEC_READ_OKAY:      db "+Sector read requested\r\n",0
TXT_DISK_READ_OKAY:     db "+Disk sector read\r\n",0
TXT_RESET:              db "+CH376s reset\r\n",0
TXT_FILECLOSED_OKAY:    db "+File closed\r\n",0
TXT_ROOT_DIR			db "\\",0,0,0,0,0,0,0
TXT_WILDCARD			db "*",0,0,0,0,0,0,0
TXT_ROOT_WILDCARD		db "\\*",0,0,0,0,0,0
TXT_USB_DRIVE			db "USB:",0
TXT_NEXTOR_DSK			db "\\NEXTOR.DSK",0
TXT_NEWLINE				db "\r\n",0
TXT_DIRECTORY_ENTRY: 	db "\r",09h,09h,"<DIR>\r",0
TXT_AUTOEXEC_TXT:		db "\\AUTOEXEC.TXT",0
