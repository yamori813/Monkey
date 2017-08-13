//
//  DecodeWindowController.m
//  Monkey
//
//  Created by hiroki on 17/08/03.
//  Copyright 2017 __MyCompanyName__. All rights reserved.
//

#import "DecodeWindowController.h"

#import "DecodeDocument.h"

@implementation DecodeWindowController

- (id)initWithWindowNibName:(NSString *)windowNibName title:(NSString *)title owner:(id)owner
{
    self = [super initWithWindowNibName:windowNibName owner:owner];
    if (self) {
		/*
		NSDate* date = [NSDate date];
		NSDateFormatter* fmt = [[[NSDateFormatter alloc]
								 initWithDateFormat:@"%Y%m%d-%H%M%S"
								 allowNaturalLanguage:YES] autorelease];
		titlestr = [NSString stringWithString:[fmt stringFromDate:date]];
		 */
		titlestr = [NSString stringWithFormat:@"%@-d", title];
    }
    return self;
}

-(NSString*)windowTitleForDocumentDisplayName:(NSString*)displayName
{
	return titlestr;
}

-(NSString*)getTitle
{
	return titlestr;
}

- (void)keyDown:(NSEvent *)theEvent {
	DecodeDocument *thedoc = [self  document];
	
	if (([theEvent modifierFlags] & NSCommandKeyMask) == NSCommandKeyMask) {
		if ([[theEvent charactersIgnoringModifiers] isEqualToString:@"+"]) {
			[[thedoc getImageView] setzoom:2];
			return;
		}
		if ([[theEvent charactersIgnoringModifiers] isEqualToString:@"-"]) {
			[[thedoc getImageView] setzoom:1];
			return;
		}
	} else {
		NSString *theArrow = [theEvent charactersIgnoringModifiers];
		unichar keyChar = 0;
		
		if ( [theArrow length] == 0 )
			return;            // reject dead keys
		
		
		if ( [theArrow length] == 1 ) {
			keyChar = [theArrow characterAtIndex:0];
			if ( keyChar == NSLeftArrowFunctionKey ) {
				if (([theEvent modifierFlags] & NSShiftKeyMask) == NSShiftKeyMask) {
					[[thedoc getImageView] keyevent:3];
				} else {
					[[thedoc getImageView] keyevent:1];
				}
				return;
			}
			
			if ( keyChar == NSRightArrowFunctionKey ) {
				if (([theEvent modifierFlags] & NSShiftKeyMask) == NSShiftKeyMask) {
					[[thedoc getImageView] keyevent:4];
				} else {
					[[thedoc getImageView] keyevent:2];
				}
				return;
			}
		}
	}
	
	[super keyDown:theEvent];
}

- (void)scrollWheel:(NSEvent *)theEvent {
	DecodeDocument *thedoc = [self  document];
	
	if([theEvent deltaX] > 1)
		[[thedoc getImageView] keyevent:1];
	if([theEvent deltaX] < -1)
		[[thedoc getImageView] keyevent:2];
}
@end
