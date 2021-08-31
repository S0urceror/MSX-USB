#include < stdio.h >
#include < string.h >
#include < intrins.h >
#include " types.h "
#include " reg80390.h "
#include "ch375_inc.h"       // CH375 header file
#include "descriptor_COM.h" // Descriptor
#include " delay.h "
#include " main.h "

// #define USB_DEBUG

#ifdef USB_DEBUG
#include " uart.h "
#endif

mREQUEST_PACKET request;
mUART_PARA uartpara;

bit CH375FLAGERR;           // error flag
bit CH375CONFLAG;           //Is the device configured flag
bit ENDP2_NEED_UP_FLAG = 0; // Endpoint 2 has data to upload flag
bit ENDP2_UP_SUC_FLAG = 1;  // Endpoint 2 this time data upload success flag
bit SET_LINE_CODING_Flag;   // Class request SET_LINE_CODING flag

U8_T VarUsbAddress;    // Device address
U8_T mVarSetupRequest; // USB request code
U16_T mVarSetupLength; // Length of subsequent data
U8_T *VarSetupDescr;   // Descriptor offset address

/* Hardware related definitions */
volatile U8_T far CH375_CMD_PORT _at_ 0x180001; // I/O address of CH375 command port
volatile U8_T far CH375_DAT_PORT _at_ 0x180000; // I/O address of CH375 data port
sbit CH375_INT_WIRE = P2 ^ 7;                   // P2.7, INT0, connected to the INT# pin of CH375, used to query the interrupt status, REV20
// sbit CH375_INT_WIRE = P2^4; // REV23

#define USB_TIMEOUT 5

U8_T far DownBuf[300];
U8_T far UpBuf[300];
U8_T far USB_timeout = USB_TIMEOUT;
U16_T far DownCtr = 0;
U16_T far UpCtr = 0;

#ifdef USB_DEBUG
// for debug
U8_T ascii[16] = {' 0 ', ' 1 ', ' 2 ', ' 3 ', ' 4 ', ' 5 ', ' 6 ', ' 7 ', ' 8 ', ' 9 ', ' A ', ' B ', ' C ', 'D ', ' E ', ' F '};
void usb_debug_print_hex(U8_T *dat, U8_T length)
{
    U8_T p[100];
    U8_T i;
    U8_T ctr = 0;

    for (i = 0; i < length; i++)
    {
        p[ctr++] = ascii[dat[i] >> 4];
        p[ctr++] = ascii[dat[i] & 0x0f];
        p[ctr++] = '  ';
    }

    p[ctr++] = ' \n ';
    p[ctr++] = ' \r ';

    Uart0_Tx(p, ctr);
}
#endif

/* Delay 1us */
static void Delay1us(void)
{
    _nop_();
    _nop_();
    _nop_();
    _nop_();
    _nop_();
    _nop_();
    _nop_();
    _nop_();
    _nop_();
    _nop_();
    _nop_();
    _nop_();
    _nop_();
    _nop_();
    _nop_();
    _nop_();
    _nop_();
    _nop_();
    _nop_();
    _nop_();
    _nop_();
    _nop_();
    _nop_();
    _nop_();
    _nop_(); /* 25MHz crystal oscillator, 25 instructions are closer to 1us */

    // _nop_(); _nop_(); _nop_(); _nop_(); _nop_(); /* slightly more than 1us */
    // _nop_(); _nop_(); _nop_(); _nop_(); _nop_();
    //
    // _nop_(); _nop_(); _nop_(); _nop_(); _nop_(); /* slightly more than 1us */
    // _nop_(); _nop_(); _nop_(); _nop_(); _nop_();
    //
    // _nop_(); _nop_(); _nop_(); _nop_(); _nop_(); /* slightly more than 1us */
    // _nop_(); _nop_(); _nop_(); _nop_(); _nop_();
}

/* Delay 2us */
static void Delay10us(void)
{
    Delay1us();
    Delay1us();
    Delay1us();
    Delay1us();
    Delay1us();
    Delay1us();
    Delay1us();
    Delay1us();
    Delay1us();
    Delay1us();
}

static void Delay5ms(void)
{
    U16_T i;
    for (i = 0; i < 5000; i++)
    {
        Delay1us();
    }
}

