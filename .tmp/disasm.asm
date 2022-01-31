L0154:       equ  0154h
L01FD:       equ  01FDh
L025D:       equ  025Dh
L03F5:       equ  03F5h
L0EB1:       equ  0EB1h
L0F9B:       equ  0F9Bh
L1E8A:       equ  1E8Ah
L1EC8:       equ  1EC8h
L1F15:       equ  1F15h
L1F3B:       equ  1F3Bh
L4042:       equ  4042h
L416C:       equ  416Ch
L417F:       equ  417Fh
L4305:       equ  4305h
LBDB1:       equ  BDB1h
LBDB5:       equ  BDB5h
LBDBF:       equ  BDBFh
LF1F1:       equ  F1F1h


             org 0020h


0020 L0020:
0020 00           NOP         
0021 00           NOP         
0022 00           NOP         
0023 00           NOP         
0024 C3 F1 F1     JP   LF1F1  


0027 00           defb 00h    
0028 C3           defb C3h    
0029 06           defb 06h    
002A C2           defb C2h    
002B 00           defb 00h    
002C 00           defb 00h    
002D 00           defb 00h    
002E 00           defb 00h    
002F 00           defb 00h    
0030 C3           defb C3h    
0031 F4           defb F4h    
0032 F1           defb F1h    
0033 00           defb 00h    
0034 00           defb 00h    
0035 00           defb 00h    
0036 00           defb 00h    
0037 00           defb 00h    
0038 08           defb 08h    
0039 D9           defb D9h    
003A F5           defb F5h    
003B C5           defb C5h    
003C D5           defb D5h    
003D E5           defb E5h    
003E 08           defb 08h    
003F D9           defb D9h    
0040 DD           defb DDh    
0041 E5           defb E5h    
0042 FD           defb FDh    
0043 E5           defb E5h    
0044 DD           defb DDh    
0045 21           defb 21h    
0046 38           defb 38h    
0047 00           defb 00h    
0048 FD           defb FDh    
0049 2A           defb 2Ah    
004A C0           defb C0h    
004B FC           defb FCh    
004C CD           defb CDh    
004D 8D           defb 8Dh    
004E 05           defb 05h    
004F FD           defb FDh    
0050 E1           defb E1h    
0051 DD           defb DDh    
0052 E1           defb E1h    
0053 08           defb 08h    
0054 D9           defb D9h    
0055 E1           defb E1h    
0056 D1           defb D1h    
0057 C1           defb C1h    
0058 F1           defb F1h    
0059 08           defb 08h    
005A D9           defb D9h    
005B FB           defb FBh    
005C ED           defb EDh    
005D 4D           defb 4Dh    
005E 00           defb 00h    
005F 00           defb 00h    
0060 00           defb 00h    
0061 00           defb 00h    
0062 00           defb 00h    
0063 00           defb 00h    
0064 00           defb 00h    
0065 00           defb 00h    
0066 C3           defb C3h    
0067 D6           defb D6h    
0068 FD           defb FDh    
0069 FB           defb FBh    
006A C3           defb C3h    
006B 51           defb 51h    
006C 26           defb 26h    
006D FB           defb FBh    
006E C3           defb C3h    
006F 56           defb 56h    
0070 25           defb 25h    
0071 FB           defb FBh    
0072 C3           defb C3h    
0073 6F           defb 6Fh    
0074 25           defb 25h    
0075 FB           defb FBh    
0076 C3           defb C3h    
0077 07           defb 07h    
0078 26           defb 26h    
0079 FB           defb FBh    
007A C3           defb C3h    
007B 2A           defb 2Ah    
007C 26           defb 26h    
007D FB           defb FBh    
007E C3           defb C3h    
007F 3F           defb 3Fh    
0080 26           defb 26h    
0081 FB           defb FBh    
0082 C3           defb C3h    
0083 48           defb 48h    


             org 00D5h


