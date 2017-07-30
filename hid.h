/*
 *  hid.h
 *  Monkey
 *
 *  Created by hiroki on 17/07/30.
 *  Copyright 2017 __MyCompanyName__. All rights reserved.
 *
 */

#include <IOKit/hid/IOHIDManager.h>
#include <IOKit/hid/IOHIDKeys.h>
#include <CoreFoundation/CoreFoundation.h>

int hid_open_device(int myVID,int myPID);
void hid_close_device();
int hid_read(unsigned char *buf, size_t bufsize, CFTimeInterval timeoutSecs);
IOReturn hid_write(unsigned char *data, size_t len);