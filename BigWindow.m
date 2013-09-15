//
//  BigWindow.m
//  Monkey
//
//  Created by hiroki on 13/09/15.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "BigWindow.h"


@implementation BigWindow

- (id)initWithContentRect:(NSRect)contentRect
                styleMask:(NSUInteger)aStyle
                  backing:(NSBackingStoreType)bufferingType
                    defer:(BOOL)flag {
    
    // Using NSBorderlessWindowMask results in a window without a title bar.
    self = [super initWithContentRect:contentRect 
							styleMask:NSBorderlessWindowMask 
							  backing:NSBackingStoreBuffered defer:NO];
    if (self != nil) {
        // Start with no transparency for all drawing into the window
//        [self setAlphaValue:1.0];
        // Turn off opacity so that the parts of the window that are not drawn into are transparent.
		[self setBackgroundColor : [ NSColor clearColor ] ];
        [self setOpaque:NO];
    }
    return self;
}

- (BOOL)canBecomeKeyWindow {
    
    return YES;
}

- (void)mouseDown:(NSEvent *)theEvent {
	[self close];
}

@end
