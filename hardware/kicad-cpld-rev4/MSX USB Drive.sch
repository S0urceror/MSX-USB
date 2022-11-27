EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L power:VCC #PWR02
U 1 1 5D24690A
P 2035 4735
F 0 "#PWR02" H 2035 4585 50  0001 C CNN
F 1 "VCC" V 2053 4862 50  0000 L CNN
F 2 "" H 2035 4735 50  0001 C CNN
F 3 "" H 2035 4735 50  0001 C CNN
	1    2035 4735
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR01
U 1 1 5D2482CD
P 2035 4335
F 0 "#PWR01" H 2035 4085 50  0001 C CNN
F 1 "GND" V 2040 4207 50  0000 R CNN
F 2 "" H 2035 4335 50  0001 C CNN
F 3 "" H 2035 4335 50  0001 C CNN
	1    2035 4335
	0    -1   -1   0   
$EndComp
Text GLabel 2035 2935 2    50   Input ~ 0
IORQ_
Text GLabel 835  1135 0    50   Input ~ 0
A0
Text GLabel 2035 3535 2    50   Input ~ 0
RD_
Text GLabel 2035 3335 2    50   Input ~ 0
WR_
Text GLabel 835  1335 0    50   Input ~ 0
A1
Text GLabel 835  1535 0    50   Input ~ 0
A2
Text GLabel 835  1935 0    50   Input ~ 0
A4
Text GLabel 835  1735 0    50   Input ~ 0
A3
Text GLabel 835  2135 0    50   Input ~ 0
A5
Text GLabel 835  2535 0    50   Input ~ 0
A7
Text GLabel 835  2335 0    50   Input ~ 0
A6
Text GLabel 835  4335 0    50   Input ~ 0
D0
Text GLabel 835  4735 0    50   Input ~ 0
D2
Text GLabel 835  5135 0    50   Input ~ 0
D4
Text GLabel 835  5535 0    50   Input ~ 0
D6
Text GLabel 835  4535 0    50   Input ~ 0
D1
Text GLabel 835  4935 0    50   Input ~ 0
D3
Text GLabel 835  5335 0    50   Input ~ 0
D5
Text GLabel 835  5735 0    50   Input ~ 0
D7
Text GLabel 2035 2735 2    50   Input ~ 0
BUSDIR_
Text GLabel 2035 1735 2    50   Input ~ 0
SLTSL_
Text GLabel 835  4135 0    50   Input ~ 0
A15
Text GLabel 835  3735 0    50   Input ~ 0
A13
$Comp
L Device:C C2
U 1 1 5E7F708E
P 6000 5540
F 0 "C2" H 6115 5586 50  0000 L CNN
F 1 "0.1 uF" H 6115 5495 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 6038 5390 50  0001 C CNN
F 3 "~" H 6000 5540 50  0001 C CNN
	1    6000 5540
	1    0    0    -1  
$EndComp
$Comp
L Device:C C3
U 1 1 5E7FAB1D
P 6500 5540
F 0 "C3" H 6615 5586 50  0000 L CNN
F 1 "0.1 uF" H 6615 5495 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 6538 5390 50  0001 C CNN
F 3 "~" H 6500 5540 50  0001 C CNN
	1    6500 5540
	1    0    0    -1  
$EndComp
$Comp
L Device:C C4
U 1 1 5E7FE759
P 7000 5540
F 0 "C4" H 7115 5586 50  0000 L CNN
F 1 "0.1 uF" H 7115 5495 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.15x1.40mm_HandSolder" H 7038 5390 50  0001 C CNN
F 3 "~" H 7000 5540 50  0001 C CNN
	1    7000 5540
	1    0    0    -1  
