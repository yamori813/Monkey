//
//  TimeView.h
//  Monkey
//
//  Created by Hiroki Mori on 12/01/09.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TimeView : NSView {
	CGContextRef gc;
	IBOutlet NSScroller *metexscroller;
	double protdata[1024];
	int datasize;
	int viewmax;
}

- (void)addData:(double)data time:(int)msec;
- (IBAction)scroll:(id)sender;

@end
