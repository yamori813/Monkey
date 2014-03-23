//
//  iwasio.h
//  Monkey
//
//  Created by Hiroki Mori on 11/12/25.
//  Copyright 2011 Hiroki Mori. All rights reserved.
//

#include <Carbon/Carbon.h>

CFDataRef sio_wave(char *cmd);
CFStringRef sio_query(char *cmd);
void sio_command(char *cmd);
int sio_init(CFStringRef devname, int speed);
void sio_close();
