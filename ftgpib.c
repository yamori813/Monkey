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
FT_HANDLE ctrlHandle = NULL;
FT_HANDLE dataHandle = NULL;

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
		ftStatus = FT_GetBitMode(ctrlHandle, &stat);
		if(!(stat & (1 << NDAC)))
			break;
		++retry;
		usleep(LOOPWAIT);
		if(retry > MAXRETRY) {
			printf("NDAC Lo wait error\n");
			return -1;
		}
	};

	// data output
	revdata = ~data;
	ftStatus = FT_Write(dataHandle, &revdata, 1, &writesize);

	for(retry = 0;;) {	// wait for NRFD Hi
		ftStatus = FT_GetBitMode(ctrlHandle, &stat);
		if((stat & (1 << NRFD)))
			break;
		++retry;
		usleep(LOOPWAIT);
		if(retry > MAXRETRY) {
			printf("NRFD Hi wait error\n");
			return -1;
		}
	};

	// DAV to Lo
	outline = outline & ~(1 << DAV);
	ftStatus = FT_Write(ctrlHandle, &outline, 1, &writesize);

	for(retry = 0;;) {	// wait for NDAC Hi
		ftStatus = FT_GetBitMode(ctrlHandle, &stat);
		if((stat & (1 << NDAC)))
			break;
		++retry;
		usleep(LOOPWAIT);
		if(retry > MAXRETRY) {
			printf("NDAC Hi wait error\n");
			return -1;
		}
	};
	
	// DAV to Hi
	outline = outline | (1 << DAV);
	ftStatus = FT_Write(ctrlHandle, &outline, 1, &writesize);

	for(retry = 0;;) {	// wait for NDAC Lo
		ftStatus = FT_GetBitMode(ctrlHandle, &stat);
		if(!(stat & (1 << NDAC)))
			break;
		++retry;
		usleep(LOOPWAIT);
		if(retry > MAXRETRY) {
			printf("NDAC Lo wait error\n");
			return -1;
		}
	};

	return 0;
}

int ftgpib_read(unsigned char *data)
{
	FT_STATUS	ftStatus;
	DWORD writesize;
	unsigned char stat;
	unsigned char revdata;
	int result;
	int retry;

//	printf("MORI MORI read\n");
//	ftgpib_debug();
//	usleep(1000*100);
	usleep(100);
	// NRFD to Hi
//	outline = outline | (1 << NRFD);
//	ftStatus = FT_Write(ctrlHandle, &outline, 1, &writesize);
	ftgpib_setlistener3();
//	ftgpib_debug();
	
	for(retry = 0;;) {	// wait for DAV Lo
		ftStatus = FT_GetBitMode(ctrlHandle, &stat);
		if(!(stat & (1 << DAV)))
			break;
		++retry;
		usleep(LOOPWAIT);
		if(retry > MAXRETRY) {
			printf("DAV Lo timeout\n");
			return -1;
		}
	};
	
	// NRFD to Lo
//	outline = outline & ~(1 << NRFD);
//	ftStatus = FT_Write(ctrlHandle, &outline, 1, &writesize);
	ftgpib_setlistener();
	
	ftStatus = FT_GetBitMode(dataHandle, &revdata);
	*data = ~revdata;
	
	ftStatus = FT_GetBitMode(ctrlHandle, &stat);
	if(stat & (1 << EOI)) {
		result = 1;
	} else {
		result = 0;
	}

	// NDAC to Hi
//	outline = outline | (1 << NDAC);
//	ftStatus = FT_Write(ctrlHandle, &outline, 1, &writesize);
	ftgpib_setlistener2();

	for(retry = 0;;) {	// wait for DAV Hi
		ftStatus = FT_GetBitMode(ctrlHandle, &stat);
		if((stat & (1 << DAV)))
			break;
		++retry;
		usleep(LOOPWAIT);
		if(retry > MAXRETRY) {
			printf("DAV Hi timeout\n");
			return -1;
		}
	};
	
//	outline = outline & ~(1 << NDAC);
//	ftStatus = FT_Write(ctrlHandle, &outline, 1, &writesize);
	ftgpib_setlistener();

	return result;
}