00D5 L00D5:
00D5 CD 42 40     CALL L4042  
00D8 FD E1        POP  IY     
00DA 21 56 01     LD   HL,0156h 
00DD L00DD:
00DD 7E           LD   A,(HL) 
00DE B7           OR   A      
00DF 28 34        JR   Z,L0115 
00E1 23           INC  HL     
00E2 E5           PUSH HL     
00E3 21 2B 00     LD   HL,002Bh 
00E6 CD FD 01     CALL L01FD  
00E9 D1           POP  DE     
00EA 3E 06        LD   A,06h  
00EC 20 66        JR   NZ,L0154 
00EE ED 4B B5 BD  LD   BC,(LBDB5) 
00F2 22 B5 BD     LD   (LBDB5),HL 
00F5 71           LD   (HL),C 
00F6 23           INC  HL     
00F7 70           LD   (HL),B 
00F8 23           INC  HL     
00F9 EB           EX   DE,HL  
00FA ED A0        LDI         
00FC ED A0        LDI         
00FE EB           EX   DE,HL  
00FF 01 06 00     LD   BC,0006h 
0102 09           ADD  HL,BC  
0103 EB           EX   DE,HL  
0104 01 0C 00     LD   BC,000Ch 
0107 ED B0        LDIR        
0109 3E 80        LD   A,80h  
010B 12           LD   (DE),A 
010C 06 14        LD   B,14h  
010E AF           XOR  A      
010F L010F:
010F 13           INC  DE     
0110 12           LD   (DE),A 
0111 10 FC        DJNZ L010F  
0113 18 C8        JR   L00DD  
0115 L0115:
0115 06 05        LD   B,05h  
0117 CD B1 0E     CALL L0EB1  
011A 06 00        LD   B,00h  
011C CD 48 1E     CALL L1E48  
011F FD E5        PUSH IY     
0121 08           EX   AF,AF' 
0122 3E 04        LD   A,04h  
0124 DD 21 A8 41  LD   IX,41A8h 
0128 CD 42 40     CALL L4042  
012B FD E1        POP  IY     
012D CD F5 03     CALL L03F5  
0130 21 A2 01     LD   HL,01A2h 
0133 11 14 B2     LD   DE,B214h 
0136 01 06 00     LD   BC,0006h 


             org 1E05h


1E05 L1E05:
1E05 CD FD 01     CALL L01FD  
1E08 C0           RET  NZ     
1E09 ED 5B B1 BD  LD   DE,(LBDB1) 
1E0D 22 B1 BD     LD   (LBDB1),HL 
1E10 73           LD   (HL),E 
1E11 23           INC  HL     
1E12 72           LD   (HL),D 
1E13 7A           LD   A,D    
1E14 B3           OR   E      
1E15 28 24        JR   Z,L1E3B 
1E17 13           INC  DE     
1E18 06 3F        LD   B,3Fh  
1E1A L1E1A:
1E1A C5           PUSH BC     
1E1B 23           INC  HL     
1E1C 13           INC  DE     
1E1D 1A           LD   A,(DE) 
1E1E 4F           LD   C,A    
1E1F 13           INC  DE     
1E20 1A           LD   A,(DE) 
1E21 47           LD   B,A    
1E22 B1           OR   C      
1E23 28 12        JR   Z,L1E37 
1E25 C5           PUSH BC     
1E26 DD E1        POP  IX     
1E28 DD CB 32 56  BIT  2,(IX+50) 
1E2C 28 09        JR   Z,L1E37 
1E2E CD 3B 1F     CALL L1F3B  
1E31 20 04        JR   NZ,L1E37 
1E33 71           LD   (HL),C 
1E34 23           INC  HL     
1E35 70           LD   (HL),B 
1E36 2B           DEC  HL     
1E37 L1E37:
1E37 23           INC  HL     
1E38 C1           POP  BC     
1E39 10 DF        DJNZ L1E1A  
1E3B L1E3B:
1E3B 3A BF BD     LD   A,(LBDBF) 
1E3E 47           LD   B,A    
1E3F 3C           INC  A      
1E40 32 BF BD     LD   (LBDBF),A 
1E43 CD C8 1E     CALL L1EC8  
1E46 AF           XOR  A      
1E47 C9           RET         