/* Delay 50ms, inaccurate */
static void Delay50ms(void)
{
    U8_T i, j;
    for (i = 0; i < 200; i++)
        for (j = 0; j < 250; j++)
            Delay1us();
}

/* CH375 write command port */
void CH375_WR_CMD_PORT(U8_T cmd) // Write command to the command port of CH375, the period is not less than 4uS
{
    Delay10us();
    CH375_CMD_PORT = cmd;
    Delay10us();
    Delay10us();
}

/* CH375 write data port */
void CH375_WR_DAT_PORT(U8_T dat)
{
    Delay10us();
    CH375_DAT_PORT = dat;
    Delay10us();
    Delay10us();
}

/* CH375 read data port */
U8_T CH375_RD_DAT_PORT(void)
{
    U8_T ret;
    Delay10us();
    ret = CH375_DAT_PORT;
    return ret;
}

void init_virtual_com(void)
{
    // uartpara.uart.bBaudRate1 = 0x80; // baudrate = 0X00002580, which is 9600 (default)
    // uartpara.uart.bBaudRate2 = 0x25;
    // uartpara.uart.bBaudRate3 = 0x00;
    // uartpara.uart.bBaudRate4 = 0x00;
    .uartpara UART.bBaudRate1 = 0x00; // baudrate = 0X00004B00, i.e. 19200
    uartpara.uart.bBaudRate2 = 0x4B;
    uartpara.uart.bBaudRate3 = 0x00;
    uartpara.uart.bBaudRate4 = 0x00;
    uartpara.uart.bStopBit = 0x00;   // Stop bit: 1
    uartpara.uart.bParityBit = 0x00; // Parity bit: None
    uartpara.uart.bDataBits = 0x08;  // Data bits: 8
}

U8_T usb_poll(void)
{
    if (CH375_INT_WIRE == 0)
        return TRUE;
    else
        return FALSE;
}

void USB_disable(void)
{
    CH375_WR_CMD_PORT(CMD_SET_USB_MODE); // Set USB working mode, necessary operation
    CH375_WR_DAT_PORT(0);                // Set to the disabled USB device mode
#ifdef USB_DEBUG
    Uart0_Tx(" Disable USB \n\r ", 13);
#endif
}

void USB_enable(void)
{
    CH375_WR_CMD_PORT(CMD_SET_USB_MODE); // Set USB working mode, necessary operation
    CH375_WR_DAT_PORT(1);                // Set to USB device mode using external firmware
}

/* CH375 initialization subroutine */
U8_T CH375_Init(void)
{
    U8_T ret = FALSE;
    U8_T i = 0;

    while (1)
    {
        CH375_WR_CMD_PORT(CMD_CHECK_EXIST);
        CH375_WR_DAT_PORT(0x55);

        Delay50ms();

        if ((i = CH375_RD_DAT_PORT()) != 0xaa)
        {
#ifdef USB_DEBUG
            Uart0_Tx(" CH375 inexistence: ", 19);
            usb_debug_print_hex(&i, 1);
#endif
            // return ret;
            OSDelay(10);
        }
        else
        {
            break;
        }
    }

#ifdef USB_DEBUG
    Uart0_Tx(" CH375 exist \n\r ", 13);
#endif

    init_virtual_com();

    USB_enable();
    for (i = 0; i < 20; i++) // Waiting for the operation to succeed, usually need to wait for 10uS-20uS
    {
        if (CH375_RD_DAT_PORT() == CMD_RET_SUCCESS)
        {
#ifdef USB_DEBUG
            Uart0_Tx(" USB enabled \n\r ", 13);
#endif
            ret = TRUE;
            break;
        }
    }

    return ret;
}