int ftgpib_settalker()
{
	FT_STATUS	ftStatus;
	DWORD writesize;
	FT_ResetDevice(ctrlHandle);
	ftStatus = FT_SetBitMode(ctrlHandle, (unsigned char)SETTALKER, 0x01);
	if(ftStatus != FT_OK) {
		printf("FT_SetBitMode failed = %d\n", ftStatus);
		return 0;
	}
	ftStatus = FT_SetBitMode(dataHandle, 0xff, 0x01);
	if(ftStatus != FT_OK) {
		printf("FT_SetBitMode failed = %d\n", ftStatus);
		return 0;
	}
	outline = SETTALKER;
	ftStatus = FT_Write(ctrlHandle, &outline, 1, &writesize);
//	ftgpib_debug();
	
	return 1;
}

int ftgpib_setlistener()
{
	FT_STATUS	ftStatus;
	DWORD writesize;
	ftStatus = FT_SetBitMode(ctrlHandle, (unsigned char)SETLISTENER, 0x01);
	if(ftStatus != FT_OK) {
		printf("FT_SetBitMode failed = %d\n", ftStatus);
		return 0;
	}
	ftStatus = FT_SetBitMode(dataHandle, 0x00, 0x01);
	if(ftStatus != FT_OK) {
		printf("FT_SetBitMode failed = %d\n", ftStatus);
		return 0;
	}
	outline = outline & ~(1 << NRFD);
	outline = outline & ~(1 << NDAC);
//	outline = SETLISTENER;
	ftStatus = FT_Write(ctrlHandle, &outline, 1, &writesize);

	return 1;
}

int ftgpib_setlistener2()
{
	FT_STATUS	ftStatus;
	DWORD writesize;
	ftStatus = FT_SetBitMode(ctrlHandle, (unsigned char)(SETCONTROLLER | (1 << NRFD)), 0x01);
	if(ftStatus != FT_OK) {
		printf("FT_SetBitMode failed = %d\n", ftStatus);
		return 0;
	}
	ftStatus = FT_SetBitMode(dataHandle, 0x00, 0x01);
	if(ftStatus != FT_OK) {
		printf("FT_SetBitMode failed = %d\n", ftStatus);
		return 0;
	}
	outline = outline & ~(1 << NRFD);
	//	outline = SETLISTENER;
	ftStatus = FT_Write(ctrlHandle, &outline, 1, &writesize);
	
	return 1;
}

int ftgpib_setlistener3()
{
	FT_STATUS	ftStatus;
	DWORD writesize;
	ftStatus = FT_SetBitMode(ctrlHandle, (unsigned char)(SETCONTROLLER | (1 << NDAC)), 0x01);
	if(ftStatus != FT_OK) {
		printf("FT_SetBitMode failed = %d\n", ftStatus);
		return 0;
	}
	ftStatus = FT_SetBitMode(dataHandle, 0x00, 0x01);
	if(ftStatus != FT_OK) {
		printf("FT_SetBitMode failed = %d\n", ftStatus);
		return 0;
	}
	outline = outline & ~(1 << NDAC);
	//	outline = SETLISTENER;
	ftStatus = FT_Write(ctrlHandle, &outline, 1, &writesize);
	
	return 1;
}


//
// uniline message
//

int ftgpib_ifc()
{
	FT_STATUS	ftStatus;
	DWORD writesize;

	if(ctrlHandle == NULL || dataHandle == NULL)
		return 0;
	
	ftgpib_settalker();

	// IFC to Lo
	outline = outline & ~(1 << IFC);
	ftStatus = FT_Write(ctrlHandle, &outline, 1, &writesize);
	// may be 500us pause
	usleep(100);
	// IFC to Hi
	outline = outline | (1 << IFC);
	ftStatus = FT_Write(ctrlHandle, &outline, 1, &writesize);

	return 1;
}

int ftgpib_ren(int val)
{
	FT_STATUS	ftStatus;
	DWORD writesize;

	if(ctrlHandle == NULL || dataHandle == NULL)
		return 0;
	
	if(val == 0) {
		outline = outline & ~(1 << REN);
	} else {
		outline = outline | (1 << REN);
	}
	ftStatus = FT_Write(ctrlHandle, &outline, 1, &writesize);

	return 1;
}

//
// universal command
//

int ftgpib_dcl()
{
	FT_STATUS	ftStatus;
	DWORD writesize;
	int result;

	if(ctrlHandle == NULL || dataHandle == NULL)
		return 0;

	outline = outline & ~(1 << ATN);
	ftStatus = FT_Write(ctrlHandle, &outline, 1, &writesize);

	if(ftgpib_write(DCL) == 0)
		result = 1;
	else
		result = 0;

	outline = outline | (1 << ATN);
	ftStatus = FT_Write(ctrlHandle, &outline, 1, &writesize);

	return result;
}

