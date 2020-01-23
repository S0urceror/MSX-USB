
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

	STRUCT WRKAREA
BASE:				; Offset to the base of the data structure 
STATUS:				db ; bit 0 = CH376s present, bit 1 = initialised, bit 2 = USB device present, bit 3 = USB device mounted, bit 4 = virtual DSK file inserted, bit 5 = DSK changed
DSK_NAME:			ds 12
DIR_NAME:			ds 8
DEVICE_INFO:		DEVINFO
IO_BUFFER:    	ds 040h
	ENDS

TXT_START:              db "Starting CH376s driver\r\n",0,"$"
TXT_FOUND:              db "+CH376s connected\r\n",0,"$"
TXT_NOT_FOUND:          db "-CH376s NOT connected\r\n",0,"$"
TXT_MODE_SET:           db "+USB mode set\r\n",0,"$"
TXT_MODE_NOT_SET:       db "+USB mode NOT set\r\n",0,"$"
TXT_DISK_CONNECTED:     db "+Disk connected\r\n",0,"$"
TXT_DISK_NOT_CONNECTED: db "-Disk NOT connected\r\n",0,"$"
TXT_DISK_MOUNTED:       db "+Disk mounted\r\n",0,"$"
TXT_DISK_NOT_MOUNTED:   db "-Disk NOT mounted\r\n",0,"$"
TXT_NO_MAKE_MODEL:      db "-Device name NOT read\r\n",0,"$"
TXT_MAKE_MODEL:         db "+Device name: ",0,"$"
TXT_DIR_OPENED:     	db "+Directory opened\r\n",0,"$"
TXT_DIR_NOT_OPENED: 	db "-Directory NOT opened\r\n",0,"$"
TXT_NO_DIR_ENTRY:       db "-Directory entry NOT read\r\n",0,"$"
TXT_CD_FAILED:          db "-Directory does NOT exist\r\n",0,"$"
TXT_SEC_LOCATE_FAILED:  db "-Cannot set file pointer to sector\r\n",0,"$"
TXT_SEC_READ_FAILED:    db "-Request sector failed\r\n",0,"$"
TXT_DISK_READ_FAILED:   db "-Disk read sector failed\r\n",0,"$"
TXT_CD_OKAY:            db "+Directory opened\r\n",0,"$"
TXT_FILEOPEN_OKAY:      db "+File opened\r\n",0,"$"
TXT_FILEOPEN_FAILED:    db "-File NOT opened\r\n",0,"$"
TXT_SEC_LOCATE_OKAY:    db "+File pointer set to sector\r\n",0,"$"
TXT_SEC_READ_OKAY:      db "+Sector read requested\r\n",0,"$"
TXT_DISK_READ_OKAY:     db "+Disk sector read\r\n",0,"$"
TXT_RESET:              db "+CH376s reset\r\n",0,"$"
TXT_FILECLOSED_OKAY:    db "+File closed\r\n",0,"$"
;TXT_NEXTOR_DSK			db "NEXTOR.DSK",0,"$"
TXT_NEXTOR_DSK			db "128MB.DSK",0,"$"
;TXT_NEXTOR_DSK			db "16MB.DSK",0,"$"
TXT_NEWLINE				db "\r\n",0,"$"
TXT_DIRECTORY_ENTRY: db "\r",09h,09h,"<DIR>\r",0,"$"