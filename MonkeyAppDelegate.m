//
//  MonkeyAppDelegate.m
//  Monkey
//
//  Created by Hiroki Mori on 11/12/25.
//  Copyright 2011 Hiroki Mori. All rights reserved.
//

#import "MonkeyAppDelegate.h"

#import "MyDocument.h"

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
}

- (IBAction)big:(id)sender
{
//	[bigWin setAlphaValue:0.7];

	NSSize screensize = [[NSScreen mainScreen] frame].size;
	[bigWin setFrame:NSMakeRect(100,
								screensize.height/2-100.0,
								screensize.width-200.0,
								200.0) display:NO];
	[bigWin makeKeyAndOrderFront:nil];
	NSLog(@"%f", screensize.width);
}

- (IBAction)open:(id)sender
{
	iwa = [[Iwatsu alloc] init];
	if([conSelect selectedSegment] == 0) {
	[iwa SerialOpen:(CFStringRef)[[devSelect selectedItem] title]
			  speed:[[[speedSelect selectedItem] title] intValue]];
	} else if([conSelect selectedSegment] == 1) {
		[iwa USBOpen];
	} else {
		[iwa SPPOpen];
	}
	NSString *scalestr;
	scalestr = [iwa QueScale:1];
	if(scalestr) {
		[ch1scale setStringValue:scalestr];
	}
	scalestr = [iwa QueScale:2];
	if(scalestr) {
		[ch2scale setStringValue:scalestr];
	}	
	scalestr = [iwa QueTimeBaseScale];
	if(scalestr) {
		[timescale setStringValue:scalestr];
	}
	[sender setEnabled:NO];
}

- (void) applicationWillTerminate:(NSNotification *)aNotification
{
	ftgpib_close();

	[iwa Close];
}

- (IBAction)dummy:(id)sender
{
}

- (IBAction)grid:(id)sender
{
	++gridtype;
	if(gridtype == 3)
		gridtype = 0;
	[iwa CmdGrid:gridtype];
}

- (IBAction)autosetup:(id)sender
{
	[iwa CmdAuto];
}

- (IBAction)keylock:(id)sender
{
	[iwa CmdKeyLock:0];
}

- (IBAction)stop:(id)sender
{
	[iwa CmdStop];
}

- (IBAction)run:(id)sender
{
	[iwa CmdAuto];
}

- (IBAction)wave:(id)sender
{
	NSData *wavedata;

	MyDocument *mydoc = [[MyDocument alloc] init];
	[mydoc makeWindowControllers];
	ds5100_info info;
	info.ch1scale = [(NSString *)[iwa QueScale:1] doubleValue];
	info.ch2scale = [(NSString *)[iwa QueScale:2] doubleValue];
	info.ch1offset = [(NSString *)[iwa QueOffset:1] doubleValue];
	info.ch2offset = [(NSString *)[iwa QueOffset:2] doubleValue];
	info.timebasescale = [(NSString *)[iwa QueTimeBaseOffset] doubleValue];

	[mydoc readFromData:[NSData dataWithBytes:&info length:sizeof(ds5100_info)]
				 ofType:@"INFO" error:NULL];
	wavedata = (NSData *)[iwa Wave:1];
	if(wavedata != NULL && [wavedata length] == 604) {
		[mydoc readFromData:wavedata ofType:@"CH1" error:NULL];
	}
	wavedata = (NSData *)[iwa Wave:2];
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

- (IBAction)gpib_get:(id)sender
{
	if(ftgpib_get([gpibaddr intValue]) == 0) {
		printf("gpib error on get\n");
	}
}

- (IBAction)gpib_tct:(id)sender
{
	if(ftgpib_tct([gpibaddr intValue]) == 0) {
		printf("gpib error on tct\n");
	}
}

- (IBAction)gpib_listen:(id)sender
{
	char buf[128];
	printf("gpib terget address = %d\n", [gpibaddr intValue]);
	ftgpib_debug();

#if 0
	if(ftgpib_listen([gpibaddr intValue], buf, sizeof(buf), 1) == 0) {
		printf("gpib error on listen\n");
		return;
	}
#else
	if(ftgpib_856g([gpibaddr intValue], buf, sizeof(buf)) == 0) {
		printf("gpib error on listen\n");
		return;
	}
#endif
	
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
	}
}

- (IBAction)gpib_test:(id)sender
{
	char buf[128];

	if(ftgpib_tr5822([gpibaddr intValue], buf, sizeof(buf))) {
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
	int interval = 0;
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
//				[metexview setScale:11.0 max:13.0];
				[metexview setScale:0.0 max:200000.0];
			}
			[metexmeter setDoubleValue:data.value];
			[metexview addData:data.value time:msec];
			metexlasttime = curtime;
			if((interval % 10) == 0) {
				printf("speech %f\n", data.value);
				NSSpeechSynthesizer *synthesizer = [[NSSpeechSynthesizer alloc] init];
				[synthesizer startSpeakingString:[NSString stringWithFormat:@"%d", (int)data.value]];
			}
			++interval;
		}
//		printf("%f %d\n", data.value, data.unittype);
	} while(!metex_willstop);
	metex_close();
    [pool release];
    [NSThread exit];
}
@end
