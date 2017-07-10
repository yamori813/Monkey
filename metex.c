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

int remainsize;
char remaindata[32];

// refered ES51986 datasheet

int metex_value(measure_value *data, int ind, double c)
{
	int readsize;
	fd_set sio_fd;
	struct timeval wtime;
	unsigned char buf[1024];
	int result;
	double tmp;
	
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

	int i;
	printf("%d: ", readsize);
	for(i = 0; i < readsize; ++i) {
		printf("%02x ", buf[i]);
	}
	printf("\n");
	
	int value = (buf[1] - '0') * 1000 + (buf[2] - '0') * 100 + (buf[3] - '0') * 10 + (buf[4] - '0');
	if(buf[6] & 0x04)
		value *= -1;
	int renge = buf[0] / 2 - 0x30;   // ???
	printf("%d %d %02x\n", buf[0] / 2 - 0x30, value, buf[5]);

	if(buf[5] == 0x3b) {
		// DC V
		if(value != 6000) {
			result = 1;
			if(renge == 0) {
				data->value = (double)value / 1000;
				data->unittype = UNIT_VOLT;
				data->edig = 3;
			} else if(renge == 1) {
				data->value = (double)value / 100;
				data->unittype = UNIT_VOLT;
				data->edig = 2;
			} else if(renge == 2) {
				data->value = (double)value / 10;
				data->unittype = UNIT_VOLT;
				data->edig = 1;
			} else if(renge == 3) {
				data->value = (double)value;
				data->unittype = UNIT_VOLT;
				data->edig = 0;
			} else if(renge == 4){
				data->value = (double)value / 10;
				data->unittype = UNIT_mVOLT;
				data->edig = 1;
			}
		} else {
			data->value = 0.0;
			result = 0;
			data->unittype = UNIT_VOLT;
		}
	} else if(buf[5] == 0x36) {
		// Cap
		if(value != 6000) {
			result = 1;
			if(renge == 0) {
				data->value = (double)value / 1000;
				data->unittype = UNIT_nF;
				data->edig = 3;
			} else if(renge == 1) {
				data->value = (double)value / 100;
				data->unittype = UNIT_nF;
				data->edig = 2;
			} else if(renge == 2) {
				data->value = (double)value / 10;
				data->unittype = UNIT_nF;
				data->edig = 1;
			} else if(renge == 3) {
				data->value = (double)value / 1000;
				data->unittype = UNIT_uF;
				data->edig = 3;
			} else if(renge == 4){
				data->value = (double)value / 100;
				data->unittype = UNIT_uF;
				data->edig = 2;
			} else if(renge == 4){
				data->value = (double)value / 10;
				data->unittype = UNIT_uF;
				data->edig = 1;
			} else if(renge == 4){
				data->value = (double)value / 1000;
				data->unittype = UNIT_mF;
				data->edig = 3;
			}
		} else {
			data->value = 0.0;
			result = 0;
			data->unittype = UNIT_VOLT;
		}
	} else if(buf[5] == 0x34) {
		// Temp
		data->value = value;
		data->unittype = UNIT_C;
		data->edig = 0;
	} else if(buf[5] == 0x33) {
		// Resistance
		if(value != 6000) {
			result = 1;
			if(renge == 0) {
				data->value = (double)value / 100;
				data->unittype = UNIT_OHM;
				data->edig = 2;
			} else if(renge == 1) {
				data->value = (double)value / 1000;
				data->unittype = UNIT_KOHM;
				data->edig = 3;
			} else if(renge == 2) {
				data->value = (double)value / 100;
				data->unittype = UNIT_KOHM;
				data->edig = 2;
			} else if(renge == 3) {
				data->value = (double)value / 10;
				data->unittype = UNIT_KOHM;
				data->edig = 1;
			} else if(renge == 4){
				data->value = (double)value / 1000;
				data->unittype = UNIT_MOHM;
				data->edig = 3;
			} else if(renge == 5){
				data->value = (double)value / 100;
				data->unittype = UNIT_MOHM;
				data->edig = 2;
			}
		} else {
			data->value = 0.0;
			result = 0;
			data->unittype = UNIT_OHM;
		}
	} else if(buf[5] == 0x3c) {
		// dB
		data->value = (double)value / 10;
		data->unittype = UNIT_dB;
		data->edig = 1;
	} else if(buf[5] == 0x3e)	{
		// LUX
		data->value = value;
		data->unittype = UNIT_LUX;
		data->edig = 0;
	} else if(buf[5] == 0x3d)	{
		// μA Current
		if(value != 6000) {
			if(renge == 0) {
				data->value = (double)value / 10;
				data->unittype = UNIT_uA;
				data->edig = 1;
			} else if(renge == 1) {
				data->value = (double)value;
				data->unittype = UNIT_uA;
				data->edig = 0;
			}			
		} else {
			data->value = 0.0;
			result = 0;
			data->unittype = UNIT_uA;
		}
	} else if(buf[5] == 0x3f)	{
		// mA Current
		if(value != 6000) {
			if(renge == 0) {
				data->value = (double)value / 100;
				data->unittype = UNIT_mA;
				data->edig = 2;
			} else if(renge == 1) {
				data->value = (double)value / 10;
				data->unittype = UNIT_mA;
				data->edig = 1;
			}			
		} else {
			data->value = 0.0;
			result = 0;
			data->unittype = UNIT_mA;
		}
	} else if(buf[5] == 0x32) {
		// Freq
		if(value != 6000) {
			if(renge == 0) {
				data->value = (double)value / 1000;
				data->unittype = UNIT_KHz;
				data->edig = 3;
			} else if(renge == 1) {
				data->value = (double)value / 100;
				data->unittype = UNIT_KHz;
				data->edig = 2;
			} else if(renge == 2) {
				data->value = (double)value / 10;
				data->unittype = UNIT_KHz;
				data->edig = 1;
			} else if(renge == 3) {
				data->value = (double)value / 1000;
				data->unittype = UNIT_MHz;
				data->edig = 3;
			} else if(renge == 4){
				data->value = (double)value / 100;
				data->unittype = UNIT_MHz;
				data->edig = 2;
			}
			// Hz
			if(ind) {
				// This is H caricurate
				if(data->unittype == UNIT_MHz)
					tmp = data->value * 1000;
				else
					tmp = data->value;
				tmp = pow(tmp * 2 * 3.14, 2) * c;
				tmp = (1 / tmp) * 1000 * 1000 * 1000;
				if(tmp < 1) {
					tmp = round((tmp * 10000) + 0.5) / 10000;
				} else {
					tmp = round((tmp * 100) + 0.5) / 100;
				}
				data->value = tmp;
				data->unittype = UNIT_H;
				data->edig = 1;
			}
		} else {
			data->value = 0.0;
			result = 0;
			data->unittype = UNIT_MHz;
		}
	}
	
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

char *unitstr(int type)
{
	char *res;

	switch (type) {
		case UNIT_VOLT:
			res = "V";
			break;
		case UNIT_mVOLT:
			res = "mV";
			break;
		case UNIT_AMPERE:
			res = "mA";
			break;
		case UNIT_OHM:
			res = "Ω";
			break;
		case UNIT_KOHM:
			res = "KΩ";
			break;
		case UNIT_MOHM:
			res = "MΩ";
			break;
		case UNIT_C:
			res = "F";
			break;
		case UNIT_nF:
			res = "nF";
			break;
		case UNIT_uF:
			res = "uF";
			break;
		case UNIT_mF:
			res = "mF";
			break;
		case UNIT_LUX:
			res = "Lux";
			break;
		case UNIT_dB:
			res = "dB";
			break;
		case UNIT_Hz:
			res = "Hz";
			break;
		case UNIT_KHz:
			res = "KHz";
			break;
		case UNIT_MHz:
			res = "MHz";
			break;
		case UNIT_H:
			res = "uH";
			break;
		default:
			res = "-";
			break;
	}
	return res;
}