int ftgpib_llo()
{
	FT_STATUS	ftStatus;
	DWORD writesize;
	int result;

	if(ctrlHandle == NULL || dataHandle == NULL)
		return 0;

	outline = outline & ~(1 << ATN);
	ftStatus = FT_Write(ctrlHandle, &outline, 1, &writesize);
	
	if(ftgpib_write(LLO) == 0)
		result = 1;
	else
		result = 0;
	
	outline = outline | (1 << ATN);
	ftStatus = FT_Write(ctrlHandle, &outline, 1, &writesize);

	return result;
}

//
// address command
//

int ftgpib_addrcmd(int taraddr, int cmd)
{
	FT_STATUS	ftStatus;
	DWORD writesize;
	int result;

	if(ctrlHandle == NULL || dataHandle == NULL)
		return 0;

	outline = outline & ~(1 << ATN);
	ftStatus = FT_Write(ctrlHandle, &outline, 1, &writesize);
	
	if(ftgpib_write(UNL) != 0) {
		result = 0;
		goto atn;
	}
	
	if(ftgpib_write(0x40 + myaddr) != 0) {
		result = 0;
		goto atn;
	}
	
	if(ftgpib_write(0x20 + taraddr) != 0) {
		result = 0;
		goto atn;
	}

	if(ftgpib_write(cmd) != 0) {
		result = 0;
		goto atn;
	}
	result = 1;

atn:
	outline = outline | (1 << ATN);
	ftStatus = FT_Write(ctrlHandle, &outline, 1, &writesize);

	return result;
}

int ftgpib_sdc(int taraddr)
{
	return ftgpib_addrcmd(taraddr, SDC);
}

int ftgpib_get(int taraddr)
{
	return ftgpib_addrcmd(taraddr, GET);
}

