/* Define for CH372 & CH375 */
/* Website: http://winchiphead.com */
/* Email: tech@winchiphead.com */
/* Author: W.ch 2003.09 */
/* V2.0 for CH372A/CH375A */
 
# ifndef _CH375_H_
 
# define  _CH375_H_
 
/* ************************************************ ************************************************** ******************* */
/* Hardware Features */
# define  CH375_EP0_SIZE  0x08
# define  CH375_MAX_DATA_LEN  0x40  /* Maximum data packet length, internal buffer length */
 
/* ************************************************ ************************************************** ******************* */
/* Command code */
 
# define  CMD_RESET_ALL  0x05  /* Perform hardware reset */
 
# define  CMD_CHECK_EXIST  0x06  /* Test working status */
/* Input: arbitrary data */
/* Output: bit-wise inversion of input data */
 
# define  CMD_SET_USB_ID  0x12  /* Device mode: Set USB manufacturer VID and product PID */
/* Input: manufacturer ID low byte, manufacturer ID high byte, product ID low byte, product ID high byte */
 
# define  CMD_SET_USB_ADDR  0x13  /* Set USB address */
/* Input: address value */
 
# define  CMD_SET_USB_MODE  0x15  /* Set USB working mode */
/* Input: mode code */
/* 00H=Disabled device mode, 01H=enabled device mode and use external firmware mode, 02H=enabled device mode and use built-in firmware mode, 03H=enabled device mode and use interrupt endpoint and built-in firmware Mode */
/* 04H=Disabled host mode, 05H=Enabled host mode, 06H=Enabled host mode and automatically generate SOF packet, 07H=Enabled host mode and reset USB bus */
/* Output: Operation status (CMD_RET_SUCCESS or CMD_RET_ABORT, other values ​​indicate that the operation is not completed) */
 
# define  CMD_SET_ENDP2  0x18  /* Device mode: set the receiver of USB endpoint 0 */
/* Input: working method */
/* Bit 7 is 1, then bit 6 is the synchronous trigger bit, otherwise the synchronous trigger bit remains unchanged */
/* Bit 3~Bit 0 is the transaction response mode: 0000-ready ACK, 1110-busy NAK, 1111-error STALL */
 
# define  CMD_SET_ENDP3  0x19  /* Device mode: set the sender of USB endpoint 0 */
/* Input: working method */
/* Bit 7 is 1, then bit 6 is the synchronous trigger bit, otherwise the synchronous trigger bit remains unchanged */
/* Bit 3~Bit 0 are transaction response methods: 0000~1000-Ready ACK, 1110-Busy NAK, 1111-Error STALL */
 
# define  CMD_SET_ENDP4  0x1A  /* Device mode: set the receiver of USB endpoint 1 */
/* Input: working method */
/* Bit 7 is 1, then bit 6 is the synchronous trigger bit, otherwise the synchronous trigger bit remains unchanged */
/* Bit 3~Bit 0 is the transaction response mode: 0000-ready ACK, 1110-busy NAK, 1111-error STALL */
 
# define  CMD_SET_ENDP5  0x1B  /* Device mode: Set the sender of USB endpoint 1 */
/* Input: working method */
/* Bit 7 is 1, then bit 6 is the synchronous trigger bit, otherwise the synchronous trigger bit remains unchanged */
/* Bit 3~Bit 0 are transaction response methods: 0000~1000-Ready ACK, 1110-Busy NAK, 1111-Error STALL */
 
# define  CMD_SET_ENDP6  0x1C  /* Set the USB endpoint 2/receiver of the host endpoint */
/* Input: working method */
/* Bit 7 is 1, then bit 6 is the synchronous trigger bit, otherwise the synchronous trigger bit remains unchanged */
/* Bit 3~Bit 0 are transaction response methods: 0000-ready ACK, 1101-ready but no ACK, 1110-busy NAK, 1111-error STALL */
 
# define  CMD_SET_ENDP7  0x1D  /* Set USB endpoint 2/Sender of host endpoint */
/* Input: working method */
/* Bit 7 is 1, then bit 6 is the synchronous trigger bit, otherwise the synchronous trigger bit remains unchanged */
/* Bit 3~Bit 0 are transaction response methods: 0000-ready ACK, 1101-ready but no response, 1110-busy NAK, 1111-error STALL */
 
# define  CMD_GET_TOGGLE  0x0A  /* Get the synchronization status of OUT transaction */
/* Input: Data 1AH */
/* Output: synchronization status */
/* Bit 4 is 1, the OUT transaction is synchronized, otherwise the OUT transaction is not synchronized */
 
