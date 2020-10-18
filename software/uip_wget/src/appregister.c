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