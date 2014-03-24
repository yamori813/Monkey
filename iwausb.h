/*
 *  iwausb.h
 *  Monkey
 *
 *  Created by Hiroki Mori on 14/03/22.
 *  Copyright 2014 Hiroki Mori. All rights reserved.
 *
 */

#include <Carbon/Carbon.h>

CFDataRef usb_wave(char *cmd);
CFStringRef usb_query(char *cmd);
void usb_command();
int usb_init();
void usb_close();
