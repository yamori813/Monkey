//
//  Iwatsu.h
//  Monkey
//
//  Created by Hiroki Mori on 14/03/22.
//  Copyright 2014 Hiroki Mori. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#include "iwasio.h"
#include "iwausb.h"
#import "iwaspp.h"

#define CONNON		0
#define CONSERIAL	1
#define CONUSB		2
#define CONSPP		3

@interface Iwatsu : NSObject {
	int ConnectType;
	iwaspp *spp;
}

- (BOOL) SerialOpen:(CFStringRef)devname speed:(int)speed;
- (BOOL) USBOpen;
- (BOOL) SPPOpen;
- (NSData *) Wave:(int)ch;
- (NSString *) QueSamplingRate:(int)ch;
- (NSString *) QueOffset:(int)ch;
- (NSString *) QueTriggerMode;
- (NSString *) QueTimeBaseOffset;
- (NSString *) QueScale:(int) ch;
- (NSString *) QueTimeBaseScale;
- (NSString *) QueTriggorsource:(char *)mode;
- (void) CmdKeyLock:(int)onoff;
- (void) CmdGrid:(int)type;
- (void) CmdAuto;
- (void) CmdRun;
- (void) CmdStop;
- (void) Close;

@end
