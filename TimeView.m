//
//  TimeView.m
//  Monkey
//
//  Created by Hiroki Mori on 12/01/09.
//  Copyright 2012 Hiroki Mori. All rights reserved.
//

#import "TimeView.h"

#import "MonkeyAppDelegate.h"
#import "TimeDocument.h"

#define OFFSETX 10
#define OFFSETY 10

@implementation TimeView

CGRect convertToCGRect(NSRect inRect);

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)plotData
{
	int i;
	NSRect therect = [self frame];
	int x = therect.size.width - OFFSETX * 2;
	float vscale = (therect.size.height - OFFSETY * 2) / (maxscale - minscale);
	TimeDocument *thedoc = [[[self window] windowController] document];

	minscale = [thedoc min];
	maxscale = [thedoc max];
	unittype = [thedoc unit];
	
	if([thedoc count] > x) {
		if([metexscroller isEnabled] == NO) {
			[metexscroller setEnabled:YES];
			[metexscroller setDoubleValue:1.0];
		} else {
			double value = (double)x / [thedoc count];
			[metexscroller setKnobProportion:value];
			if([metexscroller doubleValue] == 1.0) {
				startpos = ([thedoc count] - x) * [metexscroller doubleValue];
			}
		}
	} else {
		[metexscroller setEnabled:NO];
		startpos = 0;
	}
	
	if([thedoc count] > 1) {
		CGContextSetRGBStrokeColor(
								   gc,255/255.0f,255/255.0f,0/255.0f,1.0f);
		CGContextMoveToPoint(gc, OFFSETX, (int)(([thedoc value:startpos] - minscale)*vscale + OFFSETY));
		for(i = startpos+1; i < [thedoc count]; ++i) {
			int val = [thedoc value:i];
			if(val < minscale)
				val = minscale;
			if(val > maxscale)
				val = maxscale;
			CGContextAddLineToPoint(gc, OFFSETX+i-startpos, (int)((val - minscale)*vscale + OFFSETY));
			if(i-startpos == x)
				break;
		}
		CGContextStrokePath(gc);
	}
}

/*
- (void)setScale:(double)min max:(double)max
{
	minscale = min;
	maxscale = max;
}
 */

- (IBAction)scroll:(id)sender
{
	NSRect therect = [self frame];
	int x = therect.size.width - OFFSETX * 2;
	double curpos = [metexscroller doubleValue];
	TimeDocument *thedoc = [[[self window] windowController] document];

	int part = [sender hitPart];
	switch ( part ) {
		case NSScrollerKnob:
			break;
		case NSScrollerIncrementPage:
			[metexscroller setDoubleValue:
			 (curpos+0.3 <= 1.0 ? curpos+0.3 : 1.0)];
			break;
		case NSScrollerIncrementLine:
			[metexscroller setDoubleValue:
			 (curpos+0.1 <= 1.0 ? curpos+0.1 : 1.0)];
			break;
		case NSScrollerDecrementPage:
			[metexscroller setDoubleValue:
			 (curpos-0.3 >= 0 ? curpos-0.3 : 0.0)];
			break;
		case NSScrollerDecrementLine:
			[metexscroller setDoubleValue:
			 (curpos-0.1 >= 0 ? curpos-0.1 : 0.0)];
			break;
		case NSScrollerKnobSlot:
			break;
	}
	startpos = ([thedoc count] - x) * [metexscroller doubleValue];
	[self setNeedsDisplay:YES];
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
	int xx = ((startpos / 100) + 1) * 100 - startpos;
	for(j = 1; j < OFFSETX + x; j += 100) {
		CGContextMoveToPoint(gc, OFFSETX + j + xx, OFFSETY);
		CGContextAddLineToPoint(gc, OFFSETX + j + xx, OFFSETY + y);
	}
	CGContextMoveToPoint(gc, OFFSETX + x, OFFSETY);
	CGContextAddLineToPoint(gc, OFFSETX + x, OFFSETY + y);
	CGContextStrokePath(gc);
	
	CGContextSetTextDrawingMode(gc, kCGTextFill);
	CGContextSelectFont(gc, "Geneva", 7, kCGEncodingMacRoman);
	CGContextSetTextMatrix(gc, CGAffineTransformMakeScale(1.0, 1.0));
	CGContextSetRGBFillColor( gc,255/255.0f,255/255.0f,0/255.0f,1.0f);
	
	for(j = 0;j <= OFFSETX + x;j += 100) {
		sprintf(strbuf, "%d", ((startpos / 100) + 1) * 100 + j);
		CGContextShowTextAtPoint(gc, OFFSETX + j + xx, 2, strbuf, strlen(strbuf));
	}

	CGAffineTransform trans;
	trans = CGAffineTransformMakeScale(1.0, 1.0);
	trans = CGAffineTransformRotate(trans, 3.14/2);
	CGContextSetTextMatrix(gc, trans);
	CGContextSetRGBFillColor( gc,255/255.0f,255/255.0f,0/255.0f,1.0f);
	for(j = 0;j < 4; ++j) {
		if(maxscale < 100.0)
			sprintf(strbuf, "%.02f", (maxscale - minscale)* j / 4 + minscale);
		else
			sprintf(strbuf, "%d", (int)((maxscale - minscale)* j / 4 + minscale));
		CGContextShowTextAtPoint(gc, 8, OFFSETY + j * y / 4, strbuf, strlen(strbuf));
	}
	sprintf(strbuf, "%s", unitstr(unittype));
	CGContextShowTextAtPoint(gc, 8, OFFSETY + j * y / 4 - 8, strbuf, strlen(strbuf));
	CGContextStrokePath(gc);
}

- (void)drawRect:(NSRect)rect
{	
    gc = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSetGrayFillColor(gc, 0.0, 1.0);
	//	CGContextSetGrayFillColor(gc, 1.0, 1.0);
	CGContextFillRect(gc, convertToCGRect(rect));


	[self drawScale:rect.size];
	[self plotData];
//	[metexscroller setDoubleValue:value];
}

@end
