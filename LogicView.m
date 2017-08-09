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

	LogicDocument *thedoc = [[[self window] windowController] document];
	logic_info *info = [thedoc getInfo];
	
	for(j = 0;j <= info->channel; ++j) {
		CGContextSetRGBStrokeColor( gc, 255, 255, 255, 0.6);
		CGContextMoveToPoint(gc, OFFSETX, OFFSETY + j * y / info->channel);
		CGContextAddLineToPoint(gc, OFFSETX + x, OFFSETY + j * y / info->channel);
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

	CGContextSelectFont(gc, "Geneva", 14, kCGEncodingMacRoman);
	CGContextShowTextAtPoint(gc, OFFSETX + x - 100, y + OFFSETY + 16, info->model, strlen(info->model));
	CGContextShowTextAtPoint(gc, OFFSETX + x - 40, y + OFFSETY + 16, info->version, strlen(info->version));	
	
	CGContextSetRGBFillColor( gc,255/255.0f,255/255.0f,255/255.0f,1.0f);
	if(info->div >= 1000) {
		sprintf(strbuf, "%d ms/Div", (int)info->div/1000);
	} else {
		sprintf(strbuf, "%d us/Div", (int)info->div);
	}
	CGContextShowTextAtPoint(gc, OFFSETX, 16, strbuf, strlen(strbuf));
	
	int chhight = y / info->channel;
	int scale = chhight / 10;
	int dvi = 3 * chhight / 20;
	
	for(j = 1; j <= x / 10; j += 1) {
		for(i = 1; i <= info->channel; ++i) {
			CGContextSetRGBStrokeColor( gc, 255, 255, 255, 0.6);
			CGContextMoveToPoint(gc, OFFSETX + j*10, OFFSETY + chhight*i);
			if(j % 5 == 0)
				CGContextAddLineToPoint(gc, OFFSETX + j*10, OFFSETY + chhight*i-dvi);
			else
				CGContextAddLineToPoint(gc, OFFSETX + j*10, OFFSETY + chhight*i-scale);
			CGContextStrokePath(gc);
		}
	}

	CGContextSetTextDrawingMode(gc, kCGTextFill);
	CGContextSelectFont(gc, "Geneva", 16, kCGEncodingMacRoman);
	CGContextSetTextMatrix(gc, CGAffineTransformMakeScale(1.0, 1.0));
	CGContextSetRGBFillColor( gc,255/255.0f,255/255.0f,255/255.0f,1.0f);
	for(i = 1; i <= info->channel; ++i) {
		sprintf(strbuf, "Ch%d", i);
		CGContextShowTextAtPoint(gc, 4, OFFSETY + (chhight / 2) * ((info->channel - i) * 2 + 1) - 4, strbuf, strlen(strbuf));
	}
	
}

- (IBAction)scroll:(id)sender
{
	NSRect therect = [self frame];
	int x = therect.size.width - OFFSETX * 2;
	double curpos = [logicScroller doubleValue];
	LogicDocument *thedoc = [[[self window] windowController] document];
	logic_info *info = [thedoc getInfo];
	
	int part = [sender hitPart];
	switch ( part ) {
		case NSScrollerKnob:
			break;
		case NSScrollerIncrementPage:
			[logicScroller setDoubleValue:
			 (curpos+0.3 <= 1.0 ? curpos+0.3 : 1.0)];
			break;
		case NSScrollerIncrementLine:
			[logicScroller setDoubleValue:
			 (curpos+0.1 <= 1.0 ? curpos+0.1 : 1.0)];
			break;
		case NSScrollerDecrementPage:
			[logicScroller setDoubleValue:
			 (curpos-0.3 >= 0 ? curpos-0.3 : 0.0)];
			break;
		case NSScrollerDecrementLine:
			[logicScroller setDoubleValue:
			 (curpos-0.1 >= 0 ? curpos-0.1 : 0.0)];
			break;
		case NSScrollerKnobSlot:
			break;
	}
	startpos = (info->sample - x) * [logicScroller doubleValue];
	[self setNeedsDisplay:YES];
}

