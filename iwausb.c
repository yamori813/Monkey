/*
 *  iwausb.c
 *  Monkey
 *
 *  Created by hiroki on 14/03/22.
 *  Copyright 2014 __MyCompanyName__. All rights reserved.
 *
 */

#include "iwausb.h"
#include "libusb.h"

static unsigned char cmd1[] = {0x01,0x01,0xfe,0x00,0x00,0x00,0x00,0x00,0x01,0xff,0xff,0xff};
static unsigned char cmd2[] = {0x02,0x02,0xfd,0x00,0x40,0x00,0x00,0x00,0x01,0x0a,0x00,0x00};

libusb_device **devs; //pointer to pointer of device, used to retrieve a list of devices
libusb_device_handle *dev_handle; //a device handle
libusb_context *ctx = NULL; //a libusb session

CFStringRef usb_wave(char *cmd)
{
	char data[1024];
	int r; //for return values
	int actual; //used to find out how many bytes were written

	cmd1[4] = strlen(cmd) - 1; // ignore LF
	r = libusb_bulk_transfer(dev_handle, (1 | LIBUSB_ENDPOINT_OUT), cmd1, sizeof(cmd1), &actual, 0);
	r = libusb_bulk_transfer(dev_handle, (1 | LIBUSB_ENDPOINT_OUT), cmd, strlen(cmd) - 1, &actual, 0);
	r = libusb_bulk_transfer(dev_handle, (1 | LIBUSB_ENDPOINT_OUT), cmd2, sizeof(cmd2), &actual, 0);
	
	r = libusb_bulk_transfer(dev_handle, (2 | LIBUSB_ENDPOINT_IN), (unsigned char*)data, sizeof(data), &actual, 500);
	if(r == 0) {
		CFDataRef cfDataRef; 
		cfDataRef = CFDataCreate(kCFAllocatorDefault, 
								 (unsigned char*)data + 12, 
								 604);
		return cfDataRef;
	}
	
	return NULL;
}

CFStringRef usb_query(char *cmd)
{
	char data[128];
	int r; //for return values
	int actual; //used to find out how many bytes were written
	
	cmd1[4] = strlen(cmd) - 1; // ignore LF
	r = libusb_bulk_transfer(dev_handle, (1 | LIBUSB_ENDPOINT_OUT), cmd1, sizeof(cmd1), &actual, 0);
	r = libusb_bulk_transfer(dev_handle, (1 | LIBUSB_ENDPOINT_OUT), cmd, strlen(cmd) - 1, &actual, 0);
	r = libusb_bulk_transfer(dev_handle, (1 | LIBUSB_ENDPOINT_OUT), cmd2, sizeof(cmd2), &actual, 0);
	
	r = libusb_bulk_transfer(dev_handle, (2 | LIBUSB_ENDPOINT_IN), (unsigned char*)data, sizeof(data), &actual, 500);
	if(r == 0) {
		data[actual] = '\0';
		printf("%s\n", data+12);
		CFStringRef cfStringRef; 
		cfStringRef = CFStringCreateWithCString(kCFAllocatorDefault, 
												data+12, 
												kCFStringEncodingMacRoman);
		return cfStringRef;
	}
	
	return NULL;
}

void usb_command(char *cmd)
{
	char data[128];
	int r; //for return values
	int actual; //used to find out how many bytes were written
	
	cmd1[4] = strlen(cmd) - 1;
	r = libusb_bulk_transfer(dev_handle, (1 | LIBUSB_ENDPOINT_OUT), cmd1, sizeof(cmd1), &actual, 0);
	r = libusb_bulk_transfer(dev_handle, (1 | LIBUSB_ENDPOINT_OUT), cmd, strlen(cmd) - 1, &actual, 0);
	
	return;
}

int usb_init() {
	int r; //for return values
	ssize_t cnt; //holding number of devices in list
	r = libusb_init(&ctx); //initialize the library for the session we just declared
	if(r < 0) {
		return 0;
	}
	libusb_set_debug(ctx, 0); //set verbosity level to 3, as suggested in the documentation
	
	cnt = libusb_get_device_list(ctx, &devs); //get the list of devices
	if(cnt < 0) {
		return 0;
	}
	
	// this is 1.2.8
	dev_handle = libusb_open_device_with_vid_pid(ctx, 0x13D4, 0x0005); //these are vendorID and productID I found for my usb device
	if(dev_handle == NULL)
		return 0;
	libusb_free_device_list(devs, 1); //free the list, unref the devices in it
	
	int actual; //used to find out how many bytes were written
	r = libusb_claim_interface(dev_handle, 0); //claim interface 0 (the first) of device (mine had jsut 1)
	if(r < 0) {
		return 0;
	}
	/* write */
	char *cmd = "*IDN?";
	cmd1[4] = strlen(cmd);
	r = libusb_bulk_transfer(dev_handle, (1 | LIBUSB_ENDPOINT_OUT), cmd1, sizeof(cmd1), &actual, 0);
	r = libusb_bulk_transfer(dev_handle, (1 | LIBUSB_ENDPOINT_OUT), cmd, strlen(cmd), &actual, 0);
	r = libusb_bulk_transfer(dev_handle, (1 | LIBUSB_ENDPOINT_OUT), cmd2, sizeof(cmd2), &actual, 0);
	/* read */
	char data[128];
	r = libusb_bulk_transfer(dev_handle, (2 | LIBUSB_ENDPOINT_IN), (unsigned char*)data, sizeof(data), &actual, 500); //my device's out endpoint was 2, found with trial- the device had 2 endpoints: 2 and 129
	if(r == 0) {
		data[actual] = '\0';
		printf("%s\n", data + 12);
	}
	
	return 1;
}

void usb_close()
{
	int r; //for return values

	r = libusb_release_interface(dev_handle, 0); //release the claimed interface
	if(r!=0) {
		return 1;
	}
	
	libusb_close(dev_handle); //close the device we opened
	libusb_exit(ctx); //needs to be called to end the
}