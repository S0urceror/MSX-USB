;***********************************
;***   FUNCTIONS INDEXES TABLE   ***
;***********************************

; Mandatory routine 0: return API information.
; -----------------------------------------------------------------------------
; Input:  A  = 0
; Output: HL = Descriptive string for this implementation, on this slot, zero terminated
;         DE = API version supported, D.E
;         BC = This implementation version, B.C.
;         A  = 0 and Cy = 0
USB_INFO equ 0

; Check if the USB host controller hardware is operational.
; -----------------------------------------------------------------------------
; Output: Cy = 0 if hardware is operational, 1 if it's not
USB_CHECK equ 1

; Connect attached USB device and reset it.
; -----------------------------------------------------------------------------
; Input: (none)
; Output: A = nr of connected USB devices, zero if none or error
USB_CONNECT equ 2

; Get both the DEVICE and full CONFIG descriptors and return it
; -----------------------------------------------------------------------------
; Input:  D = device address
;         HL = pointer to buffer
; Output: Cy = 0, everything okay, Cy = 1, not connected
USB_GETDESCRIPTORS equ 3

; Perform a USB control transfer on endpoint 0.
; The size and direction of the transfer are taken from the contents
; of the setup packet.
; -----------------------------------------------------------------------------
; Input:  HL = Address of a 8 byte buffer with the setup packet
;         DE = Address of the input or output data buffer
;         B  = Maximum packet size for endpoint 0
;         C  = Device address
; Output: A  = USB error code
;         BC = Amount of data actually transferred (if IN transfer and no error)
USB_CONTROL_TRANSFER equ 4

; Perform a USB data IN transfer
; -----------------------------------------------------------------------------
; Input:  HL = Address of a buffer for the received data
;         BC = Data length
;         D  = Maximum packet size for the endpoint
;         E  = DDDDEEEE (D=device address, E=endpoint id)
;         Cy = Current state of the toggle bit
; Output: A  = USB error code
;         BC = Amount of data actually received (only if no error)
;         Cy = New state of the toggle bit (even on error)
USB_DATA_IN_TRANSFER equ 5

; Perform a USB data OUT transfer
; -----------------------------------------------------------------------------
; Input:  HL = Address of a buffer for the data to be sent
;         BC = Data length
;         D  = Maximum packet size for the endpoint
;         E  = DDDDEEEE (D=device address, E=endpoint id)
;         Cy = Current state of the toggle bit
; Output: A contains 00h when okay or CH376 error code
;         Cy = New state of the toggle bit (even on error)
USB_DATA_OUT_TRANSFER equ 6

; Set synchronous/asynchronous mode
; Default after reset and first USB_CONNECT is 8Fh
; -----------------------------------------------------------------------------
; Input: B = sync mode
;        Bits 7 and 6:
;          0x: Don't retry NAKs
;          10: Retry NAKs indefinitely (default)
;          11: Retry NAKs for 3s
;        Bits 5-0: Number of retries after device timeout
USB_SYNC_MODE equ 7

; Return USB descriptors stored in page 3 RAM to enable modification
; -----------------------------------------------------------------------------
; Input:  BC - offset within descriptor table
; Output: HL - location of USB descriptors in RAM
USB_CONTROL_PACKET equ 8

; Return the configured jumptable in WRKAREA
; -----------------------------------------------------------------------------
; Input: (none)
; Output: HL
;
; Example jumptable
; call NXT_DIRECT ; 3 bytes - call to switching code
; DB 1            ; 1 byte  - ROM slot number
; DB 7            ; 1 byte  - ROM segment
; DW FN_CHECK     ; 2 bytes - address to call
; ret             ; 1 byte
;                 ; =============
;                 ; 8 bytes total per entry
USB_JUMPTABLE equ 9