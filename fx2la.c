/*
 *  fx2lafw.c
 *  Monkey
 *
 *  Created by hiroki on 17/08/08.
 *  Copyright 2017 __MyCompanyName__. All rights reserved.
 *
 */

#include "fx2la.h"

#include <IOKit/IOKitLib.h>
#include <IOKit/IOCFPlugIn.h>
#include <IOKit/usb/IOUSBLib.h>

#include <CoreFoundation/CoreFoundation.h>

#include <fcntl.h>

#define kFx2lafwVendorID		0x0925
#define kFx2lafwProductID		0x3881

unsigned char *data1;
unsigned char *data2;
IOUSBInterfaceInterface245 	**intf = NULL;
IOUSBDeviceInterface245 	**dev=NULL;
int gTrigCh;
int gTrigType;
int gTrigOffset;

int stop;
unsigned char  	ver_data[2];

IOReturn ConfigureAnchorDevice(IOUSBDeviceInterface245 **dev)
{
    UInt8				numConf;
    IOReturn				kr;
    IOUSBConfigurationDescriptorPtr	confDesc;
    
    kr = (*dev)->GetNumberOfConfigurations(dev, &numConf);
    if (!numConf)
        return -1;
    
    // get the configuration descriptor for index 0
    kr = (*dev)->GetConfigurationDescriptorPtr(dev, 0, &confDesc);
    if (kr)
    {
        printf("\tunable to get config descriptor for index %d (err = %08x)\n", 0, kr);
        return -1;
    }
    kr = (*dev)->SetConfiguration(dev, confDesc->bConfigurationValue);
    if (kr)
    {
        printf("\tunable to set configuration to value %d (err=%08x)\n", 0, kr);
        return -1;
    }
    return kIOReturnSuccess;
}

int fx2la_isstop()
{
	return stop;
}

void fx2la_stop()
{
	if(stop == 0)
		stop = 3;
}

CFDataRef fx2la_get()
{
	CFDataRef cfDataRef;
	cfDataRef = CFDataCreate(kCFAllocatorDefault, 
							 stop == 1 ? (unsigned char*)data1 : (unsigned char*)data2, 
							 0x10000);
	free(data1);
	free(data2);
	return cfDataRef;
}

void fx2la_version(char *str)
{
	sprintf(str, "%d.%d", ver_data[0], ver_data[1]);
}

void start(int sample)
{
    IOReturn			kr;
	IOUSBDevRequest     request;
	unsigned char  	cmd_data[3];
	
	request.bRequest = 0xb1;
	request.wValue = 0;
	request.wIndex = 0;
	request.wLength = 3;
	request.pData = cmd_data;
	
	cmd_data[0] = cmd_data[1] = cmd_data[2] = 0;
	int delay = 1 << (sample + 2);
	cmd_data[1] = delay >> 8;
	cmd_data[2] = delay & 0xff;

	request.bmRequestType = USBmakebmRequestType(kUSBOut,
												 kUSBVendor,
												 kUSBDevice);
	
	kr = (*dev)->DeviceRequest(dev, &request);
	if (kIOReturnSuccess != kr)
	{
		printf("Start command failed\n");
	} else {
		printf("Start command Successful\n");
	}
	
}

void getver(IOUSBDeviceInterface245 **dev)
{
    IOReturn			kr;
	IOUSBDevRequest     request;
	
	request.bRequest = 0xb0;
	request.wValue = 0;
	request.wIndex = 0;
	request.wLength = 2;
	request.pData = ver_data;
	
	request.bmRequestType = USBmakebmRequestType(kUSBIn,
												 kUSBVendor,
												 kUSBDevice);
	
	kr = (*dev)->DeviceRequest(dev, &request);
	if (kIOReturnSuccess != kr)
	{
		printf("Get Firmware Version command failed \n");
	} else {
		printf("Get Firmware Version command Successful %d.%d \n", ver_data[0], ver_data[1]);
	}
	
}

int fx2la_trigger()
{
	return gTrigOffset;
}

