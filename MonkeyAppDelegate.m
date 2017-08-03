//
//  MonkeyAppDelegate.m
//  Monkey
//
//  Created by Hiroki Mori on 11/12/25.
//  Copyright 2011 Hiroki Mori. All rights reserved.
//

#import "MonkeyAppDelegate.h"

#import "Plugin.h"

#include "serial.h"
#include "ftgpib.h"
#include "gpibutil.h"
#include "metex.h"
#include "pickit2.h"

@implementation MonkeyAppDelegate

@synthesize window;

- (IBAction)plugin_action:(id)sender
{
	int i;
	
	for(i = 0; i < [pluginInstances count]; i++){
		if([[sender title] compare:[[pluginInstances objectAtIndex:i] pluginName]] == NSOrderedSame) {
			NSWindow *thewin = [[NSApplication sharedApplication] mainWindow];
			NSObject* doc = [[thewin windowController] document];
			NSString * className = NSStringFromClass([doc class]);
			LogicDocument *log = doc;
			NSData *data = [log getData];
			logic_info *info = [log getInfo];
			NSString *decstr = [[pluginInstances objectAtIndex:i] decode:data info:info window:thewin];
			
			if(decstr != nil) {
				NSString *title = [[thewin windowController] getTitle];
				DecodeDocument *logicdoc = [[DecodeDocument alloc] initWithTitle:title];
				[logicdoc readFromData:[NSData dataWithBytes:info length:sizeof(logic_info)]
								ofType:@"INFO" error:NULL];
				[logicdoc readFromData:[decstr dataUsingEncoding:NSUTF8StringEncoding]
								ofType:@"DATA" error:NULL];
				[logicdoc makeWindowControllers];
				[logicdoc showWindows];
			}
			
			break;
		}
	}

}

- (BOOL)validateUserInterfaceItem:(id )anItem
{
    if ([anItem action] == @selector(plugin_action:)) {
		NSWindow *thewin = [[NSApplication sharedApplication] mainWindow];
		NSObject* doc = [[thewin windowController] document];
		NSString * className = NSStringFromClass([doc class]);
		if(className != nil && [className compare:@"LogicDocument"] == NSOrderedSame) {
			return YES;
		} else {
			return NO;
		}
	}
    return YES;
}

- (Class)pluginClassAtPath:(NSString *) inPath
{
    NSBundle *pluginBundle = [NSBundle bundleWithPath:inPath];
    if (pluginBundle)
    {
        NSDictionary *pluginDict = [pluginBundle infoDictionary];
        NSString *pluginName = [pluginDict objectForKey:@"NSPrincipalClass"];
        Class pluginClass = [pluginBundle classNamed:pluginName];
        if ([pluginClass conformsToProtocol:@protocol (MDPluginProtocol)])
            return (pluginClass);
    }
    return (nil);
}

