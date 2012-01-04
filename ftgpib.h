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
#define LLC 0x11

int ftgpib_init();
int ftgpib_write(unsigned char data);
int ftgpib_read(unsigned char *data);
int ftgpib_settalker();
int ftgpib_setlistener();
int ftgpib_ifc();
void ftgpib_dcl();
int ftgpib_talk(int myaddr, int taraddr, char *buf);
int ftgpib_listen(int myaddr, int taraddr, char *buf);
int ftgpib_ren(int val);
int ftgpib_sdc(int myaddr, int taraddr);
void ftgpib_debug();
void ftgpib_test(int addr, char *buf);
void ftgpib_close();
