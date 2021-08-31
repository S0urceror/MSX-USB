;
; tsr.ASM - The resident bit of the USB Ethernet driver.
;           Will be put in a free memory mapper segment.
;
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

; major and minor version number of Ethernet UNAPI
ETHERNET_UNAPI_P:  equ  1
ETHERNET_UNAPI_S:  equ  1
; S0urceror's Ethernet driver, major and minor version
ETHERNET_IMPLEMENTATION_P:  equ  0
ETHERNET_IMPLEMENTATION_S:  equ  1

ARG:    equ  0F847h
EXTBIO: equ  0FFCAh

PACKET_TYPE_MULTICAST      equ 00010000b
PACKET_TYPE_BROADCAST      equ 00001000b
PACKET_TYPE_DIRECTED       equ 00000100b
PACKET_TYPE_ALL_MULTICAST  equ 00000010b
PACKET_TYPE_PROMISCUOUS    equ 00000001b

   org 4000h
TSR_ORG:

TSR_START:
   jp DO_EXTBIO
   jp RESERVED1
   jp RESERVED2
   jp RESERVED3

RESERVED1:
RESERVED2:
RESERVED3:   
   ret 

FN_TABLE:
FN_0:  dw  ETH_GETINFO     ;Obtain the implementation name and version
FN_1:  dw  ETH_RESET       ;Reset hardware
FN_2:  dw  ETH_GET_HWADD   ;Obtain the Ethernet address
FN_3:  dw  ETH_GET_NETSTAT ;Obtain network connection status
FN_4:  dw  ETH_NET_ONOFF   ;Enable or disable networking
FN_5:  dw  ETH_DUPLEX      ;Configure duplex mode
FN_6:  dw  ETH_FILTERS     ;Configure frame reception filters
FN_7:  dw  ETH_IN_STATUS   ;Check for received frames availability
FN_8:  dw  ETH_GET_FRAME   ;Retrieve the oldest received frame
FN_9:  dw  ETH_SEND_FRAME  ;Send a frame
FN_10: dw  ETH_OUT_STATUS  ;Check frame transmission status
FN_11: dw  ETH_SET_HWADD   ;Set the Ethernet address
MAX_FN equ 11

;************************
;***  FUNCTIONS CODE  ***
;************************

;--- Mandatory routine 0: return API information
;    Input:  A  = 0
;    Output: HL = Descriptive string for this implementation, on this slot, zero terminated
;            DE = API version supported, D.E
;            BC = This implementation version, B.C.
;            A  = 0 and Cy = 0
ETH_GETINFO:
    ld  bc,256*ETHERNET_IMPLEMENTATION_P+ETHERNET_IMPLEMENTATION_S
    ld  de,256*ETHERNET_UNAPI_P+ETHERNET_UNAPI_S
    ld  hl,ETHERNET_UNAPI_INFO
    xor  a
    ret

;--- ETH_RESET: Reset hardware
;    Input:  A  = 1
;    Output: -
ETH_RESET:
   ld a,PACKET_TYPE_DIRECTED+PACKET_TYPE_BROADCAST
   call CH_SET_PACKET_FILTER
   ; set NAK retries to return immediately
   ; this way we can poll status and keep things snappy
   ; Bits 7 and 6:
   ;   0x: Don't retry NAKs
   ;   10: Retry NAKs indefinitely (default)
   ;   11: Retry NAKs for 3s
   ; Bits 5-0: Number of retries after device timeout
   ; Default after reset and SET_USB_MODE is 8Fh
   ld b, 00001111b ; return immediately
   call TSR_FN_SYNC_MODE
   ret

;--- ETH_GET_HWADD: Get hardware address
;    Input:  A = 2
;    Output: L-H-E-D-C-B = Ethernet address
ETH_GET_HWADD:
   ld hl,(TSR_MAC_ADDRESS)
   ld de,(TSR_MAC_ADDRESS+2)
   ld bc,(TSR_MAC_ADDRESS+4)
   ret

