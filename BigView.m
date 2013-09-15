//
//  BigView.m
//  Monkey
//
//  Created by hiroki on 13/09/15.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "BigView.h"


@implementation BigView

- (void)drawRect:(NSRect)rect {
	// Drawing code here.
	[[NSColor whiteColor] set];
//	NSRectFill(rect);
	
	NSRect rect2 = NSMakeRect(0,0,
							  rect.size.width,
							  rect.size.height);
	
	NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect:rect2
														 xRadius:15.0
														 yRadius:15.0];
//	[[NSColor blackColor] set];
	[[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:0.7] set];
	[path fill];
	
	CGContextRef gc = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSetTextDrawingMode(gc, kCGTextFill);
	CGContextSelectFont(gc, "Geneva", 200, kCGEncodingMacRoman);
	
	CGContextSetRGBFillColor( gc, 255, 255, 255, 1.0f);
	char *strbuf = "46620";
	
	CGContextSetTextDrawingMode(gc, kCGTextInvisible);
	CGContextShowTextAtPoint(gc, 0, 0, strbuf, strlen(strbuf));	
	CGPoint pt = CGContextGetTextPosition(gc);
	CGContextSetTextDrawingMode(gc, kCGTextFill);
	
	CGContextShowTextAtPoint(gc, rect.size.width / 2 - pt.x / 2, 20, strbuf, strlen(strbuf));	
	CGContextStrokePath(gc);
}

@end
