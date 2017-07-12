//
//  monkey.h
//  Monkey
//
//  Created by Hiroki Mori on 12/01/09.
//  Copyright 2012 Hiroki Mori. All rights reserved.
//

#define UNIT_VOLT	1
#define UNIT_AMPERE	2
#define UNIT_OHM	3
#define UNIT_C		4
#define UNIT_LUX	5
#define UNIT_dB		6
#define UNIT_Hz		7
#define UNIT_H		8
#define UNIT_F		9


#define UNIT_KHz	10
#define UNIT_MHz	11
#define UNIT_mVOLT	12
#define UNIT_KOHM	13
#define UNIT_MOHM	14
#define UNIT_nF		15
#define UNIT_uF		16
#define UNIT_mF		17
#define UNIT_mA		18
#define UNIT_uA		19

typedef struct measure_value {
	double value;
	int unittype;
	int edig;
} measure_value;

typedef struct ds5100_info {
	char model[32];
	char version[32];
	double ch1scale;
	double ch2scale;
	double ch1offset;
	double ch2offset;
	double timebasescale;
} ds5100_info;

char *unitstr(int type);
