/*
 *  pickit2.h
 *  Monkey
 *
 *  Created by hiroki on 17/07/26.
 *  Copyright 2017 __MyCompanyName__. All rights reserved.
 *
 */

#include <Carbon/Carbon.h>

enum FWCommands
{
	FWCMD_ENTER_BOOTLOADER           = 0x42,
	FWCMD_NO_OPERATION               = 0x5A,
	FWCMD_FIRMWARE_VERSION           = 0x76,
	FWCMD_SETVDD                     = 0xA0,
	FWCMD_SETVPP                     = 0xA1,
	FWCMD_READ_STATUS                = 0xA2,
	FWCMD_READ_VOLTAGES              = 0xA3,
	FWCMD_DOWNLOAD_SCRIPT            = 0xA4,
	FWCMD_RUN_SCRIPT                 = 0xA5,
	FWCMD_EXECUTE_SCRIPT             = 0xA6,
	FWCMD_CLR_DOWNLOAD_BUFFER        = 0xA7,
	FWCMD_DOWNLOAD_DATA              = 0xA8,
	FWCMD_CLR_UPLOAD_BUFFER          = 0xA9,
	FWCMD_UPLOAD_DATA                = 0xAA,
	FWCMD_CLR_SCRIPT_BUFFER          = 0xAB,
	FWCMD_UPLOAD_DATA_NOLEN          = 0xAC,
	FWCMD_END_OF_BUFFER              = 0xAD,
	FWCMD_RESET                      = 0xAE,
	FWCMD_SCRIPT_BUFFER_CHKSM        = 0xAF,
	FWCMD_WR_INTERNAL_EE             = 0xB1,
	FWCMD_RD_INTERNAL_EE             = 0xB2,
	FWCMD_LOGIC_ANALYZER_GO          = 0xB8,
	FWCMD_COPY_RAM_UPLOAD            = 0xB9
};

int pk2_usb_init();
CFDataRef pk2_usb_start(int ch1, int ch2, int ch3, int count, int sample, int window);
void pk2_usb_cancel();
void pk2_usb_close();