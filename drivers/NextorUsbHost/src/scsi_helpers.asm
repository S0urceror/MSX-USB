;
; scsi_helpers.ASM - scsi command set for low level usb storage
; Copyright (c) 2020 Mario Smit (S0urceror)
; 
; This program is free software: you can redistribute it and/or modify  
; it under the terms of the GNU General Public License as published by  
; the Free Software Foundation, version 3.
;
; This program is distributed in the hope that it will be useful, but 
; WITHOUT ANY WARRANTY; without even the implied warranty of 
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
; General Public License for more details.
;
; You should have received a copy of the GNU General Public License 
; along with this program. If not, see <http://www.gnu.org/licenses/>.
;
    STRUCT _SCSI_COMMAND_BLOCK_WRAPPER
BASE:
CBWSIGNATURE:           DB 0x55
                        DB 0x53
                        DB 0x42
                        DB 0x43
CBWTAG:                 DS 4,0
CBWDATATRANSFERLENGTH:  DS 4,0
CBWFLAGS:               DB 0
CBWLUN:                 DB 0
CBWCBLENGTH:            DB 0
    ENDS

    STRUCT _SCSI_COMMAND_STATUS_WRAPPER
BASE:
CBWSIGNATURE:   DS 4,0
CBWTAG:         DS 4,0
CBWRESIDUE      DS 4,0
CBWSTATUS:      DB 0
    ENDS

	STRUCT _SCSI_PACKET_INQUIRY		; Contains information about a specific device
BASE:				; Offset to the base of the data structure
OPERATION_CODE: 	db 0x12
LUN:	            db 0
RESERVED1:			db 0
RESERVED2:		    db 0
ALLOCATION_LENGTH:  db 0x24
RESERVED3:		    db 0
PAD:                ds 6,0
	ENDS

    STRUCT _SCSI_PACKET_TEST
BASE:				; Offset to the base of the data structure
OPERATION_CODE: 	db 0x00
LUN:	            db 0
RESERVED1:			db 0
RESERVED2:		    db 0
RESERVED3:		    db 0
RESERVED4:		    db 0
PAD:                ds 6,0
    ENDS

    STRUCT _SCSI_PACKET_REQUEST_SENSE
BASE:				; Offset to the base of the data structure
OPERATION_CODE: 	db 0x03
LUN:	            db 0
RESERVED1:			db 0
RESERVED2:		    db 0
ALLOCATION_LENGTH:  db 18
RESERVED3:		    db 0
PAD:                ds 6,0
    ENDS

    STRUCT _SCSI_PACKET_READ
BASE:				; Offset to the base of the data structure
OPERATION_CODE: 	db 0x28
LUN:	            db 0
LBA:                dw 0 ; high-endian block number
                    dw 0
RESERVED1:			db 0
TRANSFER_LEN:       dw 0 ; high-endian in blocks of block_len (see SCSI_CAPACITY)
RESERVED2:		    db 0
PAD:                ds 2,0
    ENDS

    STRUCT _SCSI_PACKET_WRITE
BASE:				; Offset to the base of the data structure
OPERATION_CODE: 	db 0x2a
LUN:	            db 0
LBA:                dw 0 ; high-endian block number
                    dw 0
RESERVED1:			db 0
TRANSFER_LEN:       dw 0 ; high-endian in blocks of block_len (see SCSI_CAPACITY)
RESERVED2:		    db 0
PAD:                ds 2,0
    ENDS