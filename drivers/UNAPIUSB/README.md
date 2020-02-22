# USB - UNAPI DRIVER
Below the specification of an UNAPI compliant USB driver. Other, more specialised, drivers can rely on this base driver to return the basic information and low-level routines.

## API Information Routine (UNAPI:0)
```
Input: A = 0

Output:
* HL = Address of the implementation name string
* DE = API specification version supported. D=primary, E=secondary.
* BC = API implementation version. B=primary, C=secondary.
```

## JumpTable (UNAPI:1)
This function will return the jumptable to the USB functions to be directly called. 
Every jumptable entry of 8 bytes has the following proposed format. 
Although this can be changed by the UNAPI driver if necessary.
```
Input: A = 1
       HL = pointer to buffer to receive the jumptable
```
UNAPI in ROM:
```
00: RST 30h
01: DB SlotID
02: DW Address
04: RET
05: NOP
06: NOP
07: NOP
```
UNAPI in MemoryMapper:
```
00: CALL CALLS
03: DB Segment
04: DW Address
06: RET
07: NOP
```
Or in PAGE 3:
```
00: JP Address
03: NOP
04: NOP
05: NOP
06: NOP
07: NOP
```
### The functions returned are:
To call a function just do a call to one of the addresses in the jumptable.
Drivers are specifically written to be in ROM, Mapped Ram or Page 3. 
By using this jump table approach, the burden for handling all the specific cases is shifted back from the client to the driver itself. 
This is contrary to the initial UNAPI approach where slot, segment, address is returned by the EXTBIO call, and it is expected by the client to adapt to this.
```
HL+0000: Check
HL+0008: Connect
HL+0010: GetDescriptors
HL+0018: ExecuteControlTransfer
HL+0020: DataInTransfer
HL+0028: DataOutTransfer
HL+0030: ScratchArea
```
## Check (UNAPI:2/JT:00h)
Check if specialised USB hardware is present, like RookieDrive or MSXUSB cartridge.
```
Input:  A = 2
Output: Cy = 0, everything okay, Cy = 1, adapter not ready
```

## Connect (UNAPI:3/JT:08h)
Connect the inserted USB device, reset it properly and prepare for communication.
```
Input:  A = 3
Output: Cy = 0, everything okay, Cy = 1, device not connected
```

## GetDescriptors (UNAPI:4/JT:10h)
Return both the fixed length DEVICE_DESCRIPTOR followed by the variable length CONFIGURATION_DESCRIPTOR containing INTERFACE_DESCRIPTORS, ENDPOINT_DESCRIPTORS and specialised descriptors for HID, CDC ECM, etc.
```
Input: A = 4
       HL = buffer to hold the descriptor information
```

## ExecuteControlTransfer (JT:18h)
Perform a USB control transfer on endpoint 0. The size and direction of the transfer are taken from the contents of the setup packet.
```
Input:  HL = Address of a 8 byte buffer with the setup packet
        DE = Address of the input or output data buffer
        A  = Device address
        B  = Maximum packet size for endpoint 0
Output: A  = USB error code
        BC = Amount of data actually transferred (if IN transfer and no error)
```
## DataInTransfer (JT:20h)
Perform a USB data IN transfer.
```
Input:  HL = Address of a buffer for the received data
        BC = Data length
        A  = Device address
        D  = Maximum packet size for the endpoint
        E  = Endpoint number
        Cy = Current state of the toggle bit
Output: A  = USB error code
        BC = Amount of data actually received (only if no error)
        Cy = New state of the toggle bit (even on error)
```
## DataOutTransfer (JT:28h)
Perform a USB data OUT transfer.
```
Input:  HL = Address of a buffer for the data to be sent
        BC = Data length
        A  = Device address
        D  = Maximum packet size for the endpoint
        E  = Endpoint number
        Cy = Current state of the toggle bit
Output: A  = USB error code
        Cy = New state of the toggle bit (even on error)
```
## ScratchArea (JT:30h)
Get a pointer to the scratch area allocated by moving HIMEM down. Scratch area is used to store USB command packages and a bit of reserved space.
```
Input:  BC = delta in bytes should >0 and < size of scratch area (8*8 bytes currently)
Output: HL = pointer to scratch area in page 3
```
