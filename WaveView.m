//
//  WaveView.m
//  Monkey
//
//  Created by Hiroki Mori on 11/12/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WaveView.h"

#import "MonkeyAppDelegate.h"
#import "MyDocument.h"


@implementation WaveView

// A convenience function to get a CGRect from an NSRect. You can also use the
// *(CGRect *)&nsRect sleight of hand, but this way is a bit clearer.
CGRect convertToCGRect(NSRect inRect)
{
    return CGRectMake(inRect.origin.x, inRect.origin.y, inRect.size.width, inRect.size.height);
}

- (void)drawWave:(NSData *)thedata
{
	int i;
	unsigned char buff[604];
	CGContextSetRGBStrokeColor(
							   gc,255/255.0f,255/255.0f,0/255.0f,1.0f);
	[thedata getBytes:buff length:sizeof(buff)];
	CGContextMoveToPoint(gc, 4, 512 - buff[4]*2);
	for(i = 5; i < 604; ++i) {
		CGContextAddLineToPoint(gc, i, 512 - buff[i]*2); 
	}
	CGContextStrokePath(gc);
}

- (void)drawRect:(NSRect)rect
{

    gc = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSetGrayFillColor(gc, 0.0, 1.0);
//	CGContextSetGrayFillColor(gc, 1.0, 1.0);
	CGContextFillRect(gc, convertToCGRect(rect));
	MyDocument *thedoc = [[[self window] windowController] document];
	[self drawWave:[thedoc getData]];
}


@end
