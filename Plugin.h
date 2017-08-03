/*
 *  MDPlugin.h
 *  Monkey
 *
 *  Created by hiroki on 17/08/02.
 *  Copyright 2017 __MyCompanyName__. All rights reserved.
 *
 */

@protocol MDPluginProtocol

+ (BOOL)initializeClass:(NSBundle*)theBundle;
+ (void)terminateClass;

- (id)init;
- (NSString *)pluginName;
- (NSString *)decode:(NSData *)data info:(logic_info *)info window:(NSWindow *)window;

@end

