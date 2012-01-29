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

typedef struct measure_value {
	double value;
	int unittype;
} measure_value;

typedef struct ds5100_info {
	double ch1scale;
	double ch2scale;
	double ch1offset;
	double ch2offset;
	double timebasescale;
} ds5100_info;
