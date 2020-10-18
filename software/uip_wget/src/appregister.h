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