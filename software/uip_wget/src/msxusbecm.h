#ifndef __MSXUSB_ECM_H__
#define __MSXUSB_ECM_H__

#include <uip-conf.h>
#include <stdbool.h>
#include <uip.h>

bool msxusbecm_init (struct uip_eth_addr* mac);
unsigned int msxusbecm_read (void);
void msxusbecm_send (void);

#endif /* __MSXUSB_ECM_H__ */