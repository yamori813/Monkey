//
//  LogicView.h
//  Monkey
//
//  Created by hiroki on 17/07/26.
//  Copyright 2017 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LogicView : NSView {
	CGContextRef gc;
	IBOutlet NSScroller *logicScroller;
	int startpos;	
}

- (IBAction)scroll:(id)sender;

@end