1E48 L1E48:
1E48 78           LD   A,B    
1E49 B7           OR   A      
1E4A 28 07        JR   Z,L1E53 
1E4C 21 BF BD     LD   HL,BDBFh 
1E4F BE           CP   (HL)   
1E50 3E C5        LD   A,C5h  
1E52 D0           RET  NC     
1E53 L1E53:
1E53 CD 9B 0F     CALL L0F9B  
1E56 2A B1 BD     LD   HL,(LBDB1) 
1E59 E5           PUSH HL     
1E5A 7C           LD   A,H    
1E5B B5           OR   L      
1E5C 28 2C        JR   Z,L1E8A 
1E5E C5           PUSH BC     
1E5F E5           PUSH HL     
1E60 CD 5D 02     CALL L025D  
1E63 06 FF        LD   B,FFh  
1E65 04           INC  B      
1E66 CD 15 1F     CALL L1F15  


             org 202Dh


202D L202D:
202D CD           defb CDh    
202E BF           defb BFh    
202F 09           defb 09h    
2030 E1           defb E1h    
2031 F1           defb F1h    
2032 5F           defb 5Fh    
2033 D6           defb D6h    
2034 0E           defb 0Eh    
2035 30           defb 30h    
2036 FC           defb FCh    
2037 C6           defb C6h    
2038 1C           defb 1Ch    
2039 2F           defb 2Fh    
203A 3C           defb 3Ch    
203B 83           defb 83h    
203C 32           defb 32h    
203D B2           defb B2h    
203E F3           defb F3h    
203F C9           defb C9h    
2040 CD           defb CDh    
2041 26           defb 26h    
2042 06           defb 06h    
2043 DA           defb DAh    
2044 46           defb 46h    
2045 05           defb 05h    
2046 D7           defb D7h    
2047 FE           defb FEh    
2048 24           defb 24h    
2049 28           defb 28h    
204A 1A           defb 1Ah    
204B 3E           defb 3Eh    
204C 1F           defb 1Fh    
204D CD           defb CDh    
204E 18           defb 18h    
204F 23           defb 23h    
2050 E5           defb E5h    
2051 CD           defb CDh    
2052 75           defb 75h    
2053 07           defb 07h    
2054 E3           defb E3h    
2055 CF           defb CFh    
2056 EF           defb EFh    
2057 EF           defb EFh    
2058 A7           defb A7h    
2059 FA           defb FAh    
205A 46           defb 46h    
205B 05           defb 05h    
205C 01           defb 01h    
205D 10           defb 10h    
205E 00           defb 00h    
205F E3           defb E3h    
2060 CD           defb CDh    
2061 77           defb 77h    
2062 09           defb 09h    
2063 E1           defb E1h    
2064 C9           defb C9h    
2065 CF           defb CFh    
2066 24           defb 24h    
2067 3E           defb 3Eh    
2068 1F           defb 1Fh    
2069 CD           defb CDh    
206A 18           defb 18h    
206B 23           defb 23h    
206C E5           defb E5h    
206D CD           defb CDh    
206E 75           defb 75h    
206F 07           defb 07h    
2070 E3           defb E3h    
2071 CF           defb CFh    
2072 EF           defb EFh    
2073 CD           defb CDh    
2074 FC           defb FCh    
2075 05           defb 05h    
2076 E5           defb E5h    
2077 CD           defb CDh    
2078 14           defb 14h    
2079 06           defb 06h    
207A 7E           defb 7Eh    
207B FE           defb FEh    
207C 11           defb 11h    
207D 38           defb 38h    
207E 02           defb 02h    
207F 3E           defb 3Eh    
2080 10           defb 10h    
2081 23           defb 23h    
2082 5E           defb 5Eh    
2083 23           defb 23h    
2084 56           defb 56h    
2085 E1           defb E1h    
2086 E3           defb E3h    
2087 A7           defb A7h    
2088 47           defb 47h    
2089 EB           defb EBh    
208A C4           defb C4h    
208B 2B           defb 2Bh    
208C 0F           defb 0Fh    
208D E1           defb E1h    
208E C9           defb C9h    
208F D7           defb D7h    
2090 EF           defb EFh    


             org 40A7h


