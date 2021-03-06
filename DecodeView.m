//
//  DecodeView.m
//  Monkey
//
//  Created by hiroki on 17/08/03.
//  Copyright 2017 __MyCompanyName__. All rights reserved.
//

#import "DecodeView.h"

#import "DecodeDocument.h"

#define OFFSETX 40
#define OFFSETY 40

#define CHANNEL 3

@implementation DecodeView

static CGRect convertToCGRect(NSRect inRect)
{
    return CGRectMake(inRect.origin.x, inRect.origin.y, inRect.size.width, inRect.size.height);
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		zoom = 1;
    }
    return self;
}

- (void) keyevent:(int)key
{
	NSRect therect = [self frame];
	int x = therect.size.width - OFFSETX * 2;
	DecodeDocument *thedoc = [[[self window] windowController] document];
	logic_info *info = [thedoc getInfo];
	
	double curpos = [decodeScroller doubleValue];
	double scval = (double)x / (info->sample * 2 * zoom);   // 1/2 page
	
	if(key == 1) {
		[decodeScroller setDoubleValue:
		 (curpos >= scval ? curpos-scval : 0.0)];
	}
	if(key == 2) {
		[decodeScroller setDoubleValue:
		 (curpos <= 1.0 - scval ? curpos+scval : 1.0)];
	}
	if(key == 3) {
		[decodeScroller setDoubleValue:
		 (curpos >= scval*4 ? curpos-scval*4 : 0.0)];
	}
	if(key == 4) {
		[decodeScroller setDoubleValue:
		 (curpos <= 1.0 - scval*4 ? curpos+scval*4 : 1.0)];
	}
	startpos = ((info->sample * zoom - x) / zoom) * [decodeScroller doubleValue];
	[self setNeedsDisplay:YES];
}

- (IBAction)scroll:(id)sender
{
	NSRect therect = [self frame];
	int x = therect.size.width - OFFSETX * 2;
	double curpos = [decodeScroller doubleValue];
	DecodeDocument *thedoc = [[[self window] windowController] document];
	logic_info *info = [thedoc getInfo];
	
	int part = [sender hitPart];
	switch ( part ) {
		case NSScrollerKnob:
			break;
		case NSScrollerIncrementPage:
			[decodeScroller setDoubleValue:
			 (curpos+0.3 <= 1.0 ? curpos+0.3 : 1.0)];
			break;
		case NSScrollerIncrementLine:
			[decodeScroller setDoubleValue:
			 (curpos+0.1 <= 1.0 ? curpos+0.1 : 1.0)];
			break;
		case NSScrollerDecrementPage:
			[decodeScroller setDoubleValue:
			 (curpos-0.3 >= 0 ? curpos-0.3 : 0.0)];
			break;
		case NSScrollerDecrementLine:
			[decodeScroller setDoubleValue:
			 (curpos-0.1 >= 0 ? curpos-0.1 : 0.0)];
			break;
		case NSScrollerKnobSlot:
			break;
	}
	startpos = ((info->sample * zoom - x) / zoom) * [decodeScroller doubleValue];
	[self setNeedsDisplay:YES];
}


