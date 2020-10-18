/*
; flash.h
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
#ifndef __FLASH_H
#define __FLASH_H

typedef unsigned char BOOL;
const BOOL TRUE=1;
const BOOL FALSE=0;

uint8_t find_flash ();
BOOL flash_ident ();
void select_ramslot_40 ();
void select_slot_40 (uint8_t slot);
BOOL erase_flash_sectors (uint8_t slot,uint8_t sector_start,uint8_t sector_end);
BOOL write_flash_segment (uint8_t slot,uint8_t segment);
BOOL flash_command_okay (uint16_t address,uint8_t expected_value);
void press_any_key ();
void do_tests(uint8_t slot);
void print_hex_buffer (uint8_t* start, uint8_t* end);

int format_string(const char* buf, const char *fmt, va_list ap);

#endif 