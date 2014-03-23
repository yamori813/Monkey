//
//  Iwatsu.m
//  Monkey
//
//  Created by Hiroki Mori on 14/03/22.
//  Copyright 2014 Hiroki Mori. All rights reserved.
//

#import "Iwatsu.h"

@implementation Iwatsu


- (void) Command:(char *)cmd
{
	if(ConnectType == CONSERIAL) {
		sio_command(cmd);
	} else if(ConnectType == CONUSB) {
		usb_command(cmd);
	} else if(ConnectType == CONSPP) {
		[spp Command:cmd];
	}
}

- (NSString *) Query:(char *)cmd
{
	if(ConnectType == CONSERIAL) {
		return (NSString *)sio_query(cmd);
	} else if(ConnectType == CONUSB) {
		return (NSString *)usb_query(cmd);
	} else if(ConnectType == CONSPP) {
		return [spp Query:cmd];
	}
	return nil;
}

- (BOOL) SerialOpen:(CFStringRef)devname speed:(int)speed
{
	ConnectType = CONSERIAL;
	return sio_init(devname, speed);
}

- (BOOL) USBOpen
{
	ConnectType = CONUSB;
	return usb_init();
}

- (BOOL) SPPOpen
{
	ConnectType = CONSPP;
	spp = [[iwaspp alloc] init];
	return [spp Open];
}

- (NSData *) Wave:(int)ch
{
	char data[1024*2];
	
	sprintf(data, ":WAVeform:DATA? CHANnel%d\n", ch);
	
	if(ConnectType == CONSERIAL) {
		return (NSData *)sio_wave(data);
	} else if(ConnectType == CONUSB) {
		return (NSData *)usb_wave(data);
	} else if(ConnectType == CONSPP) {
		return [spp Wave:data];
	}
	return nil;
}

- (NSString *) QueSamplingRate:(int)ch
{
	char data[128];
	
	sprintf(data, ":ACQuire:SAMPlingrate? CHANnel%d\n", ch);
	
	return [self Query:data];
}

- (NSString *) QueOffset:(int)ch
{
	char data[128];
	
	sprintf(data, ":CHANnel%d:OFFSet?\n", ch);
	
	return [self Query:data];
}

- (NSString *) QueTriggerMode
{
	char data[128];
	
	strcpy(data, ":TRIGger:MODE?\n");
	
	return [self Query:data];
}

- (NSString *) QueTimeBaseOffset
{
	char data[128];
	
	strcpy(data, ":TIMebase:DELayed:OFFSet?\n");
	
	return [self Query:data];
}

- (NSString *) QueScale:(int) ch
{
	char data[128];
	
	sprintf(data, ":CHANnel%d:SCALe?\n", ch);
	
	return [self Query:data];
}

- (NSString *) QueTimeBaseScale
{
	char data[128];

	sprintf(data, ":TIMebase:DELayed:SCALe?\n");

	return [self Query:data];
}

- (NSString *) QueTriggorsource:(char *)mode
{
	char data[128];
	
	sprintf(data, ":TRIGger:%s:SOURce?\n", mode);
	
	return [self Query:data];
}

- (void) CmdKeyLock:(int)onoff
{
	char data[128];
	
	if(onoff == 0) {
		strcpy(data, ":KEY:LOCK DISable\n");
	} else {
		strcpy(data, ":KEY:LOCK ENABle\n");
	}
	
	[self Command:data];
}

- (void) CmdGrid:(int)type
{
	char data[128];
	
	strcpy(data, ":DISPlay:GRID ");
	if(type == 0)
		strcat(data, "FULL\n");
	else if(type == 1)
		strcat(data, "HALF\n");
	else
		strcat(data, "NONE\n");
	
	[self Command:data];
}

- (void) CmdAuto
{
	char data[128];
	
	strcpy(data, ":AUTO\n");
	
	[self Command:data];
}

- (void) CmdRun
{
	char data[128];
	
	strcpy(data, ":RUN\n");
	
	[self Command:data];
}

- (void) CmdStop
{
	char data[128];
	
	strcpy(data, ":STOP\n");

	[self Command:data];
}

- (void) Close
{
	if(ConnectType == CONSERIAL) {
		sio_close();
	} else if(ConnectType == CONUSB) {
		usb_close();
	} else if(ConnectType == CONSPP) {
		[spp Close];
	}
}

@end
