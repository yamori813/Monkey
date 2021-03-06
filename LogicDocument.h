//
//  LogicDocument.h
//  Monkey
//
//  Created by hiroki on 17/07/26.
//  Copyright 2017 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "LogicWindowController.h"

#import "LogicView.h"

@interface LogicDocument : NSDocument {
	IBOutlet LogicView *logicview;

	logic_info *info;
	LogicWindowController *myctl;
	NSSavePanel*		savePanel;
	IBOutlet NSView*	saveDialogCustomView;
	IBOutlet NSPopUpButton *fileTypePopup;
	NSData *myData;
}

- (logic_info *)getInfo;
- (NSData *) getData;
- (LogicView *) getImageView;
@end
