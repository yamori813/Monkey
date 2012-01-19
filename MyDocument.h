//
//  MyDocument.h
//  Untitled
//
//  Created by Hiroki Mori on 11/12/30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import <Cocoa/Cocoa.h>

#import "MyWindowController.h"


@interface MyDocument : NSDocument {
	NSData *myData;
	MyWindowController *myctl;
}

- (NSData *)getData;

@end
