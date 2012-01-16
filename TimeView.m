//
//  TimeView.m
//  Monkey
//
//  Created by Hiroki Mori on 12/01/09.
//  Copyright 2012 Hiroki Mori. All rights reserved.
//

#import "TimeView.h"

#define OFFSETX 10
#define OFFSETY 10

@implementation TimeView

CGRect convertToCGRect(NSRect inRect);

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		maxscale = 12;
		protdata = NULL;
    }
    return self;
}


- (void)plotData
{
	int i;
	NSRect therect = [self frame];
	int x = therect.size.width - OFFSETX * 2;
	float vscale = (therect.size.height - OFFSETY * 2) / maxscale;
	int startpos;

	if(datasize > x) {
		double value = (double)x / datasize;
		[metexscroller setKnobProportion:value];
		[metexscroller setEnabled:YES];
		startpos = (datasize - x) * [metexscroller doubleValue];
	} else {
		[metexscroller setEnabled:NO];
		startpos = 0;
	}
	
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
	NSRect therect = [self frame];
	int x = therect.size.width - OFFSETX * 2;

	if(msec == 0) {
		if(protdata != NULL)
			free(protdata);
		datasize = 0;
		protdata = malloc(sizeof(double)*1024);
		buffersize = 1024;
		[metexscroller setEnabled:NO];
		[metexscroller setDoubleValue:0.0];
	}
	if(datasize == buffersize) {
		// expand buffer
		double *newbuf = malloc(sizeof(double)*(buffersize+1024));
		memcpy(newbuf, protdata, buffersize*sizeof(double));
		free(protdata);
		protdata = newbuf;
		buffersize += 1024;
	}
	protdata[datasize] = data;
	++datasize;
	[self setNeedsDisplay:YES];
}

- (IBAction)scroll:(id)sender
{
	NSRect therect = [self frame];
	int x = therect.size.width - OFFSETX * 2;
	double curpos = [metexscroller doubleValue];

	int part = [sender hitPart];
	switch ( part ) {
		case NSScrollerKnob:
			break;
		case NSScrollerIncrementPage:
			if(datasize > x) {
				[metexscroller setDoubleValue:
				 (curpos+0.3 <= 1.0 ? curpos+0.3 : 1.0)];
			}
			break;
		case NSScrollerIncrementLine:
			if(datasize > x) {
				[metexscroller setDoubleValue:
				 (curpos+0.1 <= 1.0 ? curpos+0.1 : 1.0)];
			}
			break;
		case NSScrollerDecrementPage:
			if(datasize > x) {
				[metexscroller setDoubleValue:
				 (curpos-0.3 >= 0 ? curpos-0.3 : 0.0)];
			}
			break;
		case NSScrollerDecrementLine:
			if(datasize > x) {
				[metexscroller setDoubleValue:
				 (curpos-0.1 >= 0 ? curpos-0.1 : 0.0)];
			}
			break;
		case NSScrollerKnobSlot:
			break;
	}
	NSLog(@"%f", [metexscroller doubleValue]);
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
	int startpos;
	if(datasize < x)
		startpos = 0;
	else
		startpos = (datasize - x) * [metexscroller doubleValue];
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
//	[metexscroller setDoubleValue:value];
}

@end
