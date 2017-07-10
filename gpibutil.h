/*
 *  gpibutil.h
 *  Monkey
 *
 *  Created by hiroki on 17/07/10.
 *  Copyright 2017 __MyCompanyName__. All rights reserved.
 *
 */


typedef struct {
	double val;
	int edig;
	int exp;
} gpioval;

gpioval gpibstr2val(char *str);
