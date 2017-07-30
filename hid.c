/*
 *  hid.c
 *  Monkey
 *
 *  Created by hiroki on 17/07/30.
 *  Copyright 2017 __MyCompanyName__. All rights reserved.
 *
 *  This code is based KLab blog code.
 */

#include "hid.h"

#include <stdio.h>
#include <unistd.h>
#include <string.h>

IOHIDManagerRef refHidMgr = NULL;
CFSetRef refDevSet = NULL;
IOHIDDeviceRef *prefDevs = NULL;

IOHIDDeviceRef refDevice;

int hid_open_device(int myVID,int myPID)
{
    int vid;
    int pid;
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

void hid_close_device()
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
int hid_read(unsigned char *buf, size_t bufsize, CFTimeInterval timeoutSecs)
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
IOReturn hid_write(unsigned char *data, size_t len)
{
    IOReturn ret = IOHIDDeviceSetReport(refDevice, kIOHIDReportTypeOutput, data[0], data+1, len-1);
    if (ret != kIOReturnSuccess) {
        //printf("WriteToDevice: ret=0x%08X\n", ret);
    }
    return ret;
}

