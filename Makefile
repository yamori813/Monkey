cplib:
	cp ../FT_D2XX_Lib.1.1.0/D2XX/bin/10.5-10.7/libftd2xx.1.1.0.dylib .
	install_name_tool -id @executable_path/../Frameworks/libftd2xx.1.1.0.dylib libftd2xx.1.1.0.dylib
	cp ../FT_D2XX_Lib.1.1.0/D2XX/bin/ftd2xx.h .
	cp ../FT_D2XX_Lib.1.1.0/D2XX/bin/WinTypes.h .
