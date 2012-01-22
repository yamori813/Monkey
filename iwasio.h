//
//  iwasio.h
//  Monkey
//
//  Created by Hiroki Mori on 11/12/25.
//  Copyright 2011 Hiroki Mori. All rights reserved.
//

#include <Carbon/Carbon.h>

void iwatsu_dummy();
int getresponse(char *data, int datasize);
int getbinary(unsigned char *data, int datasize);
int que_idn();
int que_samplingrate(int ch);
CFStringRef que_offset(int ch);
CFStringRef que_scale(int ch);
CFStringRef que_timebasescale();
CFStringRef que_triggermode();
CFStringRef que_triggersource(CFStringRef mode);
CFStringRef que_triggerlevel(CFStringRef mode);
int cmd_keylock(int onoff);
int cmd_auto();
int cmd_stop();
int cmd_run();
int cmd_grid(int type);
CFDataRef que_wav(int ch);
int iwatsu_init(CFStringRef devname, int speed);
void iwatsu_close();
