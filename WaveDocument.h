//
//  WaveDocument.h
//  Untitled
//
//  Created by Hiroki Mori on 11/12/30.
//  Copyright 2011 Hiroki Mori. All rights reserved.
//


#import <Cocoa/Cocoa.h>

#import "WaveWindowController.h"


@interface WaveDocument : NSDocument {
	ds5100_info *info;
	NSData *myData1;
	NSData *myData2;
	WaveWindowController *myctl;
	NSSavePanel*		savePanel;
	IBOutlet NSView*	saveDialogCustomView;
	IBOutlet NSPopUpButton *fileTypePopup;
}

- (NSData *)getData1;
- (NSData *)getData2;

@end