void ReadCompletion(void *refCon, IOReturn result, void *arg0)
{
    IOReturn			kr;
//    IOUSBInterfaceInterface245	**intf = (IOUSBInterfaceInterface245 **) refCon;
	unsigned char *data = (unsigned char *)refCon;
    UInt32 			numBytesRead = (UInt32) arg0;
    UInt32			i;
    
//    printf("Async bulk read complete.\n");
    if (kIOReturnSuccess != result)
    {
        printf("error from async bulk read (%08x)\n", result);
		(void) (*intf)->USBInterfaceClose(intf);
		(void) (*intf)->Release(intf);
        return;
    }
	
	int offset = 50;
	int bit = 1 << gTrigCh;
	int last = data[offset] & bit;
	for(i = offset + 1;i < 0x10000; ++i)
	{
		if(gTrigType == 0 && (data[i] & bit) == 1) {
			break;
		}
		if(gTrigType == 1 && (data[i] & bit) == 0) {
			break;
		}
		if(gTrigType == 2 && last == 0 && (data[i] & bit)) {
			break;
		}
		if(gTrigType == 3 && last != 0 && (data[i] & bit) == 0) {
			break;
		}
		last = data[i] & bit;
	}

	if(stop == 0 && i != 0x10000) {
		gTrigOffset = i;
		if(refCon == data1)
			stop = 1;
		else
			stop = 2;
		printf("Trigger position %d　%d\n", i, stop);

	}
	
	
	if(i == 0x10000 && stop == 0) {
//		kr = (*intf)->ReadPipeAsync(intf, 1, data, 0x10000, ReadCompletion,(void *) intf);
		kr = (*intf)->ReadPipeAsync(intf, 1, data, 0x10000, ReadCompletion, refCon);
		if (kIOReturnSuccess != result)
		{
			printf("error async bulk read (%08x)\n", kr);
			(void) (*intf)->USBInterfaceClose(intf);
			(void) (*intf)->Release(intf);
			return;
		}
	}

//    printf("Read %ld bytes from bulk endpoint\n",  numBytesRead);
}