;--- ETH_GET_NETSTAT: Obtain network connection status
;    Input:  A  = 3
;    Output: A  = 0 if NOT connected to an active network
;                 1 if connected to an active network
ETH_GET_NETSTAT:
   ;
   ld b, 10001111b ; default
   call TSR_FN_SYNC_MODE
   ;
   ld a, (ETH_INT_READ_TOGGLE) ; get stored toggle value
   rla ; high bit shifted to Cy
   ;
   ld hl, SCRATCH_AREA ;ECM_NOTIFICATION_EVENT_BUFFER
   ld bc, ECM_NOTIFICATION_EVENT
   ld a, (TSR_ETHERNET_MAX_PACKET_SIZE)
   ld d, a
   ld a, (TSR_CONTROL_ENDPOINT_ID)
   ld e, a
   ld a, (TSR_DEVICE_ADDRESS)
   call _PACK_E
   call TSR_FN_DATA_IN_TRANSFER ; A=USB result code, Cy=toggle bit, BC = Amount of data actually received
   ;
   push af
   ld a, 0 ; deliberately no XOR because that wipes Cy
   rra ; Cy stored in high bit of A
   ld (ETH_INT_READ_TOGGLE),a ; stored in memory   
   ;
   ld b, 00001111b ; return immediately
   call TSR_FN_SYNC_MODE
   ;
   pop af
   cp CH_USB_INT_SUCCESS
   jr nz, _READ_ETH_ERROR
_READ_ETH_CONTINUE:
   ld ix,SCRATCH_AREA ;ECM_NOTIFICATION_EVENT_BUFFER
   ld a, (ix+ECM_NOTIFICATION_EVENT.bmRequestType)
   cp 10100001b
   jr nz,ETH_GET_NETSTAT
   ld a, (ix+ECM_NOTIFICATION_EVENT.bNotificationCode)
   and a
   jr nz,ETH_GET_NETSTAT
   ; network connection event
   ld a, (ix+ECM_NOTIFICATION_EVENT.wValue)
   ret
_READ_ETH_ERROR:
   xor a; clear A and Cy
   ret

;--- ETH_NET_ONOFF: Enable or disable networking
;    Input:  A = 4
;            B = 0: Obtain current state only
;                1: Enable networking
;                2: Disable networking
;    Output: A = State after routine execution:
;                1: Networking is enabled
;                2: Networking is disabled
ETH_NET_ONOFF:
   ld a, b
   and a ; zero?
   jr nz, _ETH_NET_NEW_STATE
   ld a, (NETWORKING_ONOFF)
   ret
_ETH_NET_NEW_STATE:
   ld (NETWORKING_ONOFF),a
   ret   

;--- ETH_DUPLEX: Configure duplex mode
;    Input:  A = 5
;            B = 0: Obtain current mode only
;                1: Set half-duplex mode
;                2: Set full-duplex mode
;    Output: A = Mode after routine execution:
;                1: Currently half-duplex mode set
;                2: Currently full-duplex mode set
;                3: Current mode unknown or duplex mode does not apply
ETH_DUPLEX:
   ld a, 2 ; only full-duplex mode
   ret  

;--- ETH_FILTERS: Configure frame reception filters
;    Input:   A = 6
;             B = Filter bitmask:
;                 Bit 7: Set to return current configuration only
;                 Bit 6: Reserved
;                 Bit 5: Reserved
;                 Bit 4: Set to enable promiscuous mode, reset do disable it
;                 Bit 3: Reserved
;                 Bit 2: Set to accept broadcast frames,
;                        reset to reject them
;                 Bit 1: Set to accept small frames (smaller than 64 bytes),
;                        reset to reject them
;                 Bit 0: Reserved
;    Output: A = Filter configuration after execution
;                (bitmask with same format as B at input)
ETH_FILTERS:
   bit 7,b
   jr z, _ETH_FILTERS_NEXT 
   ; get current configuration
   ld a, (CUR_ETH_FILTERS)
   ret
