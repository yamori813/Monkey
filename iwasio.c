//
//  iwasio.c
//  Monkey
//
//  Created by Hiroki Mori on 11/12/25.
//  Copyright 2011 Hiroki Mori. All rights reserved.
//

#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/termios.h>
#include <sys/time.h>
#include <string.h>

#include "iwasio.h"

static int iwatsu_port;

static void sioinit(int speed)
{
	struct termios	rstio;
	
	tcgetattr(iwatsu_port, &rstio);
	rstio.c_cflag |= CS8;
	rstio.c_cflag &= ~CSTOPB;
	rstio.c_cflag &= ~(PARODD | PARENB);
	rstio.c_cflag &= ~(CRTS_IFLOW | CDTR_IFLOW);
	rstio.c_cflag &= ~(CDSR_OFLOW | CCAR_OFLOW);
//	rstio.c_ispeed = rstio.c_ospeed = B9600;
//	rstio.c_ispeed = rstio.c_ospeed = B38400;
	rstio.c_ispeed = rstio.c_ospeed = speed;
	tcsetattr(iwatsu_port, TCSADRAIN, &rstio);
}

void iwatsu_dummy()
{
	write(iwatsu_port, "\n", 1);
	usleep(500);
}

int getresponse(char *data, int datasize)
{	
	fd_set sio_fd;
	struct timeval wtime;
	int totalsize = 0;
	int read_size;
	while(1) {
		FD_ZERO(&sio_fd);
		FD_SET(iwatsu_port, &sio_fd);
		wtime.tv_sec = 0;
		wtime.tv_usec = 50*1000;
		select(iwatsu_port + 1, &sio_fd, 0, 0, &wtime);
		if(!FD_ISSET(iwatsu_port, &sio_fd)) {
			printf("getresponse error\n");
			return 0;
		}
		read_size = read(iwatsu_port, data+totalsize, datasize - totalsize);
		
		// check recive ack
		if(read_size > 0) {
			totalsize += read_size;
//			printf("MORI MORI Debug %d\n", totalsize);
			if(data[totalsize-1] == '\n') {
				data[totalsize-1] = 0x00;
				printf("MORI MORI %s\n", data);
				return 1;
			}
		} else {
			return 0;
		}
	}
}

int getbinary(unsigned char *data, int datasize)
{	
	fd_set sio_fd;
	struct timeval wtime;
	int totalsize = 0;
	int read_size;
	while(1) {
		FD_ZERO(&sio_fd);
		FD_SET(iwatsu_port, &sio_fd);
		wtime.tv_sec = 0;
		wtime.tv_usec = 100*1000;
		select(iwatsu_port + 1, &sio_fd, 0, 0, &wtime);
		if(!FD_ISSET(iwatsu_port, &sio_fd)) {
			printf("getbinary error %d\n", totalsize);
			return 0;
		}
		read_size = read(iwatsu_port, data+totalsize, datasize - totalsize);
		
		// check recive ack
		if(read_size > 0) {
			totalsize += read_size;
//			printf("MORI MORI Debug %d\n", totalsize);
			if(totalsize == datasize) {
				return 1;
			}
		} else {
			return 0;
		}
	}
}

CFStringRef que_triggerlevel(CFStringRef mode)
{
	char data[128];
	char modestr[1024];
	
    CFStringGetCString(mode,
					   modestr,
					   1024, 
					   kCFStringEncodingASCII);
	
	sprintf(data, ":TRIGger:%s:LEVel?\n", modestr);
	write(iwatsu_port, data, strlen(data));
	
	if(getresponse(data, sizeof(data))) {
		CFStringRef cfStringRef; 
		cfStringRef = CFStringCreateWithCString(kCFAllocatorDefault, 
												data, 
												kCFStringEncodingMacRoman);
		return cfStringRef;
	}
	
	return NULL;
}

CFDataRef sio_wave(char *cmd)
{
	char data[1024*2];

	write(iwatsu_port, cmd, strlen(cmd));
	
	if(getbinary((unsigned char*)data, 604)) {
		/*
		int i, j;
		for(i = 0; i < 16; ++i) {
			for(j = 0; j < 16; ++j) {
				printf("%02x ", data[i * 16 + j]);
			}
			printf("\n");
		}*/
		CFDataRef cfDataRef; 
		cfDataRef = CFDataCreate(kCFAllocatorDefault, 
												(unsigned char*)data, 
												604);
		return cfDataRef;
	}

	return NULL;
}


CFStringRef sio_query(char *cmd)
{
	char data[128];

	write(iwatsu_port, cmd, strlen(cmd));
	
	if(getresponse(data, sizeof(data))) {
		printf("%s\n", data);
		CFStringRef cfStringRef; 
		cfStringRef = CFStringCreateWithCString(kCFAllocatorDefault, 
												data, 
												kCFStringEncodingMacRoman);
		return cfStringRef;
	}
	
	return NULL;
}

void sio_command(char *cmd)
{
	write(iwatsu_port, cmd, strlen(cmd));

	return;
}

int sio_init(CFStringRef devname, int speed)
{
	char devstr[1024];
	
    CFStringGetCString(devname,
					   devstr,
					   1024, 
					   kCFStringEncodingASCII);
	
	iwatsu_port = open(devstr, O_RDWR);
    if(iwatsu_port < 0)
        return 0;
	
	tcflush(iwatsu_port, TCIOFLUSH);
	
	sioinit(speed);
	
	iwatsu_dummy();

	return 0;
}

void sio_close()
{
	close(iwatsu_port);
}
