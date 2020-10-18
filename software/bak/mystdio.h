/*
; mystdio.h
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
#ifndef __MY_STDIO_H
#define __MY_STDIO_H

void press_any_key ();
uint8_t bios_chget ();
void bios_print (const char* str);
int format_string(const char* buf, const char *fmt, va_list ap);
int myprint(const char *fmt, ...);

#endif