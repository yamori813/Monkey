//
//  TimeView.h
//  Monkey
//
//  Created by Hiroki Mori on 12/01/09.
//  Copyright 2012 Hiroki Mori. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TimeView : NSView {
	CGContextRef gc;
	IBOutlet NSScroller *metexscroller;
	double *protdata;
	int buffersize;
	int datasize;
	int maxscale;
	int startpos;
}

- (void)addData:(double)data time:(int)msec;
- (IBAction)scroll:(id)sender;

@end
