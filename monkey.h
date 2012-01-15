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

typedef struct measure_value {
	double value;
	int unittype;
} measure_value;
