/*
 *  ftgpib.h
 *  Monkey
 *
 *  Created by Hiroki Mori on 12/01/01.
 *  Copyright 2012 Hiroki Mori. All rights reserved.
 *
 */

#define DATAPORT 0  // 0=A, 1=B

#define EOI   6    // 5 OUT
#define DAV   3    // 6 IN/OUT
#define NRFD  4    // 7 IN/OUT
#define NDAC  5    // 8 IN/OUT
#define IFC   0    // 9 OUT
#define SRQ   7    // 10 IN
#define ATN   2    // 11 OUT
#define REN   1    // 17 OUT

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

// command

#define UNL 0x3f
#define UNT 0x5f

// universal command

#define LLO 0x11
#define DCL 0x14
#define PPU 0x15
#define SPE 0x18
#define SPD 0x19

// address command

#define GTL 0x01
#define SDC 0x04
#define PPC 0x05
#define GET 0x08
#define TCT 0x09

// timming value

#define MAXRETRY 1000
#define LOOPWAIT 100
#define ATNPAUSE 100

// internal function

int ftgpib_write(unsigned char data);
int ftgpib_read(unsigned char *data);
int ftgpib_settalker();
int ftgpib_setlistener();

// api function (return 1 = Success,0 = Error)

int ftgpib_ifc();
int ftgpib_ren(int val);
int ftgpib_dcl();
int ftgpib_llo();
int ftgpib_sdc(int taraddr);
int ftgpib_get(int taraddr);
int ftgpib_tct(int taraddr);
int ftgpib_talk(int taraddr, char *buf, int useeoi);
int ftgpib_listen(int taraddr, char *buf, int bufsize, int useeoi);
int ftgpib_init(int addr, int ftdev);
void ftgpib_close();

// debug function

void ftgpib_debug();
int ftgpib_test(int addr, char *buf, int bufsize);
