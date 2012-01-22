//
//  MyDocument.h
//  Untitled
//
//  Created by Hiroki Mori on 11/12/30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import <Cocoa/Cocoa.h>

#import "MyWindowController.h"


@interface MyDocument : NSDocument {
	ds5100_info *info;
	NSData *myData1;
	NSData *myData2;
	MyWindowController *myctl;
	NSSavePanel*		savePanel;
	IBOutlet NSView*	saveDialogCustomView;
	IBOutlet NSPopUpButton *fileTypePopup;
}

- (NSData *)getData1;
- (NSData *)getData2;

@end
