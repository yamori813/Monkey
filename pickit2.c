/*
 *  pickit2.c
 *  Monkey
 *
 *  Created by hiroki on 17/07/26.
 *  Copyright 2017 __MyCompanyName__. All rights reserved.
 *
 */

#include "pickit2.h"

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <IOKit/hid/IOHIDManager.h>
#include <IOKit/hid/IOHIDKeys.h>
#include <CoreFoundation/CoreFoundation.h>

IOHIDManagerRef refHidMgr = NULL;
CFSetRef refDevSet = NULL;
IOHIDDeviceRef *prefDevs = NULL;

IOHIDDeviceRef refDevice;

int open_device()
{
    int vid, myVID = 0x04d8;
    int pid, myPID = 0x0033;
    int i;
    IOReturn ret;
    Boolean doDisplay = false;
	
    CFIndex numDevices;
    
    doDisplay = true;
    
    // HID マネージャリファレンスを生成
    refHidMgr = IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDOptionsTypeNone);
    // すべての HID デバイスを対象とする
    IOHIDManagerSetDeviceMatching(refHidMgr, NULL);
    IOHIDManagerScheduleWithRunLoop(refHidMgr, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    // HID マネージャを開く
    IOHIDManagerOpen(refHidMgr, kIOHIDOptionsTypeNone);
    // マッチしたデバイス群のセットを得る
    refDevSet = IOHIDManagerCopyDevices(refHidMgr);
    numDevices = CFSetGetCount(refDevSet);
    prefDevs = malloc(numDevices * sizeof(IOHIDDeviceRef));
    // セットから値を取得
    CFSetGetValues(refDevSet, (const void **)prefDevs);
    
    // HID デバイス群を走査して PICkit2 を探す
    for (i = 0; i < numDevices; i++) {
        refDevice = prefDevs[i];
        // VID, PID をチェック
        vid = getIntProperty(refDevice, CFSTR(kIOHIDVendorIDKey)); 
        pid = getIntProperty(refDevice, CFSTR(kIOHIDProductIDKey));
        if (vid != myVID || pid != myPID) {
            refDevice = NULL;
            continue;
        }
        // デバイスのオープン
        ret = IOHIDDeviceOpen(refDevice, kIOHIDOptionsTypeNone);    
        if (ret != kIOReturnSuccess) {
            refDevice = NULL;
            continue;
        }
		break;
    }
	if(i == numDevices)
		return 0;
	
    return 1;
}

static int g_readBytes;

// 指定されたキーの整数プロパティを取得
int getIntProperty(IOHIDDeviceRef inIOHIDDeviceRef, CFStringRef inKey) {
    int val;
	if (inIOHIDDeviceRef) {
        CFTypeRef tCFTypeRef = IOHIDDeviceGetProperty(inIOHIDDeviceRef, inKey);
        if (tCFTypeRef) {
            if (CFNumberGetTypeID() == CFGetTypeID(tCFTypeRef)) {
                if (!CFNumberGetValue( (CFNumberRef) tCFTypeRef, kCFNumberSInt32Type, &val)) {
                    val = -1;
                }
            }
        }
    }
    return val;
}

void close_device()
{
    IOHIDDeviceClose(refDevice, kIOHIDOptionsTypeNone);
    
    if (prefDevs) {
        free(prefDevs);
    }
    if (refDevSet) {
        CFRelease(refDevSet);
    }
    if (refHidMgr) {
        IOHIDManagerClose(refHidMgr, kIOHIDOptionsTypeNone);
        CFRelease(refHidMgr);    
    }
}

// レポートのコールバック関数
static void reportCallback(void *inContext, IOReturn inResult, void *inSender,
                           IOHIDReportType inType, uint32_t inReportID,
                           uint8_t *inReport, CFIndex InReportLength)
{
    g_readBytes = InReportLength;
}

// デバイスからの読み込み
int ReadFromeDevice(unsigned char *buf, size_t bufsize, CFTimeInterval timeoutSecs)
{
    IOHIDDeviceRegisterInputReportCallback(refDevice,
										   &buf[1],
										   bufsize-1,
										   reportCallback,
										   NULL);
    g_readBytes = -1;
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, timeoutSecs, false);
    //printf("ReadFromeDevice: len=%d, 0=%X 1=%X 2=%X\n", g_readBytes, buf[0], buf[1], buf[2]);
    return g_readBytes;
}

// デバイスへの書き込み
IOReturn WriteToDevice(unsigned char *data, size_t len)
{
    IOReturn ret = IOHIDDeviceSetReport(refDevice, kIOHIDReportTypeOutput, data[0], data+1, len-1);
    if (ret != kIOReturnSuccess) {
        //printf("WriteToDevice: ret=0x%08X\n", ret);
    }
    return ret;
}


int pk2_usb_init() {
	return open_device();
}

void pk2_usb_voltages()
{
	int r; //for return values
	uint8_t buffer[65];
	float vdd;
	float vpp;
	
	memset(buffer, 0, 65);
	buffer[0] = 0;
	buffer[1] = FWCMD_READ_VOLTAGES;
	buffer[2] = FWCMD_END_OF_BUFFER;
	WriteToDevice(buffer, 65);
	r = ReadFromeDevice(buffer, 65, 0.5);
	float valueADC = (float)((buffer[2] * 256) + buffer[1]);
	vdd = (valueADC / 65536) * 5.0F;
	valueADC = (float)((buffer[4] * 256) + buffer[3]);
	vpp = (valueADC / 65536) * 13.7F;

	printf("MORI MORI Pickit2 %d %f %f\n", r, vdd, vpp);
	
	return;
}