/* Endpoint 0 data upload */
void mCh375Ep0Up(void)
{
    U8_T i, len;
    if (mVarSetupLength) //The length is not 0 to transmit data of specific length
    {
        if (mVarSetupLength <= CH375_EP0_SIZE) // Length is less than 8, the length required for long transmission, the maximum data packet of endpoint 0 is 8 bytes
        {
            len = mVarSetupLength;
            mVarSetupLength = 0;
        }
        else //The length is greater than 8, then 8 will be transmitted, and the total length will be reduced by 8
        {
            len = CH375_EP0_SIZE;
            mVarSetupLength -= CH375_EP0_SIZE;
        }

        CH375_WR_CMD_PORT(CMD_WR_USB_DATA3); // issue a command to write endpoint 0
        CH375_WR_DAT_PORT(len);              // write length
        for (i = 0; i < len; i++)
            CH375_WR_DAT_PORT(request.buffer[i]); // Write data cyclically

#ifdef USB_DEBUG
        usb_debug_print_hex(&request.buffer[0], len);
#endif

        Delay5ms();
    }
    else
    {
        CH375_WR_CMD_PORT(CMD_WR_USB_DATA3); // issue a command to write endpoint 0
        CH375_WR_DAT_PORT(0);                // Upload 0 length data, this is a status stage

#ifdef USB_DEBUG
        Uart0_Tx(" ZLP \ n-\ R & lt ", .5);
#endif
        Delay5ms();
    }
}

/* Copy the descriptor for upload */
void mCh375DesUp(void)
{
    U8_T k;
    for (k = 0; k < CH375_EP0_SIZE; k++)
    {
        request.buffer[k] = *VarSetupDescr; // Copy 8 descriptors in turn
        VarSetupDescr++;
    }
}