$EndComp
Text GLabel 835  2735 0    50   Input ~ 0
A8
Text GLabel 835  2935 0    50   Input ~ 0
A9
Text GLabel 835  3135 0    50   Input ~ 0
A10
Text GLabel 835  3335 0    50   Input ~ 0
A11
Text GLabel 835  3535 0    50   Input ~ 0
A12
$Comp
L power:GND #PWR012
U 1 1 5E7FAB13
P 6500 5940
F 0 "#PWR012" H 6500 5690 50  0001 C CNN
F 1 "GND" H 6505 5767 50  0000 C CNN
F 2 "" H 6500 5940 50  0001 C CNN
F 3 "" H 6500 5940 50  0001 C CNN
	1    6500 5940
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR011
U 1 1 5E7FAB09
P 6500 5140
F 0 "#PWR011" H 6500 4990 50  0001 C CNN
F 1 "VCC" H 6517 5313 50  0000 C CNN
F 2 "" H 6500 5140 50  0001 C CNN
F 3 "" H 6500 5140 50  0001 C CNN
	1    6500 5140
	1    0    0    -1  
$EndComp
Wire Wire Line
	6500 5790 6500 5940
Wire Wire Line
	6000 5690 6000 5790
Wire Wire Line
	6000 5790 6500 5790
Wire Wire Line
	6500 5690 6500 5790
Connection ~ 6500 5790
Wire Wire Line
	7000 5690 7000 5790
Wire Wire Line
	7000 5790 6500 5790
Wire Wire Line
	6500 5240 6500 5140
Wire Wire Line
	6500 5240 6500 5390
Connection ~ 6500 5240
Wire Wire Line
	6000 5390 6000 5240
Wire Wire Line
	6000 5240 6500 5240
Wire Wire Line
	7000 5390 7000 5240
Wire Wire Line
	7000 5240 6500 5240
$Comp
L msx-con:MSX_CON EDG1
U 1 1 5E82E456
P 1435 3735
F 0 "EDG1" H 1435 3735 45  0001 C CNN
F 1 "MSX_CON" H 1435 3735 45  0001 C CNN
F 2 "msx-usb-kicad-cpld:msx-con-MSXCART" H 1465 3885 20  0001 C CNN
F 3 "" H 1435 3735 50  0001 C CNN
	1    1435 3735
	0    -1   -1   0   
$EndComp
NoConn ~ 2035 3935
NoConn ~ 835  5935
Wire Wire Line
	2035 5535 2035 5335
Wire Wire Line
	2035 4735 2035 4535
Wire Wire Line
	2035 4135 2035 4335
Connection ~ 2035 4735
Connection ~ 2035 4335
$Comp
L Connector_Generic:Conn_02x08_Odd_Even J2
U 1 1 5D243AE7
P 9800 1690
F 0 "J2" H 9850 2207 50  0000 C CNN
F 1 "Conn_02x08_Odd_Even" H 9850 2116 50  0000 C CNN
F 2 "msx-usb-kicad-cpld:PinHeader_2x08_P2.54mm_Vertical" H 9800 1690 50  0001 C CNN
F 3 "~" H 9800 1690 50  0001 C CNN
	1    9800 1690
	1    0    0    -1  
$EndComp
Text GLabel 10100 1690 2    50   Input ~ 0
A0
Text GLabel 10100 1490 2    50   Input ~ 0
RD_
Text GLabel 10100 1390 2    50   Input ~ 0
WR_
Text GLabel 10100 1590 2    50   Input ~ 0
CS_
$Comp
L power:GND #PWR014
U 1 1 5D2519F2
P 10100 2090
F 0 "#PWR014" H 10100 1840 50  0001 C CNN
F 1 "GND" V 10105 1962 50  0000 R CNN
F 2 "" H 10100 2090 50  0001 C CNN
F 3 "" H 10100 2090 50  0001 C CNN
	1    10100 2090
	0    -1   -1   0   
$EndComp
$Comp
L power:VCC #PWR013
U 1 1 5D252457
P 10100 1890
F 0 "#PWR013" H 10100 1740 50  0001 C CNN
F 1 "VCC" V 10117 2018 50  0000 L CNN
F 2 "" H 10100 1890 50  0001 C CNN
F 3 "" H 10100 1890 50  0001 C CNN
	1    10100 1890
	0    1    1    0   
