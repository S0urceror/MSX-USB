# ifndef _DESCRIPTOR_H_
 
# define  _DESCRIPTOR_H_
 
# define  CH375_EP0_SIZE  0x08  // Control endpoint size
# define  BULK_OUT_ENDP_MAX_SIZE  0x40  // Maximum data packet length of output endpoint
# define  BULK_IN_ENDP_MAX_SIZE  0x40  // Enter the maximum data packet length of the endpoint
 
# define  SEND_ENCAPSULATED_COMMAND  0x00  // Issues a command in the format of the supported control protocol.
# define  GET_ENCAPSULATED_RESPONSE  0x01  // Requests a response in the format of the supported control protocol.
# define  SET_COMM_FEATURE  0x02  // Controls the settings for a particular communication feature.
# define  GET_COMM_FEATURE  0x03  // Returns the current settings for the communication feature.
# define  CLEAR_COMM_FEATURE  0x04  // Clears the settings for a particular communication feature
# The DEFINE  GET_LINE_CODING  0x21  // This Request android.permission at The Host to the Find OUT at The Rate this page Currently the Configured Line Coding.
/* Line Coding Structure
 Offset Field Size Value Description
 0 dwDTERate 4 Number Data terminal rate, in bits per second.
 4 bCharFormat 1 Number Stop bits
 0-1 Stop bit
 1-1.5 Stop bits
 2-2 Stop bits
 5 bParityType 1 Number Parity
 0-None
 1-Odd
 2-Even
 3-Mark
 4-Space
 6 bDataBits 1 Number Data bits (5, 6, 7, 8 or 16).
*/
 
# define  SET_LINE_CODING  0X20  // Configures DTE rate, stop-bits, parity, and number-of-character
# define  SET_CONTROL_LINE_STATE  0X22  // This request generates RS-232/V.24 style control signals.
# define  SEND_BREAK  0x23  // Sends special carrier modulation used to specify RS-232 style break
 
 
typedef  union _UART_PARA
{
 unsigned  char uart_para_buf[ 7 ];
 struct
 {
 unsigned  char bBaudRate1; // Serial port baud rate (lowest bit)
 unsigned  char bBaudRate2; // (second low)
 unsigned  char bBaudRate3; // (second highest)
 unsigned  char bBaudRate4; // (highest bit)
 unsigned  char bStopBit; // Stop bit
 unsigned  char bParityBit; // Parity bit
 unsigned  char bDataBits; // Number of data bits
 }uart;
} mUART_PARA, *mpUART_PARA;
 
typedef  union _REQUEST_PACK
{
 unsigned  char buffer[ 8 ];
 struct {
 unsigned  char bmReuestType; // Standard request word
 unsigned  char bRequest; // Request code
 unsigned  int wValue; // Feature selection is high
 unsigned  int wIndex; // Index
 unsigned  int wLength; // data length
 }r;
} mREQUEST_PACKET, *mpREQUEST_PACKET;
 
 
/* Device descriptor */
extern  unsigned  char DevDes[];
/* Configuration descriptor */
extern  unsigned  char ConDes[];
/* Language descriptor */
extern  unsigned  char LangDes[];
/* Vendor string descriptor */
extern  unsigned  char MANUFACTURER_Des[];
/* Product string descriptor */
extern  unsigned  char PRODUCER_Des[];
/* Product serial number string descriptor */
extern  unsigned  char PRODUCER_SN_Des[];
 
# endif