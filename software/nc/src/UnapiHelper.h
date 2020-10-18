/*
--
-- UnapiHelper.h
--   UNAPI Abstraction functions.
--   Revision 0.60
--
-- Requires SDCC and Fusion-C library to compile
-- Copyright (c) 2019 Oduvaldo Pavan Junior ( ducasp@gmail.com )
-- All rights reserved.
--
-- Redistribution and use of this source code or any derivative works, are
-- permitted provided that the following conditions are met:
--
-- 1. Redistributions of source code must retain the above copyright notice,
--    this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright
--    notice, this list of conditions and the following disclaimer in the
--    documentation and/or other materials provided with the distribution.
-- 3. Redistributions may not be sold, nor may they be used in a commercial
--    product or activity without specific prior written permission.
-- 4. Source code of derivative works MUST be published to the public.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
-- "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
-- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
-- CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
-- EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
-- OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
-- WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
-- OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
*/

#ifndef _UNAPIHELPER_HEADER_INCLUDED
#define _UNAPIHELPER_HEADER_INCLUDED
//Comment the define bellow if you do not want messages printed by this code
#define UNAPIHELPER_VERBOSE

enum TcpipUnapiFunctions {
    UNAPI_GET_INFO = 0,
    TCPIP_GET_CAPAB = 1,
    TCPIP_NET_STATE = 3,
    TCPIP_DNS_Q = 6,
    TCPIP_DNS_S = 7,
    TCPIP_UDP_OPEN = 8,
    TCPIP_UDP_CLOSE = 9,
    TCPIP_UDP_STATE = 10,
    TCPIP_UDP_SEND = 11,
    TCPIP_UDP_RCV = 12,
    TCPIP_TCP_OPEN = 13,
    TCPIP_TCP_CLOSE = 14,
    TCPIP_TCP_ABORT = 15,
    TCPIP_TCP_STATE = 16,
    TCPIP_TCP_SEND = 17,
    TCPIP_TCP_RCV = 18,
    TCPIP_WAIT = 29
};

enum TcpipErrorCodes {
    ERR_OK = 0,
    ERR_NOT_IMP,
    ERR_NO_NETWORK,
    ERR_NO_DATA,
    ERR_INV_PARAM,
    ERR_QUERY_EXISTS,
    ERR_INV_IP,
    ERR_NO_DNS,
    ERR_DNS,
    ERR_NO_FREE_CONN,
    ERR_CONN_EXISTS,
    ERR_NO_CONN,
    ERR_CONN_STATE,
    ERR_BUFFER,
    ERR_LARGE_DGRAM,
    ERR_INV_OPER
};

__at 0xD500 unsigned char ucUnsafeDataTXBuffer[128];

// UnapiBreath
//
// Some UNAPI adapters will work better if you do not check them again and leave
// some "breathing room" so they can work on VDP Interrupt and proccess data.
//
// It is up to the adapter to make this call take as long as the adapter need,
// or return immediately if such "breathing" is not needed
void UnapiBreath();

// InitializeTCPIPUnapi
//
// Check if there are any TCP-IP Unapi Implementations available, and if there
// are, use the first available
//
// Return 0 if no TCP-IP Unapi implementation found
// Return 1 if a TCP-IP Unapi implementation has been found
unsigned char InitializeTCPIPUnapi ();

// OpenSingleConnection
//
// Will try do DNS resolve ucHost, if found, will try to open a TCP/IP active
// connection with the resolved IP using port uchPort (host and Port are ASCII)
//
// If connection is succesful will return connection number in uchConn and
// return ERR_OK
unsigned char OpenSingleConnection (unsigned char * uchHost, unsigned char * uchPort, unsigned char * uchConn);

// CloseConnection
//
// Will request connection ucConnNumber to be closed
//
// Will return ERR_OK if success
unsigned char CloseConnection (unsigned char ucConnNumber);

// IsConnected
//
// Return 1 if ucConnNumber connection state is established
// Return 0 otherwise
unsigned char IsConnected (unsigned char ucConnNumber);

// RXData
//
// Will try to retrieve up to uiSize bytes from ucConnNumber and place in ucBuffer
//
// Return 0 and uiSize = 0 if no data
// Return 1 and uiSize = bytes read if data was available
unsigned char RXData (unsigned char ucConnNumber, unsigned char * ucBuffer, unsigned int * uiSize);

// TXByte
//
// Will try to send uchByte in ucConnNumber
//
// Return ERR_OK if success
unsigned char TxByte (unsigned char ucConnNumber, unsigned char uchByte);

// TXData
//
// Will try to send uiDataSize bytes from lpucData in ucConnNumber
//
// Return ERR_OK if success
unsigned char TxData (unsigned char ucConnNumber, unsigned char * lpucData, unsigned int uiDataSize);

// TXUnsafeData
//
// Will try to send uiDataSize bytes from lpucData in ucConnNumber
// But will move data to high memory before doing so
// Up to 128 bytes can be sent here
//
// Return ERR_OK if success
unsigned char TxUnsafeData (unsigned char ucConnNumber, unsigned char * lpucData, unsigned int uiDataSize);

// ResolveDNS
//
// Used by OpenSingleConnection
//
// If success return ERR_OK and resolved IP in ucIP[0]...[3]
unsigned char ResolveDNS(unsigned char * uchHostString, unsigned char * ucIP);

#endif //#ifndef _UNAPIHELPER_HEADER_INCLUDED
