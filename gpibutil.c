/*
 *  gpibutil.c
 *  Monkey
 *
 *  Created by hiroki on 17/07/10.
 *  Copyright 2017 __MyCompanyName__. All rights reserved.
 *
 */

#include "gpibutil.h"

gpioval gpibstr2val(char *str)
{
	gpioval result;
	
	int seisu = 0;
//	double result = 0.0;
	int part = 0; // 0 intager, 1 decimal, 2　exponent
	int decount = 1;
	int i;
	int exp = 0;
	int sin = 1;
	int expsin = 1;
	result.val = 0.0;
	// 8840A	+03.3275E+0
	// TR5822	1.0000000E+07
	// 856G		DV     4.984E+0
	// DS-5102A	2.000e-07
	for(i = 0; str[i] != '\0'; ++i) {
		if(part == 0) {
			if(str[i] == '+')
				sin = 1;
			else if(str[i] == '-')
				sin = -1;
			else if(str[i] >= '0' && str[i] <= '9') {
				seisu *= 10;
				seisu += (str[i] - '0');
			} else if(str[i] == '.') {
				part = 1;
			}
		} else if(part == 1) {
			if(str[i] >= '0' && str[i] <= '9') {
				result.val += ((double)(str[i] - '0') / pow(10,decount));
				++decount;
			} else if(str[i] == 'E' || str[i] == 'e') {
				part = 2;
			}
		} else {
			if(str[i] == '+')
				expsin = 1;
			else if(str[i] == '-')
				expsin = -1;
			else if(str[i] >= '0' && str[i] <= '9') {
				exp *= 10;
				exp += (str[i] - '0');
			}
		}
	}
	result.val += seisu;
	if(expsin == 1)
		result.val *= pow(10, exp);
	else
		result.val /= pow(10, exp);
	result.val *= sin;
	result.edig = decount - 1;
	result.exp = exp * expsin;

	return result;
}

gpioval convval(double val)
{
	gpioval result;

	// m k - m u n
	
	if(val >= 1000 * 1000) {
		result.val = val / (1000 * 1000);
		result.exp = 2;
	} else if(val >= 1000 && val < 1000 * 1000) {
		result.val = val / (1000 * 1000);
		result.exp = 1;
	} else if(val >= 1 && val < 1000) {
		result.val = val;
		result.exp = 0;
	} else if(val >= 0.001 && val < 1) {
		result.val = val * 1000;
		result.exp = -1;
	} else if(val >= 0.000001 && val < 0.001) {
		result.val = val * 1000 * 1000;
		result.exp = -2;
	} else if(val >= 0.000000001 && val < 0.000001) {
		result.val = val * 1000 * 1000 * 1000;
		result.exp = -3;
	}
	return result;
}