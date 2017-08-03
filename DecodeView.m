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
	CGContextShowTextAtPoint(gc, 900, y + OFFSETY + 16, info->model, strlen(info->model));
	CGContextShowTextAtPoint(gc, 1000, y + OFFSETY + 16, info->version, strlen(info->version));	
	
	CGContextSetRGBFillColor( gc,255/255.0f,255/255.0f,255/255.0f,1.0f);
	if(info->div >= 1000) {
		sprintf(strbuf, "%d ms/Div", (int)info->div/1000);
	} else {
		sprintf(strbuf, "%d us/Div", (int)info->div);
	}
	CGContextShowTextAtPoint(gc, OFFSETX, 16, strbuf, strlen(strbuf));
	
	for(j = 1; j <= x / 10; j += 1) {
		CGContextSetRGBStrokeColor( gc, 255, 255, 255, 0.6);
		CGContextMoveToPoint(gc, OFFSETX + j*10, OFFSETY + y);
		if(j % 5 == 0)
			CGContextAddLineToPoint(gc, OFFSETX + j*10, OFFSETY + y-15);
		else
			CGContextAddLineToPoint(gc, OFFSETX + j*10, OFFSETY + y-10);
		CGContextStrokePath(gc);
	}
	
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

#define LOOFFSET	15
#define HIOFFSET	85

- (void)plotDecode:(int)start end:(int)end str:(char *)str
{

	CGContextSetRGBStrokeColor( gc,142/255.0f,0/255.0f,204/255.0f,1.0f);

	CGContextMoveToPoint(gc, OFFSETX+start, OFFSETY + (HIOFFSET + LOOFFSET) / 2); 
	CGContextAddLineToPoint(gc, OFFSETX+start+10, OFFSETY +  HIOFFSET); 
	CGContextAddLineToPoint(gc, OFFSETX+end-10, OFFSETY +  HIOFFSET); 
	CGContextAddLineToPoint(gc, OFFSETX+end, OFFSETY + (HIOFFSET + LOOFFSET) / 2); 
	CGContextAddLineToPoint(gc, OFFSETX+end-10, OFFSETY + LOOFFSET); 
	CGContextAddLineToPoint(gc, OFFSETX+start+10, OFFSETY + LOOFFSET); 
	CGContextAddLineToPoint(gc, OFFSETX+start, OFFSETY + (HIOFFSET + LOOFFSET) / 2); 
	CGContextStrokePath(gc);

	CGContextSetTextDrawingMode(gc, kCGTextFill);
	CGContextSelectFont(gc, "Geneva", 16, kCGEncodingMacRoman);
	CGContextSetTextMatrix(gc, CGAffineTransformMakeScale(1.0, 1.0));
	CGContextSetRGBFillColor( gc,255/255.0f,255/255.0f,255/255.0f,1.0f);
	CGContextShowTextAtPoint(gc, OFFSETX + start + (end - start) / 2 - 9,
							 OFFSETY + (HIOFFSET + LOOFFSET) / 2 - 6, str, strlen(str));
}

- (void)plotData:(NSSize) size
{
	int x = size.width - OFFSETX * 2;
	int y = size.height - OFFSETY * 2;
	
	DecodeDocument *thedoc = [[[self window] windowController] document];
	NSString *data = [thedoc getData];
	
	NSArray* values = [data componentsSeparatedByString:@","];

	for (int i = 0; i < values.count; i += 3)
	{
		[self plotDecode:[[values objectAtIndex:i] intValue]
					 end:[[values objectAtIndex:i+1] intValue]
					 str:[[values objectAtIndex:i+2] cStringUsingEncoding:NSASCIIStringEncoding]];
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