_ETH_FILTERS_NEXT:
   ld a, b
   ld (CUR_ETH_FILTERS),a ; store configuration
   ld a, PACKET_TYPE_DIRECTED ; standard receive packets for us
_ETH_FILTERS_NEXT1:
   bit 4,b
   jr z, _ETH_FILTERS_NEXT2
   or PACKET_TYPE_PROMISCUOUS ; receive all
_ETH_FILTERS_NEXT2:
   bit 2,b
   jr z, _ETH_FILTERS_NEXT3
   or PACKET_TYPE_BROADCAST ; receive broadcasted packets
_ETH_FILTERS_NEXT3:
   call CH_SET_PACKET_FILTER
   ld a, (CUR_ETH_FILTERS)
   ret

; --------------------------------------
; CH_SET_PACKET_FILTER
;
; Input: A=packet_filter
; Output: Cy=0 no error, Cy=1 error
CH_SET_PACKET_FILTER:
   push bc,af
   ld bc, 6*8
   call TSR_FN_CONTROL_PACKET
   pop af,bc
   ld ix, hl
   ; set packet_filter
   ld (ix+2),a
   ; set packet size
   ld a, (TSR_ETHERNET_MAX_PACKET_SIZE)
   ld b, a
   ; set interface id
   ld a, (TSR_CONTROL_INTERFACE_ID)
   ld (ix+4),a
   ; set device_address
   ld a, (TSR_DEVICE_ADDRESS)
   ld c, a
   call TSR_FN_CONTROL_TRANSFER
   cp CH_USB_INT_SUCCESS
   ret z ; no error
   scf ; error

   ret

;--- GET_PACKET: Get the next USB packet
;    Input:  HL = points to free memory to store the packet
;    Output: A  = USB result code, 
;            Cy = toggle bit, 
;            BC = Amount of data actually received
GET_BULK_IN_PACKET:
   ;
   ld a, (ETH_DATA_READ_TOGGLE) ; get stored toggle value
   rla ; high bit shifted to Cy
   ;
   ; request max size
   ld bc, (TSR_ETHERNET_MAX_SEGMENT_SIZE)
   ld a, (TSR_ETHERNET_MAX_PACKET_SIZE)
   ld d, a
   ld a, (TSR_DATA_BULK_IN_ENDPOINT_ID)
   ld e, a
   ld a, (TSR_DEVICE_ADDRESS)
   call _PACK_E
   call TSR_FN_DATA_IN_TRANSFER; A=USB result code, Cy=toggle bit, BC = Amount of data actually received
   ;
   push af
   ld a, 0 ; deliberately no XOR because that wipes Cy
   rra ; Cy stored in high bit of A
   ld (ETH_DATA_READ_TOGGLE),a ; stored in memory
   pop af
   ;
   ret

; GET_ETHERNET_FRAME
; Gets a full ethernet frame composed of multiple USB packets
; Output: A  = 0: No frames available
;         A  = 1: Frame available
;         BC = Size of frame
GET_ETHERNET_FRAME:
   ld a, (FRAME_IN_MEMORY)
   or a
   jr z, _GET_NEW_FRAME
   ld bc, (FRAME_SIZE)
   ret
_GET_NEW_FRAME:
   ld hl, ETH_PACKET
_GET_NEXT_PACKET:
   call GET_BULK_IN_PACKET ; BC holds amount of data retrieved
   cp CH_USB_INT_SUCCESS
   jr nz, _GET_ETHERNET_FRAME_NO_SUCCESS
_GET_ETHERNET_FRAME_SUCCESS:
   ld a, b
   or c
   jr z, _GET_ETHERNET_FRAME_NO_SUCCESS ; empty frame
   ld (FRAME_SIZE),bc
   ld a, 1
   ld (FRAME_IN_MEMORY),a
   ret
