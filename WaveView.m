//
//  WaveView.m
//  Monkey
//
//  Created by Hiroki Mori on 11/12/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WaveView.h"

#import "MonkeyAppDelegate.h"
#import "WaveDocument.h"

#define OFFSETX 40
#define OFFSETY 40

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
	for(j = 0;j <= 8; ++j) {
		if(j == 4)
			CGContextSetRGBStrokeColor( gc, 255, 255, 255, 0.6);
		else
			CGContextSetRGBStrokeColor( gc, 255, 255, 255, 0.3);
		CGContextMoveToPoint(gc, OFFSETX, OFFSETY + j * y / 8);
		CGContextAddLineToPoint(gc, OFFSETX + x, OFFSETY + j * y / 8);
		CGContextStrokePath(gc);
	}
	
	CGContextMoveToPoint(gc, OFFSETX, OFFSETY);
	CGContextAddLineToPoint(gc, OFFSETX, OFFSETY + y);
	for(j = 1; j <= 12; j += 1) {
		if(j == 6)
			CGContextSetRGBStrokeColor( gc, 255, 255, 255, 0.6);
		else
			CGContextSetRGBStrokeColor( gc, 255, 255, 255, 0.3);
		CGContextMoveToPoint(gc, OFFSETX + j*x/12, OFFSETY);
		CGContextAddLineToPoint(gc, OFFSETX + j*x/12, OFFSETY + y);
		CGContextStrokePath(gc);
	}
	WaveDocument *thedoc = [[[self window] windowController] document];
	ds5100_info *info = [thedoc getInfo];
	CGContextSetTextDrawingMode(gc, kCGTextFill);
	CGContextSelectFont(gc, "Geneva", 20, kCGEncodingMacRoman);
	CGContextSetTextMatrix(gc, CGAffineTransformMakeScale(1.0, 1.0));

	CGContextSetRGBFillColor( gc,256/255.0f,128/255.0f,0/255.0f,1.0f);
	sprintf(strbuf, "MONKEY", info->ch1scale);
	CGContextShowTextAtPoint(gc, OFFSETX, y + OFFSETY + 20, strbuf, strlen(strbuf));
	
	CGContextSelectFont(gc, "Geneva", 14, kCGEncodingMacRoman);
	CGContextSetTextMatrix(gc, CGAffineTransformMakeScale(1.0, 1.0));

	CGContextSetRGBFillColor( gc,255/255.0f,255/255.0f,0/255.0f,1.0f);
	sprintf(strbuf, "CH1 %.02f V", info->ch1scale);
	CGContextShowTextAtPoint(gc, OFFSETX, 2, strbuf, strlen(strbuf));

	CGContextSetRGBFillColor( gc,236/255.0f,0/255.0f,140/255.0f,1.0f);
	sprintf(strbuf, "CH2 %.02f V", info->ch2scale);
	CGContextShowTextAtPoint(gc, OFFSETX + 100, 2, strbuf, strlen(strbuf));

	CGContextSetRGBFillColor( gc, 255, 255, 255, 1.0f);
	sprintf(strbuf, "Time %f S", info->timebasescale);
	CGContextShowTextAtPoint(gc, OFFSETX + 200, 2, strbuf, strlen(strbuf));

	CGContextStrokePath(gc);
}

- (void)plotData
{
	int i;
	unsigned char *buff;
	WaveDocument *thedoc = [[[self window] windowController] document];
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
