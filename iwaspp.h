//
//  iwaspp.h
//  Monkey
//
//  Created by Hiroki Mori on 14/03/21.
//  Copyright 2014 Hiroki Mori. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOBluetooth/objc/IOBluetoothDevice.h>
#import <IOBluetooth/objc/IOBluetoothSDPUUID.h>
#import <IOBluetooth/objc/IOBluetoothRFCOMMChannel.h>
#import <IOBluetoothUI/objc/IOBluetoothDeviceSelectorController.h>


@interface iwaspp : NSObject {
	// Bluetooth variables:
	IOBluetoothDevice *mBluetoothDevice;
	IOBluetoothRFCOMMChannel *mRFCOMMChannel;
	
	int btStat;
	NSMutableData *readData;
}

-(NSData *)Wave:(char *)cmd;
-(void)Command:(char *)cmd;
-(NSString *)Query:(char *)cmd;
- (BOOL)Open;
- (void)Close;

@end
