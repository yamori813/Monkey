/*
 *  ftgpib.c
 *  Monkey
 *
 *  Created by Hiroki Mori on 12/01/01.
 *  Copyright 2012 Hiroki Mori. All rights reserved.
 *
 */

#include "ftd2xx.h"

#include "ftgpib.h"

#include <stdio.h>
#include <unistd.h>
#include <string.h>

// Globals
FT_HANDLE ftHandleA = NULL;
FT_HANDLE ftHandleB = NULL;

unsigned char outline;
int myaddr;

int ftgpib_write(unsigned char data)
{
	FT_STATUS	ftStatus;
	DWORD writesize;
	unsigned char stat;
	unsigned char revdata;
	int retry;

	for(retry = 0;;) {	// wait for NDAC Lo
		ftStatus = FT_GetBitMode(ftHandleA, &stat);
		if(!(stat & (1 << NDAC)))
			break;
		++retry;
		usleep(POLLWAIT);
		if(retry > MAXRETRY)
			return -1;
	};

	// data output
	revdata = ~data;
	ftStatus = FT_Write(ftHandleB, &revdata, 1, &writesize);

	for(retry = 0;;) {	// wait for NRFD Hi
		ftStatus = FT_GetBitMode(ftHandleA, &stat);
		if((stat & (1 << NRFD)))
			break;
		++retry;
		usleep(POLLWAIT);
		if(retry > MAXRETRY)
			return -1;
	};

	// DAV to Lo
	outline = outline & ~(1 << DAV);
	ftStatus = FT_Write(ftHandleA, &outline, 1, &writesize);

	for(retry = 0;;) {	// wait for NDAC Hi
		ftStatus = FT_GetBitMode(ftHandleA, &stat);
		if((stat & (1 << NDAC)))
			break;
		++retry;
		usleep(POLLWAIT);
		if(retry > MAXRETRY)
			return -1;
	};
	
	// DAV to Hi
	outline = outline | (1 << DAV);
	ftStatus = FT_Write(ftHandleA, &outline, 1, &writesize);

	for(retry = 0;;) {	// wait for NDAC Lo
		ftStatus = FT_GetBitMode(ftHandleA, &stat);
		if(!(stat & (1 << NDAC)))
			break;
		++retry;
		usleep(POLLWAIT);
		if(retry > MAXRETRY)
			return -1;
	};

	return 1;
}

int ftgpib_read(unsigned char *data)
{
	FT_STATUS	ftStatus;
	DWORD writesize;
	unsigned char stat;
	unsigned char revdata;
	int result;
	int retry;

	// NRFD to Hi
	outline = outline | (1 << NRFD);
	ftStatus = FT_Write(ftHandleA, &outline, 1, &writesize);

	for(retry = 0;;) {	// wait for DAV Lo
		ftStatus = FT_GetBitMode(ftHandleA, &stat);
		if(!(stat & (1 << DAV)))
			break;
		++retry;
		usleep(POLLWAIT);
		if(retry > MAXRETRY)
			return -1;
	};
	
	// NRFD to Lo
	outline = outline & ~(1 << NRFD);
	ftStatus = FT_Write(ftHandleA, &outline, 1, &writesize);
	
	ftStatus = FT_GetBitMode(ftHandleB, &revdata);
	*data = ~revdata;
	
	ftStatus = FT_GetBitMode(ftHandleA, &stat);
	if(stat & (1 << EOI)) {
		result = 1;
	} else {
		result = 0;
	}

	// NDAC to Hi
	outline = outline | (1 << NDAC);
	ftStatus = FT_Write(ftHandleA, &outline, 1, &writesize);

	for(retry = 0;;) {	// wait for DAV Hi
		ftStatus = FT_GetBitMode(ftHandleA, &stat);
		if((stat & (1 << DAV)))
			break;
		++retry;
		usleep(POLLWAIT);
		if(retry > MAXRETRY)
			return -1;
	};
	
	outline = outline & ~(1 << NDAC);
	ftStatus = FT_Write(ftHandleA, &outline, 1, &writesize);

	return result;
}

int ftgpib_settalker()
{
	FT_STATUS	ftStatus;
	DWORD writesize;
	ftStatus = FT_SetBitMode(ftHandleA, (unsigned char)SETTALKER, 0x01);
	if(ftStatus != FT_OK) {
		printf("FT_SetBitMode failed = %d\n", ftStatus);
		return 0;
	}
	ftStatus = FT_SetBitMode(ftHandleB, 0xff, 0x01);
	if(ftStatus != FT_OK) {
		printf("FT_SetBitMode failed = %d\n", ftStatus);
		return 0;
	}
	outline = SETTALKER;
	ftStatus = FT_Write(ftHandleA, &outline, 1, &writesize);

	return 1;
}

