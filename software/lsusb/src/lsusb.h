/*
; lsusb.h - list the USB descriptors
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
#ifndef __LSUSB_H
#define __LSUSB_H

void PrintUsageAndEnd();
void PrintImplementationName(unapi_code_block* unapi);
void PrintDescriptors (unapi_code_block* unapi);
void print_descriptors (char* buffer);
uint16_t GetJumpTable (unapi_code_block* unapi);

#endif 