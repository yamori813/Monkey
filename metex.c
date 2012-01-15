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

int metex_value(measure_value *data)
{
	int readsize;
	fd_set sio_fd;
	struct timeval wtime;
	unsigned char buf[32];
	int result;
	
	FD_ZERO(&sio_fd);
	FD_SET(metex_port, &sio_fd);
	wtime.tv_sec = 2;
	wtime.tv_usec = 0;
	select(metex_port + 1, &sio_fd, 0, 0, &wtime);
	if(!FD_ISSET(metex_port, &sio_fd)) {
		printf("metex_read error\n");
		return 0;
	}
	readsize = read(metex_port, buf, sizeof(buf));

//	int i;
//	printf("%d: ", readsize);
//	for(i = 0; i < readsize; ++i) {
//		printf("%02x ", buf[i]);
//	}
//	printf("\n");
	
	int value = (buf[1] - '0') * 1000 + (buf[2] - '0') * 100 + (buf[3] - '0') * 10 + (buf[4] - '0');

	// DC V
	if(buf[5] == 0x3b) {
//		printf("%d %d %f V\n", value, (buf[0] - 0x60), value * pow(10, (buf[0] - 0x66)/2));
		if(value != 6000) {
			data->value = value * pow(10, (buf[0] - 0x66)/2);
			result = 1;
		} else {
			data->value = 0.0;
			result = 0;
		}
		data->unittype = UNIT_VOLT;
	// R
	} else if(buf[5] == 0x3b) {
		printf("%d %d %f OHM\n", value, (buf[0] - 0x60), value * pow(10, (buf[0] - 0x68)/2));
	} else if(buf[5] == 0x3e)	// Lux
		printf("%d Lux\n", value, (buf[0] - 0x60));
	else if(buf[5] == 0x3c)	// Lux
		printf("%d %f db\n", value, (double)value / 10);
	
	return result;
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