int ftgpib_setlistener()
{
	FT_STATUS	ftStatus;
	ftStatus = FT_SetBitMode(ftHandleA, (unsigned char)SETLISTENER, 0x01);
	if(ftStatus != FT_OK) {
		printf("FT_SetBitMode failed = %d\n", ftStatus);
		return 0;
	}
	ftStatus = FT_SetBitMode(ftHandleB, 0x00, 0x01);
	if(ftStatus != FT_OK) {
		printf("FT_SetBitMode failed = %d\n", ftStatus);
		return 0;
	}
//	outline = SETLISTENER;
//	ftStatus = FT_Write(ftHandleA, &outline, 1, &writesize);

	return 1;
}


//
// uniline message
//

void ftgpib_ifc()
{
	FT_STATUS	ftStatus;
	DWORD writesize;
	// 500us
	// IFC to Lo
	outline = outline & ~(1 << IFC);
	ftStatus = FT_Write(ftHandleA, &outline, 1, &writesize);

	// IFC to Hi
	outline = outline | (1 << IFC);
	ftStatus = FT_Write(ftHandleA, &outline, 1, &writesize);
}

void ftgpib_ren(int val)
{
	FT_STATUS	ftStatus;
	DWORD writesize;
	if(val == 0) {
		printf("REN Lo\n");
		outline = outline & ~(1 << REN);
	} else {
		printf("REN Hi\n");
		outline = outline | (1 << REN);
	}
	ftStatus = FT_Write(ftHandleA, &outline, 1, &writesize);
}

//
// universal command
//

int ftgpib_dcl()
{
	FT_STATUS	ftStatus;
	DWORD writesize;
	outline = outline & ~(1 << ATN);
	ftStatus = FT_Write(ftHandleA, &outline, 1, &writesize);

	ftgpib_write(DCL);
	
	outline = outline | (1 << ATN);
	ftStatus = FT_Write(ftHandleA, &outline, 1, &writesize);
}

int ftgpib_llo()
{
	FT_STATUS	ftStatus;
	DWORD writesize;
	outline = outline & ~(1 << ATN);
	ftStatus = FT_Write(ftHandleA, &outline, 1, &writesize);
	
	ftgpib_write(LLO);
	
	outline = outline | (1 << ATN);
	ftStatus = FT_Write(ftHandleA, &outline, 1, &writesize);
}

//
// address command
//

int ftgpib_sdc(int taraddr)
{
	FT_STATUS	ftStatus;
	DWORD writesize;
	outline = outline & ~(1 << ATN);
	ftStatus = FT_Write(ftHandleA, &outline, 1, &writesize);
	
	ftgpib_write(UNL);
	
	ftgpib_write(0x40 + myaddr);
	
	ftgpib_write(0x20 + taraddr);
	
	ftgpib_write(SDC);
	
	outline = outline | (1 << ATN);
	ftStatus = FT_Write(ftHandleA, &outline, 1, &writesize);

	return 1;
}

int ftgpib_get(int taraddr)
{
	FT_STATUS	ftStatus;
	DWORD writesize;
	outline = outline & ~(1 << ATN);
	ftStatus = FT_Write(ftHandleA, &outline, 1, &writesize);
	
	ftgpib_write(UNL);
	
	ftgpib_write(0x40 + myaddr);
	
	ftgpib_write(0x20 + taraddr);
	
	ftgpib_write(GET);
	
	outline = outline | (1 << ATN);
	ftStatus = FT_Write(ftHandleA, &outline, 1, &writesize);
	
	return 1;
}

//
//
//

int ftgpib_talk(int taraddr, char *buf, int useeoi)
{
	FT_STATUS	ftStatus;
	DWORD writesize;
	int datalen;
	int i;
	outline = outline & ~(1 << ATN);
	ftStatus = FT_Write(ftHandleA, &outline, 1, &writesize);
	
	ftgpib_write(UNL);
	
	ftgpib_write(0x40 + myaddr);
	
	ftgpib_write(0x20 + taraddr);
	
	usleep(100);
	outline = outline | (1 << ATN);
	ftStatus = FT_Write(ftHandleA, &outline, 1, &writesize);
	
	datalen = strlen(buf);
	for(i = 0; i < (datalen - 1); ++i)
	{
		ftgpib_write(buf[i]);
	}
	if(useeoi) {
		outline = outline & ~(1 << EOI);
		ftStatus = FT_Write(ftHandleA, &outline, 1, &writesize);
	}
	++i;
	if(useeoi) {
		ftgpib_write(buf[i]);
		outline = outline | (1 << EOI);
		ftStatus = FT_Write(ftHandleA, &outline, 1, &writesize);
	}
	
	return 1;
}

