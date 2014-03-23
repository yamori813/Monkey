//
//  iwaspp.m
//  Monkey
//
//  Created by Hiroki Mori on 14/03/21.
//  Copyright 2014 Hiroki Mori. All rights reserved.
//

#import "iwaspp.h"

#define LOOPSEC 0.1

@implementation iwaspp


- (void)idn
{
//	[btCondition lock];
	btStat = 1;
	[readData setLength:0];
	[mRFCOMMChannel writeSync:"*IDN?\n" length:6];
	while(btStat != 2) {
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, LOOPSEC, false);
	}
	
//	[btCondition unlock];
	NSString *myString = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
	NSLog(@"MORI MORI %@", myString);
}

-(NSString *)Query:(char *)cmd
{
	//	[btCondition lock];
	btStat = 1;
	[readData setLength:0];

	[mRFCOMMChannel writeSync:cmd length:strlen(cmd)];
	while(btStat != 2) {
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, LOOPSEC, false);
	}
	
	//	[btCondition unlock];
	NSString *myString = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
	return myString;
}

-(void)Command:(char *)cmd
{
	//	[btCondition lock];	
	[mRFCOMMChannel writeSync:cmd length:strlen(cmd)];

	return;
}

-(NSData *)Wave:(char *)cmd
{
	//	[btCondition lock];
	btStat = 3;
	[readData setLength:0];
	
	[mRFCOMMChannel writeSync:cmd length:strlen(cmd)];
	while(btStat != 4) {
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, LOOPSEC, false);
	}
	
	//	[btCondition unlock];
	NSData *myData = [[NSData alloc] initWithData:readData];
	return myData;
}

// =============================
// == BLUETOOTH SPECIFIC CODE ==
// =============================

#if 0
#pragma mark -
#pragma mark Methods to handle the Baseband and RFCOMM connection
#endif

- (BOOL)Open
{
    IOBluetoothDeviceSelectorController	*deviceSelector;
	IOBluetoothSDPUUID					*sppServiceUUID;
	NSArray								*deviceArray;
	
 	btCondition = [[NSCondition alloc] init];
	readData = [[NSMutableData alloc] init];
	
	// The device selector will provide UI to the end user to find a remote device
    deviceSelector = [IOBluetoothDeviceSelectorController deviceSelector];
	
	if ( deviceSelector == nil )
	{
		NSLog( @"Error - unable to allocate IOBluetoothDeviceSelectorController.\n" );
		return FALSE;
	}
	
	// Create an IOBluetoothSDPUUID object for the chat service UUID
	sppServiceUUID = [IOBluetoothSDPUUID uuid16:kBluetoothSDPUUID16ServiceClassSerialPort];
	
	// Tell the device selector what service we are interested in.
	// It will only allow the user to select devices that have that service.
	[deviceSelector addAllowedUUID:sppServiceUUID];
	
	// Run the device selector modal.  This won't return until the user has selected a device and the device has
	// been validated to contain the specified service or the user has hit the cancel button.
	if ( [deviceSelector runModal] != kIOBluetoothUISuccess )
	{
		NSLog( @"User has cancelled the device selection.\n" );
		return FALSE;
	}
	
	// Get the list of devices the user has selected.
	// By default, only one device is allowed to be selected.
	deviceArray = [deviceSelector getResults];
	
	if ( ( deviceArray == nil ) || ( [deviceArray count] == 0 ) )
	{
		NSLog( @"Error - no selected device.  ***This should never happen.***\n" );
		return FALSE;
	}
	
	// The device we want is the first in the array (even if the user somehow selected more than
	// one device in this example we care only about the first one):
	IOBluetoothDevice *device = [deviceArray objectAtIndex:0];
	
	// Finds the service record that describes the service (UUID) we are looking for:
	IOBluetoothSDPServiceRecord	*sppServiceRecord = [device getServiceRecordForUUID:sppServiceUUID];
	
	if ( sppServiceRecord == nil )
	{
		NSLog( @"Error - no spp service in selected device.  ***This should never happen since the selector forces the user to select only devices with spp.***\n" );
		return FALSE;
	}
	
	// To connect we need a device to connect and an RFCOMM channel ID to open on the device:
	UInt8	rfcommChannelID;
	if ( [sppServiceRecord getRFCOMMChannelID:&rfcommChannelID] != kIOReturnSuccess )
	{
		NSLog( @"Error - no spp service in selected device.  ***This should never happen an spp service must have an rfcomm channel id.***\n" );
		return FALSE;
	}
	
	// Open asyncronously the rfcomm channel when all the open sequence is completed my implementation of "rfcommChannelOpenComplete:" will be called.
	if ( ( [device openRFCOMMChannelAsync:&mRFCOMMChannel withChannelID:rfcommChannelID delegate:self] != kIOReturnSuccess ) 
		&& ( mRFCOMMChannel != nil ) )
	{
		// Something went bad (looking at the error codes I can also say what, but for the moment let's not dwell on
		// those details). If the device connection is left open close it and return an error:
		NSLog( @"Error - open sequence failed.***\n" );
		
		[self closeDeviceConnectionOnDevice:device];
		
		return FALSE;
	}
	
	// So far a lot of stuff went well, so we can assume that the device is a good one and that rfcomm channel open process is going
	// well. So we keep track of the device and we (MUST) retain the RFCOMM channel:
	mBluetoothDevice = device;
	[mBluetoothDevice  retain];
	[mRFCOMMChannel retain];
	
	btStat = 0;
	while(btStat != 1) {
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, .1, false);
	}
	
	[self idn];
	return TRUE;
}

