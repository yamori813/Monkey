//
//  TimeView.m
//  Monkey
//
//  Created by Hiroki Mori on 12/01/09.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "TimeView.h"

#define OFFSETX 10
#define OFFSETY 10

@implementation TimeView

CGRect convertToCGRect(NSRect inRect);

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		viewmax = 1000;
		maxscale = 12;
    }
    return self;
}


- (void)plotData
{
	int i;
	NSRect therect = [self frame];
	int x = therect.size.width - OFFSETX * 2;
	float vscale = (therect.size.height - OFFSETY * 2) / maxscale;
	int startpos = (viewmax - x) * [metexscroller doubleValue];
	if(startpos < datasize) {
		CGContextSetRGBStrokeColor(
								   gc,255/255.0f,255/255.0f,0/255.0f,1.0f);
		CGContextMoveToPoint(gc, OFFSETX, (int)(protdata[startpos]*vscale + OFFSETY));
		for(i = startpos+1; i < datasize; ++i) {
			CGContextAddLineToPoint(gc, OFFSETX+i-startpos, (int)(protdata[i]*vscale + OFFSETY));
			if(i-startpos == x)
				break;
		}
		CGContextStrokePath(gc);
	}
}

- (void)addData:(double)data time:(int)msec
{
	if(msec == 0)
		datasize = 0;
	if(datasize < sizeof(protdata)) {
		protdata[datasize] = data;
		++datasize;
	}
	[self setNeedsDisplay:YES];
}

- (IBAction)scroll:(id)sender
{
	int part = [sender hitPart];
	switch ( part ) {
		case NSScrollerKnob:
			break;
		case NSScrollerIncrementPage:
			break;
		case NSScrollerDecrementPage:
			break;
		case NSScrollerDecrementLine:
			break;
		case NSScrollerIncrementLine:
			break;
		case NSScrollerKnobSlot:
			break;
	}
	[self setNeedsDisplay:YES];
}

- (void)drawScale:(NSSize) size
{
	char strbuf[8];
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
	int startpos = (viewmax - x) * [metexscroller doubleValue];
	int xx = ((startpos / 100) + 1) * 100 - startpos;
	for(j = 1; j < OFFSETX + x; j += 100) {
		CGContextMoveToPoint(gc, OFFSETX + j + xx, OFFSETY);
		CGContextAddLineToPoint(gc, OFFSETX + j + xx, OFFSETY + y);
	}
	CGContextMoveToPoint(gc, OFFSETX + x, OFFSETY);
	CGContextAddLineToPoint(gc, OFFSETX + x, OFFSETY + y);
	CGContextStrokePath(gc);
	
	CGContextSetTextDrawingMode(gc, kCGTextFill);
	CGContextSetRGBFillColor( gc, 0, 98, 255, 1.0);
	CGContextSelectFont(gc, "Geneva", 7, kCGEncodingMacRoman);
	CGContextSetTextMatrix(gc, CGAffineTransformMakeScale(1.0, 1.0));
	
	for(j = 0;j <= OFFSETX + x;j += 100) {
		sprintf(strbuf, "%d", ((startpos / 100) + 1) * 100 + j);
		CGContextShowTextAtPoint(gc, OFFSETX + j + xx, 2, strbuf, strlen(strbuf));
	}

	CGAffineTransform trans;
	trans = CGAffineTransformMakeScale(1.0, 1.0);
	trans = CGAffineTransformRotate(trans, 3.14/2);
	CGContextSetTextMatrix(gc, trans);
	for(j = 0;j <= 4; ++j) {
		sprintf(strbuf, "%d", maxscale * j / 4);
		CGContextShowTextAtPoint(gc, 8, OFFSETY + j * y / 4, strbuf, strlen(strbuf));
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
	int x = rect.size.width - OFFSETX * 2;
	if(x < viewmax) {
		double value = (double)x / viewmax;
		[metexscroller setKnobProportion:value];
		[metexscroller setEnabled:YES];
	} else {
		[metexscroller setEnabled:NO];
	}
//	[metexscroller setDoubleValue:value];
}

@end