int ftgpib_tct(int taraddr)
{
	return ftgpib_addrcmd(taraddr, TCT);
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
	int result = 1;

	if(ctrlHandle == NULL || dataHandle == NULL)
		return 0;

	outline = outline & ~(1 << ATN);
	ftStatus = FT_Write(ctrlHandle, &outline, 1, &writesize);
	
	if(ftgpib_write(UNL) != 0) {
		result = 0;
		goto atn;
	}
		
	if(ftgpib_write(0x40 + myaddr) != 0) {
		result = 0;
		goto atn;
	}
	
	if(ftgpib_write(0x20 + taraddr) != 0) {
		result = 0;
		goto atn;
	}

atn:
	usleep(ATNPAUSE);
	outline = outline | (1 << ATN);
	ftStatus = FT_Write(ctrlHandle, &outline, 1, &writesize);
	if(result == 0)
		return result;
	
	datalen = strlen(buf);
	for(i = 0; i < (datalen - 1); ++i)
	{
		if(ftgpib_write(buf[i]) != 0) {
			printf("ftgpib_talk error %d\n", i);
			return 0;
		}
		printf("ftgpib_write %c\n", buf[i]);
	}
	if(useeoi) {
		outline = outline & ~(1 << EOI);
		ftStatus = FT_Write(ctrlHandle, &outline, 1, &writesize);
	}
	++i;
	if(ftgpib_write(buf[i]) != 0)
		return 0;
	if(useeoi) {
		outline = outline | (1 << EOI);
		ftStatus = FT_Write(ctrlHandle, &outline, 1, &writesize);
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
	int result = 1;

	if(ctrlHandle == NULL || dataHandle == NULL)
		return 0;

	tmpptr = buf;
	outline = outline & ~(1 << ATN);
	ftStatus = FT_Write(ctrlHandle, &outline, 1, &writesize);

	if(ftgpib_write(UNL) != 0) {
		result = 0;
		goto atn;
	}

	if(ftgpib_write(0x40 + taraddr) != 0) {
		result = 0;
		goto atn;
	}

	if(ftgpib_write(0x20 + myaddr) != 0) {
		result = 0;
		goto atn;
	}

	ftgpib_setlistener();

atn:
//	ftgpib_debug();
	usleep(ATNPAUSE);
	outline = outline | (1 << ATN);
	ftStatus = FT_Write(ctrlHandle, &outline, 1, &writesize);
	if(result == 0)
		return result;
//	printf("MORI MORI ATN\n");
//	ftgpib_debug();

	do {
		dataend = ftgpib_read(&readdata);
		if(dataend == -1) {
			printf("ftgpib_read error\n");
			return 0;
		}
//		printf("ftgpib_read %c\n", readdata);
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
// ft2232 open
//

int ftgpib_init(int addr, int ftdev)
{
	FT_STATUS	ftStatus;

#if DATAPORT == 0
	ftStatus = FT_Open(ftdev, &dataHandle);
#else
	ftStatus = FT_Open(ftdev, &ctrlHandle);
#endif
	if(ftStatus != FT_OK) {
		/* 
		 This can fail if the ftdi_sio driver is loaded
		 use lsmod to check this and rmmod ftdi_sio to remove
		 also rmmod usbserial
		 */
		printf("FT_Open failed = %d\n", ftStatus);
		return 0;
	}
#if DATAPORT == 0
	ftStatus = FT_Open(ftdev+1, &ctrlHandle);
#else
	ftStatus = FT_Open(ftdev+1, &dataHandle);
#endif
	if(ftStatus != FT_OK) {
		/* 
		 This can fail if the ftdi_sio driver is loaded
		 use lsmod to check this and rmmod ftdi_sio to remove
		 also rmmod usbserial
		 */
		FT_Close(ctrlHandle);
		ctrlHandle = NULL;
		printf("FT_Open failed = %d\n", ftStatus);
		return 0;
	}
	printf("Open FT\n");

	myaddr = addr;
/*
	ftStatus = FT_SetBaudRate(ctrlHandle, 19200);
	if(ftStatus != FT_OK) {
		printf("Failed to FT_SetBaudRate\n");	
		return 0;
	}
*/	
	ftgpib_settalker();

	return 1;
}

// ft2232 close

void ftgpib_close()
{
	printf("Close FT\n");
	if(ctrlHandle != NULL) {
		FT_Close(ctrlHandle);
		ctrlHandle = NULL;
	}
	if(dataHandle != NULL) {
		FT_Close(dataHandle);
		dataHandle = NULL;
	}
}

//
// debug function
//

void ftgpib_debug()
{
	FT_STATUS	ftStatus;
	unsigned char buf[1];
	
	ftStatus = FT_GetBitMode(ctrlHandle, buf);
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

int ftgpib_tr5822(int addr, char *buf, int bufsize)
{
//	ftgpib_debug();

	ftgpib_ifc();
	usleep(1000);

	if(ftgpib_dcl() == 0) {
		printf("gpib error on dcl\n");
		return 0;
	}
	usleep(1000);

	ftgpib_ren(0);
	usleep(1000);

	//	ftgpib_get(addr);
	//	usleep(1000);

	if(ftgpib_sdc(addr) == 0) {
		printf("gpib error on sdc\n");
		return 0;
	}
	usleep(1000);

	// test for Advantest TR5820
	if(ftgpib_talk(addr, "C\r\n", 1) == 0) {
		printf("gpib error on talk\n");
		return 0;
	}
	usleep(1000);

	if(ftgpib_talk(addr, "F0\r\n", 1) == 0) {
		printf("gpib error on talk\n");
		return 0;
	}
	usleep(1000);

	if(ftgpib_listen(addr, buf, bufsize, 1) == 0) {
		printf("gpib error on listen\n");
		return 0;
	}

	ftgpib_ren(1);
	usleep(1000);

	printf("%s", buf);

	return 1;
}

int ftgpib_856g(int addr, char *buf, int bufsize)
{
//	ftgpib_debug();
	
	ftgpib_ifc();
	usleep(1000);
/*
	if(ftgpib_dcl() == 0) {
		printf("gpib error on dcl\n");
		return 0;
	}
	usleep(1000);
*/
	ftgpib_ren(0);
	usleep(1000);
	
//	ftgpib_get(addr);
//	usleep(1000);
/*	
	if(ftgpib_sdc(addr) == 0) {
		printf("gpib error on sdc\n");
		return 0;
	}
	usleep(1000);
	// test for 
//	if(ftgpib_talk(addr, "*IDN?\r\n", 1) == 0) {
	if(ftgpib_talk(addr, "C\r\n", 1) == 0) {
		printf("gpib error on talk\n");
		return 0;
	}
	usleep(1000);
 */

	if(ftgpib_listen(addr, buf, bufsize, 0) == 0) {
		printf("gpib error on listen\n");
		ftgpib_debug();
		return 0;
	}

	ftgpib_ren(1);
	usleep(1000);
	
	printf("%s", buf);
	
	return 1;
}