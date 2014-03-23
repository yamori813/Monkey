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

#define CONSERIAL	1
#define CONUSB		2
#define CONSPP		3

@interface Iwatsu : NSObject {
	int ConnectType;
	iwaspp *spp;
}

@end
