//
//  TimeWindowController.m
//  Monkey
//
//  Created by hiroki on 15/01/03.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import "TimeWindowController.h"


@implementation TimeWindowController

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

@end
