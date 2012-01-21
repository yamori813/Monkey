//
//  MonkeyAppDelegate.m
//  Monkey
//
//  Created by Hiroki Mori on 11/12/25.
//  Copyright 2011 Hiroki Mori. All rights reserved.
//

#import "MonkeyAppDelegate.h"

#import "MyDocument.h"

#include "monkey.h"

#include "iwasio.h"
#include "serial.h"
#include "ftgpib.h"

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
	ftgpib_close();

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
	NSData *wavedata;

	MyDocument *mydoc = [[MyDocument alloc] init];
	[mydoc makeWindowControllers];
	wavedata = (NSData *)que_wav(1);
	if(wavedata != NULL && [wavedata length] == 604) {
		[mydoc readFromData:wavedata ofType:@"CH1" error:NULL];
	}
	wavedata = (NSData *)que_wav(2);
	if(wavedata != NULL && [wavedata length] == 604) {
		[mydoc readFromData:wavedata ofType:@"CH2" error:NULL];
	}
	[mydoc showWindows];
}

//
//
//

- (IBAction)gpib_init:(id)sender
{
	ftgpib_init(0, 0);
	if([gpibren state] == NSOnState) {
		ftgpib_ren(0);
	}
}

- (IBAction)gpib_ren:(id)sender
{
	if([sender state] == NSOnState) {
		ftgpib_ren(0);
	} else {
		ftgpib_ren(1);
	}
}

- (IBAction)gpib_ifc:(id)sender
{
	ftgpib_ifc();
}

- (IBAction)gpib_dcl:(id)sender
{
	if(ftgpib_dcl() == 0) {
		printf("gpib error on dcl\n");
	}
}

- (IBAction)gpib_sdc:(id)sender
{
	if(ftgpib_sdc([gpibaddr intValue]) == 0) {
		printf("gpib error on sdc\n");
	}
}

- (IBAction)gpib_listen:(id)sender
{
	char buf[128];
	printf("gpib terget address = %d\n", [gpibaddr intValue]);
	ftgpib_debug();
	
	if(ftgpib_listen([gpibaddr intValue], buf, sizeof(buf), 1) == 0) {
		printf("gpib error on listen\n");
		return;
	}
	
	NSString *freqstr = [NSString stringWithCString:buf encoding:NSASCIIStringEncoding];
	[gpiblisten setStringValue:freqstr];
	printf("%s", buf);
}

- (IBAction)gpib_talk:(id)sender
{
	char buf[128];
	NSString *cmd = [gpibtalk stringValue];
	if([cmd length] > 100)
		return;
	printf("talk %s %s %s EOI\n",
		   [cmd cStringUsingEncoding:NSASCIIStringEncoding],
		   [gpiblineend indexOfSelectedItem] == 0 ? "LF" : "CR+LF", 
		   [gpibeoi state] == NSOnState ? "With": "Without");
	if([gpiblineend indexOfSelectedItem] == 0) {
		sprintf(buf, "%s\n", [cmd cStringUsingEncoding:NSASCIIStringEncoding]);
	} else {
		sprintf(buf, "%s\r\n", [cmd cStringUsingEncoding:NSASCIIStringEncoding]);
	}
	if(ftgpib_talk([gpibaddr intValue], buf, 
					 [sender state] == NSOnState ? 1 : 0) == 0) {
		printf("gpib error on talk\n");
		return;
	}
}

- (IBAction)gpib_test:(id)sender
{
	char buf[128];

	if(ftgpib_test([gpibaddr intValue], buf, sizeof(buf))) {
		NSString *freqstr = [NSString stringWithCString:buf encoding:NSASCIIStringEncoding];
		[gpiblisten setStringValue:freqstr];
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
			metexlasttime = 0;
		}
	} else {
		metex_willstop = 1;
		[sender setTitle:@"Start"];
	}
}

-(void)metex_poll
{
	measure_value data;
    NSAutoreleasePool* pool;
    pool = [[NSAutoreleasePool alloc]init];
	do {
		if(metex_value(&data)) {
			uint64_t curtime = mach_absolute_time();
			int msec = 0;
			if(metexlasttime != 0) {
				Nanoseconds elapsedNano;
				uint64_t tmptime = curtime - metexlasttime;
				elapsedNano = AbsoluteToNanoseconds( *(AbsoluteTime *) &tmptime );
				msec = *(uint64_t *)&elapsedNano;
				msec /= 1000*1000;
			} else {
				[metexview setScale:8.0 max:10.0];
			}
			[metexmeter setDoubleValue:data.value];
			[metexview addData:data.value time:msec];
			metexlasttime = curtime;
		}
//		printf("%f %d\n", data.value, data.unittype);
	} while(!metex_willstop);
	metex_close();
    [pool release];
    [NSThread exit];
}

@end