$EndComp
Text GLabel 9600 2090 0    50   Input ~ 0
D0
Text GLabel 9600 1990 0    50   Input ~ 0
D1
Text GLabel 9600 1890 0    50   Input ~ 0
D2
Text GLabel 9600 1790 0    50   Input ~ 0
D3
Text GLabel 9600 1690 0    50   Input ~ 0
D4
Text GLabel 9600 1590 0    50   Input ~ 0
D5
Text GLabel 9600 1490 0    50   Input ~ 0
D6
Text GLabel 9600 1390 0    50   Input ~ 0
D7
Wire Wire Line
	10100 1990 10100 2090
Connection ~ 10100 2090
NoConn ~ 10100 1790
Text GLabel 10945 3265 2    50   Input ~ 0
D0
Text GLabel 10945 3365 2    50   Input ~ 0
D1
Text GLabel 10945 3465 2    50   Input ~ 0
D2
Text GLabel 10945 3565 2    50   Input ~ 0
D3
Text GLabel 10945 3665 2    50   Input ~ 0
D4
Text GLabel 10945 3765 2    50   Input ~ 0
D5
Text GLabel 10945 3865 2    50   Input ~ 0
D6
Text GLabel 10945 3965 2    50   Input ~ 0
D7
Text GLabel 9745 3265 0    50   Input ~ 0
A0
Text GLabel 9745 3365 0    50   Input ~ 0
A1
Text GLabel 9745 3465 0    50   Input ~ 0
A2
Text GLabel 9745 3565 0    50   Input ~ 0
A3
Text GLabel 9745 3665 0    50   Input ~ 0
A4
Text GLabel 9745 3765 0    50   Input ~ 0
A5
Text GLabel 9745 3865 0    50   Input ~ 0
A6
Text GLabel 9745 3965 0    50   Input ~ 0
A7
Text GLabel 9745 4065 0    50   Input ~ 0
A8
Text GLabel 9745 4165 0    50   Input ~ 0
A9
Text GLabel 9745 4265 0    50   Input ~ 0
A10
Text GLabel 9745 4365 0    50   Input ~ 0
A11
Text GLabel 9745 4465 0    50   Input ~ 0
A12
$Comp
L Memory_Flash:SST39SF040 U5
U 1 1 5DB86845
P 10345 4465
F 0 "U5" H 10345 5946 50  0000 L CNN
F 1 "AM29f040" H 10345 5855 50  0000 L CNN
F 2 "msx-usb-kicad-cpld:PLCC-32_THT-Socket" H 10345 4765 50  0001 C CNN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/25022B.pdf" H 10345 4765 50  0001 C CNN
	1    10345 4465
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR018
U 1 1 5DBA29A0
P 10345 5815
F 0 "#PWR018" H 10345 5565 50  0001 C CNN
F 1 "GND" H 10350 5642 50  0000 C CNN
F 2 "" H 10345 5815 50  0001 C CNN
F 3 "" H 10345 5815 50  0001 C CNN
	1    10345 5815
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR017
U 1 1 5DBA455B
P 10345 2765
F 0 "#PWR017" H 10345 2615 50  0001 C CNN
F 1 "VCC" H 10362 2938 50  0000 C CNN
F 2 "" H 10345 2765 50  0001 C CNN
F 3 "" H 10345 2765 50  0001 C CNN
	1    10345 2765
	1    0    0    -1  
$EndComp
Wire Wire Line
	10345 3165 10345 2765
Text GLabel 9745 5465 0    50   Input ~ 0
SLTSL_
Text GLabel 9745 5565 0    50   Input ~ 0
RD_
Text GLabel 9745 5265 0    50   Input ~ 0
WR_
Wire Wire Line
	10345 5815 10345 5665
$Comp
L EPM7064_(44-PLCC):EPM7032_7064 U1
U 1 1 5E86BBA0
P 5935 2830
F 0 "U1" H 5935 4633 60  0000 C CNN
F 1 "EPM7032_7064" H 5935 4527 60  0000 C CNN
F 2 "msx-usb-kicad-cpld:PLCC44" H 5935 2830 60  0001 C CNN
F 3 "" H 5935 2830 60  0000 C CNN
	1    5935 2830
	1    0    0    -1  
