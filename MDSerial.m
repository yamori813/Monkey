//
//  MDSerial.m
//  Monkey
//
//  Created by hiroki on 17/08/02.
//  Copyright 2017 __MyCompanyName__. All rights reserved.
//

#import "MDSerial.h"

@implementation MDSerial

static NSBundle* pluginBundle = nil;

+ (BOOL)initializeClass:(NSBundle*)theBundle {
	if (pluginBundle) {
		return NO;
	}
	pluginBundle = [theBundle retain];
	return YES;
}

+ (void)terminateClass {
	if (pluginBundle) {
		[pluginBundle release];
		pluginBundle = nil;
	}
}


- (id)init
{
    self = [super init];
    if(self != nil) {
		//your initialization here
		[NSBundle loadNibNamed:@"MDSerial" owner:self];
    }
    return self;
}

- (NSString *)pluginName
{
	return @"Serial";
}

- (IBAction)sheetButtonClicked:(id)sender
{
	if([[sender title] compare:@"OK"] == NSOrderedSame) {
		button = OK_BUTTON;
		ch = [channel intValue];
		baud = [baudrate intValue];
	} else {
		button = CANCEL_BUTTON;
	}

	[[NSApplication sharedApplication] stopModal];
	[sheetDialog orderOut:nil];
	[[NSApplication sharedApplication] endSheet: sheetDialog];
}

- (NSString *)decode:(NSData *)data info:(logic_info *)info window:(NSWindow *)window 
{
	char strbuf[32];
	
	[[NSApplication sharedApplication] beginSheet: sheetDialog
								   modalForWindow: window
									modalDelegate: nil
								   didEndSelector: nil
									  contextInfo: nil];
	
    // Display modal dialog
	[[NSApplication sharedApplication] runModalForWindow: sheetDialog];

	NSMutableString *result = [[NSMutableString alloc] init];

	unsigned char *ptr = [data bytes];
	if(button == OK_BUTTON) {
		int bitmask = 1 << (ch - 1);
		int bitlen = (1000 * 1000 * 1000 / baud) / (info->div / 50);
		int last = *ptr & bitmask;
		int lastpos = 0;
		++ptr;
		int stat = 0;	// 1 = start 2 = data 3 = stop
		int bitcount;
		int startpos;
		int bytedata;
		for(int i = 1; i < info->sample; ++i) {
			if(last != (*ptr & bitmask) || i == info->sample - 1) {
				if(stat == 0 && ((i - lastpos) / bitlen) > 0 && last == 0) {
					stat = 1;
					bitcount = ((i - lastpos) / bitlen) - 1;
					startpos = lastpos;
					bytedata = 0;
				} else if(stat == 1) {
					if(last) {
						int clen = (i - lastpos) / bitlen;
						if(clen + bitcount > 8)
							clen = 8 - bitcount;
						bytedata |= ((1 << clen) - 1) << bitcount;
						bytedata &= 0xff;
					}
					bitcount += (i - lastpos)/ bitlen;
					if(bitcount > 8) {
						stat = 0;
						if([result length] !=0)
							[result appendString:[NSString stringWithCString:"," encoding:NSASCIIStringEncoding]];
						if(i - startpos > (bitlen * 11)) {
							sprintf(strbuf, "%d,%d,%02x", startpos, startpos + bitlen*10, bytedata);
						} else {
							sprintf(strbuf,"%d,%d,%02x", startpos, i - 1, bytedata);
						}
						[result appendString:[NSString stringWithCString:strbuf encoding:NSASCIIStringEncoding]];
					}
				}
				lastpos = i;
			}
			last = *ptr & bitmask;
			++ptr;
		}
		return result;
	}
	return nil;	
}
@end