- (void)checkPlugins
{
	[pluginMenu removeAllItems];
	
    NSString *folderPath = [[NSBundle mainBundle] builtInPlugInsPath];
    if (folderPath)
    {
        NSEnumerator *enumerator = [[NSBundle pathsForResourcesOfType:@"bundle" inDirectory:folderPath] objectEnumerator];
        NSString *pluginPath;
        while ((pluginPath = [enumerator nextObject]))
        {
            Class pluginClass = [self pluginClassAtPath:pluginPath];
            if (pluginClass)
            {
				id pobj = [[pluginClass alloc] init];
				[pluginInstances addObject:pobj];
				NSString *name = [pobj pluginName];
				NSMenuItem *aMenu = [[NSMenuItem alloc] initWithTitle:name action:@selector( plugin_action: ) keyEquivalent:@""];
				[pluginMenu addItem:aMenu];
            }
        }
    }
}

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

	iwa = [[Iwatsu alloc] init];
	
	talkswitch = 0;

	pluginInstances = [[NSMutableArray alloc] init];
	[self checkPlugins];
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
	BOOL isopen = FALSE;
	if([conSelect selectedSegment] == 0) {
		if([iwa SerialOpen:(CFStringRef)[[devSelect selectedItem] title]
					 speed:[[[speedSelect selectedItem] title] intValue]] == TRUE) {
			isopen = TRUE;
		}
	} else if([conSelect selectedSegment] == 1) {
		if([iwa USBOpen] == TRUE) {
			isopen = TRUE;
		}
	} else {
		if([iwa SPPOpen] == TRUE) {
			isopen = TRUE;
		}
	}
	if(isopen == TRUE) {
		NSString *questr;
		questr = [iwa QueIDN];
		if(questr) {
			idnarr = [[NSArray arrayWithArray:[questr componentsSeparatedByString:@","]] retain];
		}
		
		questr = [iwa QueScale:1];
		if(questr) {
			[ch1scale setStringValue:questr];
		}
		questr = [iwa QueScale:2];
		if(questr) {
			[ch2scale setStringValue:questr];
		}	
		questr = [iwa QueTimeBaseScale];
		if(questr) {
			[timescale setStringValue:questr];
		}
		[sender setEnabled:NO];
	}
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

	WaveDocument *mydoc = [[WaveDocument alloc] init];
	[mydoc makeWindowControllers];
	ds5100_info info;
	strcpy(info.model, [[idnarr objectAtIndex:1] cStringUsingEncoding:NSASCIIStringEncoding]);
	strcpy(info.version, [[idnarr objectAtIndex:3] cStringUsingEncoding:NSASCIIStringEncoding]);
	info.ch1scale = [(NSString *)[iwa QueScale:1] doubleValue];
	info.ch2scale = [(NSString *)[iwa QueScale:2] doubleValue];
	info.ch1offset = [(NSString *)[iwa QueOffset:1] doubleValue];
	info.ch2offset = [(NSString *)[iwa QueOffset:2] doubleValue];
//	info.timebasescale = [(NSString *)[iwa QueTimeBaseScale] doubleValue];
	char *ptr = [(NSString *)[iwa QueTimeBaseScale] cStringUsingEncoding:NSASCIIStringEncoding];
	gpioval gpio = gpibstr2val(ptr);
	info.timebasescale = gpio.val;

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
//	printf("gpib terget address = %d\n", [gpibaddr intValue]);
//	ftgpib_debug();

#if 1
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
	gpioval gpib = gpibstr2val(buf);
	printf("%.*lf", gpib.edig > gpib.exp ? gpib.edig - gpib.exp : 0, gpib.val);
	if(talkswitch) {
		NSSpeechSynthesizer *synthesizer = [[NSSpeechSynthesizer alloc] init];
		[synthesizer setRate:140.0];
		[synthesizer startSpeakingString:[NSString stringWithFormat:@"%.*lf", 
										  gpib.edig > gpib.exp ? gpib.edig - gpib.exp : 0, gpib.val]];
	}
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