# define  CMD_GET_STATUS  0x22  /* Get interrupt status and cancel interrupt request */
/* Output: interrupt status */
 
# define  CMD_UNLOCK_USB  0x23  /* Device mode: release the current USB buffer */
 
# define  CMD_RD_USB_DATA  0x28  /* Read the data block from the endpoint buffer of the current USB interrupt, and release the buffer */
/* Output: length, data stream */
 
# define  CMD_WR_USB_DATA3  0x29  /* Device mode: write data block to the send buffer of USB endpoint 0 */
/* Input: length, data stream */
 
# define  CMD_WR_USB_DATA5  0x2A  /* Device mode: write data block to the send buffer of USB endpoint 1 */
/* Input: length, data stream */
 
# define  CMD_WR_USB_DATA7  0x2B  /* Write data block to the send buffer of USB endpoint 2 */
/* Input: length, data stream */
 
/* ************************************************ ************************** */
/*The following commands are used in USB host mode, only CH375 supports */
 
# define  CMD_SET_BAUDRATE  0x02  /* Serial port mode: Set the serial port communication baud rate */
/* Input: baud rate division coefficient, baud rate division constant */
/* Output: Operation status (CMD_RET_SUCCESS or CMD_RET_ABORT, other values ​​indicate that the operation is not completed) */
 
# define  CMD_ABORT_NAK  0x17  /* Host mode: give up the current NAK retry */
 
# define  CMD_SET_RETRY  0x0B  /* Host mode: Set the number of retries for USB transaction operations */
/* Input: data 25H, number of retries */
/* Bit 7 is 1 means unlimited retries when receiving NAK, Bit 3~Bit 0 are the number of retries after timeout */
 
# define  CMD_ISSUE_TOKEN  0x4F  /* Host mode: issue token, execute transaction */
/* Input: transaction attributes */
/*The lower 4 bits are the token, and the upper 4 bits are the endpoint number */
/* Output interruption */
 
# define  CMD_CLR_STALL  0x41  /* Host mode: control transmission-clear endpoint error */
/* Input: endpoint number */
/* Output interruption */
 
# define  CMD_SET_ADDRESS  0x45  /* Host mode: control transmission-set USB address */
/* Input: address value */
/* Output interruption */
 
# define  CMD_GET_DESCR  0x46  /* Host mode: control transmission-get descriptor */
/* Input: Descriptor type */
/* Output interruption */
 
# define  CMD_SET_CONFIG  0x49  /* Host mode: control transmission-set USB configuration */
/* Input: configuration value */
/* Output interruption */
 
# define  CMD_DISK_INIT  0x51  /* Host mode: Initialize USB storage */
/* Output interruption */
 
# define  CMD_DISK_RESET  0x52  /* Host mode: reset USB storage */
/* Output interruption */
 
# define  CMD_DISK_SIZE  0x53  /* Host mode: Get the capacity of USB storage */
/* Output interruption */
 
# define  CMD_DISK_READ  0x54  /* Host mode: read data block from USB memory (in units of sector 512 bytes) */
/* Input: LBA sector address (total length 32 bits, low byte first), number of sectors (01H~FFH) */
/* Output interruption */
 
# define  CMD_DISK_RD_GO  0x55  /* Host mode: continue to perform USB memory read operation */
/* Output interruption */
 
# define  CMD_DISK_WRITE  0x56  /* Host mode: write data block to USB memory (in units of sector 512 bytes) */
/* Input: LBA sector address (total length 32 bits, low byte first), number of sectors (01H~FFH) */
/* Output interruption */
 
# define  CMD_DISK_WR_GO  0x57  /* Host mode: continue to execute USB memory write operation */
/* Output interruption */
 
/* ************************************************ ************************** */
/*The following new V2.0 command codes are only supported by CH372A/CH375A */
 
# define  CMD_GET_IC_VER  0x01  /* Get chip and firmware version */
/* Output: version number (bit 7 is 1, bit 6 is 0, bit 5~bit 0 is the version number) */
/* CH375 returns an invalid value of 5FH, and CH375A returns a version number of 0A2H */
 
# define  CMD_ENTER_SLEEP  0x03  /* Go to sleep */
 
# define  CMD_RD_USB_DATA0  0x27  /* Read the data block from the endpoint buffer of the current USB interrupt */
/* Output: length, data stream */
 
# define  CMD_DELAY_100US  0x0F  /* Parallel mode: delay 100uS */
/* Output: output 0 during the delay, and output non-zero when the delay ends */
 
# define  CMD_CHK_SUSPEND  0x0B  /* Device mode: Set the mode to check the USB bus suspension state */
/* Input: data 10H, check method */
/* 00H=Do not check USB suspend, 04H=Check USB suspend every 50mS, 05H=Check USB suspend every 10mS */
 
