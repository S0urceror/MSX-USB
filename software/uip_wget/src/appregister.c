/*
;
; appregister.c - combine multiple UDP apps together.
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

#include "appregister.h"
#include "stdint.h"

uint8_t countAppHandlers = 0;
void* (*udp_app_handlers[10])(void);

void register_udp (void (*udp_app_handler)(void))
{
    if (countAppHandlers<=sizeof (udp_app_handlers))
    {
        udp_app_handlers[countAppHandlers++] = udp_app_handler;
    }
}

void udp_appcall()
{
    for (uint8_t i=0;i<countAppHandlers;i++) 
    {
        *(udp_app_handlers[i])();
    }
}