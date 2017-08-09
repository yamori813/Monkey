//
//  LogicWindowController.m
//  Monkey
//
//  Created by hiroki on 17/07/26.
//  Copyright 2017 __MyCompanyName__. All rights reserved.
//

#import "LogicWindowController.h"


@implementation LogicWindowController

- (id)initWithWindowNibName:(NSString *)windowNibName owner:(id)owner
{
    self = [super initWithWindowNibName:windowNibName owner:owner];
    if (self) {
		NSDate* date = [NSDate date];
		NSDateFormatter* fmt = [[[NSDateFormatter alloc]
								 initWithDateFormat:@"%Y%m%d-%H%M%S"
								 allowNaturalLanguage:YES] autorelease];
		titlestr = [NSString stringWithString:[fmt stringFromDate:date]];
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
	NSString *theArrow = [theEvent charactersIgnoringModifiers];
	unichar keyChar = 0;

	if ( [theArrow length] == 0 )
		return;            // reject dead keys
	
	if ( [theArrow length] == 1 ) {
		keyChar = [theArrow characterAtIndex:0];
		if ( keyChar == NSLeftArrowFunctionKey ) {
			printf("MORI MORI key\n");
			return;
		}
		
		if ( keyChar == NSRightArrowFunctionKey ) {
			printf("MORI MORI key\n");
			return;
		}
	}
	
	[super keyDown:theEvent];
}
@end