IOReturn FindInterfaces(IOUSBDeviceInterface245 **dev)
{
    IOReturn			kr;
    IOUSBFindInterfaceRequest	request;
    io_iterator_t		iterator;
    io_service_t		usbInterface;
    IOCFPlugInInterface 	**plugInInterface = NULL;
    HRESULT 			res;
    SInt32 			score;
    UInt8			intfClass;
    UInt8			intfSubClass;
    UInt8			intfNumEndpoints;
    int				pipeRef;
    
    request.bInterfaceClass = kIOUSBFindInterfaceDontCare;
    request.bInterfaceSubClass = kIOUSBFindInterfaceDontCare;
    request.bInterfaceProtocol = kIOUSBFindInterfaceDontCare;
    request.bAlternateSetting = kIOUSBFindInterfaceDontCare;
	
    kr = (*dev)->CreateInterfaceIterator(dev, &request, &iterator);
    
    while ( (usbInterface = IOIteratorNext(iterator)) )
    {
        printf("Interface found.\n");
		
        kr = IOCreatePlugInInterfaceForService(usbInterface, kIOUSBInterfaceUserClientTypeID, kIOCFPlugInInterfaceID, &plugInInterface, &score);
        kr = IOObjectRelease(usbInterface);				// done with the usbInterface object now that I have the plugin
        if ((kIOReturnSuccess != kr) || !plugInInterface)
        {
            printf("unable to create a plugin (%08x)\n", kr);
            break;
        }
		
        // I have the interface plugin. I need the interface interface
        res = (*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOUSBInterfaceInterfaceID245), (LPVOID) &intf);
        IODestroyPlugInInterface(plugInInterface);			// done with this
		
        if (res || !intf)
        {
            printf("couldn't create an IOUSBInterfaceInterface245 (%08x)\n", (int) res);
            break;
        }
        
        kr = (*intf)->GetInterfaceClass(intf, &intfClass);
        kr = (*intf)->GetInterfaceSubClass(intf, &intfSubClass);
        
        printf("Interface class %d, subclass %d\n", intfClass, intfSubClass);
        
        // Now open the interface. This will cause the pipes to be instantiated that are 
        // associated with the endpoints defined in the interface descriptor.
        kr = (*intf)->USBInterfaceOpen(intf);
        if (kIOReturnSuccess != kr)
        {
            printf("unable to open interface (%08x)\n", kr);
            (void) (*intf)->Release(intf);
            break;
        }
        
    	kr = (*intf)->GetNumEndpoints(intf, &intfNumEndpoints);
        if (kIOReturnSuccess != kr)
        {
            printf("unable to get number of endpoints (%08x)\n", kr);
            (void) (*intf)->USBInterfaceClose(intf);
            (void) (*intf)->Release(intf);
            break;
        }
        
        printf("Interface has %d endpoints.\n", intfNumEndpoints);
		
        for (pipeRef = 1; pipeRef <= intfNumEndpoints; pipeRef++)
        {
            IOReturn	kr2;
            UInt8	direction;
            UInt8	number;
            UInt8	transferType;
            UInt16	maxPacketSize;
            UInt8	interval;
            char	*message;
            
            kr2 = (*intf)->GetPipeProperties(intf, pipeRef, &direction, &number, &transferType, &maxPacketSize, &interval);
            if (kIOReturnSuccess != kr)
                printf("unable to get properties of pipe %d (%08x)\n", pipeRef, kr2);
            else {
                printf("pipeRef %d: ", pipeRef);
				
                switch (direction) {
                    case kUSBOut:
                        message = "out";
                        break;
                    case kUSBIn:
                        message = "in";
                        break;
                    case kUSBNone:
                        message = "none";
                        break;
                    case kUSBAnyDirn:
                        message = "any";
                        break;
                    default:
                        message = "???";
                }
                printf("direction %s, ", message);
                
                switch (transferType) {
                    case kUSBControl:
                        message = "control";
                        break;
                    case kUSBIsoc:
                        message = "isoc";
                        break;
                    case kUSBBulk:
                        message = "bulk";
                        break;
                    case kUSBInterrupt:
                        message = "interrupt";
                        break;
                    case kUSBAnyType:
                        message = "any";
                        break;
                    default:
                        message = "???";
                }
                printf("transfer type %s, maxPacketSize %d\n", message, maxPacketSize);
            }
        }


        // We can now address endpoints 1 through intfNumEndpoints. Or, we can also address endpoint 0,
        // the default control endpoint. But it's usually better to use (*usbDevice)->DeviceRequest() instead.
        
        // For this test we just want to use the first interface, so exit the loop.
        break;
    }
    
    return kr;
}

void Fx2laswAdded(void *refCon, io_iterator_t iterator)
{
	kern_return_t		kr;
    io_service_t		usbDevice;
	IOCFPlugInInterface 	**plugInInterface=NULL;
	SInt32 			score;
	HRESULT 			res;
		
    while ( (usbDevice = IOIteratorNext(iterator)) )
    {
		printf("MORI MORI fx2lafw Added\n");

		kr = IOCreatePlugInInterfaceForService(usbDevice, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &plugInInterface, &score);
		kr = IOObjectRelease(usbDevice);				// done with the device object now that I have the plugin
		if ((kIOReturnSuccess != kr) || !plugInInterface)
		{
			printf("unable to create a plugin (%08x)\n", kr);
			continue;
		}
		
		// I have the device plugin, I need the device interface
		res = (*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID245), (LPVOID)&dev);
		IODestroyPlugInInterface(plugInInterface);			// done with this
		
        // need to open the device in order to change its state
        kr = (*dev)->USBDeviceOpen(dev);
        if (kIOReturnSuccess != kr)
        {
            printf("unable to open device: %08x\n", kr);
            (*dev)->Release(dev);
            continue;
        }
        kr = ConfigureAnchorDevice(dev);
        if (kIOReturnSuccess != kr)
        {
            printf("unable to configure device: %08x\n", kr);
            (*dev)->USBDeviceClose(dev);
            (*dev)->Release(dev);
            continue;
        }
		
        kr = FindInterfaces(dev);
        if (kIOReturnSuccess != kr)
        {
            printf("unable to find interfaces on device: %08x\n", kr);
            (*dev)->USBDeviceClose(dev);
            (*dev)->Release(dev);
            continue;
        }
		
		getver(dev);
		
//        kr = (*dev)->USBDeviceClose(dev);
//        kr = (*dev)->Release(dev);
	}
	
}
	
