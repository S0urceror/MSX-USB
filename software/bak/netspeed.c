/*
; netspeed.c - check download/upload speed via TCP/UDP
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

int main(char *argv[], int argc)
{  
  printf ("NETSPEED - check download/upload speed - (press ESC to exit)\r\n");
  if (argc!=3)
  {
    printf ("Usage: NETSPEED t|u hostname port\r\n");
    return 0;
  }
  printf ("-------------------------------------------- \r\n");
  if (!InitializeTCPIPUnapi ())
  {
    printf ("Unable to init TCPIP");
    return 0;
  }
  unsigned char connid;
  if (OpenSingleConnection (argv[1],argv[2],&connid)!=ERR_OK)
  {
    printf ("Unable to open connection to: %s",argv[0]);
    return 0;
  }
  printf ("-------------------------------------------- \r\n");
  memset (ucRcvDataMemory,0,128);
  unsigned int bufsize = 128;
  char outbuffer[128];
  char* outbufpt = outbuffer;
  //unsigned int cnt = 0;
  while (1)
  {
    unsigned char key = Inkey ();
    if (key!=0)
    {
      if (key==27)
        break;
      putchar (key);
      *(outbufpt++) = key;
      if (key==13) {
        putchar ('\n');
        *(outbufpt++) = '\n';
        TxUnsafeData (connid,outbuffer,outbufpt-outbuffer);
        outbufpt = outbuffer;
      }
    }
    bufsize = 128;
    if (RXData (connid,ucRcvDataMemory,&bufsize))
    {
      if (bufsize>0) {
        *(ucRcvDataMemory+bufsize) = 0;
        printf ("%s\r",ucRcvDataMemory);
      }
    }
    //if (cnt%100 == 0) {
    //  if (!IsConnected(connid))
    //    break;
    //}
    //cnt++;
  }
  CloseConnection(connid);
  return 0;
}