40A7 L40A7:
40A7 CD           defb CDh    
40A8 62           defb 62h    
40A9 40           defb 40h    
40AA 08           defb 08h    
40AB F1           defb F1h    
40AC CD           defb CDh    
40AD D0           defb D0h    
40AE 7F           defb 7Fh    
40AF 08           defb 08h    
40B0 C9           defb C9h    
40B1 08           defb 08h    
40B2 3A           defb 3Ah    
40B3 19           defb 19h    
40B4 F3           defb F3h    
40B5 DD           defb DDh    
40B6 E5           defb E5h    
40B7 D9           defb D9h    
40B8 E1           defb E1h    
40B9 D9           defb D9h    
40BA DD           defb DDh    
40BB 2A           defb 2Ah    
40BC D0           defb D0h    
40BD F1           defb F1h    
40BE 18           defb 18h    
40BF 07           defb 07h    
40C0 08           defb 08h    
40C1 3E           defb 3Eh    
40C2 07           defb 07h    
40C3 DD           defb DDh    
40C4 21           defb 21h    
40C5 30           defb 30h    
40C6 41           defb 41h    
40C7 D9           defb D9h    
40C8 5F           defb 5Fh    
40C9 3A           defb 3Ah    
40CA FF           defb FFh    
40CB 40           defb 40h    
40CC F5           defb F5h    
40CD 01           defb 01h    
40CE DD           defb DDh    
40CF 40           defb 40h    
40D0 C5           defb C5h    
40D1 DD           defb DDh    
40D2 E5           defb E5h    
40D3 E5           defb E5h    
40D4 DD           defb DDh    
40D5 E1           defb E1h    
40D6 7B           defb 7Bh    
40D7 D9           defb D9h    
40D8 CD           defb CDh    
40D9 D0           defb D0h    
40DA 7F           defb 7Fh    
40DB 08           defb 08h    
40DC C9           defb C9h    
40DD 08           defb 08h    
40DE F1           defb F1h    
40DF CD           defb CDh    
40E0 D0           defb D0h    
40E1 7F           defb 7Fh    
40E2 08           defb 08h    
40E3 C9           defb C9h    
40E4 F5           defb F5h    
40E5 3A           defb 3Ah    
40E6 FF           defb FFh    
40E7 40           defb 40h    
40E8 F5           defb F5h    
40E9 AF           defb AFh    
40EA CD           defb CDh    
40EB D0           defb D0h    
40EC 7F           defb 7Fh    
40ED CD           defb CDh    
40EE 03           defb 03h    
40EF 4E           defb 4Eh    
40F0 F1           defb F1h    
40F1 CD           defb CDh    
40F2 D0           defb D0h    
40F3 7F           defb 7Fh    
40F4 F1           defb F1h    
40F5 C9           defb C9h    
40F6 AF           defb AFh    
40F7 32           defb 32h    
40F8 00           defb 00h    
40F9 50           defb 50h    
40FA C3           defb C3h    
40FB D6           defb D6h    
40FC 47           defb 47h    
40FD 00           defb 00h    
40FE 07           defb 07h    
40FF 07           defb 07h    
4100 4E           defb 4Eh    
4101 45           defb 45h    
4102 58           defb 58h    
4103 54           defb 54h    
4104 4F           defb 4Fh    
4105 52           defb 52h    
4106 5F           defb 5Fh    
4107 44           defb 44h    
4108 52           defb 52h    
4109 49           defb 49h    
410A 56           defb 56h    


             org 4136h


4136 L4136:
4136 C3 6C 41     JP   L416C  


4139 C3           defb C3h    
413A 9B           defb 9Bh    
413B 41           defb 41h    
413C C3           defb C3h    
413D 9D           defb 9Dh    
413E 41           defb 41h    
413F C3           defb C3h    
4140 9F           defb 9Fh    
4141 41           defb 41h    
4142 C3           defb C3h    
4143 A0           defb A0h    
4144 41           defb 41h    
4145 C3           defb C3h    
4146 A0           defb A0h    
4147 41           defb 41h    
4148 C3           defb C3h    
4149 A0           defb A0h    


             org 4151h


4151 L4151:
4151 C3 7F 41     JP   L417F  


4154 FF           defb FFh    
4155 FF           defb FFh    
4156 FF           defb FFh    
4157 FF           defb FFh    
4158 FF           defb FFh    
4159 FF           defb FFh    
415A FF           defb FFh    
415B FF           defb FFh    
415C FF           defb FFh    
415D FF           defb FFh    
415E FF           defb FFh    
415F FF           defb FFh    
4160 C3           defb C3h    
4161 A1           defb A1h    
4162 41           defb 41h    
4163 C3           defb C3h    
4164 A2           defb A2h    


             org 42EEh