$EndComp
Text GLabel 7085 3330 2    50   Input ~ 0
A1
Text GLabel 4785 1980 0    50   Input ~ 0
CS_
Text GLabel 4785 2130 0    50   Input ~ 0
BUSDIR_
Text GLabel 7085 1880 2    50   Input ~ 0
SLTSL_
Text GLabel 4785 3380 0    50   Input ~ 0
A4
Text GLabel 4785 3230 0    50   Input ~ 0
A5
Text GLabel 4785 2280 0    50   Input ~ 0
D5
Text GLabel 7085 3680 2    50   Input ~ 0
A3
Text GLabel 4785 2830 0    50   Input ~ 0
D0
Text GLabel 4785 2730 0    50   Input ~ 0
D1
Text GLabel 7085 3130 2    50   Input ~ 0
A15
Text GLabel 7085 2930 2    50   Input ~ 0
A13
Text GLabel 4785 3130 0    50   Input ~ 0
A6
Text GLabel 4785 1830 0    50   Input ~ 0
IORQ_
Text GLabel 4785 2380 0    50   Input ~ 0
D4
Text GLabel 7085 2130 2    50   Input ~ 0
MA13
Text GLabel 4785 2580 0    50   Input ~ 0
D2
Text GLabel 7085 2330 2    50   Input ~ 0
MA14
Text GLabel 7085 3530 2    50   Input ~ 0
A2
Text GLabel 7085 2530 2    50   Input ~ 0
MA16
Text GLabel 7085 2430 2    50   Input ~ 0
MA15
Text GLabel 7085 2730 2    50   Input ~ 0
MA18
Text GLabel 7085 2630 2    50   Input ~ 0
MA17
Text GLabel 7085 3230 2    50   Input ~ 0
A0
Text GLabel 7085 1630 2    50   Input ~ 0
RD_
Text GLabel 4785 2480 0    50   Input ~ 0
D3
Text GLabel 7085 2030 2    50   Input ~ 0
WR_
Text GLabel 4785 3030 0    50   Input ~ 0
A7
Text GLabel 9745 4565 0    50   Input ~ 0
MA13
Text GLabel 9745 4665 0    50   Input ~ 0
MA14
Text GLabel 9745 4765 0    50   Input ~ 0
MA15
Text GLabel 9745 4865 0    50   Input ~ 0
MA16
Text GLabel 9745 4965 0    50   Input ~ 0
MA17
Text GLabel 9745 5065 0    50   Input ~ 0
MA18
$Comp
L power:GND #PWR0102
U 1 1 5E848649
P 1435 7485
F 0 "#PWR0102" H 1435 7235 50  0001 C CNN
F 1 "GND" H 1440 7312 50  0000 C CNN
F 2 "" H 1435 7485 50  0001 C CNN
F 3 "" H 1435 7485 50  0001 C CNN
	1    1435 7485
	1    0    0    -1  
$EndComp
NoConn ~ 1935 6585
NoConn ~ 1935 6685
Text GLabel 1935 6785 2    50   Input ~ 0
TCK
Text GLabel 1935 6885 2    50   Input ~ 0
TMS
Text GLabel 1935 6985 2    50   Input ~ 0
TDO
Text GLabel 1935 7085 2    50   Input ~ 0
TDI
Text GLabel 4785 3880 0    50   Input ~ 0
TCK
Text GLabel 4785 3780 0    50   Input ~ 0
TMS
Text GLabel 4785 3980 0    50   Input ~ 0
TDO
Text GLabel 4785 3680 0    50   Input ~ 0
TDI
Wire Wire Line
	5835 4430 5935 4430
Connection ~ 5935 4430
Wire Wire Line
	5935 4430 6035 4430
Connection ~ 6035 4430
Wire Wire Line
	6035 4430 6185 4430
$Comp
L power:GND #PWR0103
U 1 1 5E84AE0F
P 6185 4430
F 0 "#PWR0103" H 6185 4180 50  0001 C CNN
F 1 "GND" H 6190 4257 50  0000 C CNN
F 2 "" H 6185 4430 50  0001 C CNN
F 3 "" H 6185 4430 50  0001 C CNN
	1    6185 4430
	1    0    0    -1  
