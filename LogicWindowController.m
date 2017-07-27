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

@end
