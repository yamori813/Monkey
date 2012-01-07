//
//  MonkeyAppDelegate.m
//  Monkey
//
//  Created by Hiroki Mori on 11/12/25.
//  Copyright 2011 Hiroki Mori. All rights reserved.
//

#import "MonkeyAppDelegate.h"

#import "MyDocument.h"

#include "iwasio.h"
#include "serial.h"

@implementation MonkeyAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	
	NSMutableArray *ifList = [[ NSMutableArray alloc ] init];
	
    io_iterator_t	serialPortIterator;
    FindModems(&serialPortIterator);
    GetModemPath(serialPortIterator, (CFMutableArrayRef)ifList);
	if([ ifList count]) {
        [ devSelect addItemsWithTitles : ifList];
        [ devSelect setEnabled : true];
        [ metexDevSelect addItemsWithTitles : ifList];
        [ metexDevSelect setEnabled : true];
	}
	gridtype = 0;
	NSLog(@"MORI MORI Debug");
}

- (IBAction)open:(id)sender
{
	if(iwatsu_init((CFStringRef)[[devSelect selectedItem] title], 
				   [[[speedSelect selectedItem] title] intValue])) {
		NSString *scalestr;
		scalestr = (NSString *)que_scale(1);
		if(scalestr) {
			[ch1scale setStringValue:scalestr];
		}
		scalestr = (NSString *)que_scale(2);
		if(scalestr) {
			[ch2scale setStringValue:scalestr];
		}	
		scalestr = (NSString *)que_timebasescale();
		if(scalestr) {
			[timescale setStringValue:scalestr];
		}
	}
}

- (void) applicationWillTerminate:(NSNotification *)aNotification
{
	iwatsu_close();
}

- (IBAction)grid:(id)sender
{
	++gridtype;
	if(gridtype == 3)
		gridtype = 0;
	cmd_grid(gridtype);
}

- (IBAction)autosetup:(id)sender
{
	cmd_auto();
}

- (IBAction)keylock:(id)sender
{
	cmd_keylock(0);
}

- (IBAction)stop:(id)sender
{
	cmd_stop();
}

- (IBAction)run:(id)sender
{
	cmd_run();
}

- (IBAction)wave:(id)sender
{
//	NSData *wavedata = [[NSData alloc] init];
	NSData *wavedata = (NSData *)que_wav(1);
	if(wavedata != NULL && [wavedata length] == 604) {
		MyDocument *mydoc = [[MyDocument alloc] init];
		[mydoc makeWindowControllers];
		[mydoc readFromData:wavedata ofType:@"WAVE" error:NULL];
		[mydoc showWindows];
	}
}

//
//
//

- (IBAction)gpib_init:(id)sender
{
	ftgpib_init(0);
}
- (IBAction)gpib_test:(id)sender
{
	char buf[128];
	if(ftgpib_test([gpibaddr intValue], buf)) {
		NSString *freqstr = [NSString stringWithCString:buf encoding:NSASCIIStringEncoding];
		[trfreq setStringValue:freqstr];
	}	
}
- (IBAction)gpib_close:(id)sender
{
	ftgpib_close();
}

//
//
//

- (IBAction)metex_action:(id)sender
{
	if([[sender title] compare:@"Start"] == NSOrderedSame) {
		if(metex_init((CFStringRef)[[metexDevSelect selectedItem] title])) {
			[NSThread detachNewThreadSelector:@selector(metex_poll)
									 toTarget:self withObject:nil];
			[sender setTitle:@"Stop"];
			metex_willstop = 0;
		}
	} else {
		metex_willstop = 1;
		[sender setTitle:@"Start"];
	}
}


-(void)metex_poll
{
	unsigned char buf[32];

    NSAutoreleasePool* pool;
    pool = [[NSAutoreleasePool alloc]init];
	do {
		if(metex_read(buf, sizeof(buf), sizeof(buf))) {
			int value = (buf[1] - '0') * 1000 + (buf[2] - '0') * 100 + (buf[3] - '0') * 10 + (buf[4] - '0');
			[metexmeter setIntValue:value];
		}
	} while(!metex_willstop);
	metex_close();
    [pool release];
    [NSThread exit];
}
@end