$EndComp
Connection ~ 6185 4430
Wire Wire Line
	5885 1230 5985 1230
Connection ~ 5985 1230
Wire Wire Line
	5985 1230 6085 1230
Connection ~ 6085 1230
Wire Wire Line
	6085 1230 6185 1230
$Comp
L power:VCC #PWR0104
U 1 1 5E84BF99
P 6185 980
F 0 "#PWR0104" H 6185 830 50  0001 C CNN
F 1 "VCC" H 6202 1153 50  0000 C CNN
F 2 "" H 6185 980 50  0001 C CNN
F 3 "" H 6185 980 50  0001 C CNN
	1    6185 980 
	1    0    0    -1  
$EndComp
Connection ~ 6185 1230
Wire Wire Line
	6185 980  6185 1230
$Comp
L Device:C C1
U 1 1 5E84DCA7
P 5500 5540
F 0 "C1" H 5615 5586 50  0000 L CNN
F 1 "100 uF" H 5615 5495 50  0000 L CNN
F 2 "Capacitor_THT:CP_Radial_D5.0mm_P2.50mm" H 5538 5390 50  0001 C CNN
F 3 "~" H 5500 5540 50  0001 C CNN
	1    5500 5540
	1    0    0    -1  
$EndComp
Wire Wire Line
	5500 5390 5500 5240
Wire Wire Line
	5500 5240 6000 5240
Connection ~ 6000 5240
Wire Wire Line
	6000 5790 5500 5790
Wire Wire Line
	5500 5790 5500 5690
Connection ~ 6000 5790
Text GLabel 2035 3735 2    50   Input ~ 0
RESET_
Text GLabel 7085 1730 2    50   Input ~ 0
RESET_
NoConn ~ 4785 1630
NoConn ~ 4785 1730
$Comp
L Connector:AVR-JTAG-10 J1
U 1 1 5E822CA8
P 1435 6885
F 0 "J1" H 1055 6931 50  0000 R CNN
F 1 "AVR-JTAG-10" H 1055 6840 50  0000 R CNN
F 2 "msx-usb-kicad-cpld:PinHeader_2x05_P2.54mm_Vertical" V 1285 7035 50  0001 C CNN
F 3 " ~" H 160 6335 50  0001 C CNN
	1    1435 6885
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR0101
U 1 1 5E8479A5
P 1335 6285
F 0 "#PWR0101" H 1335 6135 50  0001 C CNN
F 1 "VCC" H 1352 6458 50  0000 C CNN
F 2 "" H 1335 6285 50  0001 C CNN
F 3 "" H 1335 6285 50  0001 C CNN
	1    1335 6285
	1    0    0    -1  
