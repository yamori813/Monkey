//
//  prototype.h
//  Monkey
//
//  Created by hiroki on 17/08/02.
//  Copyright 2017 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Plugin.h"

#define OK_BUTTON		1
#define CANCEL_BUTTON	2

@interface MDSerial : NSObject <MDPluginProtocol> {
    IBOutlet NSPanel *sheetDialog;
	IBOutlet NSTextField *channel;
	IBOutlet NSTextField *baudrate;
	
	int button;
	int ch;
	int baud;
}

- (IBAction)sheetButtonClicked:(id)sender;

@end