- (IBAction)gpib_start:(id)sender
{
	if([[sender title] compare:@"Start"] == NSOrderedSame) {
		gpibdoc = [[TimeDocument alloc] initWithScale:[gpiomin doubleValue] max:[gpiomax doubleValue]];
		[gpibdoc makeWindowControllers];
		[gpibdoc showWindows];
		[gpibdoc setUnit:UNIT_VOLT];
		[gpibdoc start:@selector(gpib_poll) src:self];
		[sender setTitle:@"Stop"];
	} else {
		[gpibdoc stop];
		[sender setTitle:@"Start"];
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

-(NSNumber *)gpib_poll
{
	char buf[128];
//	printf("gpib terget address = %d\n", [gpibaddr intValue]);
//	ftgpib_debug();
	
	if(ftgpib_listen([gpibaddr intValue], buf, sizeof(buf), 1) == 0) {
		printf("gpib error on listen\n");
		return;
	}
	
	NSString *freqstr = [NSString stringWithCString:buf encoding:NSASCIIStringEncoding];
	[gpiblisten setStringValue:freqstr];
	printf("%s", buf);

	gpioval gpib = gpibstr2val(buf);
	return [NSNumber numberWithDouble:gpib.val];
}


//
//
//

- (IBAction)metex_get:(id)sender
{
	if(metex_init((CFStringRef)[[metexDevSelect selectedItem] title])) {
		measure_value data;
		metex_value(&data, [inductor state] == NSOnState, [metexc doubleValue]);
		[metexmeter setStringValue:[NSString stringWithFormat:@"%.*lf", 
									data.edig, data.value]];
		[metexunit setStringValue:[NSString stringWithCString:unitstr(data.unittype) encoding:NSUTF8StringEncoding]];	
		metex_close();
		if(talkswitch) {
			NSSpeechSynthesizer *synthesizer = [[NSSpeechSynthesizer alloc] init];
			[synthesizer setRate:140.0];
			[synthesizer startSpeakingString:[NSString stringWithFormat:@"%.*lf", 
											  data.edig, data.value]];
		}
		
	}
}

- (IBAction)metex_action:(id)sender
{
	if([[sender title] compare:@"Start"] == NSOrderedSame) {
		if(metex_init((CFStringRef)[[metexDevSelect selectedItem] title])) {
			timedoc = [[TimeDocument alloc] initWithScale:[metexmin doubleValue] max:[metexmax doubleValue]];
			[timedoc makeWindowControllers];
			[timedoc showWindows];
			[timedoc setUnit:[self metex_unit]];
			[timedoc start:@selector(metex_poll) src:self];
			[sender setTitle:@"Stop"];
			[metexget setEnabled:NO];
		}
	} else {
//		metex_willstop = 1;
		[timedoc stop];
		[sender setTitle:@"Start"];
		metex_close();
		[metexget setEnabled:YES];
	}
}

-(int)metex_unit
{
	measure_value data;
	metex_value(&data, [inductor state] == NSOnState, [metexc doubleValue]);
	return data.unittype;
}

-(NSNumber *)metex_poll
{
	measure_value data;
	metex_value(&data, [inductor state] == NSOnState, [metexc doubleValue]);
	[metexmeter setDoubleValue:data.value];
	[metexunit setStringValue:[NSString stringWithCString:unitstr(data.unittype) encoding:NSUTF8StringEncoding]];
	return [NSNumber numberWithDouble:data.value];
}


-(void)logic_thread
{
    NSAutoreleasePool* pool;
    pool = [[NSAutoreleasePool alloc]init];
	if(pk2_usb_init()) {
		NSData *data = (NSData *)pk2_usb_start([ch1Select indexOfSelectedItem], [ch2Select indexOfSelectedItem], 
									  [ch3Select indexOfSelectedItem], [trigCount intValue],
									  [samplingSelect indexOfSelectedItem], [windowSelect indexOfSelectedItem]);
		if(data != nil) {
			int divlist[8] = {50, 100, 200, 500, 1000, 2000, 5000, 10000};
			int PostTrigCount[6] = {973, 523, 73, 1973, 2973, 3973};
			LogicDocument *logicdoc = [[LogicDocument alloc] init];
			logic_info info;
			strcpy(info.model, "PICkit 2");
			pk2_usb_version(&info.version);
			info.channel = 3;
			info.sample = 1024;
			info.div = divlist[[samplingSelect indexOfSelectedItem]];
			info.triggerpos = 1024 - PostTrigCount[[windowSelect indexOfSelectedItem]];
			[logicdoc readFromData:[NSData dataWithBytes:&info length:sizeof(logic_info)]
						 ofType:@"INFO" error:NULL];
			[logicdoc readFromData:data ofType:@"DATA" error:NULL];
			[logicdoc makeWindowControllers];
			[logicdoc showWindows];
		}
		pk2_usb_close();
	}
	[lastart setEnabled: YES];
    [pool release];
    [NSThread exit];
}

- (IBAction)logic_action:(id)sender
{
	if([ch1Select indexOfSelectedItem] == 0 && [ch2Select indexOfSelectedItem] == 0 &&
	   [ch3Select indexOfSelectedItem] == 0) {
		NSAlert *alert = [[NSAlert alloc] init];
		[alert setMessageText:@"Error"];
		[alert setInformativeText:@"Please set toriger"];
		[alert runModal];
		[alert release];
	} else {
		[NSThread detachNewThreadSelector:@selector(logic_thread)
								 toTarget:self withObject:nil];
		[sender setEnabled: NO];		
	}
}

- (IBAction)talk_action:(id)sender
{
	talkswitch = !talkswitch;
	if(talkswitch)
		[sender setState:NSOnState];
	else
		[sender setState:NSOffState];
}

@end