- (void)drawScale:(NSSize) size
{
	char strbuf[32];
	int i, j;
	int x = size.width - OFFSETX * 2;
	int y = size.height - OFFSETY * 2;
	for(j = 0;j <= 1; ++j) {
		CGContextSetRGBStrokeColor( gc, 255, 255, 255, 0.6);
		CGContextMoveToPoint(gc, OFFSETX, OFFSETY + j * y);
		CGContextAddLineToPoint(gc, OFFSETX + x, OFFSETY + j * y);
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
	
	DecodeDocument *thedoc = [[[self window] windowController] document];
	logic_info *info = [thedoc getInfo];
	CGContextSelectFont(gc, "Geneva", 14, kCGEncodingMacRoman);
	CGContextShowTextAtPoint(gc, OFFSETX + x - 100, y + OFFSETY + 16, info->model, strlen(info->model));
	CGContextShowTextAtPoint(gc, OFFSETX + x - 40, y + OFFSETY + 16, info->version, strlen(info->version));	
	CGContextSetRGBFillColor( gc,255/255.0f,255/255.0f,255/255.0f,1.0f);
	if(info->div >= 1000 * 1000) {
		sprintf(strbuf, "%d ms/Div", (int)info->div/(1000*1000));
	} else if(info->div >= 1000) {
			sprintf(strbuf, "%d us/Div", (int)info->div/1000);
	} else {
		sprintf(strbuf, "%d ns/Div", (int)info->div);
	}
	CGContextShowTextAtPoint(gc, OFFSETX, 16, strbuf, strlen(strbuf));
/*	
	for(j = 1; j <= x / 10; j += 1) {
		CGContextSetRGBStrokeColor( lgc, 255, 255, 255, 0.6);
		CGContextMoveToPoint(lgc, OFFSETX + j*10, OFFSETY + y);
		if(j % 5 == 0)
			CGContextAddLineToPoint(lgc, OFFSETX + j*10, OFFSETY + y-15);
		else
			CGContextAddLineToPoint(lgc, OFFSETX + j*10, OFFSETY + y-10);
		CGContextStrokePath(lgc);
	}
 */
	CGContextSetRGBStrokeColor( lgc, 255.0f, 255.0f, 255.0f, 0.6f);
	for(j = 1; j <= x / 10; j += 1) {
		CGContextMoveToPoint(lgc, j*10, y);
		if(j % 5 == 0)
			CGContextAddLineToPoint(lgc, j*10, y-15);
		else
			CGContextAddLineToPoint(lgc, j*10, y-10);
		CGContextStrokePath(lgc);
	}
	CGContextDrawLayerAtPoint (gc, CGPointMake(OFFSETX, OFFSETY),
							   lref);
	
	CGContextSetTextDrawingMode(gc, kCGTextFill);
	CGContextSelectFont(gc, "Geneva", 16, kCGEncodingMacRoman);
	CGContextSetTextMatrix(gc, CGAffineTransformMakeScale(1.0, 1.0));
	CGContextSetRGBFillColor( gc,255/255.0f,255/255.0f,255/255.0f,1.0f);
							 /*
	for(i = 1; i <= CHANNEL; ++i) {
		sprintf(strbuf, "Ch%d", i);
		CGContextShowTextAtPoint(gc, 4, OFFSETY + (chhight / 2) * ((CHANNEL - i) * 2 + 1) - 4, strbuf, strlen(strbuf));
	}
							  */
	
}

- (void)plotDecode:(NSSize) size start:(int)start end:(int)end str:(char *)str
{
	int x = size.width - OFFSETX * 2;
	int y = size.height - OFFSETY * 2;

	int looffset = 15;
	int hihight = y - 30;
	
	CGContextSetRGBStrokeColor( lgc,142/255.0f,0/255.0f,204/255.0f,1.0f);

	int spos = start - startpos;
	int epos = end - startpos;
	CGContextMoveToPoint(lgc, spos, (hihight + looffset) / 2); 
	CGContextAddLineToPoint(lgc, spos+10, hihight); 
	CGContextAddLineToPoint(lgc, epos-10, hihight); 
	CGContextAddLineToPoint(lgc, epos, (hihight + looffset) / 2); 
	CGContextAddLineToPoint(lgc, epos-10, looffset); 
	CGContextAddLineToPoint(lgc, spos+10, looffset); 
	CGContextAddLineToPoint(lgc, spos, (hihight + looffset) / 2); 
	CGContextStrokePath(lgc);

	CGContextSetTextDrawingMode(lgc, kCGTextFill);
	CGContextSelectFont(lgc, "Geneva", 16, kCGEncodingMacRoman);
	CGContextSetTextMatrix(lgc, CGAffineTransformMakeScale(1.0, 1.0));
	CGContextSetRGBFillColor( lgc,255/255.0f,255/255.0f,255/255.0f,1.0f);
	CGContextShowTextAtPoint(lgc, spos + (epos - spos) / 2 - 9,
							 (hihight + looffset) / 2 - 6, str, strlen(str));

	CGContextDrawLayerAtPoint (gc, CGPointMake(OFFSETX, OFFSETY),
							   lref);
}

- (void)plotData:(NSSize) size
{
	int x = size.width - OFFSETX * 2;
	int y = size.height - OFFSETY * 2;

	DecodeDocument *thedoc = [[[self window] windowController] document];
	NSString *data = [thedoc getData];
	
	logic_info *info = [thedoc getInfo];
	
	if(info->sample * zoom > x) {
		if([decodeScroller isEnabled] == NO) {
			[decodeScroller setEnabled:YES];
			//			[logicScroller setDoubleValue:0.0];
			[decodeScroller setDoubleValue:((float)info->triggerpos - 50)/ info->sample];
			double value = (double)x / (info->sample * zoom);
			[decodeScroller setKnobProportion:value];
			startpos = info->triggerpos - 50;
		} else {
			double value = (double)x / (info->sample * zoom);
			[decodeScroller setKnobProportion:value];
			if([decodeScroller doubleValue] == 1.0) {
				startpos = ((info->sample * zoom - x) / zoom)* [decodeScroller doubleValue];
			}
		}
	} else {
		[decodeScroller setEnabled:NO];
		startpos = 0;
	}
	
	NSArray* values = [data componentsSeparatedByString:@","];

	for (int i = 0; i < values.count; i += 3)
	{
		int spos = [[values objectAtIndex:i] intValue];
		int epos = [[values objectAtIndex:i+1] intValue];
		if((spos > startpos && spos < startpos + x) ||
		   (epos > startpos && epos < startpos + x)) {
		[self plotDecode:size
				   start:spos
					 end:epos
					 str:[[values objectAtIndex:i+2] cStringUsingEncoding:NSASCIIStringEncoding]];
		}
	}
}

- (void)drawRect:(NSRect)rect
{
    gc = [[NSGraphicsContext currentContext] graphicsPort];

	lref = CGLayerCreateWithContext(gc, 
											   CGSizeMake(rect.size.width - OFFSETX*2, rect.size.height - OFFSETY*2), NULL);
	if(lref != 0) {   // NULL at Application to background 
		lgc = CGLayerGetContext (lref);
		CGContextSetRGBFillColor (lgc, 0, 0, 0, 1);
		CGContextFillRect (lgc, CGRectMake(0,0,rect.size.width - OFFSETX*2, rect.size.height - OFFSETY*2));
		
		CGContextSetGrayFillColor(gc, 0.0, 1.0);
		//	CGContextSetGrayFillColor(gc, 1.0, 1.0);
		CGContextFillRect(gc, convertToCGRect(rect));
		[self drawScale:rect.size];
		[self plotData:rect.size];
		
		CGLayerRelease(lref);
	}
}

@end
