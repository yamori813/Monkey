//
//  TimeDocument.h
//  Monkey
//
//  Created by hiroki on 15/01/03.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TimeWindowController.h"
#import "TimeView.h"

typedef struct {
	double time;
	double val;
} plotdate;

@protocol TimeDocumentDelegate <NSObject>

- (double)metex_poll;

@end

@interface TimeDocument : NSDocument {
	TimeWindowController *myctl;
	NSSavePanel*		savePanel;
	IBOutlet NSView*	saveDialogCustomView;
	IBOutlet NSPopUpButton *fileTypePopup;
	IBOutlet TimeView *imgView;
	NSTimer *polltimer;
	id datasrc;
	SEL sel;

	int datasize;
	plotdate *data;
	int buffsize;
	uint64_t pollstart;

	double minscale;
	double maxscale;
	int unittype;
}

-(double)max;
-(double)min;
-(int)unit;
-(int)count;
-(double)value:(int)num;
-(double)time:(int)num;

@end
