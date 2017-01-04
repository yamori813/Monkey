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
	int buffersize;
	double minscale;
	double maxscale;
	int unittype;
	int startpos;
}

- (IBAction)scroll:(id)sender;

@end