void pk2_usb_version()
{
	int r; //for return values
	uint8_t buffer[65];
	float vdd;
	float vpp;
	
	memset(buffer, 0, 65);
	buffer[0] = 0;
	buffer[1] = FWCMD_FIRMWARE_VERSION;
	buffer[2] = FWCMD_END_OF_BUFFER;
	WriteToDevice(buffer, 65);
	r = ReadFromeDevice(buffer, 65, 0.5);
	
	printf("MORI MORI Pickit2 Version %d.%d.%d\n", buffer[1], buffer[2], buffer[3]);
	
	return;
}


int trigmask(int ch1, int ch2, int ch3)
{
	int result = 0;
	
	if(ch1 != 0)
		result |= 1 << 2;
	if(ch2 != 0)
		result |= 1 << 3;
	if(ch3 != 0)
		result |= 1 << 4;
		
	return result;
}

int trigstates(int ch1, int ch2, int ch3)
{
	int result = 0;
	if(ch1 == 1 || ch1 == 3)
		result |= 1 << 2;
	if(ch2 == 1 || ch2 == 3)
		result |= 1 << 3;
	if(ch3 == 1 || ch3 == 3)
		result |= 1 << 4;
	
	return result;
}

int edgemask(int ch1, int ch2, int ch3)
{
	int result = 0;
	if(ch1 == 3 || ch1 == 4)
		result |= 1 << 2;
	if(ch2 == 3 || ch2 == 4)
		result |= 1 << 3;
	if(ch3 == 3 || ch3 == 4)
		result |= 1 << 4;
	
	return result;
}

CFDataRef pk2_usb_start(int ch1, int ch2, int ch3, int count, int sample, int window)
{
	int r; //for return values
	uint8_t buffer[65];
	uint8_t SampleRateFactor[8] = {0, 1, 3, 9, 19, 39, 99, 199};

	memset(buffer, 0, 64);
	buffer[0] = 0;
	buffer[1] = FWCMD_LOGIC_ANALYZER_GO;
	if(ch1 == 4 || ch2 == 4 || ch3 == 4)
		buffer[2] = 0;
	else
		buffer[2] = 1;
	buffer[3] = trigmask(ch1, ch2, ch3);
	buffer[4] = trigstates(ch1, ch2, ch3);
	buffer[5] = edgemask(ch1, ch2, ch3);
	buffer[6] = count;
	switch(window) {
		case 0:
			buffer[7] = 0xcc;   // Start
			buffer[8] = 0x03;
			break;
		case 1:
			buffer[7] = 0x0a;   // Center
			buffer[8] = 0x02;
			break;
		case 2:
			buffer[7] = 0x48;   // End
			buffer[8] = 0x00;
			break;
		case 3:
			buffer[7] = 0xb4;   // 1 Window
			buffer[8] = 0x07;
			break;
		case 4:
			buffer[7] = 0x9c;   // 2 Window
			buffer[8] = 0x0b;
			break;
		case 5:
			buffer[7] = 0x84;   // 3 Window
			buffer[8] = 0x0f;
			break;
	}
	buffer[9] = SampleRateFactor[sample];
	
	buffer[10] = FWCMD_END_OF_BUFFER;
	WriteToDevice(buffer, 65);

	do {
		r = ReadFromeDevice(buffer, 65, 0.5);
	} while (r == -1);
	printf("MORI MORI Pickit2 %d %02x %02x %02d\n", r, buffer[1], buffer[2], (buffer[1] + ((buffer[2] & 0x7) << 8)) - 0x600);

	if(buffer[2] & 0x40)   // cancel
		return nil;
	
	int trigloc = (buffer[1] + ((buffer[2] & 0x7) << 8)) - 0x600;
	trigloc += 1;
	if(trigloc == 512)
		trigloc = 0;
	printf("MORI %d %d\n", 64*2*4 - trigloc , trigloc);
	uint8_t data[64*2*4];
	pk2_usb_read(6, 0, data);
	pk2_usb_read(6, 0x80, data + 64*2);
	pk2_usb_read(7, 0, data + 64*2*2);
	pk2_usb_read(7, 0x80, data + 64*2*3);
	uint8_t redata[64*2*4];
	memcpy(redata, data + trigloc, 64*2*4 - trigloc);
	memcpy(redata + 64*2*4 - trigloc, data, trigloc);
	CFDataRef cfDataRef;
	cfDataRef = CFDataCreate(kCFAllocatorDefault, 
							 (unsigned char*)redata, 
							 64*2*4);
	return cfDataRef;
}

void pk2_usb_read(int bank, int offset, uint8_t *data)
{
	int r; //for return values
	int actual; //used to find out how many bytes were written
	uint8_t buffer[64];
	int i;
	
	memset(buffer, 0, 64);
	buffer[0] = 0;
	buffer[1] = FWCMD_COPY_RAM_UPLOAD;
	buffer[2] = offset;
	buffer[3] = bank;
	buffer[4] = FWCMD_END_OF_BUFFER;
	WriteToDevice(buffer, 65);

	for(i = 0; i < 2; ++i) {
		buffer[0] = 0;
		buffer[1] = FWCMD_UPLOAD_DATA_NOLEN;
		buffer[2] = FWCMD_END_OF_BUFFER;
		WriteToDevice(buffer, 65);
		
		r = ReadFromeDevice(buffer, 65, 0.5);
		if(r == 64) {
			memcpy(data + i * 64, buffer+1, 64);
		}
	}
	
	return;
}

void pk2_usb_cancel()
{
	uint8_t buffer[65];
	
	memset(buffer, 0, 65);
	buffer[0] = 0;
	buffer[1] = FWCMD_LOGIC_ANALYZER_GO;
	buffer[2] = FWCMD_END_OF_BUFFER;
	WriteToDevice(buffer, 65);
}

void pk2_usb_close()
{
	// how to cancel ?
}