/*
 *  metex.h
 *  Monkey
 *
 *  Created by Hiroki Mori on 12/01/03.
 *  Copyright 2012 Hiroki Mori. All rights reserved.
 *
 */

#include <Carbon/Carbon.h>

int metex_init(CFStringRef devname);
int metex_value(measure_value *data, int ind, double c);
void metex_close();
char *unitstr(int type);
