//
//  MyDocument.m
//  Untitled
//
//  Created by Hiroki Mori on 11/12/30.
//  Copyright 2011 Hiroki Mori. All rights reserved.
//

#import "MyDocument.h"

@implementation MyDocument

- (id)init
{
    self = [super init];
    if (self) {
    
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
		info = malloc(sizeof(ds5100_info));
		myData1 = NULL;
		myData2 = NULL;
    }
    return self;
}

/*
- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}
 */

-(void)makeWindowControllers
{
	myctl = [[MyWindowController alloc] initWithWindowNibName:@"MyDocument" owner:self];
	[self addWindowController:myctl];
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.
	NSData *pdfData = [[myctl window] dataWithPDFInsideRect:NSMakeRect(0,0,660,460)];
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

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.

    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
    
	if([typeName isEqualToString:@"INFO"] == YES) {
		[data getBytes:info];
		NSLog(@"MORI MORI readFromData %f", info->ch1scale);
		NSLog(@"MORI MORI readFromData %f", info->ch2scale);
		NSLog(@"MORI MORI readFromData %f", info->ch1offset);
		NSLog(@"MORI MORI readFromData %f", info->ch2offset);
		NSLog(@"MORI MORI readFromData %f", info->timebasescale);
	}
	
	if([typeName isEqualToString:@"CH1"] == YES) {
		myData1 = [[NSData alloc ] initWithData:data];
	}
	if([typeName isEqualToString:@"CH2"] == YES) {
		myData2 = [[NSData alloc ] initWithData:data];
	}
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    return YES;
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

- (ds5100_info *)getInfo
{
	return info;
}

- (NSData *)getData1
{
	return myData1;
}

- (NSData *)getData2
{
	return myData2;
}
@end
