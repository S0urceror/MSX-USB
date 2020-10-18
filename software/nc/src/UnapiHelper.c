/*
--
-- UnapiHelper.c
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

#include <msx_fusion.h>
#include <asm.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "UnapiHelper.h"

unapi_code_block helperCodeBlock;
Z80_registers helperRegs; //auxiliary structure for asm function calling
char chHelperString[128];

#define print(str) printf(str)
#define printChar(character) putchar (character)

void UnapiBreath()
{
    UnapiCall(&helperCodeBlock, TCPIP_WAIT, &helperRegs, REGS_NONE, REGS_NONE);
}

unsigned char InitializeTCPIPUnapi ()
{
    unsigned char uchRet = 0;
    uint uiSpecVersion;
    byte btReadChar;
    byte btVersionMain;
    byte btVersionSec;
    uint uiNameAddress;
    int i;
#ifdef UNAPIHELPER_VERBOSE
    print("Looking for UNAPI Implementations...\r\n");
#endif
	i = UnapiGetCount("TCP/IP");
    if(i==0)
    {
#ifdef UNAPIHELPER_VERBOSE
        print("Error, no TCP/IP Unapi found...\r\n");
#endif
        uchRet = 0;
    }
    else
    {
        uchRet = 1;
        UnapiBuildCodeBlock(NULL, 1, &helperCodeBlock);
#ifdef UNAPIHELPER_VERBOSE
        print("Implementation name: ");
#endif
        UnapiCall(&helperCodeBlock, UNAPI_GET_INFO, &helperRegs, REGS_NONE, REGS_MAIN);
        btVersionMain = helperRegs.Bytes.B;
        btVersionSec = helperRegs.Bytes.C;
        uiNameAddress = helperRegs.UWords.HL;
        uiSpecVersion = helperRegs.UWords.DE;   //Also, save specification version implemented

        while(1) {
            btReadChar = UnapiRead(&helperCodeBlock, uiNameAddress);
            if(btReadChar == 0) {
                break;
            }
#ifdef UNAPIHELPER_VERBOSE
            printChar(btReadChar);
#endif
            uiNameAddress++;
        }
#ifdef UNAPIHELPER_VERBOSE
        sprintf(chHelperString," v%u.%u\r\n", btVersionMain, btVersionSec);
        print(chHelperString);
#endif
    }

    return uchRet;
}

unsigned char RXData (unsigned char ucConnNumber, unsigned char * ucBuffer, unsigned int * uiSize)
{
    unsigned char ucRet = 0;

    helperRegs.Bytes.B = ucConnNumber;
    helperRegs.Words.DE = (int)ucBuffer;
    helperRegs.Words.HL = *uiSize;
    UnapiCall(&helperCodeBlock, TCPIP_TCP_RCV, &helperRegs, REGS_MAIN, REGS_MAIN);

    if (helperRegs.Bytes.A == ERR_OK)
        *uiSize = (helperRegs.UWords.BC + helperRegs.UWords.HL);
    else
        *uiSize = 0;

    if (*uiSize)
        ucRet = 1;

    return ucRet;
}

unsigned char IsConnected (unsigned char ucConnNumber)
{
    unsigned char ucRet = 0;

    helperRegs.Bytes.B = ucConnNumber;
    helperRegs.Words.HL = 0;
    UnapiCall(&helperCodeBlock, TCPIP_TCP_STATE, &helperRegs, REGS_MAIN, REGS_MAIN);

    if ((helperRegs.Bytes.A == ERR_OK) && (helperRegs.Bytes.B == 4))
        ucRet = 1;
    else
        ucRet = 0;

    return ucRet;
}

unsigned char TxByte (unsigned char ucConnNumber, unsigned char uchByte)
{
    return TxData (ucConnNumber,&uchByte,1);
}

unsigned char TxData (unsigned char ucConnNumber, unsigned char * lpucData, unsigned int uiDataSize)
{
    do
    {
        helperRegs.Words.DE = (int)lpucData;
        helperRegs.UWords.HL = uiDataSize;
        helperRegs.Bytes.C = 0;
        helperRegs.Bytes.B = ucConnNumber;

        UnapiCall(&helperCodeBlock, TCPIP_TCP_SEND, &helperRegs, REGS_MAIN, REGS_MAIN);
        if (helperRegs.Bytes.A == ERR_BUFFER)
            UnapiBreath();
    }
    while (helperRegs.Bytes.A == ERR_BUFFER);

    return helperRegs.Bytes.A;
}

unsigned char TxUnsafeData (unsigned char ucConnNumber, unsigned char * lpucData, unsigned int uiDataSize)
{
    if (uiDataSize>128)
        return ERR_INV_PARAM;
    memcpy (ucUnsafeDataTXBuffer,lpucData,uiDataSize);
    do
    {
        helperRegs.Words.DE = (int)ucUnsafeDataTXBuffer;
        helperRegs.UWords.HL = uiDataSize;
        helperRegs.Bytes.C = 0;
        helperRegs.Bytes.B = ucConnNumber;

        UnapiCall(&helperCodeBlock, TCPIP_TCP_SEND, &helperRegs, REGS_MAIN, REGS_MAIN);
        if (helperRegs.Bytes.A == ERR_BUFFER)
            UnapiBreath();
    }
    while (helperRegs.Bytes.A == ERR_BUFFER);

    return helperRegs.Bytes.A;
}

unsigned char ResolveDNS(unsigned char * uchHostString, unsigned char * ucIP)
{
#ifdef UNAPIHELPER_VERBOSE
    sprintf(chHelperString,"Resolving host (%s)...\r\n",uchHostString);
    print(chHelperString);
#endif
    helperRegs.Words.HL = (int)uchHostString;
    helperRegs.Bytes.B = 0;
    UnapiCall(&helperCodeBlock, TCPIP_DNS_Q, &helperRegs, REGS_MAIN, REGS_MAIN);
    if (helperRegs.Bytes.A != ERR_OK)
    {
#ifdef UNAPIHELPER_VERBOSE
        if(helperRegs.Bytes.A == ERR_NO_NETWORK)
            print("No network connection available\r\n");
        else if(helperRegs.Bytes.A == ERR_NO_DNS)
            print("There are no DNS servers configured\r\n");
        else if(helperRegs.Bytes.A == ERR_NOT_IMP)
            print("This TCP/IP UNAPI implementation does not support resolving host names.\nSpecify an IP address instead.\r\n");
        else
        {
            sprintf(chHelperString,"Unknown error when resolving the host name (code %i)\r\n", helperRegs.Bytes.A);
            print(chHelperString);
        }
#endif
        return helperRegs.Bytes.A;
    }

    do
    {
        UnapiBreath();
        helperRegs.Bytes.B = 0;
        UnapiCall(&helperCodeBlock, TCPIP_DNS_S, &helperRegs, REGS_MAIN, REGS_MAIN);
    }
    while (helperRegs.Bytes.A == 0 && helperRegs.Bytes.B == 1);

    if(helperRegs.Bytes.A != 0)
    {
#ifdef UNAPIHELPER_VERBOSE
        if(helperRegs.Bytes.B == 2)
            print("DNS server failure\r\n");
        else if(helperRegs.Bytes.B == 3)
            print("Unknown host name\r\n");
        else if(helperRegs.Bytes.B == 5)
            print("DNS server refused the query\r\n");
        else if(helperRegs.Bytes.B == 16 || helperRegs.Bytes.B == 17)
            print("DNS server did not reply\r\n");
        else if(helperRegs.Bytes.B == 19)
            print("No network connection available\r\n");
        else if(helperRegs.Bytes.B == 0)
            print("DNS query failed\r\n");
        else
        {
            sprintf(chHelperString,"Unknown error returned by DNS server (code %i)\r\n", helperRegs.Bytes.B);
            print(chHelperString);
        }
#endif
    }
    else
    {
        ucIP[0] = helperRegs.Bytes.L;
        ucIP[1] = helperRegs.Bytes.H;
        ucIP[2] = helperRegs.Bytes.E;
        ucIP[3] = helperRegs.Bytes.D;
    }
    return helperRegs.Bytes.A;
}

unsigned char CloseConnection (unsigned char ucConnNumber)
{
    helperRegs.Bytes.B = ucConnNumber;
    UnapiCall(&helperCodeBlock, TCPIP_TCP_CLOSE, &helperRegs, REGS_MAIN, REGS_MAIN);
    return helperRegs.Bytes.A;
}

unsigned char OpenSingleConnection (unsigned char * uchHost, unsigned char * uchPort, unsigned char * uchConn)
{
    unsigned char uchRet;
    unsigned char uchIP[4];
    unsigned char paramsBlock[11];
    unsigned int iPort = atoi(uchPort);

    uchRet = ResolveDNS(uchHost,uchIP);

    if (uchRet == ERR_OK)
    {
        paramsBlock[0] = uchIP[0];
        paramsBlock[1] = uchIP[1];
        paramsBlock[2] = uchIP[2];
        paramsBlock[3] = uchIP[3];
        paramsBlock[4] = (iPort&0xff); //remote port
        paramsBlock[5] = (iPort>>8)&0xff;
        paramsBlock[6] = 0xff; //local port can be randomly assigned
        paramsBlock[7] = 0xff;
        paramsBlock[8] = 0; //Suggestion time out
        paramsBlock[9] = 0;
        if (paramsBlock[0]==0 && 
            paramsBlock[1]==0 && 
            paramsBlock[2]==0 && 
            paramsBlock[3]==0)
            paramsBlock[10] = 1;
        else
            paramsBlock[10] = 0; //bit 1 set means passive, bit 1 set means resident
#ifdef UNAPIHELPER_VERBOSE
        sprintf(chHelperString,"OK, opening %u.%u.%u.%u:%u\r\n", paramsBlock[0], paramsBlock[1], paramsBlock[2], paramsBlock[3],iPort);
        print(chHelperString);
#endif
        helperRegs.UWords.HL = (int)paramsBlock; //conn info goes there
        UnapiCall(&helperCodeBlock, TCPIP_TCP_OPEN, &helperRegs, REGS_MAIN, REGS_MAIN);
        uchRet = helperRegs.Bytes.A;
        if (uchRet != ERR_OK)
        {
#ifdef UNAPIHELPER_VERBOSE
            if(uchRet == ERR_NO_FREE_CONN)
                print("No free TCP connections available\r\n");
            else if(uchRet == ERR_CONN_EXISTS)
                print("There is a resident TCP connection which uses the same IP/Port combination\r\n");
            else
            {
                sprintf(chHelperString,"Unknown error when opening TCP connection (code %i)\r\n", helperRegs.Bytes.A);
                print(chHelperString);
            }
#endif
        }
        else
            *uchConn = helperRegs.Bytes.B;
    }

    return uchRet;
}