//- (void)closeRFCOMMConnectionOnChannel:(IOBluetoothRFCOMMChannel*)channel
- (void)Close
{
	[mRFCOMMChannel closeChannel];
}

- (void)closeDeviceConnectionOnDevice:(IOBluetoothDevice*)device
{
	if ( mBluetoothDevice == device )
	{
		IOReturn error = [mBluetoothDevice closeConnection];
		if ( error != kIOReturnSuccess )
		{
			// I failed to close the connection, maybe the device is busy, no problem, as soon as the device is no more busy it will close the connetion itself.
			NSLog(@"Error - failed to close the device connection with error %08lx.\n", (UInt32)error);
		}
		
		[mBluetoothDevice release];
		mBluetoothDevice = nil;
	}
	
}

#if 0
#pragma mark -
#pragma mark These are methods that are called when "things" happen on the
#pragma mark bluetooth connection, read along and it will all be clearer:
#endif

// Called by the RFCOMM channel on us once the baseband and rfcomm connection is completed:
- (void)rfcommChannelOpenComplete:(IOBluetoothRFCOMMChannel*)rfcommChannel status:(IOReturn)error
{
	// If it failed to open the channel call our close routine and from there the code will
	// perform all the necessary cleanup:
	if ( error != kIOReturnSuccess )
	{
		NSLog(@"Error - failed to open the RFCOMM channel with error %08lx.\n", (UInt32)error);
		[self rfcommChannelClosed:rfcommChannel];
		return;
	}
	[btCondition lock];
	++btStat;
	[btCondition signal];
	[btCondition unlock];
	NSLog(@"MORI MORI rfcommChannelOpenComplete");
	// The RFCOMM channel is now completly open so it is possible to send and receive data
	// ... add the code that begin the send data ... for example to reset a modem:
}

// Called by the RFCOMM channel on us when new data is received from the channel:
- (void)rfcommChannelData:(IOBluetoothRFCOMMChannel *)rfcommChannel data:(void *)dataPointer length:(size_t)dataLength
{
	unsigned char *dataAsBytes = (unsigned char *)dataPointer;
	
	[readData appendBytes:dataAsBytes length:dataLength];
	if(btStat == 1) {
		if(dataAsBytes[dataLength - 1] == '\n') {
			btStat = 2;
		}
	} else if(btStat == 3) {
		if([readData length] == 604) {
			btStat = 4;
		}
	}
}

// Called by the RFCOMM channel on us when something happens and the connection is lost:
- (void)rfcommChannelClosed:(IOBluetoothRFCOMMChannel *)rfcommChannel
{
	// wait a second and close the device connection as well:
	[self performSelector:@selector(closeDeviceConnectionOnDevice:) withObject:mBluetoothDevice afterDelay:1.0];
}

@end