_GET_ETHERNET_FRAME_NO_SUCCESS:
   xor a
   ld (FRAME_IN_MEMORY),a
   ld bc, 0
   ret

;--- ETH_IN_STATUS: Check for received frames availability
;    Input:  A = 7
;    Output: A = 0: No received frames available
;                1: At least one received frame is available
;            When A=1:
;                BC = Size of the oldest available frame
;                HL = Bytes 12 and 13 of the oldest available frame
ETH_IN_STATUS:
   call GET_ETHERNET_FRAME
   push af
   ld a, (ETH_PACKET+12)
   ld h,a
   ld a, (ETH_PACKET+13)
   ld l,a
   pop af
   ret

;--- ETH_GET_FRAME: Retrieve the oldest received frame
;    Input:  A  = 8
;            HL = Destination address for the frame, or
;                 0 to discard the frame
;    Output: A  = 0 if frame has been retrieved or discarded
;                 1 if no received frames are available
;            BC = Size of the retrieved frame
ETH_GET_FRAME:
   call GET_ETHERNET_FRAME
   or a
   jr nz, _ETH_GET_FRAME_AVAILABLE
   ld a, 1
   ld bc, 0
   ret
_ETH_GET_FRAME_AVAILABLE:
   ;ld a, h
   ;or l
   ;jr z, _ETH_GET_FRAME_NO_COPY
   ;ex de,hl
   ;ld hl, ETH_WORK_AREA
   ;push bc
   ;ldir
   ;pop bc
_ETH_GET_FRAME_NO_COPY:
   xor a
   ld (FRAME_IN_MEMORY),a
   ret

SEND_BULK_OUT_PACKET:
   ;
   ld a, (ETH_DATA_WRITE_TOGGLE) ; get stored toggle value
   rla ; high bit shifted to Cy
   ;
   ; -----------------------------------------------------------------------------
   ; HW_DATA_OUT_TRANSFER: Perform a USB data OUT transfer
   ; -----------------------------------------------------------------------------
   ; Input:  HL = Address of a buffer for the data to be sent
   ;         BC = Data length
   ;         A  = Device address
   ;         D  = Maximum packet size for the endpoint
   ;         E  = Endpoint number
   ;         Cy = Current state of the toggle bit
   ; Output: A  = USB error code, or 0 when all is okay
   ;         Cy = New state of the toggle bit (even on error)
   ld a, (TSR_ETHERNET_MAX_PACKET_SIZE)
   ld d, a
   ld a, (TSR_DATA_BULK_OUT_ENDPOINT_ID)
   ld e, a
   ld a, (TSR_DEVICE_ADDRESS)
   call _PACK_E
   call TSR_FN_DATA_OUT_TRANSFER; A=USB result code, Cy=toggle bit
   ;
   push af
   ld a, 0 ; deliberately no XOR because that wipes Cy
   rra ; Cy stored in high bit of A
   ld (ETH_DATA_WRITE_TOGGLE),a ; stored in memory
   pop af
   ;
   ret

;--- ETH_SEND_FRAME: Send a frame
;    Input:  A  = 9
;            HL = Frame address in memory
;            BC = Frame length
;            D  = Routine execution mode:
;                 0: Synchronous
;                 1: Asynchronous
;    Output: A  = 0: Frame sent, or transmission started
;                 1: Invalid frame length
;                 3: Carrier lost
;                 4: Excessive collisions
;                 5: Asyncrhonous mode not supported
ETH_SEND_FRAME:
   call SEND_BULK_OUT_PACKET
   cp CH_USB_INT_SUCCESS
   jr nz, _ETH_SEND_FRAME_NEXT
   xor a ; frame sent
   ret
_ETH_SEND_FRAME_NEXT:
   or a
   ret z ; zero is no error
   ld a, 3
   ret