$EndComp
NoConn ~ 1435 6285
Text GLabel 4785 2930 0    50   Input ~ 0
A12
Text GLabel 3550 3485 2    50   Input ~ 0
A0
Text GLabel 3050 3485 0    50   Input ~ 0
A1
Text GLabel 3550 3585 2    50   Input ~ 0
A2
Text GLabel 3550 3685 2    50   Input ~ 0
A4
Text GLabel 3050 3585 0    50   Input ~ 0
A3
Text GLabel 3050 3685 0    50   Input ~ 0
A5
Text GLabel 3050 3185 0    50   Input ~ 0
A7
Text GLabel 3550 3185 2    50   Input ~ 0
A6
Text GLabel 3550 3785 2    50   Input ~ 0
D0
Text GLabel 3550 3885 2    50   Input ~ 0
D2
Text GLabel 3550 3985 2    50   Input ~ 0
D4
Text GLabel 3550 4085 2    50   Input ~ 0
D6
Text GLabel 3050 3785 0    50   Input ~ 0
D1
Text GLabel 3050 3885 0    50   Input ~ 0
D3
Text GLabel 3050 3985 0    50   Input ~ 0
D5
Text GLabel 3050 4085 0    50   Input ~ 0
D7
Text GLabel 3550 2985 2    50   Input ~ 0
A15
Text GLabel 3550 3385 2    50   Input ~ 0
A13
Text GLabel 3550 3285 2    50   Input ~ 0
A8
Text GLabel 3050 2985 0    50   Input ~ 0
A9
Text GLabel 3550 3085 2    50   Input ~ 0
A10
Text GLabel 3050 3085 0    50   Input ~ 0
A11
Text GLabel 3050 3285 0    50   Input ~ 0
A12
NoConn ~ 3050 2385
Text GLabel 3550 2285 2    50   Input ~ 0
SLTSL_
Text GLabel 3050 2685 0    50   Input ~ 0
IORQ_
Text GLabel 3550 2785 2    50   Input ~ 0
RD_
Text GLabel 3050 2785 0    50   Input ~ 0
WR_
Text GLabel 3550 2585 2    50   Input ~ 0
BUSDIR_
Text GLabel 3050 2885 0    50   Input ~ 0
RESET_
NoConn ~ 3550 2885
$Comp
L power:VCC #PWR0105
U 1 1 610BFA8E
P 3050 4485
F 0 "#PWR0105" H 3050 4335 50  0001 C CNN
F 1 "VCC" V 3068 4612 50  0000 L CNN
F 2 "" H 3050 4485 50  0001 C CNN
F 3 "" H 3050 4485 50  0001 C CNN
	1    3050 4485
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR0106
U 1 1 610C3E3E
P 3050 4285
F 0 "#PWR0106" H 3050 4035 50  0001 C CNN
F 1 "GND" V 3055 4157 50  0000 R CNN
F 2 "" H 3050 4285 50  0001 C CNN
F 3 "" H 3050 4285 50  0001 C CNN
	1    3050 4285
	0    1    1    0   
$EndComp
Wire Wire Line
	3050 4185 3050 4285
Wire Wire Line
	3050 4385 3050 4485
Text GLabel 9235 3235 2    50   Input ~ 0
D0
Text GLabel 9235 3335 2    50   Input ~ 0
D1
Text GLabel 9235 3435 2    50   Input ~ 0
D2
Text GLabel 9235 3535 2    50   Input ~ 0
D3
Text GLabel 9235 3635 2    50   Input ~ 0
D4
Text GLabel 9235 3735 2    50   Input ~ 0
D5
Text GLabel 9235 3835 2    50   Input ~ 0
D6
Text GLabel 9235 3935 2    50   Input ~ 0
D7
Text GLabel 8035 3235 0    50   Input ~ 0
A0
Text GLabel 8035 3335 0    50   Input ~ 0
A1
Text GLabel 8035 3435 0    50   Input ~ 0
A2
Text GLabel 8035 3535 0    50   Input ~ 0
A3
Text GLabel 8035 3635 0    50   Input ~ 0
A4
Text GLabel 8035 3735 0    50   Input ~ 0
A5
Text GLabel 8035 3835 0    50   Input ~ 0
A6
Text GLabel 8035 3935 0    50   Input ~ 0
A7
Text GLabel 8035 4035 0    50   Input ~ 0
A8
Text GLabel 8035 4135 0    50   Input ~ 0
A9
Text GLabel 8035 4235 0    50   Input ~ 0
A10
Text GLabel 8035 4335 0    50   Input ~ 0
A11
Text GLabel 8035 4435 0    50   Input ~ 0
A12
$Comp
L Memory_Flash:SST39SF040 U2
U 1 1 610FF941
P 8635 4435
F 0 "U2" H 8635 5916 50  0000 L CNN
F 1 "AM29f040" H 8635 5825 50  0000 L CNN
F 2 "msx-usb-kicad-cpld:DIP-32_W15.24mm_Socket" H 8635 4735 50  0001 C CNN
F 3 "http://ww1.microchip.com/downloads/en/DeviceDoc/25022B.pdf" H 8635 4735 50  0001 C CNN
	1    8635 4435
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0107
U 1 1 610FF947
P 8635 5785
F 0 "#PWR0107" H 8635 5535 50  0001 C CNN
F 1 "GND" H 8640 5612 50  0000 C CNN
F 2 "" H 8635 5785 50  0001 C CNN
F 3 "" H 8635 5785 50  0001 C CNN
	1    8635 5785
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR0108
U 1 1 610FF94D
P 8635 2735
F 0 "#PWR0108" H 8635 2585 50  0001 C CNN
F 1 "VCC" H 8652 2908 50  0000 C CNN
F 2 "" H 8635 2735 50  0001 C CNN
F 3 "" H 8635 2735 50  0001 C CNN
	1    8635 2735
	1    0    0    -1  
