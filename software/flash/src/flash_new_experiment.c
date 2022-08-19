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
#include "flash.h"
#include "bios.h"

#define SEGMENT_SIZE 8*1024

__at 0x8000 uint8_t file_segment[SEGMENT_SIZE];
__at 0x4000 uint8_t flash_memory[];
uint16_t flash_address1;
uint16_t flash_address2;

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

uint8_t bios_chget () __naked
{
    __asm
    push ix
    ld iy, #0
    ld ix, #BIOS_CHGET
    call BIOS_CALSLT
    pop ix
    ld h, #0
    ld l,a
    ret
    __endasm;
}

void press_any_key ()
{
    printf ("Press any key to continue\r\n");
    bios_chget ();
}


int putchar (int character)
{
    __asm
    ld      hl, #2 
    add     hl, sp   ;Bypass the return address of the function 
    ld     a, (hl)

    ld     iy,(#BIOS_EXPTBL-1)       ;BIOS slot in iyh
    push ix
    ld     ix,#BIOS_CHPUT       ;address of BIOS routine
    call   BIOS_CALSLT          ;interslot call
    pop ix
    __endasm;

    return character;
}

void select_slot_40 (uint8_t slot)
{
    __asm
    ld iy,#2
    add iy,sp ;Bypass the return address of the function 

    ld a,(iy)   ;slot
    ld h,#0x40
    jp	0x24 ; ENASLT
    __endasm;
}
void select_slot_80 (uint8_t slot)
{
    __asm
    ld iy,#2
    add iy,sp ;Bypass the return address of the function 

    ld a,(iy)   ;slot
    ld h,#0x80
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
void select_ramslot_80 ()
{
    __asm
    ld	a,(#0xf343) ; RAMAD2
	ld	h,#0x80
	jp	0x24 ; ENASLT
    __endasm;
}
void select_flash_segment (uint8_t segment)
{
    flash_memory[0x1000] = segment;
}

void do_tests (uint8_t slot)
{
    // select flash in slot
    select_slot_40 (slot);
    for (int i=0;i<8;i++)
    {
        printf ("Segment: %d in slot: %d\r\n",i,slot);
        // select segment
        select_flash_segment (i);
        // debug purposes
        print_hex_buffer (flash_memory, flash_memory+16);
        press_any_key();
    }
    select_ramslot_40 ();
}

void write_flash (uint32_t address,uint8_t value)
{
    uint8_t segment = (address / (SEGMENT_SIZE));
    address = address - (segment * SEGMENT_SIZE);
    printf ("segment: %d, address: %x\r\n",segment, address);
    select_flash_segment (segment);
    flash_memory[address] = value;
}
uint8_t read_flash (uint32_t address)
{
    uint8_t segment = (address / (SEGMENT_SIZE));
    address = address - (segment * SEGMENT_SIZE);
    select_flash_segment (segment);
    return flash_memory[address];
}

BOOL flash_ident (uint16_t address1,uint16_t address2)
{
    // write autoselect code
    write_flash (address1,0xaa);
    write_flash (address2,0x55);
    write_flash (address1,0x90);

    // read response
    uint8_t manufacturer = read_flash (0x0000); 
    uint8_t device = read_flash (0x0001); 

    // print findings
    // printf ("M: 0x%x, D: 0x%x\r\n",manufacturer,device);

    // AMD_AM29F040 = A4
    // SST_SST39SF040 = B7
    // AMIC_A29040B = 86
    if (device==0xA4)  // device ID is correct
    {
        printf ("Found device: AMD_AM29F040\r\n");
        // reset
        write_flash (0x0000,0xf0);
        return TRUE;
    }
    else if (device==0xB7)  // device ID is correct
    {
        printf ("Found device: SST_SST39SF040\r\n");
        // reset
        write_flash (0x0000,0xf0);
        return TRUE;
    }
    else if (device==0x86)  // device ID is correct
    {
        printf ("Found device: AMIC_A29040B\r\n");
        // reset
        write_flash (0x0000,0xf0);
        return TRUE;
    }
    printf ("No flash\r\n");
    return FALSE;
}

uint8_t find_flash_ex (uint16_t address1,uint16_t address2)
{
    int i;
    for (i=0;i<4;i++)
    {
        // select slot in 0x4000-0x7fff
        select_slot_40 (i);

        printf ("S: %d - ",i);
        // do flash identification
        if (flash_ident (address1,address2))
        {
            flash_address1 = address1;
            flash_address2 = address2;
            return i; // yes? return.
        }
    }
    return i;
}

uint8_t find_flash ()
{
    uint8_t highest_slot = 4;
    
    // find flash
    printf ("0x555 / 0x2aa:\r\n");
    highest_slot = find_flash_ex (0x555,0x2aa);
    printf ("\r\n");
    // try again with other address range when not found
    if (highest_slot==4)
    {
        printf ("0x5555 / 0x2aaa:\r\n");
        highest_slot = find_flash_ex (0x5555,0x2aaa);
        printf ("\r\n");
    }

    // restore RAM
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
    // select slot in 0x4000-0x7fff
    select_slot_40 (slot);
    // main loop
    uint8_t i;
    uint32_t high_address;
    for (i=sector_start;i<sector_end;i++)
    {
        printf ("Erasing sector: %d (%x,%x)\r\n",i,flash_address1,flash_address2);
        // select start segment in sector
        select_flash_segment (i*8);
        // debug purposes
        print_hex_buffer (flash_memory, flash_memory+16);
        // write autoselect code
        write_flash(flash_address1, 0xaa);
        write_flash(flash_address2, 0x55);
        write_flash(flash_address1, 0x80);
        write_flash(flash_address1, 0xaa);
        write_flash(flash_address2, 0x55);
        high_address = i*8*SEGMENT_SIZE;
        write_flash(high_address,0x30);
        // check if ready
        if (!flash_command_okay (high_address,0xff))
        {
            // reset
            write_flash(0x0000,0xf0);
            printf ("Error erasing sector: %d, segment: %d\r\n",i,i*8);
            break;   
        }
        // debug purposes
        print_hex_buffer (flash_memory, flash_memory+16);
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
        value = read_flash (address);
        if (value==expected_value)
            return TRUE;
        if ((value & 0x20) != 0)
            break;
    }
    value = read_flash (address);
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
    // select slot in 0x4000-0x7fff
    select_slot_40 (slot);
    // debug purposes
    select_flash_segment (segment);
    print_hex_buffer (flash_memory, flash_memory+16);
    // write 8k bytes from 0x8000 to 0x4000
    int i;
    for (i=0;i<SEGMENT_SIZE;i++)
    {
        // write autoselect code
        write_flash(flash_address1, 0xaa);
        write_flash(flash_address2, 0x55);
        write_flash(flash_address1, 0xa0);
        write_flash(segment*SEGMENT_SIZE+i, file_segment[i]);
        // check if ready
        if (!flash_command_okay (segment*SEGMENT_SIZE+i,file_segment[i]))
        {
            printf ("Error writing byte: %x in segment: %d\r\n",i,segment);
            break;   
        }
    }
    // debug purposes
    select_flash_segment (segment);
    print_hex_buffer (flash_memory, flash_memory+16);
    // select ram in slot
    select_ramslot_40 ();

    if (i<SEGMENT_SIZE)
        return FALSE;
    else
        return TRUE;
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
    if (ReadSP ()<((uint16_t)file_segment+SEGMENT_SIZE))
    {
        printf ("Not enough memory to read file segment");
        return (0);
    }
    //printf ("Maximum memory address: %x\r\n",ReadSP());
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
    printf ("Filesize is %ld bytes\r\n",romsize);

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
        // read segment
        bytes_read = fcb_read( &fcb, file_segment,SEGMENT_SIZE);
        // ready?
        if (bytes_read<SEGMENT_SIZE)
            not_ready=FALSE;
        printf ("Reading %d bytes, segment %d\r\n",bytes_read,segmentnr);
        // write 8k segment
        if (!write_flash_segment (slot,segmentnr))
        {
            fcb_close (&fcb);
            return (0);
        }
        segmentnr++;
    }
    fcb_close (&fcb);

    return(0);
}
