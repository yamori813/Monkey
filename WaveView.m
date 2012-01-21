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

#define OFFSETX 10
#define OFFSETY 10

@implementation WaveView

// A convenience function to get a CGRect from an NSRect. You can also use the
// *(CGRect *)&nsRect sleight of hand, but this way is a bit clearer.
CGRect convertToCGRect(NSRect inRect)
{
    return CGRectMake(inRect.origin.x, inRect.origin.y, inRect.size.width, inRect.size.height);
}

- (void)drawScale:(NSSize) size
{
	char strbuf[32];
	int j;
	int x = size.width - OFFSETX * 2;
	int y = size.height - OFFSETY * 2;
	CGContextSetRGBStrokeColor( gc, 255, 255, 255, 0.3);
	for(j = 0;j <= 8; ++j) {
		CGContextMoveToPoint(gc, OFFSETX, OFFSETY + j * y / 8);
		CGContextAddLineToPoint(gc, OFFSETX + x, OFFSETY + j * y / 8);
	}
	
	CGContextMoveToPoint(gc, OFFSETX, OFFSETY);
	CGContextAddLineToPoint(gc, OFFSETX, OFFSETY + y);
	for(j = 1; j <= 12; j += 1) {
		CGContextMoveToPoint(gc, OFFSETX + j*x/12, OFFSETY);
		CGContextAddLineToPoint(gc, OFFSETX + j*x/12, OFFSETY + y);
	}
	CGContextStrokePath(gc);
}

- (void)plotData
{
	int i;
	unsigned char *buff;
	MyDocument *thedoc = [[[self window] windowController] document];
	if([thedoc getData1] != NULL) {
		buff = malloc([[thedoc getData1] length]);
		CGContextSetRGBStrokeColor(
								   gc,255/255.0f,255/255.0f,0/255.0f,1.0f);
		[[thedoc getData1] getBytes:buff length:[[thedoc getData1] length]];
		CGContextMoveToPoint(gc, OFFSETX, 400 - (buff[4] - 28)*2+OFFSETY);
		for(i = 5; i < 604; ++i) {
			CGContextAddLineToPoint(gc, i-4+OFFSETX, 400 - (buff[i] - 28)*2+OFFSETY); 
		}
		CGContextStrokePath(gc);
		free(buff);
	}
	if([thedoc getData2] != NULL) {
		buff = malloc([[thedoc getData2] length]);
		CGContextSetRGBStrokeColor(
								   gc,236/255.0f,0/255.0f,140/255.0f,1.0f);
		[[thedoc getData2] getBytes:buff length:[[thedoc getData2] length]];
		CGContextMoveToPoint(gc, OFFSETX, 400 - (buff[4] - 28)*2+OFFSETY);
		for(i = 5; i < 604; ++i) {
			CGContextAddLineToPoint(gc, i-4+OFFSETX, 400 - (buff[i] - 28)*2+OFFSETY); 
		}
		CGContextStrokePath(gc);
		free(buff);
	}
}

- (void)drawRect:(NSRect)rect
{

    gc = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSetGrayFillColor(gc, 0.0, 1.0);
//	CGContextSetGrayFillColor(gc, 1.0, 1.0);
	CGContextFillRect(gc, convertToCGRect(rect));
	[self drawScale:rect.size];
	[self plotData];
}

@end
