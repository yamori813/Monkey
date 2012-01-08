/*
 *  ftgpib.h
 *  Monkey
 *
 *  Created by Hiroki Mori on 12/01/01.
 *  Copyright 2012 Hiroki Mori. All rights reserved.
 *
 */

// A

#define EOI   7    // 5 OUT
#define DAV   6    // 6 IN/OUT
#define NRFD  5    // 7 IN/OUT
#define NDAC  4    // 8 IN/OUT
#define IFC   3    // 9 OUT
#define SRQ   2    // 10 IN
#define ATN   1    // 11 OUT
#define REN   0    // 17 OUT

// B

#define DIO1  0    // 1 IN/OUT
#define DIO2  1    // 2 IN/OUT
#define DIO3  2    // 3 IN/OUT
#define DIO4  3    // 4 IN/OUT
#define DIO5  4    // 13 IN/OUT
#define DIO6  5    // 14 IN/OUT
#define DIO7  6    // 15 IN/OUT
#define DIO8  7    // 16 IN/OUT

#define SETCONTROLLER ((1 << EOI) | (1 << IFC) | (1 << ATN) | (1 << REN))
#define SETTALKER (SETCONTROLLER | (1 << DAV))
#define SETLISTENER (SETCONTROLLER | (1 << NRFD) | (1 << NDAC))

#define GTL 0x01
#define GET 0x08
#define UNL 0x3f
#define SDC 0x04
#define DCL 0x14
#define LLO 0x11

#define MAXRETRY 100
#define LOOPWAIT 100
#define ATNPAUSE 100

// internal function

int ftgpib_write(unsigned char data);
int ftgpib_read(unsigned char *data);
int ftgpib_settalker();
int ftgpib_setlistener();

// api function (return 1 = Success,0 = Error)

void ftgpib_ifc();
void ftgpib_ren(int val);
int ftgpib_dcl();
int ftgpib_llo();
int ftgpib_sdc(int taraddr);
int ftgpib_get(int taraddr);
int ftgpib_talk(int taraddr, char *buf, int useeoi);
int ftgpib_listen(int taraddr, char *buf, int bufsize, int useeoi);
int ftgpib_init(int addr, int ftdev);
void ftgpib_close();

// debug function

void ftgpib_debug();
int ftgpib_test(int addr, char *buf, int bufsize);
