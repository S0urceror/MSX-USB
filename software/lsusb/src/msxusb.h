/*
; msxusb.h - low-level Unapi to communicate with USB
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
#ifndef __MSXUSB_H
#define __MSXUSB_H

#define FN_CHECK                0*8
#define FN_CONNECT              1*8
#define FN_GETDESCRIPTORS       2*8
#define FN_CONTROL_TRANSFER     3*8
#define FN_DATA_IN_TRANSFER     4*8
#define FN_DATA_OUT_TRANSFER    5*8
#define FN_SYNC_MODE            6*8
#define FN_CONTROL_PACKET       7*8

#endif 