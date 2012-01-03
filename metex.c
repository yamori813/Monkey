/*
 *  metex.c
 *  Monkey
 *
 *  Created by Hiroki Mori on 12/01/03.
 *  Copyright 2012 Hiroki Mori. All rights reserved.
 *
 */

#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/termios.h>
#include <sys/time.h>
#include <string.h>

#include "metex.h"

static int metex_port;

static void sioinit(int speed)
{
	struct termios	rstio;
	
	tcgetattr(metex_port, &rstio);
	rstio.c_cflag |= CS8;
	rstio.c_cflag &= ~CSTOPB;
	rstio.c_cflag &= ~(PARODD | PARENB);
	rstio.c_cflag &= ~(CRTS_IFLOW | CDTR_IFLOW);
	rstio.c_cflag &= ~(CDSR_OFLOW | CCAR_OFLOW);
	rstio.c_ispeed = rstio.c_ospeed = speed;
	tcsetattr(metex_port, TCSADRAIN, &rstio);
}

int metex_read(unsigned char* buf, int bufsize)
{
	int readsize;
	fd_set sio_fd;
	struct timeval wtime;

	FD_ZERO(&sio_fd);
	FD_SET(metex_port, &sio_fd);
	wtime.tv_sec = 2;
	wtime.tv_usec = 0;
	select(metex_port + 1, &sio_fd, 0, 0, &wtime);
	if(!FD_ISSET(metex_port, &sio_fd)) {
		printf("metex_read error\n");
		return;
	}
	readsize = read(metex_port, buf, bufsize);

	return readsize;
}

int metex_init(CFStringRef devname)
{
	char devstr[1024];
	
    CFStringGetCString(devname,
					   devstr,
					   1024, 
					   kCFStringEncodingASCII);
	
	metex_port = open(devstr, O_RDWR);
    if(metex_port < 0)
        return 0;
	
	tcflush(metex_port, TCIOFLUSH);
	
	sioinit(9600);
	
	return 1;
}

void metex_close()
{
	close(metex_port);
}