int ftgpib_listen(int taraddr, char *buf, int bufsize, int useeoi)
{
	FT_STATUS	ftStatus;
	DWORD writesize;
	int dataend;
	unsigned char readdata;
	char *tmpptr;

	tmpptr = buf;
	outline = outline & ~(1 << ATN);
	ftStatus = FT_Write(ftHandleA, &outline, 1, &writesize);
	
	ftgpib_write(UNL);
	
	ftgpib_write(0x40 + taraddr);
	
	ftgpib_write(0x20 + myaddr);
	
	ftgpib_setlistener();
	
	usleep(100);
	outline = outline | (1 << ATN);
	ftStatus = FT_Write(ftHandleA, &outline, 1, &writesize);
	
	do {
		dataend = ftgpib_read(&readdata);
		if(dataend == -1)
			return 0;
		if((tmpptr - buf - 1) < bufsize)
		   *tmpptr++ = readdata;
		if(!useeoi && readdata == '\n') {
			useeoi = 0;
		}
	} while(dataend);
	*tmpptr = 0x00;
	
	ftgpib_settalker();
	return 1;
}

//
//
//

int ftgpib_init(int addr)
{
	FT_STATUS	ftStatus;
	
	ftStatus = FT_Open(0, &ftHandleA);
	if(ftStatus != FT_OK) {
		/* 
		 This can fail if the ftdi_sio driver is loaded
		 use lsmod to check this and rmmod ftdi_sio to remove
		 also rmmod usbserial
		 */
		printf("FT_Open failed = %d\n", ftStatus);
		return 0;
	}
	ftStatus = FT_Open(1, &ftHandleB);
	if(ftStatus != FT_OK) {
		/* 
		 This can fail if the ftdi_sio driver is loaded
		 use lsmod to check this and rmmod ftdi_sio to remove
		 also rmmod usbserial
		 */
		printf("FT_Open failed = %d\n", ftStatus);
		return 0;
	}
	printf("Open FT\n");
	
	myaddr = addr;
	/*
	 ftStatus = FT_SetBaudRate(ftHandleA, 9600);
	 if(ftStatus != FT_OK) {
	 printf("Failed to FT_SetBaudRate\n");	
	 return 0;
	 }
	 */

	ftgpib_settalker();

	return 1;
}

void ftgpib_close()
{
	printf("Close FT\n");
	if(ftHandleA != NULL) {
		FT_Close(ftHandleA);
		ftHandleA = NULL;
	}
	if(ftHandleB != NULL) {
		FT_Close(ftHandleB);
		ftHandleB = NULL;
	}
}

//
// debug function
//

void ftgpib_debug()
{
	FT_STATUS	ftStatus;
	unsigned char buf[1];
	
	ftStatus = FT_GetBitMode(ftHandleA, buf);
	if(ftStatus != FT_OK) {
		printf("FT_GetBitMode failed = %d\n", ftStatus);
		return;
	}
	
	printf("EOI = %d, ", (buf[0] >> EOI) & 1);
	printf("DAV = %d, ", (buf[0] >> DAV) & 1);
	printf("NRFD = %d, ", (buf[0] >> NRFD) & 1);
	printf("NDAC = %d, ", (buf[0] >> NDAC) & 1);
	printf("IFC = %d, ", (buf[0] >> IFC) & 1);
	printf("SRQ = %d, ", (buf[0] >> SRQ) & 1);
	printf("ATN = %d, ", (buf[0] >> ATN) & 1);
	printf("REN = %d\n",  (buf[0] >> REN) & 1);
}

void ftgpib_test(int addr, char *buf, int bufsize)
{
	ftgpib_debug();

	ftgpib_ifc();
	usleep(1000);

	ftgpib_dcl();
	usleep(1000);

	//	ftgpib_ren(0);
	//	usleep(1000);

	//	ftgpib_get(addr);
	//	usleep(1000);

	ftgpib_sdc(addr);
	usleep(1000);

	ftgpib_listen(addr, buf, bufsize, 1);
	printf("%s", buf);
}