42EE L42EE:
42EE DD E5        PUSH IX     
42F0 DD 21 00 00  LD   IX,0000h 
42F4 DD 39        ADD  IX,SP  
42F6 DD 4E 05     LD   C,(IX+5) 
42F9 DD 46 04     LD   B,(IX+4) 
42FC CB 68        BIT  5,B    
42FE 28 05        JR   Z,L4305 
4300 11 01 00     LD   DE,0001h 


             org F38Fh


F38F LF38F:
F38F CD 98 F3     CALL LF398  
F392 08           EX   AF,AF' 
F393 F1           POP  AF     
F394 D3 A8        OUT  (00A8h),A 
F396 08           EX   AF,AF' 
F397 C9           RET         


F398 LF398:
F398 DD E9        JP   (IX)   


F39A 5A           defb 5Ah    
F39B 47           defb 47h    
F39C 5A           defb 5Ah    
F39D 47           defb 47h    
F39E 5A           defb 5Ah    
F39F 47           defb 47h    
F3A0 5A           defb 5Ah    
F3A1 47           defb 47h    
F3A2 5A           defb 5Ah    
F3A3 47           defb 47h    
F3A4 5A           defb 5Ah    
F3A5 47           defb 47h    
F3A6 5A           defb 5Ah    
F3A7 47           defb 47h    
F3A8 5A           defb 5Ah    
F3A9 47           defb 47h    
F3AA 5A           defb 5Ah    
F3AB 47           defb 47h    
F3AC 5A           defb 5Ah    
F3AD 47           defb 47h    
F3AE 25           defb 25h    
F3AF 1D           defb 1Dh    
F3B0 1D           defb 1Dh    
F3B1 18           defb 18h    
F3B2 0E           defb 0Eh    
F3B3 00           defb 00h    
F3B4 00           defb 00h    
F3B5 00           defb 00h    
F3B6 00           defb 00h    
F3B7 00           defb 00h    
F3B8 08           defb 08h    
F3B9 00           defb 00h    
F3BA 00           defb 00h    
F3BB 00           defb 00h    
F3BC 00           defb 00h    
F3BD 00           defb 00h    
F3BE 18           defb 18h    
F3BF 00           defb 00h    
F3C0 20           defb 20h    
F3C1 00           defb 00h    
F3C2 00           defb 00h    
F3C3 00           defb 00h    
F3C4 1B           defb 1Bh    
F3C5 00           defb 00h    
F3C6 38           defb 38h    
F3C7 00           defb 00h    
F3C8 18           defb 18h    
F3C9 00           defb 00h    
F3CA 20           defb 20h    
F3CB 00           defb 00h    
F3CC 00           defb 00h    
F3CD 00           defb 00h    
F3CE 1B           defb 1Bh    
F3CF 00           defb 00h    
F3D0 38           defb 38h    
F3D1 00           defb 00h    
F3D2 08           defb 08h    
F3D3 00           defb 00h    
F3D4 00           defb 00h    
F3D5 00           defb 00h    
F3D6 00           defb 00h    
F3D7 00           defb 00h    
F3D8 1B           defb 1Bh    
F3D9 00           defb 00h    
F3DA 38           defb 38h    
F3DB 01           defb 01h    
F3DC 04           defb 04h    
F3DD 01           defb 01h    
F3DE 00           defb 00h    
F3DF 00           defb 00h    
F3E0 60           defb 60h    
F3E1 06           defb 06h    
F3E2 80           defb 80h    
F3E3 00           defb 00h    
F3E4 36           defb 36h    
F3E5 07           defb 07h    
F3E6 04           defb 04h    
F3E7 9F           defb 9Fh    
F3E8 F1           defb F1h    
F3E9 0F           defb 0Fh    
F3EA 04           defb 04h    
F3EB 04           defb 04h    
F3EC C3           defb C3h    
F3ED 00           defb 00h    
F3EE 00           defb 00h    
F3EF C3           defb C3h    
F3F0 00           defb 00h    
F3F1 00           defb 00h    
F3F2 0F           defb 0Fh    