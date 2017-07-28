//
//  LogicView.m
//  Monkey
//
//  Created by hiroki on 17/07/26.
//  Copyright 2017 __MyCompanyName__. All rights reserved.
//

#import "LogicView.h"

#import "LogicDocument.h"

#define OFFSETX 40
#define OFFSETY 40

#define CHANNEL 3

@implementation LogicView

static CGRect convertToCGRect(NSRect inRect)
{
    return CGRectMake(inRect.origin.x, inRect.origin.y, inRect.size.width, inRect.size.height);
}

- (void)drawScale:(NSSize) size
{
	char strbuf[32];
	int i, j;
	int x = size.width - OFFSETX * 2;
	int y = size.height - OFFSETY * 2;
	for(j = 0;j <= CHANNEL; ++j) {
		CGContextSetRGBStrokeColor( gc, 255, 255, 255, 0.6);
		CGContextMoveToPoint(gc, OFFSETX, OFFSETY + j * y / CHANNEL);
		CGContextAddLineToPoint(gc, OFFSETX + x, OFFSETY + j * y / CHANNEL);
		CGContextStrokePath(gc);
	}
	CGContextSetRGBStrokeColor( gc, 255, 255, 255, 0.6);
	CGContextMoveToPoint(gc, OFFSETX, OFFSETY);
	CGContextAddLineToPoint(gc, OFFSETX, OFFSETY + y);
	CGContextStrokePath(gc);
	CGContextMoveToPoint(gc, OFFSETX+x, OFFSETY);
	CGContextAddLineToPoint(gc, OFFSETX+x, OFFSETY + y);
	CGContextStrokePath(gc);
	
	CGContextSetTextDrawingMode(gc, kCGTextFill);
	CGContextSelectFont(gc, "Geneva", 20, kCGEncodingMacRoman);
	CGContextSetTextMatrix(gc, CGAffineTransformMakeScale(1.0, 1.0));
	
	CGContextSetRGBFillColor( gc,256/255.0f,128/255.0f,0/255.0f,1.0f);
	strcpy(strbuf, "Monkey");
	CGContextShowTextAtPoint(gc, 20, y + OFFSETY + 16, strbuf, strlen(strbuf));

	LogicDocument *thedoc = [[[self window] windowController] document];
	logic_info *info = [thedoc getInfo];
	CGContextSelectFont(gc, "Geneva", 14, kCGEncodingMacRoman);
	CGContextShowTextAtPoint(gc, 900, y + OFFSETY + 16, info->model, strlen(info->model));
	CGContextShowTextAtPoint(gc, 1000, y + OFFSETY + 16, info->version, strlen(info->version));	
	
	CGContextSetRGBFillColor( gc,255/255.0f,255/255.0f,255/255.0f,1.0f);
	if(info->div >= 1000) {
		sprintf(strbuf, "%d ms/Dvi", (int)info->div/1000);
	} else {
		sprintf(strbuf, "%d us/Dvi", (int)info->div);
	}
	CGContextShowTextAtPoint(gc, OFFSETX, 16, strbuf, strlen(strbuf));
	
	int chhight = y / CHANNEL;

	for(j = 1; j <= x / 10; j += 1) {
		for(i = 1; i <= CHANNEL; ++i) {
			CGContextSetRGBStrokeColor( gc, 255, 255, 255, 0.6);
			CGContextMoveToPoint(gc, OFFSETX + j*10, OFFSETY + chhight*i);
			if(j % 5 == 0)
				CGContextAddLineToPoint(gc, OFFSETX + j*10, OFFSETY + chhight*i-15);
			else
				CGContextAddLineToPoint(gc, OFFSETX + j*10, OFFSETY + chhight*i-10);
			CGContextStrokePath(gc);
		}
	}

	CGContextSetTextDrawingMode(gc, kCGTextFill);
	CGContextSelectFont(gc, "Geneva", 16, kCGEncodingMacRoman);
	CGContextSetTextMatrix(gc, CGAffineTransformMakeScale(1.0, 1.0));
	CGContextSetRGBFillColor( gc,255/255.0f,255/255.0f,255/255.0f,1.0f);
	for(i = 1; i <= CHANNEL; ++i) {
		sprintf(strbuf, "Ch%d", i);
		CGContextShowTextAtPoint(gc, 4, OFFSETY + (chhight / 2) * ((CHANNEL - i) * 2 + 1) - 4, strbuf, strlen(strbuf));
	}
	
}

#define LOOFFSET	20
#define HIOFFSET	90

- (void)plotData:(NSSize) size
{
	int x = size.width - OFFSETX * 2;
	int y = size.height - OFFSETY * 2;

	LogicDocument *thedoc = [[[self window] windowController] document];
	NSData *data = [thedoc getData];
	
	int chhight = y / CHANNEL;
	
	logic_info *info = [thedoc getInfo];
	
	if(info->triggerpos > 0) {
		CGContextSetRGBStrokeColor( gc, 255, 0, 0, 1.0);
		CGContextMoveToPoint(gc, OFFSETX + info->triggerpos, OFFSETY);
		CGContextAddLineToPoint(gc, OFFSETX + info->triggerpos, OFFSETY + y);
		CGContextStrokePath(gc);
	}

	const char *bytes = [data bytes];
	CGContextSetRGBStrokeColor(
							   gc,127/255.0f,246/255.0f,85/255.0f,1.0f);

	for(int j = 0;j < CHANNEL; ++j) {
		int bit = 1 << j;
		int off = CHANNEL - j - 1;
		if(bytes[0] & bit)
			CGContextMoveToPoint(gc, OFFSETX+1, OFFSETY + chhight * off + HIOFFSET); 
		else
			CGContextMoveToPoint(gc, OFFSETX+1, OFFSETY + chhight * off + LOOFFSET); 
		for (int i = 1; i < [data length]; i++)
		{
			if(bytes[i] & bit)
				CGContextAddLineToPoint(gc, OFFSETX+i*2+1, OFFSETY + chhight * off + HIOFFSET); 
			else
				CGContextAddLineToPoint(gc, OFFSETX+i*2+1, OFFSETY + chhight * off + LOOFFSET); 
			
		}
		CGContextStrokePath(gc);
	}

	
}

- (void)drawRect:(NSRect)rect
{
	
    gc = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSetGrayFillColor(gc, 0.0, 1.0);
	//	CGContextSetGrayFillColor(gc, 1.0, 1.0);
	CGContextFillRect(gc, convertToCGRect(rect));
	[self drawScale:rect.size];
	[self plotData:rect.size];
}

@end