void fx2la_start(int ch, int type, int sample)
{
	kern_return_t		kr;

	if(intf == NULL)
		return;
	
	gTrigCh = ch;
	gTrigType = type;
	
	CFRunLoopSourceRef		runLoopSource;
	// Just like with service matching notifications, we need to create an event source and add it 
	//  to our run loop in order to receive async completion notifications.
	kr = (*intf)->CreateInterfaceAsyncEventSource(intf, &runLoopSource);
	if (kIOReturnSuccess != kr)
	{
		printf("unable to create async event source (%08x)\n", kr);
		(void) (*intf)->USBInterfaceClose(intf);
		(void) (*intf)->Release(intf);
		return;
	}
	CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopDefaultMode);
	
	printf("Async event source added to run loop.\n");
	
	data1 = malloc(0x10000);
//	kr = (*intf)->ReadPipeAsync(intf, 1, data1, 0x10000, ReadCompletion,(void *) intf);
	kr = (*intf)->ReadPipeAsync(intf, 1, data1, 0x10000, ReadCompletion, data1);
	if (kIOReturnSuccess != kr)
	{
		printf("unable to do async bulk read (%08x)\n", kr);
		(void) (*intf)->USBInterfaceClose(intf);
		(void) (*intf)->Release(intf);
		return;
	}

	data2 = malloc(0x10000);
	kr = (*intf)->ReadPipeAsync(intf, 1, data2, 0x10000, ReadCompletion, data2);
	if (kIOReturnSuccess != kr)
	{
		printf("unable to do async bulk read (%08x)\n", kr);
		(void) (*intf)->USBInterfaceClose(intf);
		(void) (*intf)->Release(intf);
		return;
	}
	
	stop = 0;
	start(sample);
}

void fx2la_init()
{
	io_iterator_t		gFx2lafwAddedIter;
	IONotificationPortRef	gNotifyPort;
    CFRunLoopSourceRef		runLoopSource;
    CFMutableDictionaryRef 	fx2Dict;
    mach_port_t 		masterPort;
	kern_return_t		kr;
    SInt32			usbVendor;
    SInt32			usbProduct;
	
	usbVendor = kFx2lafwVendorID;
	usbProduct = kFx2lafwProductID;
	
	kr = IOMasterPort(MACH_PORT_NULL, &masterPort);
    if (kr || !masterPort)
    {
        printf("ERR: Couldn't create a master IOKit Port(%08x)\n", kr);
        return;
    }
	
    printf("\nLooking for devices matching vendor ID=0x%04x and product ID=0x%04x\n", usbVendor, usbProduct);
	
    // Set up the matching criteria for the devices we're interested in
    fx2Dict = IOServiceMatching(kIOUSBDeviceClassName);	// Interested in instances of class IOUSBDevice and its subclasses
    if (!fx2Dict)
    {
        printf("Can't create a USB matching dictionary\n");
        mach_port_deallocate(mach_task_self(), masterPort);
        return;
    }
    
    // Add our vendor and product IDs to the matching criteria
    CFDictionarySetValue( 
						 fx2Dict, 
						 CFSTR(kUSBVendorID), 
						 CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &usbVendor)); 
    CFDictionarySetValue( 
						 fx2Dict, 
						 CFSTR(kUSBProductID), 
						 CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &usbProduct)); 
	
    
    gNotifyPort = IONotificationPortCreate(masterPort);
    runLoopSource = IONotificationPortGetRunLoopSource(gNotifyPort);
    
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopDefaultMode);
	
    fx2Dict = (CFMutableDictionaryRef) CFRetain( fx2Dict ); 
	
    kr = IOServiceAddMatchingNotification(  gNotifyPort,
										  kIOFirstMatchNotification,
										  fx2Dict,
										  Fx2laswAdded,
										  NULL,
										  &gFx2lafwAddedIter );
	
    Fx2laswAdded(NULL, gFx2lafwAddedIter);	// Iterate once to get already-present devices and
}
