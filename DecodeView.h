//
//  DecodeView.h
//  Monkey
//
//  Created by hiroki on 17/08/03.
//  Copyright 2017 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DecodeView : NSView {
	CGContextRef gc;
	IBOutlet NSScroller *decodeScroller;
	int startpos;	
	int zoom;
}

- (IBAction)scroll:(id)sender;

@end
