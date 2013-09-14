#
# copy ftdi lib
#

FTLIBPATH = ../FT_D2XX_Lib.1.1.0/
ARCHTYPE = 10.5-10.7
LOCALPATH = @executable_path/../Frameworks/libftd2xx.1.1.0.dylib

cplib:
	cp $(FTLIBPATH)/D2XX/bin/$(ARCHTYPE)/libftd2xx.1.1.0.dylib .
	install_name_tool -id $(LOCALPATH) libftd2xx.1.1.0.dylib
	cp $(FTLIBPATH)/D2XX/bin/ftd2xx.h . 
	cp $(FTLIBPATH)/D2XX/bin/WinTypes.h .
