/*
 * Copyright (c) 2001, Adam Dunkels.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *      This product includes software developed by Adam Dunkels.
 * 4. The name of the author may not be used to endorse or promote
 *    products derived from this software without specific prior
 *    written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS
 * OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 * GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * This file is part of the uIP TCP/IP stack.
 *
 * $Id: main.c,v 1.16 2006/06/11 21:55:03 adam Exp $
 *
 */


#include "uip.h"
#include "uip_arp.h"
#include "msxusbecm.h"

#include "timer.h"
#include "stdio.h"

#define BUF ((struct uip_eth_hdr *)&uip_buf[0])

#ifndef NULL
#define NULL (void *)0
#endif /* NULL */

/*---------------------------------------------------------------------------*/
int
main(void)
{
  printf ("Hello world\r\n===========\r\n");

  int i;
  uip_ipaddr_t ipaddr;
  struct timer periodic_timer, arp_timer;

  timer_set(&periodic_timer, CLOCK_SECOND / 2);
  timer_set(&arp_timer, CLOCK_SECOND * 10);
  
  struct uip_eth_addr mac;
  if (!msxusbecm_init(&mac))
    return 0;

  uip_setethaddr (mac);
  uip_init();

#if DHCP
  uip_ipaddr(ipaddr, 0,0,0,0);
  uip_sethostaddr(ipaddr);
  dhcpc_init((void*) &mac, 6);
#else
  uip_ipaddr(ipaddr, 192,168,1,25);
  uip_sethostaddr(ipaddr);
  uip_ipaddr(ipaddr, 192,168,1,1);
  uip_setdraddr(ipaddr);
  uip_ipaddr(ipaddr, 255,255,255,0);
  uip_setnetmask(ipaddr);
#endif
  //httpd_init();
  
  /*  telnetd_init();*/
  
  hello_world_init();
  
  /*uip_ipaddr(ipaddr, 127,0,0,1);
  smtp_configure("localhost", ipaddr);
  SMTP_SEND("adam@sics.se", NULL, "uip-testing@example.com",
	    "Testing SMTP from uIP",
	    "Test message sent by uIP\r\n");*/

  /*
    webclient_init();
    resolv_init();
    uip_ipaddr(ipaddr, 195,54,122,204);
    resolv_conf(ipaddr);
    resolv_query("www.sics.se");*/

  while(1) {
    uip_len = msxusbecm_read();
    if(uip_len > 0) {
      // packet read from driver
      if(BUF->type == htons(UIP_ETHTYPE_IP)) {
        // IP packet received
        uip_arp_ipin();
        uip_input();
        /* If the above function invocation resulted in data that
          should be sent out on the network, the global variable
          uip_len is set to a value > 0. */
        if(uip_len > 0) {
          uip_arp_out();
          msxusbecm_send();
        }
      } 
      else if(BUF->type == htons(UIP_ETHTYPE_ARP)) {
        // ARP packet received
        uip_arp_arpin();
        /* If the above function invocation resulted in data that
          should be sent out on the network, the global variable
          uip_len is set to a value > 0. */
        if(uip_len > 0) {
          msxusbecm_send();
        }
      }
    } 
    else if(timer_expired(&periodic_timer)) {
      // time to do something
      timer_reset(&periodic_timer);
      // check every IP connection
      for(i = 0; i < UIP_CONNS; i++) {
        uip_periodic(i);
        /* If the above function invocation resulted in data that
          should be sent out on the network, the global variable
          uip_len is set to a value > 0. */
        if(uip_len > 0) {
          uip_arp_out();
          msxusbecm_send();
        }
      }

#if UIP_UDP
      // check every UDP connection
      for(i = 0; i < UIP_UDP_CONNS; i++) {
        uip_udp_periodic(i);
        /* If the above function invocation resulted in data that
          should be sent out on the network, the global variable
          uip_len is set to a value > 0. */
        if(uip_len > 0) {
          uip_arp_out();
          msxusbecm_send();
        }
      }
#endif /* UIP_UDP */
      
      /* Call the ARP timer function every 10 seconds. */
      if(timer_expired(&arp_timer)) {
        timer_reset(&arp_timer);
        uip_arp_timer();
      }
    }
  }
  return 0;
}
/*---------------------------------------------------------------------------*/
void
uip_log(char *m)
{
  //printf("uIP log message: %s\r\n", m);
}
void
resolv_found(char *name, u16_t *ipaddr)
{
  u16_t *ipaddr2;
  
  if(ipaddr == NULL) {
    printf("Host '%s' not found.\r\n", name);
  } else {
    printf("Found name '%s' = %d.%d.%d.%d\r\n", name,
	   htons(ipaddr[0]) >> 8,
	   htons(ipaddr[0]) & 0xff,
	   htons(ipaddr[1]) >> 8,
	   htons(ipaddr[1]) & 0xff);
    /*    webclient_get("www.sics.se", 80, "/~adam/uip");*/
  }
}
#if DHCP
#ifdef __DHCPC_H__
void
dhcpc_configured(const struct dhcpc_state *s)
{
  printf("Got IP address %d.%d.%d.%d\r\n",
	 uip_ipaddr1(s->ipaddr), uip_ipaddr2(s->ipaddr),
	 uip_ipaddr3(s->ipaddr), uip_ipaddr4(s->ipaddr));
  printf("Got netmask %d.%d.%d.%d\r\n",
	 uip_ipaddr1(s->netmask), uip_ipaddr2(s->netmask),
	 uip_ipaddr3(s->netmask), uip_ipaddr4(s->netmask));
  printf("Got DNS server %d.%d.%d.%d\r\n",
	 uip_ipaddr1(s->dnsaddr), uip_ipaddr2(s->dnsaddr),
	 uip_ipaddr3(s->dnsaddr), uip_ipaddr4(s->dnsaddr));
  printf("Got default router %d.%d.%d.%d\r\n",
	 uip_ipaddr1(s->default_router), uip_ipaddr2(s->default_router),
	 uip_ipaddr3(s->default_router), uip_ipaddr4(s->default_router));
  printf("Lease expires in %d seconds\r\n",
	 ntohs(s->lease_time[0])*65536ul + ntohs(s->lease_time[1]));

  uip_sethostaddr(s->ipaddr);
  uip_setnetmask(s->netmask);
  uip_setdraddr(s->default_router);
  //resolv_conf(s->dnsaddr);
}
#endif /* __DHCPC_H__ */
#endif
void
smtp_done(unsigned char code)
{
  printf("SMTP done with code %d\r\n", code);
}
void
webclient_closed(void)
{
  printf("Webclient: connection closed\r\n");
}
void
webclient_aborted(void)
{
  printf("Webclient: connection aborted\r\n");
}
void
webclient_timedout(void)
{
  printf("Webclient: connection timed out\r\n");
}
void
webclient_connected(void)
{
  printf("Webclient: connected, waiting for data...\r\n");
}
void
webclient_datahandler(char *data, u16_t len)
{
  printf("Webclient: got %d bytes of data.\r\n", len);
}
/*---------------------------------------------------------------------------*/
