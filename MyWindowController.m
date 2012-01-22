//
//  MyWindowController.m
//  Monkey
//
//  Created by Hiroki Mori on 11/12/30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyWindowController.h"

@implementation MyWindowController

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
@end
