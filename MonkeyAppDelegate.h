//
//  MonkeyAppDelegate.h
//  Monkey
//
//  Created by Hiroki Mori on 11/12/25.
//  Copyright 2011 Hiroki Mori. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "WaveDocument.h"
#import "TimeDocument.h"
#import "LogicDocument.h"

#import "TimeView.h"
#import "BigWindow.h"
#import "Iwatsu.h"

@interface MonkeyAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    IBOutlet NSWindow *wavewindow;
	IBOutlet NSPopUpButton *devSelect;
	IBOutlet NSPopUpButton *speedSelect;
	IBOutlet NSTextField *ch1scale;
	IBOutlet NSTextField *ch2scale;
	IBOutlet NSTextField *timescale;
	IBOutlet NSSegmentedControl *conSelect;
	int gridtype;

	IBOutlet NSTextField *gpibaddr;
	IBOutlet NSTextField *gpiblisten;
	IBOutlet NSTextField *gpibtalk;
	IBOutlet NSButton *gpibren;
	IBOutlet NSButton *gpibeoi;
	IBOutlet NSPopUpButton *gpiblineend;
	IBOutlet NSTextField *gpiomin;
	IBOutlet NSTextField *gpiomax;

	IBOutlet NSPopUpButton *metexDevSelect;
	IBOutlet NSTextField *metexmeter;
	IBOutlet NSTextField *metexunit;
	IBOutlet NSTextField *metexmin;
	IBOutlet NSTextField *metexmax;
	IBOutlet NSButton *metexget;
	IBOutlet NSButton *inductor;
	IBOutlet NSTextField *metexc;
	IBOutlet TimeView *metexview;
	uint64_t metexlasttime;
	
	TimeDocument *timedoc;
	TimeDocument *gpibdoc;

	IBOutlet NSPopUpButton *ch1Select;
	IBOutlet NSPopUpButton *ch2Select;
	IBOutlet NSPopUpButton *ch3Select;
	IBOutlet NSTextField *trigCount;
	IBOutlet NSPopUpButton *windowSelect;
	IBOutlet NSPopUpButton *samplingSelect;
	IBOutlet NSButton *lastart;

	IBOutlet NSMenuItem *voiceMenu;

	IBOutlet BigWindow *bigWin;
	
	int metex_willstop;
	Iwatsu *iwa;
	
	NSArray *idnarr;
}

- (IBAction)big:(id)sender;
- (IBAction)open:(id)sender;
- (IBAction)grid:(id)sender;
- (IBAction)keylock:(id)sender;
- (IBAction)autosetup:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)run:(id)sender;
- (IBAction)wave:(id)sender;

- (IBAction)gpib_init:(id)sender;
- (IBAction)gpib_ren:(id)sender;
- (IBAction)gpib_ifc:(id)sender;
- (IBAction)gpib_dcl:(id)sender;
- (IBAction)gpib_sdc:(id)sender;
- (IBAction)gpib_get:(id)sender;
- (IBAction)gpib_tct:(id)sender;
- (IBAction)gpib_listen:(id)sender;
- (IBAction)gpib_talk:(id)sender;
- (IBAction)gpib_start:(id)sender;
- (IBAction)gpib_close:(id)sender;

- (IBAction)metex_get:(id)sender;
- (IBAction)metex_action:(id)sender;

- (IBAction)logic_action:(id)sender;

@property (assign) IBOutlet NSWindow *window;

@end
