/*
; flash.c - flash the ROM in the MSXUSB cartridge
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
#include <io.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <math.h>
//#include "mystdio.h"
#include "flash.h"

#define SEGMENT_SIZE 8*1024

__at 0x8000 uint8_t file_segment[SEGMENT_SIZE];
__at 0x4000 uint8_t flash_segment[];

void FT_SetName( FCB *p_fcb, const char *p_name )  // Routine servant à vérifier le format du nom de fichier
{
  char i, j;
  memset( p_fcb, 0, sizeof(FCB) );
  for( i = 0; i < 11; i++ ) {
    p_fcb->name[i] = ' ';
  }
  for( i = 0; (i < 8) && (p_name[i] != 0) && (p_name[i] != '.'); i++ ) {
    p_fcb->name[i] =  p_name[i];
  }
  if( p_name[i] == '.' ) {
    i++;
    for( j = 0; (j < 3) && (p_name[i + j] != 0) && (p_name[i + j] != '.'); j++ ) {
      p_fcb->ext[j] =  p_name[i + j] ;
    }
  }
}

void press_any_key ()
{
    printf ("Press any key to continue\r\n");
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

int main(char *argv[], int argc)
{   
    uint8_t slot=0;
    uint8_t argnr=0;
    printf ("MSXUSB Flash, (c) 2020 S0urceror\r\n\r\n");
    if (argc < 1)
    {
        printf ("FLASH.COM [flags] [romfile]\r\n\r\nOptions:\r\n/T - perform tests\r\n/S0 - skip flash detection and select slot 0\r\n/S1 - skip flash detection and select slot 1\r\n/S2 - skip flash detection and select slot 2\r\n/S3 - skip flash detection and select slot 3\r\n");
        return (0);
    }
    if (ReadSP ()<(0x8000+SEGMENT_SIZE))
    {
        printf ("Not enough memory to read file segment");
        return (0);
    }
    if (strcmp (argv[0],"/S0")==0) {
        slot = 0;argnr++;
    } 
    if (strcmp (argv[0],"/S1")==0) {
        slot = 1;argnr++;
    } 
    if (strcmp (argv[0],"/S2")==0) {
        slot = 2;argnr++;
    } 
    if (strcmp (argv[0],"/S3")==0) {
        slot = 3;argnr++;
    }
    if (argnr==0)
    {   
        // find the slot where the flash rom is sitting
        if (!((slot = find_flash())<4))
        {
            printf ("Cannot find slot with flash\r\n");
            return (0);
        } 
    }
    printf ("Found flash in slot: %d\r\n",slot);
    if (strcmp (argv[argnr],"/T")==0 || strcmp (argv[argnr],"/t")==0)
    {
        // test mode
        do_tests (slot);
        return (0);
    }
    // open file
    FCB fcb;
    FT_SetName (&fcb,argv[argnr]);
    if(fcb_open( &fcb ) != FCB_SUCCESS) 
    {
        printf ("Error: opening file\r\n");
        return (0);   
    }
    printf ("Opened: %s\r\n",argv[0]);

    // get ROM size
    unsigned long romsize = fcb.file_size;
    printf ("Filesize is %d bytes\r\n",romsize);

    // erase flash sectors
    float endsector = romsize;
    endsector = endsector / 65536;
    endsector = ceilf (endsector);
    if (!erase_flash_sectors (slot,0,(uint8_t)endsector)) // 64Kb sectors
        return (0); 
    press_any_key();

    // read file from beginning to end
    int bytes_read=0;
    BOOL not_ready = TRUE;
    uint8_t segmentnr = 0;
    // for each 8k segment
    while (not_ready)
    {
        // read 8k segment
        MemFill (file_segment,0xff,SEGMENT_SIZE);
        printf ("Reading ");
        bytes_read = fcb_read( &fcb, file_segment,SEGMENT_SIZE);
        // ready?
        if (bytes_read<SEGMENT_SIZE)
            not_ready=FALSE;
        printf ("%d bytes, segment %d\r\n",bytes_read,segmentnr);
        // write 8k segment
        if (!write_flash_segment (slot,segmentnr))
            break;
        segmentnr++;
    }
    fcb_close (&fcb);
    return(0);
}

void do_tests (uint8_t slot)
{
    // select flash in slot
    select_slot_40 (slot);
    for (int i=0;i<8;i++)
    {
        printf ("segment: %d in slot: %d\r\n",i,slot);
        // select segment
        flash_segment[0x1000] = i;
        // debug purposes
        print_hex_buffer (flash_segment, flash_segment+16);
        /*
        if (flash_segment[0x00]==0xff && // empty segment? let's stop
            flash_segment[0x10]==0xff &&
            flash_segment[0x20]==0xff &&
            flash_segment[0x30]==0xff)
            break;
        */
        press_any_key();
    }
    select_ramslot_40 ();
}

