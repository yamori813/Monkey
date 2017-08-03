//
//  DecodeDocument.h
//  Monkey
//
//  Created by hiroki on 17/08/03.
//  Copyright 2017 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


#import "DecodeWindowController.h"


@interface DecodeDocument : NSDocument {
	logic_info *info;
	DecodeWindowController *myctl;
	NSSavePanel*		savePanel;
	IBOutlet NSView*	saveDialogCustomView;
	IBOutlet NSPopUpButton *fileTypePopup;
	NSString *myData;
}

- (logic_info *)getInfo;
- (NSString *) getData;

@end