; Input:    A: device address
;           E: endpoint id
; Output:   Everything preserved including Cy
;           E will contain DDDDEEEE (D=device address, E=endpoint id)
_PACK_E:
   push af ; preserve Cy
   sla a
   sla a
   sla a
   sla a
   and 0xf0
   or e
   ld e, a
   pop af
   ;
   ret

;--- ETH_OUT_STATUS: Check frame transmission status
;    Input:  A = 10
;    Output: A = 0: No frames were sent since last reset
;                1: Now transmitting
;                2: Transmission finished successfully
;                3: Carrier lost
;                4: Excessive collisions
;                6: Timeout
ETH_OUT_STATUS:
   ld a, 2
   ret

;--- ETH_SET_HWADD: Set hardware address
;    Input:  A  = 11
;            L-H-E-D-C-B = Ethernet address to set
;    Output: L-H-E-D-C-B = Current ethernet address
ETH_SET_HWADD:
   ; this version of the driver does not allow to change it
   ld hl,(TSR_MAC_ADDRESS)
   ld de,(TSR_MAC_ADDRESS+2)
   ld bc,(TSR_MAC_ADDRESS+4)
   ret

   include "unapi.asm"

UNAPI_ID DB "ETHERNET",0
ETHERNET_UNAPI_INFO: db "USB CDC ECM Ethernet driver by Sourceror",0
NETWORKING_ONOFF: DB 1 ; default ON
CUR_ETH_FILTERS: DB 00000110b ; broadcast + small frames
FRAME_IN_MEMORY: DB 0
FRAME_SIZE: DW 0

    STRUCT ECM_NOTIFICATION_EVENT
bmRequestType: DB 0
bNotificationCode: DB 0
wValue: DB 0
wIndex: DB 0
wLength: DB 0
    ENDS

ECM_NOTIFICATION_EVENT_BUFFER: ECM_NOTIFICATION_EVENT
ETH_INT_READ_TOGGLE: DB 0
ETH_DATA_READ_TOGGLE: DB 0
ETH_DATA_WRITE_TOGGLE: DB 0

TSR_END:
   DB 0

TSR_SHARED_VARS_START:
;
TSR_DEVICE_ADDRESS               DB 0
; CDC ECM identifiers
TSR_CONTROL_INTERFACE_ID:        DB 0
TSR_CONTROL_ENDPOINT_ID:         DB 0
TSR_DATA_INTERFACE_ID:           DB 0
TSR_DATA_INTERFACE_ALTERNATE:    DB 0
TSR_DATA_BULK_IN_ENDPOINT_ID:    DB 0
TSR_DATA_BULK_OUT_ENDPOINT_ID:   DB 0
TSR_ETHERNET_MAX_PACKET_SIZE:    DB 0
TSR_ETHERNET_CONFIG_ID:          DB 0
TSR_ETHERNET_MAX_SEGMENT_SIZE:   DW 0
TSR_MAC_ADDRESS                  DW 503eh,0aa7bh,601ah
; EXTBIO variables
TSR_OLD_EXTBIO:                  DS 5
TSR_MAPPER_SEGMENT:              DB 0
TSR_MAPPER_SLOT:                 DB 0
TSR_JUMP_TABLE_START:
TSR_FN_CHECK: DS 8
TSR_FN_CONNECT: DS 8
TSR_FN_GET_DESCRIPTORS: DS 8
TSR_FN_CONTROL_TRANSFER: DS 8
TSR_FN_DATA_IN_TRANSFER: DS 8
TSR_FN_DATA_OUT_TRANSFER: DS 8
TSR_FN_SYNC_MODE: DS 8
TSR_FN_CONTROL_PACKET: DS 8
TSR_SHARED_VARS_END:

; temp space to receive ethernet packet
;ETH_WORK_AREA:                   DS 1522
SCRATCH_AREA:                   EQU 0b800h
ETH_PACKET: EQU 08b7ah