void select_slot_40 (uint8_t slot)
{
    slot;
    __asm
    ld iy,#2
    add iy,sp ;Bypass the return address of the function 

    ld a,(iy)   ;slot
    ld h,#0x40
    jp	0x24 ; ENASLT
    __endasm;
}
void select_ramslot_40 ()
{
    __asm
    ld	a,(#0xf342) ; RAMAD1
	ld	h,#0x40
	jp	0x24 ; ENASLT
    __endasm;
}
BOOL flash_ident ()
{
    uint8_t dummy;
    // reset
    flash_segment[0] = 0xf0;
    // write autoselect code
    dummy = flash_segment [0x555];
    flash_segment[0x555] = 0xaa;
    dummy = flash_segment [0x2aa];
    flash_segment[0x2aa] = 0x55;
    dummy = flash_segment [0x555];
    flash_segment[0x555] = 0x90;
    // read response
    uint8_t manufacturer = flash_segment[0];
    uint8_t device = flash_segment[1];
    printf ("M: %x, D: %x\r\n",manufacturer,device);
    // AMD_AM29F040 = A4
    // SST_SST39SF040 = B7
    // AMIC_A29040B = 86
    if (device==0xA4)  // device ID is correct
    {
        printf ("Found device: AMD_AM29F040\r\n");
        // reset
        flash_segment[0] = 0xf0;
        return TRUE;
    }
    if (device==0xB7)  // device ID is correct
    {
        printf ("Found device: SST_SST39SF040\r\n");
        // reset
        flash_segment[0] = 0xf0;
        return TRUE;
    }
    if (device==0x86)  // device ID is correct
    {
        printf ("Found device: AMIC_A29040B\r\n");
        // reset
        flash_segment[0] = 0xf0;
        return TRUE;
    }
    return FALSE;
}

uint8_t find_flash ()
{
    uint8_t i;
    uint8_t highest_slot = 4;
    for (i=0;i<4;i++)
    {
        // select slot in 0x4000-0x7fff
        select_slot_40 (i);
        // do flash identification
        if (flash_ident ())
            highest_slot=i; // yes? save slot number
    }
    select_ramslot_40 ();
    return highest_slot;
}

void print_hex_buffer (uint8_t* start, uint8_t* end)
{
    char str[3];
    uint8_t* cur = start;
    uint8_t cnt=0;
    while (cur<end)
    {
        char hex[]="0\0\0";
        uint8_t len = sprintf (str,"%x",*cur);
        if (len<2)
        {
            strcat (hex,str);
            printf (hex);
        }
        else
            printf (str);
        
        cur++;
        cnt++;
        if ((cnt%8)==0)
            printf ("\r\n");
    }
}

BOOL erase_flash_sectors (uint8_t slot,uint8_t sector_start,uint8_t sector_end)
{
    // select flash in slot
    select_slot_40 (slot);
    // main loop
    int i;
    for (i=sector_start;i<sector_end;i++)
    {
        printf ("Erasing sector: %d\r\n",i);
        // select start segment in sector
        flash_segment[0x1000] = i*8;
        // debug purposes
        // print_hex_buffer (flash_segment, flash_segment+16);
        // write autoselect code
        flash_segment[0x555] = 0xaa;
        flash_segment[0x2aa] = 0x55;
        flash_segment[0x555] = 0x80;
        flash_segment[0x555] = 0xaa;
        flash_segment[0x2aa] = 0x55;
        flash_segment[0] = 0x30;
        // check if ready
        if (!flash_command_okay (0,0xff))
        {
            // reset
            flash_segment[0] = 0xf0;
            printf ("Error erasing sector: %d, segment: %d\r\n",i,i*8);
            break;   
        }
        // debug purposes
        // print_hex_buffer (flash_segment, flash_segment+16);
    }
    // select ram in slot
    select_ramslot_40 ();
    if (i<sector_start)
        return FALSE;
    else
        return TRUE;
}
BOOL flash_command_okay (uint16_t address,uint8_t expected_value)
{
    uint8_t value=0;
    while (TRUE)
    {
        value = flash_segment[address];
        if (value==expected_value)
            return TRUE;
        if ((value & 0x20) != 0)
            break;
    }
    value = flash_segment[address];
    if (value==expected_value)
        return TRUE;
    else
    {
        printf ("=> address: %x, value: %x, response: %x\r\n",address,expected_value,value);
        return FALSE;
    }
}
BOOL write_flash_segment (uint8_t slot,uint8_t segment)
{
    // select flash in slot
    select_slot_40 (slot);
    // select segment
    flash_segment[0x1000] = segment;
    // debug purposes
    // print_hex_buffer (flash_segment, flash_segment+16);
    // write 8k bytes from 0x8000 to 0x4000
    int i;
    for (i=0;i<(8*1024);i++)
    {
        // write autoselect code
        flash_segment[0x555] = 0xaa;
        flash_segment[0x2aa] = 0x55;
        flash_segment[0x555] = 0xa0;
        flash_segment[i] = file_segment[i];
        // check if ready
        if (i>=0x1000) // addresses 0x5000 to 0x5fff
            flash_segment[0x1000] = segment; // necessary to switch back
        if (!flash_command_okay (i,file_segment[i]))
        {
            printf ("Error writing byte: %x in segment: %d\r\n",i,segment);
            break;   
        }
    }
    // debug purposes
    // print_hex_buffer (flash_segment, flash_segment+16);
    // select ram in slot
    select_ramslot_40 ();

    if (i<(8*1024))
        return FALSE;
    else
        return TRUE;
}