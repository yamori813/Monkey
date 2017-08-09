//
//  LogicWindowController.h
//  Monkey
//
//  Created by hiroki on 17/07/26.
//  Copyright 2017 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "LogicView.h"

@interface LogicWindowController : NSWindowController {
	NSString *titlestr;
	
	LogicView *logicview;
}

@end