# define  CMD_SET_SYS_FREQ  0x04  /* Set system operating frequency */
/* Input: frequency */
/* 00H=12MHz, 01H=1.5MHz */
 
/* ************************************************ ************************** */
/*The following improved V2.0 command codes are used in USB host mode, only CH375A supports */
 
/* #define CMD_SET_RETRY 0x0B */  /* Host mode: Set the number of retries for USB transaction operations */
/* Input: data 25H, number of retries */
/* Bit 7 is 0, no retry when receiving NAK, bit 7 is 1 bit 6 is 0, unlimited retry when receiving NAK, bit 7 is 1 bit 6 is 1, retry 200mS when receiving NAK, bit 5~bit 0 is the number of retries after timeout */
 
/* ************************************************ ************************** */
/*The following new V2.0 command codes are used for USB host mode, only CH375A supports */
 
# define  CMD_TEST_CONNECT  0x16  /* Host mode: check USB device connection status */
/* Output: Status (USB_INT_CONNECT or USB_INT_DISCONNECT, other values ​​indicate that the operation is not completed) */
 
# define  CMD_AUTO_SETUP  0x4D  /* Host mode: automatically configure USB device */
/* Output interruption */
 
# define  CMD_ISSUE_TKN_X  0x4E  /* Host mode: issue synchronization token, execute transaction */
/* Input: synchronization flag, transaction attribute */
/* Bit 7 of the synchronization flag is the synchronization trigger bit of the host endpoint IN, bit 6 is the synchronization trigger bit of the host endpoint OUT, bit 5~bit 0 must be 0 */
/* The lower 4 bits of the transaction attribute are the token, and the upper 4 bits are the endpoint number */
/* Output interruption */
 
# define  CMD_SET_DISK_LUN  0x0B  /* Host mode: Set the current logical unit number of the USB storage */
/* Input: data 34H, new current logical unit number (00H-0FH) */
 
# define  CMD_DISK_BOC_CMD  0x50  /* Host mode: execute BulkOnly transmission protocol commands on USB storage */
/* Output interruption */
 
# define  CMD_DISK_INQUIRY  0x58  /* Host mode: Query USB storage characteristics */
/* Output interruption */
 
# define  CMD_DISK_READY  0x59  /* Host mode: Check USB storage is ready */
/* Output interruption */
 
# define  CMD_DISK_R_SENSE  0x5A  /* Host mode: check USB storage error */
/* Output interruption */
 
# define  CMD_DISK_MAX_LUN  0x5D  /* Host mode: Get the maximum logical unit number of USB storage */
/* Output interruption */
 
/* ************************************************ ************************************************** ******************* */
/* Operation status */
 
# define  CMD_RET_SUCCESS  0x51  /* Command operation succeeded */
# define  CMD_RET_ABORT  0x5F  /* Command operation failed */
 
/* ************************************************ ************************************************** ******************* */
/* USB interrupt status */
 
/*The following status codes are special event interrupts, which are only supported by CH372A/CH375A. If the USB bus suspension check is enabled through CMD_CHK_SUSPEND, then the interrupt status of USB bus suspension and sleep wakeup must be handled */
# define  USB_INT_USB_SUSPEND  0x05  /* USB bus suspend event */
# define  USB_INT_WAKE_UP  0x06  /* Wake up event from sleep */
 
/*The following status code 0XH is used for USB device mode */
/*In the built-in firmware mode, only need to process: USB_INT_EP1_IN, USB_INT_EP2_OUT, USB_INT_EP2_IN, for CH372A/CH375A also need to process: USB_INT_EP1_OUT */
/* Bit 7-Bit 4 is 0000 */
/* Bit 3-Bit 2 indicates the current transaction, 00=OUT, 10=IN, 11=SETUP */
/* Bit 1-Bit 0 indicates the current endpoint, 00=Endpoint 0, 01=Endpoint 1, 10=Endpoint 2, 11=USB bus reset */
# define  USB_INT_EP0_SETUP  0x0C  /* SETUP of USB endpoint 0 */
# define  USB_INT_EP0_OUT  0x00  /* OUT of USB endpoint 0 */
# define  USB_INT_EP0_IN  0x08  /* IN of USB endpoint 0 */
# define  USB_INT_EP1_OUT  0x01  /* OUT of USB endpoint 1 */
# define  USB_INT_EP1_IN  0x09  /* IN of USB endpoint 1 */
# define  USB_INT_EP2_OUT  0x02  /* OUT of USB endpoint 2 */
# define  USB_INT_EP2_IN  0x0A  /* IN of USB endpoint 2 */
/* USB_INT_BUS_RESET 0x0000XX11B */  /* USB bus reset */
# define  USB_INT_BUS_RESET1  0x03  /* USB bus reset */
# define  USB_INT_BUS_RESET2  0x07  /* USB bus reset */
# define  USB_INT_BUS_RESET3  0x0B  /* USB bus reset */
# define  USB_INT_BUS_RESET4  0x0F  /* USB bus reset */
 