$EndComp
Wire Wire Line
	8635 3135 8635 2735
Text GLabel 8035 5435 0    50   Input ~ 0
SLTSL_
Text GLabel 8035 5535 0    50   Input ~ 0
RD_
Text GLabel 8035 5235 0    50   Input ~ 0
WR_
Wire Wire Line
	8635 5785 8635 5635
Text GLabel 8035 4535 0    50   Input ~ 0
MA13
Text GLabel 8035 4635 0    50   Input ~ 0
MA14
Text GLabel 8035 4735 0    50   Input ~ 0
MA15
Text GLabel 8035 4835 0    50   Input ~ 0
MA16
Text GLabel 8035 4935 0    50   Input ~ 0
MA17
Text GLabel 8035 5035 0    50   Input ~ 0
MA18
$Comp
L Connector_Generic:Conn_02x25_Odd_Even J3
U 1 1 60FF3953
P 3250 3385
F 0 "J3" H 3300 4802 50  0000 C CNN
F 1 "Conn_02x25_Odd_Even" H 3300 4711 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_2x25_P2.54mm_Vertical" H 3250 3385 50  0001 C CNN
F 3 "~" H 3250 3385 50  0001 C CNN
	1    3250 3385
	1    0    0    -1  
$EndComp
Connection ~ 3050 4485
Connection ~ 3050 4285
Text GLabel 835  3935 0    50   Input ~ 0
A14
Text GLabel 3050 3385 0    50   Input ~ 0
A14
Text GLabel 3050 2285 0    50   Input ~ 0
CS12
Text GLabel 3050 4585 0    50   Input ~ 0
SOUNDIN
Text GLabel 3050 2485 0    50   Input ~ 0
WAIT
Text GLabel 3050 2585 0    50   Input ~ 0
M1
Text GLabel 3550 2185 2    50   Input ~ 0
CS2
Text GLabel 3550 2385 2    50   Input ~ 0
RFSH
Text GLabel 3550 2485 2    50   Input ~ 0
INT
Text GLabel 3550 2685 2    50   Input ~ 0
MREQ
Text GLabel 3550 4185 2    50   Input ~ 0
CLOCK
Text GLabel 3050 2185 0    50   Input ~ 0
CS1
Text GLabel 3550 4485 2    50   Input ~ 0
+12V
Text GLabel 3550 4585 2    50   Input ~ 0
-12V
Text GLabel 3550 4285 2    50   Input ~ 0
SW1
Text GLabel 3550 4385 2    50   Input ~ 0
SW2
Text GLabel 2035 5735 2    50   Input ~ 0
+12V
Text GLabel 2035 5935 2    50   Input ~ 0
-12V
Text GLabel 2035 4935 2    50   Input ~ 0
SOUNDIN
Text GLabel 2035 5135 2    50   Input ~ 0
CLOCK
Text GLabel 2035 2335 2    50   Input ~ 0
INT
Text GLabel 2035 2535 2    50   Input ~ 0
M1
Text GLabel 2035 2135 2    50   Input ~ 0
WAIT
Text GLabel 2035 1935 2    50   Input ~ 0
RFSH
Text GLabel 2035 1535 2    50   Input ~ 0
CS12
Text GLabel 2035 1135 2    50   Input ~ 0
CS1
Text GLabel 2035 1335 2    50   Input ~ 0
CS2
Text GLabel 2035 3135 2    50   Input ~ 0
MREQ
Text GLabel 2035 5335 2    50   Input ~ 0
SW1
Text GLabel 2035 5535 2    50   Input ~ 0
SW2
$EndSCHEMATC