- (void)plotData:(NSSize) size
{
	int x = size.width - OFFSETX * 2;
	int y = size.height - OFFSETY * 2;

	LogicDocument *thedoc = [[[self window] windowController] document];
	NSData *data = [thedoc getData];
	
	logic_info *info = [thedoc getInfo];

	if(info->sample > x) {
		if([logicScroller isEnabled] == NO) {
			[logicScroller setEnabled:YES];
			//			[logicScroller setDoubleValue:0.0];
			[logicScroller setDoubleValue:((float)info->triggerpos - 50)/ info->sample];
			startpos = info->triggerpos - 50;
		} else {
			double value = (double)x / info->sample;
			[logicScroller setKnobProportion:value];
			if([logicScroller doubleValue] == 1.0) {
				startpos = (info->sample - x) * [logicScroller doubleValue];
			}
		}
	} else {
		[logicScroller setEnabled:NO];
		startpos = 0;
	}
	
	int chhight = y / info->channel;
	int looffset = 2 * chhight / 10;
	int hihight = 8 * chhight / 10;

	if(info->triggerpos > startpos && info->triggerpos < startpos + x) {
		int curpos = info->triggerpos - startpos;
		CGContextSetRGBStrokeColor( gc, 255, 0, 0, 1.0);
		CGContextMoveToPoint(gc, OFFSETX + curpos, OFFSETY);
		CGContextAddLineToPoint(gc, OFFSETX + curpos, OFFSETY + y);
		CGContextStrokePath(gc);

		CGContextSetRGBFillColor( gc,255/255.0f,0/255.0f,0/255.0f,1.0f);
		CGMutablePathRef pathRef = CGPathCreateMutable();
		CGPathMoveToPoint(pathRef, NULL, OFFSETX + curpos, OFFSETY);
		CGPathAddLineToPoint(pathRef, NULL, OFFSETX + curpos+5, OFFSETY + 12);
		CGPathAddLineToPoint(pathRef, NULL, OFFSETX + curpos-5, OFFSETY + 12);
		CGPathAddLineToPoint(pathRef, NULL, OFFSETX + curpos, OFFSETY);
		CGContextAddPath(gc, pathRef);
		CGContextFillPath(gc);
		CGPathRelease(pathRef);

		pathRef = CGPathCreateMutable();
		CGPathMoveToPoint(pathRef, NULL, OFFSETX + curpos, OFFSETY + y);
		CGPathAddLineToPoint(pathRef, NULL, OFFSETX + curpos+5, OFFSETY + y - 12);
		CGPathAddLineToPoint(pathRef, NULL, OFFSETX + curpos-5, OFFSETY + y - 12);
		CGPathAddLineToPoint(pathRef, NULL, OFFSETX + curpos, OFFSETY + y);
		CGContextAddPath(gc, pathRef);
		CGContextFillPath(gc);
		CGPathRelease(pathRef);
	}

	const char *bytes = [data bytes] + startpos;
	CGContextSetRGBStrokeColor(
							   gc,127/255.0f,246/255.0f,85/255.0f,1.0f);

	for(int j = 0;j < info->channel; ++j) {
		int lastbit;
		int bit = 1 << j;
		int off = info->channel - j - 1;
		if(bytes[0] & bit)
			CGContextMoveToPoint(gc, OFFSETX, OFFSETY + chhight * off + hihight); 
		else
			CGContextMoveToPoint(gc, OFFSETX, OFFSETY + chhight * off + looffset); 
		lastbit = bytes[0] & bit;
		int sample = info->sample < x ? info->sample : x;
		for (int i = 1; i < sample; i++)
		{
			if((bytes[i] & bit) == lastbit) {
				if(bytes[i] & bit)
					CGContextAddLineToPoint(gc, OFFSETX+i, OFFSETY + chhight * off + hihight); 
				else
					CGContextAddLineToPoint(gc, OFFSETX+i, OFFSETY + chhight * off + looffset); 
			} else {
				if(bytes[i] & bit) {
					CGContextAddLineToPoint(gc, OFFSETX+i, OFFSETY + chhight * off + looffset); 
					CGContextAddLineToPoint(gc, OFFSETX+i, OFFSETY + chhight * off + hihight); 
				} else {
					CGContextAddLineToPoint(gc, OFFSETX+i, OFFSETY + chhight * off + hihight); 
					CGContextAddLineToPoint(gc, OFFSETX+i, OFFSETY + chhight * off + looffset); 
				}
			}
			lastbit = bytes[i] & bit;	
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