/*The following status codes 2XH-3XH are used for USB host communication failure codes, only CH375/CH375A support */
/* Bit 7-Bit 6 is 00 */
/* Bit 5 is 1 */
/* Bit 4 indicates whether the currently received data packet is synchronized */
/* Bit 3-Bit 0 indicates the response of the USB device when the communication fails: 0010=ACK, 1010=NAK, 1110=STALL, 0011=DATA0, 1011=DATA1, XX00=timeout */
/* USB_INT_RET_ACK 0x001X0010B */  /* Error: return ACK for IN transaction */
/* USB_INT_RET_NAK 0x001X1010B */  /* Error: return NAK */
/* USB_INT_RET_STALL 0x001X1110B */  /* error: return STALL */
/* USB_INT_RET_DATA0 0x001X0011B */  /* Error: return DATA0 for OUT/SETUP transaction */
/* USB_INT_RET_DATA1 0x001X1011B */  /* Error: return DATA1 for OUT/SETUP transaction */
/* USB_INT_RET_TOUT 0x001XXX00B */  /* Error: return timeout */
/* USB_INT_RET_TOGX 0x0010X011B */  /* Error: The returned data for IN transactions is out of sync */
/* USB_INT_RET_PID 0x001XXXXXB */  /* Error: undefined */
 
/*The following status code 1XH is used for the operation status code of USB host mode, only CH375/CH375A support */
 
# define  USB_INT_SUCCESS  0x14  /* USB transaction or transfer operation succeeded */
# define  USB_INT_CONNECT  0x15  /* USB device connection event detected */
# define  USB_INT_DISCONNECT  0x16  /* USB device disconnect event detected */
# define  USB_INT_BUF_OVER  0x17  /* USB control transfers too much data, buffer overflow */
# define  USB_INT_DISK_READ  0x1D  /* USB memory read data block, request data read */
# define  USB_INT_DISK_WRITE  0x1E  /* USB memory write data block, request data write */
# define  USB_INT_DISK_ERR  0x1F  /* USB storage operation failed */
 
/* ************************************************ ************************************************** ******************* */
/* Common USB definition */
 
/* USB package identification PID, the host method may be used */
# define  DEF_USB_PID_NULL  0x00  /* PID is reserved, undefined */
# define  DEF_USB_PID_SOF  0x05
# define  DEF_USB_PID_SETUP  0x0D
# define  DEF_USB_PID_IN  0x09
# define  DEF_USB_PID_OUT  0x01
# define  DEF_USB_PID_ACK  0x02
# define  DEF_USB_PID_NAK  0x0A
# define  DEF_USB_PID_STALL  0x0E
# define  DEF_USB_PID_DATA0  0x03
# define  DEF_USB_PID_DATA1  0x0B
# define  DEF_USB_PID_PRE  0x0C
 
/* USB request type, external firmware mode may be used */
# define  DEF_USB_REQ_READ  0x80  /* Control read operation */
# define  DEF_USB_REQ_WRITE  0x00  /* Control write operation */
# define  DEF_USB_REQ_TYPE  0x60  /* Control request type */
# define  DEF_USB_REQ_STAND  0x00  /* Standard request */
# define  DEF_USB_REQ_CLASS  0x20  /* Device class request */
# define  DEF_USB_REQ_VENDOR  0x40  /* Vendor request */
# define  DEF_USB_REQ_RESERVE  0x60  /* Reservation request */
 
/* USB standard device request, bit 6 of RequestType 5=00 (Standard), external firmware mode may be used */
# define  DEF_USB_CLR_FEATURE  0x01
# define  DEF_USB_SET_FEATURE  0x03
# define  DEF_USB_GET_STATUS  0x00
# define  DEF_USB_SET_ADDRESS  0x05
# define  DEF_USB_GET_DESCR  0x06
# define  DEF_USB_SET_DESCR  0x07
# define  DEF_USB_GET_CONFIG  0x08
# define  DEF_USB_SET_CONFIG  0x09
# define  DEF_USB_GET_INTERF  0x0A
# define  DEF_USB_SET_INTERF  0x0B
# define  DEF_USB_SYNC_FRAME  0x0C
 
/* ************************************************ ************************************************** ******************* */
 
 
# endif