/* CH375 interrupt service program, use query mode */
void mCH375Interrupt(void)
{
    U8_T InterruptStatus;
    U8_T length, c1, len;

    CH375_WR_CMD_PORT(CMD_GET_STATUS);     // Get interrupt status and cancel interrupt request
    InterruptStatus = CH375_RD_DAT_PORT(); // Get interrupt status

    switch (InterruptStatus) // Analyze interrupt source
    {
    case USB_INT_EP2_OUT: //The batch endpoint download is successful
#ifdef USB_DEBUG
        Uart0_Tx(" EP2_OUT: ", 9);
#endif
        CH375_WR_CMD_PORT(CMD_RD_USB_DATA); // Issue read data command
        if (length = CH375_RD_DAT_PORT())   //The first thing to read is the length
        {
            for (len = 0; len < length; len++)
            {
                DownBuf[DownCtr++] = CH375_RD_DAT_PORT();
            }
#ifdef USB_DEBUG
            usb_debug_print_hex(DownBuf + DownCtr - length, length);
#endif
            USB_timeout = USB_TIMEOUT;
        }
        break;
    case USB_INT_EP2_IN: //The bulk endpoint upload was successful and not processed
#ifdef USB_DEBUG
        Uart0_Tx(" EP2_IN \n\r ", 8);
#endif
        ENDP2_UP_SUC_FLAG = 1;             // Set this upload success flag
        CH375_WR_CMD_PORT(CMD_UNLOCK_USB); // Release buffer
        break;
    case USB_INT_EP1_IN: // Interrupt endpoint upload is successful, not processed
#ifdef USB_DEBUG
        Uart0_Tx(" EP1_IN \n\r ", 8);
#endif
        CH375_WR_CMD_PORT(CMD_UNLOCK_USB); // Release buffer
        break;
    case USB_INT_EP1_OUT: //The interrupt endpoint is downloaded successfully, but not processed
#ifdef USB_DEBUG
        Uart0_Tx(" EP1_OUT \n\r ", 9);
#endif
        CH375_WR_CMD_PORT(CMD_RD_USB_DATA); // Issue read data command
        if (length = CH375_RD_DAT_PORT())   //The first thing to read is the length
        {
            for (len = 0; len < length; len++)
                CH375_RD_DAT_PORT();
        }
        break;
    case USB_INT_EP0_SETUP:                 //The control endpoint is successfully established
        CH375_WR_CMD_PORT(CMD_RD_USB_DATA); // Read data buffer
        length = CH375_RD_DAT_PORT();       // Get data length
        for (len = 0; len < length; len++)
        {
            request.buffer[len] = CH375_RD_DAT_PORT(); // Retrieve the data packet of output endpoint 0
        }

#ifdef USB_DEBUG
        Uart0_Tx(" USB_SETUP->Request: ", 20);
        usb_debug_print_hex(&request.buffer[0], length);
#endif

        if (length == 0x08) // request
        {
            mVarSetupLength = (request.buffer[7] << 8) | request.buffer[6]; // Control the data length of the transmission request

            if ((c1 = request.r.bmReuestType) & 0x40) // Vendor request, not processed
            {
                // NO DEAL..............
#ifdef USB_DEBUG
                Uart0_Tx(" ->Vendor request \n\r ", 18);
#endif
            }

            if ((c1 = request.r.bmReuestType) & 0x20) // Class request, proceed accordingly
            {
#ifdef USB_DEBUG
                Uart0_Tx(" ->Class request \n\r ", 17);
#endif
                mVarSetupRequest = request.r.bRequest; // Temporary storage type request code
                switch (mVarSetupRequest)              // Analyze the class request code and process it
                {
                case SET_LINE_CODING: // SET_LINE_CODING
#ifdef USB_DEBUG
                    Uart0_Tx(" [COM] SET_LINE_CODING \n\r ", 23);
#endif
                    SET_LINE_CODING_Flag = 1; // Set the SET_LINE_CODING command flag
                    mVarSetupLength = 0;
                    break;
                case GET_LINE_CODING: // GET_LINE_CODING
#ifdef USB_DEBUG
                    Uart0_Tx(" [COM] GET_LINE_CODING \n\r ", 23);
#endif
                    for (c1 = 0; c1 < 7; c1++)
                    {
                        request.buffer[c1] = uartpara.uart_para_buf[c1];
                    }
                    mVarSetupLength = 7;
                    break;
                case SET_CONTROL_LINE_STATE: // SET_CONTROL_LINE_STATE
#ifdef USB_DEBUG
                    Uart0_Tx(" [COM] SET_CONTROL_LINE_STATE \n\r ", 30);
#endif
                    mVarSetupLength = 0;
                    break;
                default:
                    CH375FLAGERR = 1; // Unsupported class command code
                    break;
                }
            }
            else if (!((c1 = request.r.bmReuestType) & 0x60)) // Standard request, proceed accordingly
            {
#ifdef USB_DEBUG
                Uart0_Tx(" ->Standard request ", 18);
#endif

                mVarSetupRequest = request.r.bRequest; // temporarily store standard request code
                switch (request.r.bRequest)            // Analyze standard requests
                {
                case DEF_USB_CLR_FEATURE: // Clear feature
#ifdef USB_DEBUG
                    Uart0_Tx(" ->Clear feature \n\r ", 17);
#endif
                    if ((c1 = request.r.bmReuestType & 0x1F) == 0X02) //It is not that the endpoint does not support
                    {
                        switch (request.buffer[4]) // wIndex
                        {
                        case 0x82:
                            CH375_WR_CMD_PORT(CMD_SET_ENDP7); // Clear endpoint 2 upload
                            CH375_WR_DAT_PORT(0x8E);          // Send a command to clear the endpoint
                            break;
                        case 0x02:
                            CH375_WR_CMD_PORT(CMD_SET_ENDP6);
                            CH375_WR_DAT_PORT(0x80); // Clear endpoint 2 download
                            break;
                        case 0x81:
                            CH375_WR_CMD_PORT(CMD_SET_ENDP5); // Clear endpoint 1 upload
                            CH375_WR_DAT_PORT(0x8E);
                            break;
                        case 0x01:
                            CH375_WR_CMD_PORT(CMD_SET_ENDP4); // Clear endpoint 1 download
                            CH375_WR_DAT_PORT(0x80);
                            break;
                        default:
                            break;
                        }
                    }
                    else
                    {
                        CH375FLAGERR = 1; // Unsupported clearing feature, set error flag
                    }
                    break;
                case DEF_USB_GET_STATUS: // Get status
#ifdef USB_DEBUG
                    Uart0_Tx(" ->Get status \n\r ", 14);
#endif
                    request.buffer[0] = 0; // Upload the status of two bytes
                    request.buffer[1] = 0;
                    mVarSetupLength = 2;
                    break;
                case DEF_USB_SET_ADDRESS: // Set the address
#ifdef USB_DEBUG
                    Uart0_Tx(" ->Set address \n\r ", 15);
#endif
                    VarUsbAddress = request.buffer[2]; // temporarily store the address sent by the USB host
                    break;
                case DEF_USB_GET_DESCR: // Get the descriptor
#ifdef USB_DEBUG
                    Uart0_Tx(" ->Get descriptor ", 16);
#endif
                    if (request.buffer[3] == 1) // Upload device descriptor
                    {
#ifdef USB_DEBUG
                        Uart0_Tx(" ->device \n\r ", 10);
#endif
                        VarSetupDescr = DevDes;
                        if (mVarSetupLength > DevDes[0])
                            mVarSetupLength = DevDes[0]; // If the required length is greater than the actual length, take the actual length
                    }
                    else if (request.buffer[3] == 2) // upload configuration descriptor
                    {
#ifdef USB_DEBUG
                        Uart0_Tx(" ->config \n\r ", 10);
#endif
                        VarSetupDescr = ConDes;
                        if (mVarSetupLength >= 0x43)
                            mVarSetupLength = 0x43; // If the required length is greater than the actual length, take the actual length
                    }
                    else if (request.buffer[3] == 3) // Get the string descriptor
                    {
#ifdef USB_DEBUG
                        Uart0_Tx(" ->string ", 8);
#endif
                        switch (request.buffer[2])
                        {
                        case 0: // Get the language ID
#ifdef USB_DEBUG
                            Uart0_Tx(" ->language \n\r ", 12);
#endif
                            VarSetupDescr = LangDes;
                            if (mVarSetupLength > LangDes[0])
                                mVarSetupLength = LangDes[0]; // If the required length is greater than the actual length, take the actual length
                            break;
                        case 1: // Get manufacturer string
#ifdef USB_DEBUG
                            Uart0_Tx(" ->manufacturer \n\r ", 16);
#endif
                            VarSetupDescr = MANUFACTURER_Des;
                            if (mVarSetupLength > MANUFACTURER_Des[0])
                                mVarSetupLength = MANUFACTURER_Des[0]; // If the required length is greater than the actual length, take the actual length
                            break;
                        case 2: // Get product string
#ifdef USB_DEBUG
                            Uart0_Tx(" ->product \n\r ", 11);
#endif
                            VarSetupDescr = PRODUCER_Des;
                            if (mVarSetupLength > PRODUCER_Des[0])
                                mVarSetupLength = PRODUCER_Des[0]; // If the required length is greater than the actual length, take the actual length
                            break;
                        case 3: // Get the product serial number
#ifdef USB_DEBUG
                            Uart0_Tx(" ->serial number \n\r ", 17);
#endif
                            VarSetupDescr = PRODUCER_SN_Des;
                            if (mVarSetupLength > PRODUCER_SN_Des[0])
                                mVarSetupLength = PRODUCER_SN_Des[0]; // If the required length is greater than the actual length, take the actual length
                            break;
                        }
                    }

                    mCh375DesUp();
                    break;
                case DEF_USB_GET_CONFIG: // Get configuration
#ifdef USB_DEBUG
                    Uart0_Tx(" ->Get config \n\r ", 14);
#endif
                    request.buffer[0] = 0; // Pass 0 if there is no configuration
                    if (CH375CONFLAG)
                        request.buffer[0] = 1; // Pass 1 if configured
                    mVarSetupLength = 1;
                    break;
                case DEF_USB_SET_CONFIG: // Set configuration
#ifdef USB_DEBUG
                    Uart0_Tx(" ->Set config \n\r ", 14);
#endif
                    CH375CONFLAG = 0;
                    if (request.buffer[2] != 0)
                        CH375CONFLAG = 1; // Set configuration flag
                    break;
                case DEF_USB_GET_INTERF: // Get the interface
#ifdef USB_DEBUG
                    Uart0_Tx(" ->Get interface \n\r ", 17);
#endif
                    request.buffer[0] = 1; // Number of upload interfaces, this case only supports one interface
                    mVarSetupLength = 1;
                    break;
                default:
#ifdef USB_DEBUG
                    Uart0_Tx(" ->Other standard requests \n\r ", 27);
#endif
                    CH375FLAGERR = 1; // Unsupported standard request
                    break;
                }
            }
        }
        else // Unsupported control transmission, not 8-byte control transmission
        {
            CH375FLAGERR = 1;
#ifdef USB_DEBUG
            Uart0_Tx(" USB_SETUP ERROR \n\r ", 17);
#endif
        }

        if (!CH375FLAGERR)
        {
            mCh375Ep0Up(); // There is no error, call data upload, if the length is 0, upload is status 3
        }
        else
        {
            CH375_WR_CMD_PORT(CMD_SET_ENDP3); //If there is an error, set the endpoint 0 to STALL, indicating an error
            CH375_WR_DAT_PORT(0x0F);
#ifdef USB_DEBUG
            Uart0_Tx(" USB STALL! \n\r ", 12);
#endif
        }
        break;
    case USB_INT_EP0_IN:
#ifdef USB_DEBUG
        Uart0_Tx(" EP0_IN \n\r ", 8);
#endif                                               // Successful upload of control endpoint
        if (mVarSetupRequest == DEF_USB_SET_ADDRESS) // Set the address
        {
#ifdef USB_DEBUG
            Uart0_Tx(" EP0_IN \n\r ", 8);
#endif

            CH375_WR_CMD_PORT(CMD_SET_USB_ADDR);
            CH375_WR_DAT_PORT(VarUsbAddress);

#ifdef USB_DEBUG
            Uart0_Tx(" Set address as: ", 16); // Set the USB address, set the USB address of the next transaction
            usb_debug_print_hex(&VarUsbAddress, 1);
#endif
        }
        else
        {
#ifdef USB_DEBUG
            Uart0_Tx(" Other EP0 IN \n\r ", 14);
#endif
            mCh375DesUp();
            mCh375Ep0Up();
        }

        CH375_WR_CMD_PORT(CMD_UNLOCK_USB); // Release buffer
        CH375_WR_CMD_PORT(CMD_UNLOCK_USB);
        CH375_WR_CMD_PORT(CMD_UNLOCK_USB);
        CH375_WR_CMD_PORT(CMD_UNLOCK_USB);
        CH375_WR_CMD_PORT(CMD_UNLOCK_USB);
        CH375_WR_CMD_PORT(CMD_UNLOCK_USB);
        CH375_WR_CMD_PORT(CMD_UNLOCK_USB);
        CH375_WR_CMD_PORT(CMD_UNLOCK_USB);
        CH375_WR_CMD_PORT(CMD_UNLOCK_USB);
        CH375_WR_CMD_PORT(CMD_UNLOCK_USB);
        CH375_WR_CMD_PORT(CMD_UNLOCK_USB);
        CH375_WR_CMD_PORT(CMD_UNLOCK_USB);
        CH375_WR_CMD_PORT(CMD_UNLOCK_USB);

        break;
    case USB_INT_EP0_OUT: //The control endpoint is successfully downloaded
#ifdef USB_DEBUG
        Uart0_Tx(" EP0_OUT \n\r ", 9);
#endif

        CH375_WR_CMD_PORT(CMD_RD_USB_DATA); // Issue read data command
        length = CH375_RD_DAT_PORT();       //The first thing to read is the length
        if (length == 7)                    // SET LINE CODING
        {
            for (len = 0; len < length; len++)
            {
                uartpara.uart_para_buf[len] = CH375_RD_DAT_PORT();
            }

#ifdef USB_DEBUG
            Uart0_Tx(" [COM] SET_LINE_CODING \n\r ", 23);
            usb_debug_print_hex(&uartpara.uart_para_buf[0], length);
#endif

            SET_LINE_CODING_Flag = 1;
        }

        if (SET_LINE_CODING_Flag == 1)
        {
            SET_LINE_CODING_Flag = 0; //The SET_LINE_CODING flag of the class command is cleared to 0
            // ......
            for (c1 = 0; c1 < 20; c1++)
                Delay10us();

            mVarSetupLength = 0;
            mCh375Ep0Up();
        }
        break;
    default:
        if ((InterruptStatus & 0x03) == 0x03) // Bus reset
        {
            CH375FLAGERR = 0; // clear error to 0
            CH375CONFLAG = 0; // Clear configuration
            mVarSetupLength = 0;
#ifdef USB_DEBUG
            Uart0_Tx(" USB_RESET \n\r ", 11);
#endif
        }
        else
        {
#ifdef USB_DEBUG
            Uart0_Tx(" Other USB interrupt \n\r ", 21);
#endif
        }
        CH375_WR_CMD_PORT(CMD_UNLOCK_USB); // Release buffer
        CH375_RD_DAT_PORT();
        break;
    }
}