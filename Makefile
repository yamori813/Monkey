#
# copy ftdi lib
#

FTLIBVER = 1.1.0
ARCHTYPE = 10.5-10.7

LOCALPATH = @executable_path/../Frameworks/libftd2xx.dylib

cplib:
	cp ../FT_D2XX_Lib.$(FTLIBVER)/D2XX/bin/$(ARCHTYPE)/libftd2xx.$(FTLIBVER).dylib libftd2xx.dylib 
	install_name_tool -id $(LOCALPATH) libftd2xx.dylib
	cp ../FT_D2XX_Lib.$(FTLIBVER)/D2XX/bin/ftd2xx.h . 
	cp ../FT_D2XX_Lib.$(FTLIBVER)/D2XX/bin/WinTypes.h .
