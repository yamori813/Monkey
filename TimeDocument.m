//
//  TimeDocument.m
//  Monkey
//
//  Created by hiroki on 15/01/03.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import "TimeDocument.h"


@implementation TimeDocument

- (id)initWithScale:(double)min max:(double)max
{
    self = [super init];
    if (self) {
		minscale = min;
		maxscale = max;
	}
    return self;
}

-(void)setUnit:(int)utype
{
	unittype = utype;
}

-(double)min
{
	return minscale;
}

-(double)max
{
	return maxscale;
}

-(int)unit
{
	return unittype;
}

-(void)makeWindowControllers
{
	myctl = [[TimeWindowController alloc] initWithWindowNibName:@"TimeDocument" owner:self];
	[self addWindowController:myctl];
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

-(int)count
{
	return datasize;
}

-(double)value:(int)num
{
	return data[num];
}

-(void)poll:(NSTimer*)timer{
	double val = [[datasrc performSelector:sel] doubleValue];
	NSLog(@"MORI MORI poll %f\n", val);
	data[datasize] = val;
	++datasize;
	if(datasize == buffsize) {
		double *oldbuff = data;
		buffsize += 1024;
		data = malloc(sizeof(double) * buffsize);
		memcpy(data, oldbuff, datasize * sizeof(double));
		free(oldbuff);
	}
	[imgView setNeedsDisplay:YES];
}

-(void)start:(SEL)selector src:(id)src
{
	polltimer = [NSTimer scheduledTimerWithTimeInterval:0.1
											  target:self
											selector:@selector(poll:)
											userInfo:nil
											 repeats:YES];
	datasrc = src;
	sel = selector;
	datasize = 0;
	buffsize = 1024;
	data = malloc(sizeof(double) * buffsize);
}

-(void)stop
{
	[polltimer invalidate];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.
	
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
	
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.
	NSRect winrect = [[myctl window] frame];
	int winw = winrect.size.width;
	int winh = winrect.size.height - 22.0;	
	NSData *pdfData = [[myctl window] dataWithPDFInsideRect:NSMakeRect(0,0,winw,winh)];
	NSImage * myImage = [[NSImage alloc] initWithData:pdfData];
	NSData *imageData = [myImage TIFFRepresentation];
	NSBitmapImageRep* imageRep = [NSBitmapImageRep imageRepWithData: imageData];
	if([fileTypePopup indexOfSelectedItem] == 0) {
		NSDictionary* imageProps = [NSDictionary dictionaryWithObject: [NSNumber numberWithFloat: 0.9]
															   forKey:NSImageCompressionFactor];
		imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
	} else {
		NSDictionary* imageProps = [NSDictionary
									dictionaryWithObject:[NSNumber numberWithBool:YES]
									forKey:NSImageInterlaced];
		imageData = [imageRep representationUsingType:NSPNGFileType properties:imageProps];
	}
	return imageData;
	/*
	 if ( outError != NULL ) {
	 *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	 }
	 return nil;
	 */
}

- (BOOL)prepareSavePanel:(NSSavePanel*)inSavePanel
{
	// here we explicitly want to always start in the user's home directory,
	// If we don't set this, then the save panel will remember the last visited
	// directory, which is generally preferred.
	//
	//	[inSavePanel setDirectory: NSHomeDirectory()];
	
	[inSavePanel setDelegate: self];	// allows us to be notified of save panel events
	
	[inSavePanel setAccessoryView: saveDialogCustomView];	// add our custom view
	[inSavePanel setAllowedFileTypes:[NSArray arrayWithObjects:@"jpg",@"png",nil ]];
	
	//	[inSavePanel setNameFieldLabel:@"FILE NAME:"];			// override the file name label
	//	[inSavePanel setMessage:@"This is a customized save dialog for saving text files:"];
	
	savePanel = inSavePanel;	// keep track of the save panel for later
	
    return YES;
}

- (NSString*)panel:(id)sender userEnteredFilename:(NSString*)filename confirmed:(BOOL)okFlag
{
	NSString *namestr;
	if([fileTypePopup indexOfSelectedItem] == 0)
		namestr = [NSString stringWithFormat:@"%@.jpg",filename];
	else
		namestr = [NSString stringWithFormat:@"%@.png",filename];
	
	return namestr;
}

- (void)setFileURL:(NSURL *)absoluteURL
{
	// for not set proxy icon on window title
	// my be this method call NSWindow setRepresentedFilename by default
}
@end
