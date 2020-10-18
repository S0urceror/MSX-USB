#include <stdio.h>
#include <stdint.h>
#include "mystdio.h"
#include <stdlib.h>

#define do_char_inc(c) {*bufPnt = c; if(bufPnt) { bufPnt++; } count++;}
//extern void uitoa(int val, char* buffer, char base);
//extern void itoa(int val, char* buffer, char base);

void press_any_key ()
{
    myprint ("Press any key to continue\r\n");
    bios_chget ();
}

uint8_t bios_chget ()
{
    __asm
    push ix
    ld iy, #0
    ld ix, #0x9F ;CHGET
    call 0x1c ;CALSLT
    pop ix
    ld h, #0
    ld l,a
    ret
    __endasm;
}

void bios_print (const char* str)
{
    str;
    __asm
    ld iy,#3
    add iy,sp ;Bypass the return address of the function 

    push ix
    ld h, (iy)
    dec iy
    ld l, (iy)

again_:
    ld a, (hl)
    and a
    jr z, end_

    ld iy, #0
    ld ix, #0xA2 ;CHPUT
    call 0x1c ;CALSLT
    inc hl
    jr again_
end_:
    pop ix
    __endasm;
}

int format_string(const char* buf, const char *fmt, va_list ap)
{
  char *fmtPnt;
  char *bufPnt;
  char base;
  char isUnsigned;
  char *strPnt;
  long val;
  static char buffer[16];
  char theChar;
  int count=0;

  fmtPnt = (char*) fmt;
  bufPnt = (char*) buf;

  while((theChar = *fmtPnt)!=0)
  {
    isUnsigned = 0;
    base = 10;

    fmtPnt++;

    if(theChar != '%') {
      do_char_inc(theChar);
      continue;
    }

    theChar = *fmtPnt;
    fmtPnt++;

    if(theChar == 's')
    {
      strPnt = va_arg(ap, char *);
      while((theChar = *strPnt++) != 0) 
        do_char_inc(theChar);

      continue;
    } 

    if(theChar == 'c')
    {
      val = va_arg(ap, int);
      do_char_inc((char) val);

      continue;
    } 

    if(theChar == 'u') {
      isUnsigned = 1;
    }
    else if(theChar == 'x') {
      base = 16;
    }
    else if(theChar != 'd' && theChar != 'i') {
      do_char_inc(theChar);
      continue;
    }

    val = va_arg(ap, int);
    
    if(isUnsigned)
      uitoa(val, buffer, base);
    else
      itoa(val, buffer, base);

    strPnt = buffer;
    while((theChar = *strPnt++) != 0) 
      do_char_inc(theChar);
  }

  if(bufPnt) *bufPnt = '\0';

  return count;
}

char buf[255];
int myprint(const char *fmt, ...)
{
  va_list arg;
  va_start(arg, fmt);
  int len = format_string(buf, fmt, arg);
  bios_print (buf);
  return len;
}