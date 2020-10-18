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
#include "clock-arch.h"

#include "timer.h"
#include "stdio.h"
#include "stdlib.h"

#define BUF ((struct uip_eth_hdr *)&uip_buf[0])

#ifndef NULL
#define NULL (void *)0
#endif /* NULL */

char hostname[100];
uint16_t port=80;
char path[100];

struct timer periodic_timer, arp_timer;

void uip_arp_loop () {
  uip_len = msxusbecm_read();
  if(uip_len > 0) 
  {
    // READ
    ///////////////////////////
    // packet read from driver
    if(BUF->type == htons(UIP_ETHTYPE_IP)) 
    {
      // IP packet received
      uip_arp_ipin();
      uip_input();
      /* If the above function invocation resulted in data that
        should be sent out on the network, the global variable
        uip_len is set to a value > 0. */
      if(uip_len > 0) 
      {
        uip_arp_out();
        msxusbecm_send();
      }
    } 
    else if(BUF->type == htons(UIP_ETHTYPE_ARP)) 
    {
      // ARP packet received
      uip_arp_arpin();
      /* If the above function invocation resulted in data that
        should be sent out on the network, the global variable
        uip_len is set to a value > 0. */
      if(uip_len > 0) 
      {
        msxusbecm_send();
      }
    }
  } 
  else if(timer_expired(&periodic_timer)) 
  {
    // WRITE
    ///////////////////////////
    timer_reset(&periodic_timer);
    // check every IP connection
    for(int i = 0; i < UIP_CONNS; i++) 
    {
      uip_periodic(i);
      /* If the above function invocation resulted in data that
        should be sent out on the network, the global variable
        uip_len is set to a value > 0. */
      if(uip_len > 0) 
      {
        uip_arp_out();
        msxusbecm_send();
      }
    }

    #if UIP_UDP
    // check every UDP connection
    for(int i = 0; i < UIP_UDP_CONNS; i++) 
    {
      uip_udp_periodic(i);
      /* If the above function invocation resulted in data that
        should be sent out on the network, the global variable
        uip_len is set to a value > 0. */
      if(uip_len > 0) 
      {
        uip_arp_out();
        msxusbecm_send();
      }
    }
    #endif /* UIP_UDP */
    
    /* Call the ARP timer function every 10 seconds. */
    if(timer_expired(&arp_timer)) 
    {
      timer_reset(&arp_timer);
      uip_arp_timer();
    }
  }
}

/*---------------------------------------------------------------------------*/
int main(char *argv[], int argc)
{
  char url[255];
  bool benchmark = false;
  uip_ipaddr_t ipaddr;

  // Check arguments
  ////////////////////////////////////////////////////////////
  if (argc==0) {
    printf ("WGET [b] <url>\r\n\r\n");
    printf ("Downloads the file specified by <url> from the Web\r\n");
    exit (0);
  }
  if (argc==1) 
    strcpy (url,argv[0]);
  if (argc==2) {
    if (argv[0][0]!='b')
      printf ("WGET\r\nIncorrect option specified\r\n");
    benchmark = true;
    strcpy (url,argv[1]);
  }
  // check url
  if (strstr (url,"http://")==NULL) {
    printf ("WGET\r\nIncorrect URL specified\r\n");
    exit (0);
  }
  // tell what we are going to do
  if (benchmark) {
    printf ("WGET - HTTP downloader for MSX\r\nBenchmarking download from %s\r\n--------------------------------\r\n",url);
  } else {
    printf ("WGET - HTTP downloader for MSX\r\nDownloading %s\r\n--------------------------------\r\n",url);
  }
  // extract hostname, port, url
  strcpy (hostname,strstr (url,"http://")+7);
  if (strchr (hostname,'/')!=0) 
  {
    strcpy (path,strstr (hostname,"/"));
    strstr (hostname,"/")[0]='\0';
  }
  else
    strcpy (path, "/");
  
  if (strchr (hostname,':')!=0)
  {
    port = atoi (strstr (hostname,":")+1);
    strstr (hostname,":")[0]='\0';
  }
  
  // Init uIP
  ////////////////////////////////////////////////////////////
  timer_set(&periodic_timer, CLOCK_SECOND / 2);
  timer_set(&arp_timer, CLOCK_SECOND * 10);
  // Init MSXUSB CDC ECM driver
  struct uip_eth_addr mac;
  if (!msxusbecm_init(&mac))
    return 0;
  // Set MAC address of CDC ECM adapter
  uip_setethaddr (mac);

  /* Initialize the uIP TCP/IP stack. */
  uip_init();
  uip_arp_init();
  // Init uIP modules/apps
  webclient_init();
  resolv_init();

  register_udp (dhcpc_appcall);
  register_udp (resolv_appcall);

  // set IP addresses or DHCP
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
    // set DNS
  uip_getdraddr (ipaddr);
  //uip_ipaddr(ipaddr, 192,168,1,201);
  resolv_conf(ipaddr);
#endif

  printf ("--------------------------------\r\n");
  //printf ("Hostname: %s, port: %d, path: %s\r\n",hostname,port,path);

  // query for hostname
  //resolv_query(hostname);

  // MAIN LOOP - TCPIP + ARP
  while(1) {
    uip_arp_loop();
  }
  return 0;
}

//---------------------------------------------------------------------------
// CALLBACK HANDLERS
//
void
uip_log(char *m)
{
  printf("uIP log message: %s\r\n", m);
}
void
resolv_found(char *name, u16_t *ipaddr)
{
  u16_t *ipaddr2;
  
  if(ipaddr == NULL) {
    printf("Host '%s' not found.\r\n", name);
    exit (0);
  } 
  else 
  {
    printf("Found name '%s' = %d.%d.%d.%d\r\n", name,
    htons(ipaddr[0]) >> 8,
    htons(ipaddr[0]) & 0xff,
    htons(ipaddr[1]) >> 8,
    htons(ipaddr[1]) & 0xff);
    webclient_get(hostname, port, path);
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
  resolv_conf(s->dnsaddr);

  // query for hostname
  resolv_query(hostname);
}
#endif /* __DHCPC_H__ */
#endif
void
webclient_closed(void)
{
  printf("Webclient: connection closed\r\n");
  exit (0);
}
void
webclient_aborted(void)
{
  printf("Webclient: connection aborted\r\n");
  exit (0);
}
void
webclient_timedout(void)
{
  printf("Webclient: connection timed out\r\n");
  exit (0);
}
void
webclient_connected(void)
{
  printf("Webclient: connected, receiving data...\r\n");
}

clock_time_t start=0;
void
webclient_datahandler(char *data, u16_t len)
{
  if (start==0)
    start = clock_time();
  if (data==NULL) 
  {
    printf ("Total frames: %d\r\n",(clock_time()-start));
    start=0;
    webclient_close();
  }
}
/*---------------------------------------------------------------------------*/
