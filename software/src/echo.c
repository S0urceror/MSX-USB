/*
; echo.c - communicate with the Echo TCP/UDP service
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
*/
#include <msx_fusion.h>
#include <asm.h>
#include <stdio.h>
#include <string.h>
#include "UnapiHelper.h"

__at 0xD000 unsigned char ucRcvDataMemory[];

int main(int argc, char* argv[])
{
  if (!InitializeTCPIPUnapi ())
    return -1;
  unsigned char connid;
  if (OpenSingleConnection ("192.168.1.185","7",&connid)!=ERR_OK)
    return -1;
  char str[] = "HELLO WORLD";
  printf ("Sending: [%s]\r\n");
  if (TxUnsafeData (connid,str,strlen (str))!=ERR_OK)
    return -1;
  //unsigned char buffer[255];
  memset (ucRcvDataMemory,0,128);
  unsigned int bufsize = 128;
  int count = 5;
  while (count--)
  {
    if (RXData (connid,ucRcvDataMemory,&bufsize)==ERR_OK)
    {
        printf ("Received %d bytes: [%s]\r\n",bufsize,ucRcvDataMemory);
    }
  }
  CloseConnection(connid);
  return 0;
}