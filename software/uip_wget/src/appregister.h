/*
;
; appregister.h - combine multiple UDP apps together.
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
#ifndef __APP_REGISTER_H_

void register_udp (void (*udp_app_handler)(void));

union udp_app_state 
{
    struct dhcpc_state dhcp;
    int resolv;
};

typedef union udp_app_state uip_udp_appstate_t;

#define UIP_UDP_APPCALL udp_appcall
void udp_appcall(void);

#endif // __APP_REGISTER_H_