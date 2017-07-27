//
//  LogicDocument.h
//  Monkey
//
//  Created by hiroki on 17/07/26.
//  Copyright 2017 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "LogicWindowController.h"


@interface LogicDocument : NSDocument {
	LogicWindowController *myctl;
	NSSavePanel*		savePanel;
	IBOutlet NSView*	saveDialogCustomView;
	IBOutlet NSPopUpButton *fileTypePopup;
	NSData *myData;
}

- (BOOL) setData:(NSData *)data;
- (NSData *) getData;
@end
