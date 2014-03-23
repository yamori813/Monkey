/*
 *  iwausb.h
 *  Monkey
 *
 *  Created by hiroki on 14/03/22.
 *  Copyright 2014 __MyCompanyName__. All rights reserved.
 *
 */

#include <Carbon/Carbon.h>

CFStringRef usb_wave(char *cmd);
CFStringRef usb_query(char *cmd);
void usb_command();
int usb_init();
void usb_close();
