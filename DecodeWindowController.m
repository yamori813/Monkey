//
//  DecodeWindowController.m
//  Monkey
//
//  Created by hiroki on 17/08/03.
//  Copyright 2017 __MyCompanyName__. All rights reserved.
//

#import "DecodeWindowController.h"


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

@end
