//
//  MonkeyAppDelegate.h
//  Monkey
//
//  Created by Hiroki Mori on 11/12/25.
//  Copyright 2011 Hiroki Mori. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MonkeyAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    IBOutlet NSWindow *wavewindow;
	IBOutlet NSPopUpButton *devSelect;
	IBOutlet NSPopUpButton *speedSelect;
	IBOutlet NSTextField *ch1scale;
	IBOutlet NSTextField *ch2scale;
	IBOutlet NSTextField *timescale;
	int gridtype;

	IBOutlet NSTextField *trfreq;

	IBOutlet NSPopUpButton *metexDevSelect;
	IBOutlet NSTextField *metexmeter;
	
	int metex_willstop;
}

- (IBAction)open:(id)sender;
- (IBAction)grid:(id)sender;
- (IBAction)keylock:(id)sender;
- (IBAction)autosetup:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)run:(id)sender;
- (IBAction)wave:(id)sender;

- (IBAction)gpib_init:(id)sender;
- (IBAction)gpib_test:(id)sender;
- (IBAction)gpib_close:(id)sender;

- (IBAction)metex_action:(id)sender;

@property (assign) IBOutlet NSWindow *window;

@end
