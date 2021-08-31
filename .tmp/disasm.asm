L0000:       equ  0000h
L0005:       equ  0005h
L001C:       equ  001Ch
L049B:       equ  049Bh
L08DD:       equ  08DDh
L08E6:       equ  08E6h
L0979:       equ  0979h
L09C5:       equ  09C5h
L0B29:       equ  0B29h
L0F35:       equ  0F35h
L1ADE:       equ  1ADEh
L242E:       equ  242Eh
L253D:       equ  253Dh
L260B:       equ  260Bh
L26ED:       equ  26EDh
L27B1:       equ  27B1h
L284E:       equ  284Eh
L2868:       equ  2868h
L2884:       equ  2884h
L28AD:       equ  28ADh
L28E2:       equ  28E2h
L2908:       equ  2908h
L2A35:       equ  2A35h
L2A38:       equ  2A38h
L2A8E:       equ  2A8Eh
L2ABF:       equ  2ABFh
L2ACE:       equ  2ACEh
L2B49:       equ  2B49h
L2B50:       equ  2B50h
L2DA0:       equ  2DA0h
L2E0F:       equ  2E0Fh
L2E80:       equ  2E80h
L2E8A:       equ  2E8Ah
L2EB8:       equ  2EB8h
L3000:       equ  3000h
L33E8:       equ  33E8h
L3972:       equ  3972h
L3D0A:       equ  3D0Ah
L3D76:       equ  3D76h
L3D7A:       equ  3D7Ah
L3DB9:       equ  3DB9h
L3E31:       equ  3E31h
L7AD1:       equ  7AD1h
LB212:       equ  B212h
LBD39:       equ  BD39h
LBD5D:       equ  BD5Dh
LBD60:       equ  BD60h
LBD67:       equ  BD67h
LBD71:       equ  BD71h
LBD72:       equ  BD72h
LBD74:       equ  BD74h
LBD76:       equ  BD76h
LBD77:       equ  BD77h
LBD79:       equ  BD79h
LBD7A:       equ  BD7Ah
LBD7B:       equ  BD7Bh
LBD7C:       equ  BD7Ch
LBD7D:       equ  BD7Dh
LBD7E:       equ  BD7Eh
LBD7F:       equ  BD7Fh
LBD80:       equ  BD80h
LBD81:       equ  BD81h
LBD82:       equ  BD82h
LBDB7:       equ  BDB7h
LBDB9:       equ  BDB9h
LBDBE:       equ  BDBEh
LBDC5:       equ  BDC5h
LBDC6:       equ  BDC6h
LE15B:       equ  E15Bh
LEBD1:       equ  EBD1h
LEBE5:       equ  EBE5h
LF1D0:       equ  F1D0h
LF224:       equ  F224h
LF2BE:       equ  F2BEh
LF2CB:       equ  F2CBh
LF2CD:       equ  F2CDh
LF2CF:       equ  F2CFh
LF2EA:       equ  F2EAh
LF2EB:       equ  F2EBh
LF33F:       equ  F33Fh
LF347:       equ  F347h
LF34D:       equ  F34Dh
LF368:       equ  F368h
LF36B:       equ  F36Bh
LFCC8:       equ  FCC8h
LFFFF:       equ  FFFFh


             org 02A3h


02A3 L02A3:
02A3 CD AA 02     CALL L02AA  
02A6 32 BE BD     LD   (LBDBE),A 
02A9 C9           RET         


02AA L02AA:
02AA E5           PUSH HL     
02AB C5           PUSH BC     
02AC 08           EX   AF,AF' 
02AD 3A BE F2     LD   A,(LF2BE) 
02B0 3D           DEC  A      
02B1 CC 29 0B     CALL Z,L0B29 
02B4 79           LD   A,C    
02B5 FE 6F        CP   6Fh    
02B7 28 32        JR   Z,L02EB 
02B9 FE 7F        CP   7Fh    
02BB 38 02        JR   C,L02BF 
02BD 0E 1C        LD   C,1Ch  
02BF L02BF:
02BF 08           EX   AF,AF' 
02C0 06 00        LD   B,00h  
02C2 21 F7 02     LD   HL,02F7h 
02C5 09           ADD  HL,BC  
02C6 09           ADD  HL,BC  
02C7 4E           LD   C,(HL) 
02C8 23           INC  HL     
02C9 66           LD   H,(HL) 
02CA 69           LD   L,C    
02CB 08           EX   AF,AF' 
02CC 7C           LD   A,H    
02CD E6 C0        AND  C0h    
02CF 28 12        JR   Z,L02E3 
02D1 08           EX   AF,AF' 
02D2 22 D0 F1     LD   (LF1D0),HL 
02D5 C1           POP  BC     
02D6 E1           POP  HL     
02D7 4F           LD   C,A    
02D8 DD 21 92 40  LD   IX,4092h 
02DC FD 2A 47 F3  LD   IY,(LF347) 
02E0 C3 1C 00     JP   L001C  
02E3 L02E3:
02E3 08           EX   AF,AF' 
02E4 FD 21 41 BD  LD   IY,BD41h 
02E8 C1           POP  BC     
02E9 E3           EX   (SP),HL 
02EA C9           RET         
02EB L02EB:
02EB 08           EX   AF,AF' 
02EC C1           POP  BC     
02ED E1           POP  HL     
02EE C3 35 0F     JP   L0F35  


02F1 3E           defb 3Eh    
02F2 DC           defb DCh    
02F3 21           defb 21h    
02F4 00           defb 00h    
02F5 00           defb 00h    
02F6 C9           defb C9h    
02F7 19           defb 19h    
02F8 0E           defb 0Eh    
02F9 19           defb 19h    
02FA 04           defb 04h    
02FB 27           defb 27h    
02FC 04           defb 04h    
02FD 9F           defb 9Fh    
02FE 04           defb 04h    
02FF AE           defb AEh    
0300 04           defb 04h    
0301 B2           defb B2h    
0302 04           defb 04h    
0303 45           defb 45h    
0304 04           defb 04h    
0305 6F           defb 6Fh    
0306 04           defb 04h    


             org 0428h


0428 L0428:
0428 CD DD 08     CALL L08DD  
042B AF           XOR  A      
042C 67           LD   H,A    
042D 6F           LD   L,A    
042E C9           RET         


042F FD           defb FDh    
0430 CB           defb CBh    
0431 F6           defb F6h    
0432 46           defb 46h    
0433 0E           defb 0Eh    
0434 FF           defb FFh    
0435 20           defb 20h    
0436 4E           defb 4Eh    
0437 CD           defb CDh    
0438 23           defb 23h    
0439 09           defb 09h    
043A 6F           defb 6Fh    
043B AF           defb AFh    
043C 67           defb 67h    
043D C9           defb C9h    
043E CD           defb CDh    
043F 08           defb 08h    
0440 09           defb 09h    
0441 6F           defb 6Fh    
0442 AF           defb AFh    
0443 67           defb 67h    
0444 C9           defb C9h    
0445 7B           defb 7Bh    
0446 3C           defb 3Ch    
0447 28           defb 28h    
0448 10           defb 10h    
0449 FD           defb FDh    
044A CB           defb CBh    
044B F6           defb F6h    
044C 4E           defb 4Eh    
044D 7B           defb 7Bh    
044E 0E           defb 0Eh    
044F 00           defb 00h    
0450 20           defb 20h    
0451 49           defb 49h    
0452 CD           defb CDh    
0453 1A           defb 1Ah    
0454 0B           defb 0Bh    
0455 AF           defb AFh    
0456 67           defb 67h    
0457 6F           defb 6Fh    
0458 C9           defb C9h    
0459 FD           defb FDh    
045A CB           defb CBh    
045B F6           defb F6h    
045C 46           defb 46h    
045D 0E           defb 0Eh    
045E 00           defb 00h    
045F 20           defb 20h    
0460 24           defb 24h    
0461 21           defb 21h    
0462 3B           defb 3Bh    
0463 BD           defb BDh    
0464 BE           defb BEh    
0465 20           defb 20h    
0466 10           defb 10h    
0467 CD           defb CDh    
0468 F0           defb F0h    
0469 0A           defb 0Ah    
046A 20           defb 20h    
046B 0B           defb 0Bh    
046C 6F           defb 6Fh    
046D 67           defb 67h    
046E C9           defb C9h    
046F FD           defb FDh    
0470 CB           defb CBh    
0471 F6           defb F6h    
0472 46           defb 46h    
0473 0E           defb 0Eh    
0474 00           defb 00h    
0475 20           defb 20h    
0476 0E           defb 0Eh    
0477 3A           defb 3Ah    
0478 3B           defb 3Bh    
0479 BD           defb BDh    
047A B7           defb B7h    
047B CC           defb CCh    
047C DB           defb DBh    
047D 0A           defb 0Ah    
047E 6F           defb 6Fh    
047F AF           defb AFh    
0480 67           defb 67h    
0481 32           defb 32h    
0482 3B           defb 3Bh    
0483 BD           defb BDh    
0484 C9           defb C9h    
0485 06           defb 06h    
0486 00           defb 00h    
0487 C5           defb C5h    
0488 CD           defb CDh    
0489 03           defb 03h    
048A 1B           defb 1Bh    
048B D1           defb D1h    


             org 04B7h


04B7 L04B7:
04B7 CD DE 1A     CALL L1ADE  
04BA B7           OR   A      
04BB 6F           LD   L,A    
04BC 67           LD   H,A    
04BD C8           RET  Z      
04BE 0E 9C        LD   C,9Ch  
04C0 47           LD   B,A    
04C1 79           LD   A,C    
04C2 CD 31 3E     CALL L3E31  
04C5 L04C5:
04C5 18 FE        JR   L04C5  


04C7 D5           defb D5h    
04C8 FD           defb FDh    
04C9 CB           defb CBh    
04CA F6           defb F6h    
04CB 46           defb 46h    
04CC 20           defb 20h    
04CD 06           defb 06h    
04CE AF           defb AFh    
04CF CD           defb CDh    
04D0 22           defb 22h    
04D1 05           defb 05h    
04D2 18           defb 18h    
04D3 3B           defb 3Bh    
04D4 EB           defb EBh    
04D5 46           defb 46h    
04D6 0E           defb 0Eh    
04D7 00           defb 00h    
04D8 23           defb 23h    
04D9 E5           defb E5h    
04DA E5           defb E5h    
04DB C5           defb C5h    
04DC 0E           defb 0Eh    
04DD FF           defb FFh    
04DE CD           defb CDh    
04DF 85           defb 85h    
04E0 04           defb 04h    
04E1 7D           defb 7Dh    
04E2 C1           defb C1h    
04E3 E1           defb E1h    
04E4 B7           defb B7h    
04E5 28           defb 28h    
04E6 F3           defb F3h    
04E7 FE           defb FEh    
04E8 0A           defb 0Ah    
04E9 28           defb 28h    
04EA EF           defb EFh    
04EB FE           defb FEh    
04EC 0D           defb 0Dh    
04ED 28           defb 28h    
04EE 1B           defb 1Bh    
04EF 5F           defb 5Fh    
04F0 78           defb 78h    
04F1 B9           defb B9h    
04F2 28           defb 28h    
04F3 0B           defb 0Bh    
04F4 0C           defb 0Ch    
04F5 23           defb 23h    
04F6 73           defb 73h    
04F7 7B           defb 7Bh    
04F8 E5           defb E5h    
04F9 C5           defb C5h    
04FA CD           defb CDh    
04FB DD           defb DDh    
04FC 08           defb 08h    
04FD 18           defb 18h    
04FE 07           defb 07h    
04FF E5           defb E5h    
0500 C5           defb C5h    
0501 3E           defb 3Eh    
0502 07           defb 07h    
0503 CD           defb CDh    
0504 1A           defb 1Ah    
0505 0B           defb 0Bh    
0506 C1           defb C1h    
0507 E1           defb E1h    
0508 18           defb 18h    
0509 D0           defb D0h    
050A E1           defb E1h    
050B 71           defb 71h    
050C CD           defb CDh    
050D DD           defb DDh    
050E 08           defb 08h    
050F E1           defb E1h    
0510 E5           defb E5h    
0511 7E           defb 7Eh    
0512 23           defb 23h    
0513 BE           defb BEh    
0514 28           defb 28h    
0515 07           defb 07h    
0516 5E           defb 5Eh    
0517 16           defb 16h    
0518 00           defb 00h    
0519 19           defb 19h    
051A 23           defb 23h    


             org 08E8h


08E8 L08E8:
08E8 CD F3 08     CALL L08F3  
08EB 3A 39 BD     LD   A,(LBD39) 
08EE E6 07        AND  07h    
08F0 20 F4        JR   NZ,L08E6 
08F2 C9           RET         


08F3 L08F3:
08F3 2A 39 BD     LD   HL,(LBD39) 
08F6 CD C5 09     CALL L09C5  
08F9 22 39 BD     LD   (LBD39),HL 
08FC FD CB F6 4E  BIT  1,(IY-10) 
0900 CA 79 09     JP   Z,L0979 
0903 0E FF        LD   C,FFh  
0905 C3 9B 04     JP   L049B  


0908 CD           defb CDh    
0909 F0           defb F0h    
090A 0A           defb 0Ah    
090B 47           defb 47h    
090C 3A           defb 3Ah    
090D 3B           defb 3Bh    
090E BD           defb BDh    
090F B7           defb B7h    
0910 20           defb 20h    
0911 0E           defb 0Eh    
0912 78           defb 78h    
0913 B7           defb B7h    
0914 C8           defb C8h    
0915 CD           defb CDh    
0916 DB           defb DBh    
0917 0A           defb 0Ah    
0918 CD           defb CDh    
0919 36           defb 36h    
091A 09           defb 09h    
091B B7           defb B7h    
091C C8           defb C8h    
091D 32           defb 32h    
091E 3B           defb 3Bh    
091F BD           defb BDh    
0920 AF           defb AFh    
0921 3D           defb 3Dh    
0922 C9           defb C9h    
0923 3A           defb 3Ah    
0924 3B           defb 3Bh    
0925 BD           defb BDh    
0926 FD           defb FDh    
0927 36           defb 36h    
0928 FA           defb FAh    
0929 00           defb 00h    
092A B7           defb B7h    
092B C0           defb C0h    
092C CD           defb CDh    
092D DB           defb DBh    
092E 0A           defb 0Ah    
092F CD           defb CDh    
0930 36           defb 36h    
0931 09           defb 09h    
0932 B7           defb B7h    
0933 28           defb 28h    
0934 F7           defb F7h    
0935 C9           defb C9h    
0936 FE           defb FEh    
0937 10           defb 10h    
0938 28           defb 28h    
0939 1C           defb 1Ch    
093A FE           defb FEh    
093B 0E           defb 0Eh    
093C 28           defb 28h    
093D 1B           defb 1Bh    
093E FE           defb FEh    
093F 03           defb 03h    
0940 28           defb 28h    
0941 0B           defb 0Bh    
0942 FE           defb FEh    
0943 13           defb 13h    
0944 C0           defb C0h    
0945 CD           defb CDh    
0946 DB           defb DBh    
0947 0A           defb 0Ah    
0948 FE           defb FEh    
0949 03           defb 03h    
094A 3E           defb 3Eh    
094B 00           defb 00h    


             org 18F0h


18F0 L18F0:
18F0 FC D1 7A     CALL M,L7AD1 
18F3 A3           AND  E      
18F4 3C           INC  A      
18F5 20 02        JR   NZ,L18F9 
18F7 50           LD   D,B    
18F8 58           LD   E,B    
18F9 L18F9:
18F9 01 FC FF     LD   BC,FFFCh 
18FC 09           ADD  HL,BC  
18FD 72           LD   (HL),D 
18FE 2B           DEC  HL     
18FF 73           LD   (HL),E 
1900 D1           POP  DE     
1901 E5           PUSH HL     
1902 C5           PUSH BC     
1903 D5           PUSH DE     
1904 21 16 00     LD   HL,0016h 
1907 19           ADD  HL,DE  
1908 E5           PUSH HL     
1909 DD E5        PUSH IX     
190B FD E5        PUSH IY     
190D 08           EX   AF,AF' 
190E F5           PUSH AF     
190F 08           EX   AF,AF' 
1910 DD 21 84 41  LD   IX,4184h 
1914 DD 22 D0 F1  LD   (LF1D0),IX 
1918 DD 21 92 40  LD   IX,4092h 
191C FD 2A 47 F3  LD   IY,(LF347) 
1920 CD 1C 00     CALL L001C  
1923 08           EX   AF,AF' 
1924 F1           POP  AF     
1925 08           EX   AF,AF' 
1926 FD E1        POP  IY     
1928 DD E1        POP  IX     
192A E3           EX   (SP),HL 
192B 79           LD   A,C    
192C 87           ADD  A,A    
192D 87           ADD  A,A    
192E 0E 03        LD   C,03h  
1930 L1930:
1930 87           ADD  A,A    
1931 CB 10        RL   B      
1933 0D           DEC  C      
1934 20 FA        JR   NZ,L1930 
1936 CB 3B        SRL  E      
1938 83           ADD  A,E    
1939 77           LD   (HL),A 
193A 23           INC  HL     
193B 70           LD   (HL),B 
193C 23           INC  HL     
193D C1           POP  BC     
193E 78           LD   A,B    
193F B7           OR   A      
1940 1F           RRA         
1941 1F           RRA         
1942 1F           RRA         
1943 1F           RRA         
1944 CB 12        RL   D      
1946 81           ADD  A,C    
1947 77           LD   (HL),A 
1948 23           INC  HL     
1949 72           LD   (HL),D 
194A D1           POP  DE     
194B C1           POP  BC     
194C E1           POP  HL     
194D C9           RET         


194E CD           defb CDh    
194F 1E           defb 1Eh    
1950 1A           defb 1Ah    
1951 38           defb 38h    
1952 1A           defb 1Ah    
1953 DD           defb DDh    


             org 1AFFh


1AFF L1AFF:
1AFF CD 0B 26     CALL L260B  
1B02 C9           RET         


1B03 CD           defb CDh    
1B04 15           defb 15h    
1B05 1F           defb 1Fh    
1B06 D0           defb D0h    
1B07 C8           defb C8h    
1B08 DD           defb DDh    
1B09 CB           defb CBh    
1B0A 1E           defb 1Eh    
1B0B 7E           defb 7Eh    
1B0C 28           defb 28h    
1B0D 1B           defb 1Bh    
1B0E DD           defb DDh    
1B0F CB           defb CBh    
1B10 1E           defb 1Eh    
1B11 B6           defb B6h    
1B12 DD           defb DDh    
1B13 6E           defb 6Eh    
1B14 1C           defb 1Ch    
1B15 DD           defb DDh    
1B16 66           defb 66h    
1B17 1D           defb 1Dh    
1B18 C5           defb C5h    
1B19 CD           defb CDh    
1B1A F4           defb F4h    
1B1B 1A           defb 1Ah    
1B1C D1           defb D1h    
1B1D FE           defb FEh    
1B1E B9           defb B9h    
1B1F 28           defb 28h    
1B20 06           defb 06h    
1B21 CB           defb CBh    
1B22 6B           defb 6Bh    
1B23 C0           defb C0h    
1B24 FE           defb FEh    
1B25 C7           defb C7h    
1B26 C0           defb C0h    
1B27 AF           defb AFh    
1B28 C9           defb C9h    
1B29 C5           defb C5h    
1B2A 11           defb 11h    
1B2B 83           defb 83h    
1B2C BD           defb BDh    
1B2D 01           defb 01h    
1B2E 01           defb 01h    
1B2F 00           defb 00h    
1B30 3E           defb 3Eh    
1B31 FF           defb FFh    
1B32 CD           defb CDh    
1B33 0F           defb 0Fh    
1B34 26           defb 26h    
1B35 21           defb 21h    
1B36 83           defb 83h    
1B37 BD           defb BDh    
1B38 46           defb 46h    
1B39 D1           defb D1h    
1B3A B7           defb B7h    
1B3B C0           defb C0h    
1B3C B3           defb B3h    
1B3D C8           defb C8h    
1B3E 78           defb 78h    
1B3F FE           defb FEh    
1B40 1A           defb 1Ah    
1B41 3E           defb 3Eh    
1B42 C7           defb C7h    
1B43 C8           defb C8h    
1B44 AF           defb AFh    
1B45 C9           defb C9h    
1B46 08           defb 08h    
1B47 CB           defb CBh    
1B48 58           defb 58h    
1B49 3E           defb 3Eh    
1B4A CF           defb CFh    
1B4B C0           defb C0h    
1B4C CD           defb CDh    
1B4D 28           defb 28h    
1B4E 17           defb 17h    
1B4F C0           defb C0h    
1B50 06           defb 06h    
1B51 FF           defb FFh    
1B52 CB           defb CBh    
1B53 67           defb 67h    
1B54 20           defb 20h    
1B55 42           defb 42h    
1B56 18           defb 18h    
1B57 0A           defb 0Ah    
1B58 08           defb 08h    
1B59 CD           defb CDh    
1B5A C5           defb C5h    
1B5B 16           defb 16h    
1B5C C0           defb C0h    
1B5D CB           defb CBh    
1B5E 67           defb 67h    
1B5F 3E           defb 3Eh    
1B60 CC           defb CCh    
1B61 C0           defb C0h    
1B62 E5           defb E5h    


             org 24CAh


24CA L24CA:
24CA CD 3D 25     CALL L253D  
24CD C1           POP  BC     
24CE FD 34 31     INC  (IY+49) 
24D1 20 08        JR   NZ,L24DB 
24D3 FD 34 32     INC  (IY+50) 
24D6 20 03        JR   NZ,L24DB 
24D8 FD 34 30     INC  (IY+48) 
24DB L24DB:
24DB C3 2E 24     JP   L242E  


24DE CD           defb CDh    
24DF EC           defb ECh    
24E0 2B           defb 2Bh    
24E1 C5           defb C5h    
24E2 D9           defb D9h    
24E3 CD           defb CDh    
24E4 1C           defb 1Ch    
24E5 2C           defb 2Ch    
24E6 28           defb 28h    
24E7 52           defb 52h    
24E8 01           defb 01h    
24E9 04           defb 04h    
24EA 00           defb 00h    
24EB 09           defb 09h    
24EC 5E           defb 5Eh    
24ED 23           defb 23h    
24EE 56           defb 56h    
24EF 01           defb 01h    
24F0 03           defb 03h    
24F1 00           defb 00h    
24F2 09           defb 09h    
24F3 7E           defb 7Eh    
24F4 EB           defb EBh    
24F5 ED           defb EDh    
24F6 4B           defb 4Bh    
24F7 72           defb 72h    
24F8 BD           defb BDh    
24F9 ED           defb EDh    
24FA 42           defb 42h    
24FB ED           defb EDh    
24FC 4B           defb 4Bh    
24FD 71           defb 71h    
24FE BD           defb BDh    
24FF 99           defb 99h    
2500 C1           defb C1h    
2501 A4           defb A4h    
2502 3C           defb 3Ch    
2503 20           defb 20h    
2504 15           defb 15h    
2505 7D           defb 7Dh    
2506 80           defb 80h    
2507 30           defb 30h    
2508 11           defb 11h    
2509 1B           defb 1Bh    
250A 1B           defb 1Bh    
250B EB           defb EBh    
250C FD           defb FDh    
250D CB           defb CBh    
250E 41           defb 41h    
250F 46           defb 46h    
2510 20           defb 20h    
2511 0B           defb 0Bh    
2512 2B           defb 2Bh    
2513 36           defb 36h    
2514 00           defb 00h    
2515 2B           defb 2Bh    
2516 2B           defb 2Bh    
2517 CD           defb CDh    
2518 34           defb 34h    
2519 2C           defb 2Ch    
251A D9           defb D9h    
251B 18           defb 18h    
251C C4           defb C4h    
251D CB           defb CBh    
251E 7E           defb 7Eh    
251F 28           defb 28h    
2520 F9           defb F9h    
2521 79           defb 79h    
2522 D9           defb D9h    
2523 D5           defb D5h    
2524 D9           defb D9h    
2525 01           defb 01h    
2526 08           defb 08h    
2527 00           defb 00h    
2528 09           defb 09h    
2529 E3           defb E3h    
252A 53           defb 53h    
252B 58           defb 58h    
252C 19           defb 19h    
252D 19           defb 19h    


             org 267Ah


267A L267A:
267A CD B1 27     CALL L27B1  
267D ED 4B 7C BD  LD   BC,(LBD7C) 
2681 ED 5B 80 BD  LD   DE,(LBD80) 
2685 DD 6E 2E     LD   L,(IX+46) 
2688 DD 66 2F     LD   H,(IX+47) 
268B 09           ADD  HL,BC  
268C DD 75 2E     LD   (IX+46),L 
268F DD 74 2F     LD   (IX+47),H 
2692 30 08        JR   NC,L269C 
2694 DD 34 30     INC  (IX+48) 
2697 20 03        JR   NZ,L269C 
2699 DD 34 31     INC  (IX+49) 
269C L269C:
269C B7           OR   A      
269D 20 0D        JR   NZ,L26AC 
269F FD CB 41 66  BIT  4,(IY+65) 
26A3 20 06        JR   NZ,L26AB 
26A5 78           LD   A,B    
26A6 B1           OR   C      
26A7 3E C7        LD   A,C7h  
26A9 28 F1        JR   Z,L269C 
26AB L26AB:
26AB AF           XOR  A      
26AC L26AC:
26AC 08           EX   AF,AF' 
26AD 3A C6 BD     LD   A,(LBDC6) 
26B0 FE 02        CP   02h    
26B2 20 39        JR   NZ,L26ED 
26B4 E1           POP  HL     
26B5 22 80 BD     LD   (LBD80),HL 
26B8 E1           POP  HL     
26B9 22 72 BD     LD   (LBD72),HL 
26BC E1           POP  HL     
26BD 7D           LD   A,L    
26BE 32 82 BD     LD   (LBD82),A 
26C1 7C           LD   A,H    
26C2 32 71 BD     LD   (LBD71),A 
26C5 E1           POP  HL     
26C6 22 81 BD     LD   (LBD81),HL 
26C9 E1           POP  HL     
26CA 22 7F BD     LD   (LBD7F),HL 
26CD E1           POP  HL     
26CE 22 7D BD     LD   (LBD7D),HL 
26D1 E1           POP  HL     
26D2 22 7B BD     LD   (LBD7B),HL 
26D5 E1           POP  HL     
26D6 22 79 BD     LD   (LBD79),HL 
26D9 E1           POP  HL     
26DA 22 77 BD     LD   (LBD77),HL 
26DD E1           POP  HL     


             org 27EAh


27EA L27EA:
27EA CD 08 29     CALL L2908  
27ED C0           RET  NZ     
27EE ED 4B 7E BD  LD   BC,(LBD7E) 
27F2 78           LD   A,B    
27F3 B1           OR   C      
27F4 C8           RET  Z      
27F5 ED 5B 7A BD  LD   DE,(LBD7A) 
27F9 CD 8E 2A     CALL L2A8E  
27FC ED 53 74 BD  LD   (LBD74),DE 
2800 C0           RET  NZ     
2801 ED 4B 77 BD  LD   BC,(LBD77) 
2805 78           LD   A,B    
2806 B1           OR   C      
2807 C4 84 28     CALL NZ,L2884 
280A C0           RET  NZ     
280B FD 4E 3E     LD   C,(IY+62) 
280E CB 39        SRL  C      
2810 28 56        JR   Z,L2868 
2812 CD AD 28     CALL L28AD  
2815 C0           RET  NZ     
2816 FD 96 38     SUB  (IY+56) 
2819 47           LD   B,A    
281A ED 5B 74 BD  LD   DE,(LBD74) 
281E CD E2 28     CALL L28E2  
2821 L2821:
2821 78           LD   A,B    
2822 FD 86 35     ADD  A,(IY+53) 
2825 47           LD   B,A    
2826 B9           CP   C      
2827 30 1F        JR   NC,L2848 
2829 D5           PUSH DE     
282A CD 35 2D     CALL L2D35  
282D E3           EX   (SP),HL 
282E B7           OR   A      
282F 23           INC  HL     
2830 ED 52        SBC  HL,DE  
2832 20 0B        JR   NZ,L283F 
2834 FD 34 39     INC  (IY+57) 
2837 20 03        JR   NZ,L283C 
2839 FD 34 3A     INC  (IY+58) 
283C L283C:
283C E1           POP  HL     
283D 18 E2        JR   L2821  
283F L283F:
283F 19           ADD  HL,DE  
2840 EB           EX   DE,HL  
2841 1B           DEC  DE     
2842 E1           POP  HL     
2843 3A 76 BD     LD   A,(LBD76) 
2846 18 06        JR   L284E  
2848 L2848:
2848 3A 76 BD     LD   A,(LBD76) 
284B 90           SUB  B      
284C 81           ADD  A,C    
284D 41           LD   B,C    


             org 29D0h


29D0 L29D0:
29D0 CD 2B 2F     CALL L2F2B  
29D3 20 12        JR   NZ,L29E7 
29D5 7A           LD   A,D    
29D6 B3           OR   E      
29D7 1B           DEC  DE     
29D8 28 10        JR   Z,L29EA 
29DA C5           PUSH BC     
29DB CD 8E 2A     CALL L2A8E  
29DE C1           POP  BC     
29DF 20 06        JR   NZ,L29E7 
29E1 CD A0 2D     CALL L2DA0  
29E4 18 17        JR   L29FD  


29E6 D1           defb D1h    


29E7 L29E7:
29E7 D1           POP  DE     
29E8 D1           POP  DE     
29E9 C9           RET         
29EA L29EA:
29EA DD 71 28     LD   (IX+40),C 
29ED DD 70 29     LD   (IX+41),B 
29F0 AF           XOR  A      
29F1 DD 71 2A     LD   (IX+42),C 
29F4 DD 70 2B     LD   (IX+43),B 
29F7 DD 77 2C     LD   (IX+44),A 
29FA DD 77 2D     LD   (IX+45),A 
29FD L29FD:
29FD DD CB 32 FE  SET  7,(IX+50) 
2A01 D9           EXX         
2A02 08           EX   AF,AF' 
2A03 20 02        JR   NZ,L2A07 
2A05 30 12        JR   NC,L2A19 
2A07 L2A07:
2A07 03           INC  BC     
2A08 78           LD   A,B    
2A09 B1           OR   C      
2A0A 20 01        JR   NZ,L2A0D 
2A0C 13           INC  DE     
2A0D L2A0D:
2A0D DD 71 15     LD   (IX+21),C 
2A10 DD 70 16     LD   (IX+22),B 
2A13 DD 73 17     LD   (IX+23),E 
2A16 DD 72 18     LD   (IX+24),D 
2A19 L2A19:
2A19 C1           POP  BC     
2A1A D1           POP  DE     
2A1B 78           LD   A,B    
2A1C B1           OR   C      
2A1D 0B           DEC  BC     
2A1E 20 01        JR   NZ,L2A21 
2A20 2B           DEC  HL     
2A21 L2A21:
2A21 CB 7C        BIT  7,H    
2A23 28 10        JR   Z,L2A35 
2A25 7C           LD   A,H    
2A26 A5           AND  L      
2A27 3C           INC  A      
2A28 21 FF FF     LD   HL,FFFFh 
2A2B 20 0B        JR   NZ,L2A38 
2A2D 23           INC  HL     
2A2E ED 42        SBC  HL,BC  
2A30 20 06        JR   NZ,L2A38 
2A32 2B           DEC  HL     
2A33 18 00        JR   L2A35  


             org 2B60h


2B60 L2B60:
2B60 CD 15 2D     CALL L2D15  
2B63 C1           POP  BC     
2B64 D1           POP  DE     
2B65 28 1A        JR   Z,L2B80+1 
2B67 FE F1        CP   F1h    
2B69 28 02        JR   Z,L2B6D 
2B6B 10 E3        DJNZ L2B50  
2B6D L2B6D:
2B6D D1           POP  DE     
2B6E C1           POP  BC     
2B6F B7           OR   A      
2B70 CB 48        BIT  1,B    
2B72 20 01        JR   NZ,L2B75 
2B74 37           SCF         
2B75 L2B75:
2B75 C5           PUSH BC     
2B76 ED 4B 5D BD  LD   BC,(LBD5D) 
2B7A CD 7A 3D     CALL L3D7A  
2B7D C1           POP  BC     
2B7E 28 C9        JR   Z,L2B49 
2B80 L2B80:
2B80 CA D1 C1     JP   Z,LC1D1 
2B83 E3           EX   (SP),HL 
2B84 DD E1        POP  IX     
2B86 FE C1        CP   C1h    
2B88 FD CB 25 CE  SET  1,(IY+37) 
2B8C 22 B7 BD     LD   (LBDB7),HL 
2B8F 3A C5 BD     LD   A,(LBDC5) 
2B92 B7           OR   A      
2B93 CC 54 2C     CALL Z,L2C54 
2B96 AF           XOR  A      
2B97 C9           RET         


2B98 E5           defb E5h    
2B99 C5           defb C5h    
2B9A 23           defb 23h    
2B9B 23           defb 23h    
2B9C 47           defb 47h    
2B9D 7E           defb 7Eh    
2B9E 91           defb 91h    
2B9F 20           defb 20h    
2BA0 10           defb 10h    
2BA1 23           defb 23h    
2BA2 23           defb 23h    
2BA3 7E           defb 7Eh    
2BA4 93           defb 93h    
2BA5 20           defb 20h    
2BA6 0A           defb 0Ah    
2BA7 23           defb 23h    
2BA8 7E           defb 7Eh    
2BA9 92           defb 92h    
2BAA 20           defb 20h    
2BAB 05           defb 05h    
2BAC 23           defb 23h    
2BAD 23           defb 23h    
2BAE 23           defb 23h    
2BAF 7E           defb 7Eh    
2BB0 90           defb 90h    
2BB1 78           defb 78h    
2BB2 C1           defb C1h    
2BB3 E1           defb E1h    
2BB4 C9           defb C9h    


2BB5 L2BB5:
2BB5 2A B7 BD     LD   HL,(LBDB7) 
2BB8 23           INC  HL     
2BB9 23           INC  HL     
2BBA 23           INC  HL     
2BBB CB FE        SET  7,(HL) 
2BBD C9           RET         


2BBE C5           defb C5h    
2BBF E5           defb E5h    
2BC0 CD           defb CDh    
2BC1 C3           defb C3h    
2BC2 3C           defb 3Ch    
2BC3 E1           defb E1h    


             org 2C31h


2C31 L2C31:
2C31 CD 8C 2C     CALL L2C8C  


2C34 L2C34:
2C34 D5           PUSH DE     
2C35 ED 5B B9 BD  LD   DE,(LBDB9) 
2C39 B7           OR   A      
2C3A ED 52        SBC  HL,DE  
2C3C 19           ADD  HL,DE  
2C3D 28 3C        JR   Z,L2C7B 
2C3F C5           PUSH BC     
2C40 E5           PUSH HL     
2C41 22 B9 BD     LD   (LBDB9),HL 
2C44 4E           LD   C,(HL) 
2C45 23           INC  HL     
2C46 46           LD   B,(HL) 
2C47 C5           PUSH BC     
2C48 72           LD   (HL),D 
2C49 2B           DEC  HL     
2C4A 73           LD   (HL),E 
2C4B EB           EX   DE,HL  
2C4C 42           LD   B,D    
2C4D 4B           LD   C,E    
2C4E CD 7D 2C     CALL L2C7D  
2C51 C1           POP  BC     
2C52 18 21        JR   L2C75  


2C54 L2C54:
2C54 7E           LD   A,(HL) 
2C55 23           INC  HL     
2C56 B6           OR   (HL)   
2C57 2B           DEC  HL     
2C58 C8           RET  Z      
2C59 D5           PUSH DE     
2C5A C5           PUSH BC     
2C5B E5           PUSH HL     
2C5C 5E           LD   E,(HL) 
2C5D 23           INC  HL     
2C5E 56           LD   D,(HL) 
2C5F D5           PUSH DE     
2C60 AF           XOR  A      
2C61 77           LD   (HL),A 
2C62 2B           DEC  HL     
2C63 77           LD   (HL),A 
2C64 44           LD   B,H    
2C65 4D           LD   C,L    
2C66 21 B9 BD     LD   HL,BDB9h 
2C69 CD 7D 2C     CALL L2C7D  
2C6C EB           EX   DE,HL  
2C6D D1           POP  DE     
2C6E 73           LD   (HL),E 
2C6F 23           INC  HL     
2C70 72           LD   (HL),D 
2C71 2B           DEC  HL     
2C72 CD 7D 2C     CALL L2C7D  


2C75 L2C75:
2C75 EB           EX   DE,HL  
2C76 71           LD   (HL),C 
2C77 23           INC  HL     
2C78 70           LD   (HL),B 
2C79 E1           POP  HL     
2C7A C1           POP  BC     
2C7B L2C7B:
2C7B D1           POP  DE     
2C7C C9           RET         


2C7D L2C7D:
2C7D 5E           LD   E,(HL) 
2C7E 23           INC  HL     
2C7F 56           LD   D,(HL) 
2C80 2B           DEC  HL     
2C81 EB           EX   DE,HL  
2C82 7C           LD   A,H    
2C83 B5           OR   L      
2C84 C8           RET  Z      
2C85 ED 42        SBC  HL,BC  
2C87 09           ADD  HL,BC  
2C88 20 F3        JR   NZ,L2C7D 
2C8A B7           OR   A      
2C8B C9           RET         


2C8C L2C8C:
2C8C CD 2B 2D     CALL L2D2B  
2C8F FD CB 25 CE  SET  1,(IY+37) 
2C93 E5           PUSH HL     
2C94 23           INC  HL     


             org 2CDCh


2CDC L2CDC:
2CDC CD           defb CDh    
2CDD 15           defb 15h    
2CDE 2D           defb 2Dh    
2CDF C1           defb C1h    
2CE0 D1           defb D1h    
2CE1 20           defb 20h    
2CE2 01           defb 01h    
2CE3 0C           defb 0Ch    
2CE4 FE           defb FEh    
2CE5 F1           defb F1h    
2CE6 20           defb 20h    
2CE7 03           defb 03h    
2CE8 01           defb 01h    
2CE9 01           defb 01h    
2CEA 01           defb 01h    
2CEB F5           defb F5h    
2CEC DD           defb DDh    
2CED 7E           defb 7Eh    
2CEE FC           defb FCh    
2CEF B7           defb B7h    
2CF0 28           defb 28h    
2CF1 04           defb 04h    
2CF2 83           defb 83h    
2CF3 5F           defb 5Fh    
2CF4 30           defb 30h    
2CF5 01           defb 01h    
2CF6 14           defb 14h    
2CF7 F1           defb F1h    
2CF8 10           defb 10h    
2CF9 D8           defb D8h    
2CFA D1           defb D1h    
2CFB 0D           defb 0Dh    
2CFC 20           defb 20h    
2CFD 0E           defb 0Eh    
2CFE DD           defb DDh    
2CFF CB           defb CBh    
2D00 F8           defb F8h    
2D01 4E           defb 4Eh    
2D02 20           defb 20h    
2D03 01           defb 01h    
2D04 37           defb 37h    
2D05 ED           defb EDh    
2D06 4B           defb 4Bh    
2D07 5D           defb 5Dh    
2D08 BD           defb BDh    
2D09 CD           defb CDh    
2D0A 7A           defb 7Ah    
2D0B 3D           defb 3Dh    
2D0C E1           defb E1h    
2D0D 28           defb 28h    
2D0E 96           defb 96h    
2D0F DD           defb DDh    
2D10 E1           defb E1h    
2D11 C1           defb C1h    
2D12 D1           defb D1h    
2D13 E1           defb E1h    
2D14 C9           defb C9h    


2D15 L2D15:
2D15 F5           PUSH AF     
2D16 3A C5 BD     LD   A,(LBDC5) 
2D19 3C           INC  A      
2D1A 32 C5 BD     LD   (LBDC5),A 
2D1D F1           POP  AF     
2D1E CD E8 33     CALL L33E8  
2D21 F5           PUSH AF     
2D22 3A C5 BD     LD   A,(LBDC5) 
2D25 3D           DEC  A      
2D26 32 C5 BD     LD   (LBDC5),A 
2D29 F1           POP  AF     
2D2A C9           RET         


2D2B L2D2B:
2D2B 3A C5 BD     LD   A,(LBDC5) 
2D2E B7           OR   A      
2D2F C8           RET  Z      
2D30 7E           LD   A,(HL) 
2D31 23           INC  HL     
2D32 66           LD   H,(HL) 
2D33 6F           LD   L,A    
2D34 C9           RET         


2D35 L2D35:
2D35 CD 0F 2E     CALL L2E0F  
2D38 28 13        JR   Z,L2D4D 
2D3A L2D3A:
2D3A FD 36 6A 00  LD   (IY+106),%s 
2D3E 3E F2        LD   A,F2h  
2D40 11 FF FF     LD   DE,FFFFh 
2D43 C5           PUSH BC     
2D44 42           LD   B,D    
2D45 CD 76 3D     CALL L3D76  
2D48 C1           POP  BC     
2D49 28 EF        JR   Z,L2D3A 
2D4B 18 28        JR   L2D75  
2D4D L2D4D:
2D4D E5           PUSH HL     
2D4E 1A           LD   A,(DE) 
2D4F 6F           LD   L,A    
2D50 13           INC  DE     
2D51 1A           LD   A,(DE) 
2D52 11 F7 FF     LD   DE,FFF7h 
2D55 DD E3        EX   (SP),IX 
2D57 DD CB 04 4E  BIT  1,(IX+4) 
2D5B DD E3        EX   (SP),IX 
2D5D 20 0B        JR   NZ,L2D6A 
2D5F 16 0F        LD   D,0Fh  
2D61 30 05        JR   NC,L2D68 
2D63 67           LD   H,A    
2D64 CD 80 2E     CALL L2E80  
2D67 6C           LD   L,H    
2D68 L2D68:
2D68 E6 0F        AND  0Fh    
2D6A L2D6A:
2D6A 67           LD   H,A    
2D6B EB           EX   DE,HL  
2D6C B7           OR   A      
2D6D ED 52        SBC  HL,DE  
2D6F E1           POP  HL     
2D70 D0           RET  NC     
2D71 ED 53 12 B2  LD   (LB212),DE 
2D75 L2D75:
2D75 11 FF FF     LD   DE,FFFFh 
2D78 C9           RET         


2D79 E5           defb E5h    
2D7A DD           defb DDh    
2D7B E3           defb E3h    
2D7C C5           defb C5h    
2D7D DD           defb DDh    
2D7E 46           defb 46h    
2D7F 0B           defb 0Bh    
2D80 EB           defb EBh    
2D81 2B           defb 2Bh    


             org 2EC4h


2EC4 L2EC4:
2EC4 CD BF 2A     CALL L2ABF  
2EC7 CD 8C 2C     CALL L2C8C  
2ECA E5           PUSH HL     
2ECB CD B5 2B     CALL L2BB5  
2ECE CB F6        SET  6,(HL) 
2ED0 E1           POP  HL     
2ED1 CD 31 2C     CALL L2C31  
2ED4 23           INC  HL     
2ED5 23           INC  HL     
2ED6 36 00        LD   (HL),00h 
2ED8 F1           POP  AF     
2ED9 C1           POP  BC     
2EDA 13           INC  DE     
2EDB 10 DB        DJNZ L2EB8  
2EDD 47           LD   B,A    
2EDE 78           LD   A,B    
2EDF DD BE 18     CP   (IX+24) 
2EE2 28 1B        JR   Z,L2EFF 
2EE4 C5           PUSH BC     
2EE5 AF           XOR  A      
2EE6 57           LD   D,A    
2EE7 5F           LD   E,A    
2EE8 06 01        LD   B,01h  
2EEA CD CE 2A     CALL L2ACE  
2EED CD 34 2C     CALL L2C34  
2EF0 CD B5 2B     CALL L2BB5  
2EF3 11 08 00     LD   DE,0008h 
2EF6 19           ADD  HL,DE  
2EF7 CD 00 30     CALL L3000  
2EFA C1           POP  BC     
2EFB 70           LD   (HL),B 
2EFC DD 70 18     LD   (IX+24),B 
2EFF L2EFF:
2EFF D1           POP  DE     
2F00 C1           POP  BC     
2F01 DD E3        EX   (SP),IX 
2F03 E1           POP  HL     
2F04 C9           RET         


2F05 11           defb 11h    
2F06 00           defb 00h    
2F07 00           defb 00h    
2F08 4F           defb 4Fh    
2F09 06           defb 06h    
2F0A FF           defb FFh    
2F0B CD           defb CDh    
2F0C 9D           defb 9Dh    
2F0D 2D           defb 2Dh    
2F0E 13           defb 13h    
2F0F 01           defb 01h    
2F10 FF           defb FFh    
2F11 FF           defb FFh    
2F12 CD           defb CDh    
2F13 9D           defb 9Dh    
2F14 2D           defb 2Dh    
2F15 13           defb 13h    
2F16 01           defb 01h    
2F17 00           defb 00h    
2F18 00           defb 00h    
2F19 CD           defb CDh    
2F1A 9D           defb 9Dh    
2F1B 2D           defb 2Dh    
2F1C E5           defb E5h    
2F1D 01           defb 01h    
2F1E 16           defb 16h    
2F1F 00           defb 00h    
2F20 09           defb 09h    
2F21 7E           defb 7Eh    
2F22 23           defb 23h    
2F23 66           defb 66h    
2F24 6F           defb 6Fh    
2F25 ED           defb EDh    
2F26 52           defb 52h    
2F27 E1           defb E1h    
2F28 20           defb 20h    
2F29 EB           defb EBh    
2F2A C9           defb C9h    


2F2B L2F2B:
2F2B 32 67 BD     LD   (LBD67),A 
2F2E D5           PUSH DE     
2F2F C5           PUSH BC     
2F30 11 FF FF     LD   DE,FFFFh 
2F33 ED 53 00 00  LD   (L0000),DE 


             org 2F7Bh


2F7B L2F7B:
2F7B CD 8A 2E     CALL L2E8A  
2F7E ED 4B 60 BD  LD   BC,(LBD60) 
2F82 D1           POP  DE     
2F83 AF           XOR  A      
2F84 C9           RET         


2F85 D1           defb D1h    
2F86 D1           defb D1h    
2F87 ED           defb EDh    
2F88 5B           defb 5Bh    
2F89 60           defb 60h    
2F8A BD           defb BDh    
2F8B 7A           defb 7Ah    
2F8C A3           defb A3h    
2F8D 3C           defb 3Ch    
2F8E C4           defb C4h    
2F8F E8           defb E8h    
2F90 2F           defb 2Fh    
2F91 D1           defb D1h    
2F92 3E           defb 3Eh    
2F93 D4           defb D4h    
2F94 B7           defb B7h    
2F95 C9           defb C9h    
2F96 E5           defb E5h    
2F97 DD           defb DDh    
2F98 E3           defb E3h    
2F99 D5           defb D5h    
2F9A 7A           defb 7Ah    
2F9B B3           defb B3h    
2F9C 20           defb 20h    
2F9D 19           defb 19h    
2F9E E5           defb E5h    
2F9F DD           defb DDh    
2FA0 4E           defb 4Eh    
2FA1 12           defb 12h    
2FA2 DD           defb DDh    
2FA3 46           defb 46h    
2FA4 13           defb 13h    
2FA5 DD           defb DDh    
2FA6 5E           defb 5Eh    
2FA7 14           defb 14h    
2FA8 DD           defb DDh    
2FA9 56           defb 56h    
2FAA 15           defb 15h    
2FAB 62           defb 62h    
2FAC 6B           defb 6Bh    
2FAD ED           defb EDh    
2FAE 42           defb 42h    
2FAF 0E           defb 0Eh    
2FB0 00           defb 00h    
2FB1 45           defb 45h    
2FB2 05           defb 05h    
2FB3 1B           defb 1Bh    
2FB4 E1           defb E1h    
2FB5 18           defb 18h    
2FB6 0A           defb 0Ah    
2FB7 DD           defb DDh    
2FB8 7E           defb 7Eh    
2FB9 0A           defb 0Ah    
2FBA CD           defb CDh    
2FBB 79           defb 79h    
2FBC 2D           defb 2Dh    
2FBD 4F           defb 4Fh    
2FBE DD           defb DDh    
2FBF 46           defb 46h    
2FC0 0A           defb 0Ah    
2FC1 04           defb 04h    
2FC2 C5           defb C5h    
2FC3 20           defb 20h    
2FC4 03           defb 03h    
2FC5 CD           defb CDh    
2FC6 34           defb 34h    
2FC7 2C           defb 2Ch    
2FC8 06           defb 06h    
2FC9 00           defb 00h    
2FCA 79           defb 79h    
2FCB CD           defb CDh    
2FCC CE           defb CEh    
2FCD 2A           defb 2Ah    
2FCE E5           defb E5h    
2FCF 01           defb 01h    
2FD0 0B           defb 0Bh    
2FD1 00           defb 00h    
2FD2 09           defb 09h    
2FD3 48           defb 48h    
2FD4 71           defb 71h    
2FD5 23           defb 23h    
2FD6 71           defb 71h    
2FD7 23           defb 23h    
2FD8 10           defb 10h    
2FD9 FA           defb FAh    
2FDA CD           defb CDh    
2FDB B5           defb B5h    
2FDC 2B           defb 2Bh    
2FDD E1           defb E1h    
2FDE C1           defb C1h    


             org 33EBh


33EB L33EB:
33EB CD 72 39     CALL L3972  
33EE E5           PUSH HL     
33EF CD E4 3C     CALL L3CE4  
33F2 DD E3        EX   (SP),IX 
33F4 DD 36 09 07  LD   (IX+9),%s 
33F8 DD E3        EX   (SP),IX 
33FA E1           POP  HL     
33FB B7           OR   A      
33FC C9           RET         


33FD F5           defb F5h    
33FE D5           defb D5h    
33FF E5           defb E5h    
3400 11           defb 11h    
3401 09           defb 09h    
3402 00           defb 00h    
3403 19           defb 19h    
3404 7E           defb 7Eh    
3405 FE           defb FEh    
3406 02           defb 02h    
3407 E1           defb E1h    
3408 C5           defb C5h    
3409 38           defb 38h    
340A 13           defb 13h    
340B CD           defb CDh    
340C C0           defb C0h    
340D 33           defb 33h    
340E 38           defb 38h    
340F 2C           defb 2Ch    
3410 CD           defb CDh    
3411 E4           defb E4h    
3412 3C           defb 3Ch    
3413 FE           defb FEh    
3414 03           defb 03h    
3415 30           defb 30h    
3416 25           defb 25h    
3417 FE           defb FEh    
3418 02           defb 02h    
3419 CC           defb CCh    
341A 40           defb 40h    
341B 34           defb 34h    
341C 28           defb 28h    
341D 1E           defb 1Eh    
341E DD           defb DDh    
341F E5           defb E5h    
3420 CD           defb CDh    
3421 62           defb 62h    
3422 35           defb 35h    
3423 DD           defb DDh    
3424 21           defb 21h    
3425 82           defb 82h    
3426 B8           defb B8h    
3427 CD           defb CDh    
3428 5F           defb 5Fh    
3429 37           defb 37h    
342A CD           defb CDh    
342B F4           defb F4h    
342C 34           defb 34h    
342D 28           defb 28h    
342E 0B           defb 0Bh    
342F 3E           defb 3Eh    
3430 F5           defb F5h    
3431 11           defb 11h    
3432 FF           defb FFh    
3433 FF           defb FFh    
3434 42           defb 42h    
3435 CD           defb CDh    
3436 79           defb 79h    
3437 3D           defb 3Dh    
3438 18           defb 18h    
3439 E6           defb E6h    
343A DD           defb DDh    
343B E1           defb E1h    
343C C1           defb C1h    
343D D1           defb D1h    
343E F1           defb F1h    
343F C9           defb C9h    
3440 DD           defb DDh    
3441 E5           defb E5h    
3442 E5           defb E5h    
3443 DD           defb DDh    
3444 E1           defb E1h    
3445 DD           defb DDh    
3446 CB           defb CBh    
3447 05           defb 05h    
3448 5E           defb 5Eh    
3449 DD           defb DDh    
344A E1           defb E1h    
344B 28           defb 28h    
344C 04           defb 04h    
344D 3E           defb 3Eh    
344E 01           defb 01h    


             org 3AE4h


3AE4 L3AE4:
3AE4 CD FA 3A     CALL L3AFA  
3AE7 08           EX   AF,AF' 
3AE8 F1           POP  AF     
3AE9 08           EX   AF,AF' 
3AEA D9           EXX         
3AEB C1           POP  BC     
3AEC D1           POP  DE     
3AED E1           POP  HL     
3AEE D9           EXX         
3AEF DD E1        POP  IX     
3AF1 E1           POP  HL     
3AF2 FD E1        POP  IY     
3AF4 B7           OR   A      
3AF5 C9           RET         


3AF6 3E           defb 3Eh    
3AF7 DF           defb DFh    
3AF8 B7           defb B7h    
3AF9 C9           defb C9h    


3AFA L3AFA:
3AFA E9           JP   (HL)   


3AFB 13           defb 13h    
3AFC 3B           defb 3Bh    
3AFD 16           defb 16h    
3AFE 3B           defb 3Bh    
3AFF 3C           defb 3Ch    
3B00 3B           defb 3Bh    
3B01 59           defb 59h    
3B02 3B           defb 3Bh    
3B03 71           defb 71h    
3B04 3B           defb 3Bh    
3B05 7C           defb 7Ch    
3B06 3B           defb 3Bh    
3B07 BB           defb BBh    
3B08 3B           defb 3Bh    
3B09 BE           defb BEh    
3B0A 3B           defb 3Bh    
3B0B FC           defb FCh    
3B0C 3B           defb 3Bh    
3B0D 29           defb 29h    
3B0E 3C           defb 3Ch    
3B0F 2A           defb 2Ah    
3B10 3C           defb 3Ch    
3B11 2D           defb 2Dh    
3B12 3C           defb 3Ch    
3B13 B7           defb B7h    
3B14 18           defb 18h    
3B15 01           defb 01h    
3B16 37           defb 37h    
3B17 08           defb 08h    
3B18 21           defb 21h    
3B19 00           defb 00h    
3B1A 40           defb 40h    
3B1B D9           defb D9h    
3B1C 79           defb 79h    
3B1D F5           defb F5h    
3B1E DD           defb DDh    
3B1F CB           defb CBh    
3B20 04           defb 04h    
3B21 4E           defb 4Eh    
3B22 DD           defb DDh    
3B23 7E           defb 7Eh    
3B24 1D           defb 1Dh    
3B25 28           defb 28h    
3B26 03           defb 03h    
3B27 3A           defb 3Ah    
3B28 5E           defb 5Eh    
3B29 BD           defb BDh    
3B2A 4F           defb 4Fh    
3B2B F1           defb F1h    
3B2C C5           defb C5h    
3B2D CD           defb CDh    
3B2E 30           defb 30h    
3B2F 3C           defb 3Ch    
3B30 38           defb 38h    
3B31 03           defb 03h    
3B32 C1           defb C1h    
3B33 AF           defb AFh    
3B34 C9           defb C9h    
3B35 08           defb 08h    
3B36 F1           defb F1h    
3B37 90           defb 90h    
3B38 47           defb 47h    
3B39 08           defb 08h    
3B3A 18           defb 18h    
3B3B 56           defb 56h    
3B3C 08           defb 08h    
3B3D 21           defb 21h    
3B3E 03           defb 03h    
3B3F 40           defb 40h    
3B40 D9           defb D9h    
3B41 06           defb 06h    
3B42 00           defb 00h    
3B43 DD           defb DDh    
3B44 4E           defb 4Eh    
3B45 1D           defb 1Dh    
3B46 CB           defb CBh    
3B47 F9           defb F9h    


             org 3BF1h


3BF1 L3BF1:
3BF1 CD 30 3C     CALL L3C30  
3BF4 B7           OR   A      
3BF5 28 03        JR   Z,L3BFA 
3BF7 E1           POP  HL     
3BF8 37           SCF         
3BF9 C9           RET         
3BFA L3BFA:
3BFA C1           POP  BC     
3BFB C9           RET         


3BFC DD           defb DDh    
3BFD CB           defb CBh    
3BFE 05           defb 05h    
3BFF 56           defb 56h    
3C00 20           defb 20h    
3C01 05           defb 05h    
3C02 D9           defb D9h    
3C03 AF           defb AFh    
3C04 06           defb 06h    
3C05 01           defb 01h    
3C06 C9           defb C9h    
3C07 21           defb 21h    
3C08 66           defb 66h    
3C09 41           defb 41h    
3C0A 79           defb 79h    
3C0B D9           defb D9h    
3C0C 08           defb 08h    
3C0D DD           defb DDh    
3C0E 7E           defb 7Eh    
3C0F 01           defb 01h    
3C10 08           defb 08h    
3C11 DD           defb DDh    
3C12 46           defb 46h    
3C13 06           defb 06h    
3C14 CD           defb CDh    
3C15 30           defb 30h    
3C16 3C           defb 3Ch    
3C17 B7           defb B7h    
3C18 28           defb 28h    
3C19 0C           defb 0Ch    
3C1A 3D           defb 3Dh    
3C1B 06           defb 06h    
3C1C 01           defb 01h    
3C1D C8           defb C8h    
3C1E 3D           defb 3Dh    
3C1F 06           defb 06h    
3C20 FF           defb FFh    
3C21 C8           defb C8h    
3C22 AF           defb AFh    
3C23 06           defb 06h    
3C24 00           defb 00h    
3C25 C9           defb C9h    
3C26 3E           defb 3Eh    
3C27 FC           defb FCh    
3C28 C9           defb C9h    
3C29 C9           defb C9h    
3C2A 3E           defb 3Eh    
3C2B F0           defb F0h    
3C2C C9           defb C9h    
3C2D 3E           defb 3Eh    
3C2E F0           defb F0h    
3C2F C9           defb C9h    


3C30 L3C30:
3C30 CD 29 0B     CALL L0B29  
3C33 D9           EXX         
3C34 DD CB 05 46  BIT  0,(IX+5) 
3C38 20 08        JR   NZ,L3C42 
3C3A DD 5E 01     LD   E,(IX+1) 
3C3D 16 00        LD   D,00h  
3C3F 19           ADD  HL,DE  
3C40 18 06        JR   L3C48  
3C42 L3C42:
3C42 22 D0 F1     LD   (LF1D0),HL 
3C45 21 48 40     LD   HL,4048h 
3C48 L3C48:
3C48 DD 46 00     LD   B,(IX+0) 
3C4B DD CB 04 6E  BIT  5,(IX+4) 
3C4F CD 24 F2     CALL LF224  
3C52 E5           PUSH HL     
3C53 C5           PUSH BC     
3C54 01 00 00     LD   BC,0000h 


             org 3C9Fh


3C9F L3C9F:
3C9F 08           EX   AF,AF' 
3CA0 3A CF F2     LD   A,(LF2CF) 
3CA3 CD 24 F2     CALL LF224  
3CA6 08           EX   AF,AF' 
3CA7 C9           RET         


3CA8 06           defb 06h    
3CA9 08           defb 08h    
3CAA 78           defb 78h    
3CAB CD           defb CDh    
3CAC C3           defb C3h    
3CAD 3C           defb 3Ch    
3CAE 5E           defb 5Eh    
3CAF 23           defb 23h    
3CB0 56           defb 56h    
3CB1 7A           defb 7Ah    
3CB2 B3           defb B3h    
3CB3 28           defb 28h    
3CB4 0A           defb 0Ah    
3CB5 21           defb 21h    
3CB6 09           defb 09h    
3CB7 00           defb 00h    
3CB8 19           defb 19h    
3CB9 7E           defb 7Eh    
3CBA B7           defb B7h    
3CBB 28           defb 28h    
3CBC 02           defb 02h    
3CBD 36           defb 36h    
3CBE 01           defb 01h    
3CBF 10           defb 10h    
3CC0 E9           defb E9h    
3CC1 AF           defb AFh    
3CC2 C9           defb C9h    
3CC3 D5           defb D5h    
3CC4 B7           defb B7h    
3CC5 20           defb 20h    
3CC6 03           defb 03h    
3CC7 3A           defb 3Ah    
3CC8 3C           defb 3Ch    
3CC9 F2           defb F2h    
3CCA 0E           defb 0Eh    
3CCB DB           defb DBh    
3CCC FE           defb FEh    
3CCD 09           defb 09h    
3CCE 38           defb 38h    
3CCF 01           defb 01h    
3CD0 AF           defb AFh    
3CD1 21           defb 21h    
3CD2 C8           defb C8h    
3CD3 BB           defb BBh    
3CD4 5F           defb 5Fh    
3CD5 16           defb 16h    
3CD6 00           defb 00h    
3CD7 19           defb 19h    
3CD8 7E           defb 7Eh    
3CD9 5F           defb 5Fh    
3CDA 16           defb 16h    
3CDB 00           defb 00h    
3CDC 21           defb 21h    
3CDD D1           defb D1h    
3CDE BB           defb BBh    
3CDF 19           defb 19h    
3CE0 19           defb 19h    
3CE1 D1           defb D1h    
3CE2 B7           defb B7h    
3CE3 C9           defb C9h    


3CE4 L3CE4:
3CE4 F5           PUSH AF     
3CE5 E5           PUSH HL     
3CE6 2A 4D F3     LD   HL,(LF34D) 
3CE9 2B           DEC  HL     
3CEA 7E           LD   A,(HL) 
3CEB 3C           INC  A      
3CEC 20 1C        JR   NZ,L3D0A 
3CEE 36 00        LD   (HL),00h 
3CF0 D5           PUSH DE     
3CF1 ED 5B 3F F3  LD   DE,(LF33F) 
3CF5 16 00        LD   D,00h  
3CF7 21 D3 BB     LD   HL,BBD3h 
3CFA 19           ADD  HL,DE  
3CFB 19           ADD  HL,DE  
3CFC 5E           LD   E,(HL) 
3CFD 23           INC  HL     
3CFE 56           LD   D,(HL) 
3CFF 21 09 00     LD   HL,0009h 
3D02 19           ADD  HL,DE  


             org C1CEh


C1CE LC1CE:
C1CE CD B9 3D     CALL L3DB9  


C1D1 LC1D1:
C1D1 F1           POP  AF     
C1D2 D1           POP  DE     
C1D3 C9           RET         


C1D4 E5           defb E5h    
C1D5 CD           defb CDh    
C1D6 2A           defb 2Ah    
C1D7 4B           defb 4Bh    
C1D8 11           defb 11h    
C1D9 0E           defb 0Eh    
C1DA 00           defb 00h    
C1DB CD           defb CDh    
C1DC 68           defb 68h    
C1DD 27           defb 27h    
C1DE E1           defb E1h    
C1DF DA           defb DAh    
C1E0 FE           defb FEh    
C1E1 44           defb 44h    
C1E2 E5           defb E5h    
C1E3 CD           defb CDh    
C1E4 5C           defb 5Ch    
C1E5 4A           defb 4Ah    
C1E6 28           defb 28h    
C1E7 FB           defb FBh    
C1E8 CD           defb CDh    
C1E9 5C           defb 5Ch    
C1EA 4A           defb 4Ah    
C1EB 20           defb 20h    
C1EC FB           defb FBh    
C1ED CD           defb CDh    
C1EE 7A           defb 7Ah    
C1EF 4A           defb 4Ah    
C1F0 E1           defb E1h    
C1F1 CD           defb CDh    
C1F2 44           defb 44h    
C1F3 47           defb 47h    
C1F4 E5           defb E5h    
C1F5 CD           defb CDh    
C1F6 20           defb 20h    
C1F7 4B           defb 4Bh    
C1F8 EB           defb EBh    
C1F9 E1           defb E1h    
C1FA D5           defb D5h    
C1FB CD           defb CDh    
C1FC 5C           defb 5Ch    
C1FD 4A           defb 4Ah    
C1FE CD           defb CDh    
C1FF 7A           defb 7Ah    
C200 4A           defb 4Ah    
C201 B7           defb B7h    
C202 28           defb 28h    
C203 08           defb 08h    
C204 CD           defb CDh    
C205 63           defb 63h    
C206 45           defb 45h    
C207 CD           defb CDh    
C208 B0           defb B0h    
C209 3B           defb 3Bh    
C20A 18           defb 18h    
C20B F2           defb F2h    
C20C D1           defb D1h    
C20D EB           defb EBh    
C20E CD           defb CDh    
C20F 4E           defb 4Eh    
C210 4B           defb 4Bh    
C211 EB           defb EBh    
C212 3A           defb 3Ah    
C213 B1           defb B1h    
C214 64           defb 64h    
C215 CB           defb CBh    
C216 D7           defb D7h    
C217 32           defb 32h    
C218 B1           defb B1h    
C219 64           defb 64h    
C21A C3           defb C3h    
C21B FE           defb FEh    
C21C 44           defb 44h    
C21D E5           defb E5h    
C21E CD           defb CDh    
C21F 2A           defb 2Ah    
C220 4B           defb 4Bh    
C221 11           defb 11h    
C222 0E           defb 0Eh    
C223 00           defb 00h    
C224 CD           defb CDh    
C225 68           defb 68h    
C226 27           defb 27h    
C227 E1           defb E1h    
C228 DA           defb DAh    
C229 FE           defb FEh    
C22A 44           defb 44h    
C22B E5           defb E5h    
C22C CD           defb CDh    
C22D 5C           defb 5Ch    
C22E 4A           defb 4Ah    
C22F CD           defb CDh    
C230 7A           defb 7Ah    
C231 4A           defb 4Ah    


             org DFE7h


DFE7 LDFE7:
DFE7 CD 5B E1     CALL LE15B  
DFEA 7D           LD   A,L    
DFEB 44           LD   B,H    
DFEC C9           RET         


DFED 1E           defb 1Eh    
DFEE 00           defb 00h    
DFEF D5           defb D5h    
DFF0 CD           defb CDh    
DFF1 5B           defb 5Bh    
DFF2 E1           defb E1h    
DFF3 D1           defb D1h    
DFF4 B7           defb B7h    
DFF5 7B           defb 7Bh    
DFF6 20           defb 20h    
DFF7 03           defb 03h    
DFF8 32           defb 32h    
DFF9 04           defb 04h    
DFFA 00           defb 00h    
DFFB 7D           defb 7Dh    
DFFC 44           defb 44h    
DFFD C9           defb C9h    
DFFE 3A           defb 3Ah    
DFFF EF           defb EFh    
E000 F2           defb F2h    
E001 E6           defb E6h    
E002 01           defb 01h    
E003 28           defb 28h    
E004 14           defb 14h    
E005 EB           defb EBh    
E006 ED           defb EDh    
E007 5B           defb 5Bh    
E008 4D           defb 4Dh    
E009 F3           defb F3h    
E00A 01           defb 01h    
E00B FF           defb FFh    
E00C 01           defb 01h    
E00D ED           defb EDh    
E00E B0           defb B0h    
E00F 3E           defb 3Eh    
E010 24           defb 24h    
E011 12           defb 12h    
E012 0E           defb 0Eh    
E013 09           defb 09h    
E014 CD           defb CDh    
E015 5B           defb 5Bh    
E016 E1           defb E1h    
E017 18           defb 18h    
E018 46           defb 46h    
E019 1A           defb 1Ah    
E01A 13           defb 13h    
E01B FE           defb FEh    
E01C 1B           defb 1Bh    
E01D 20           defb 20h    
E01E 18           defb 18h    
E01F CD           defb CDh    
E020 41           defb 41h    
E021 E0           defb E0h    
E022 1A           defb 1Ah    
E023 13           defb 13h    
E024 FE           defb FEh    
E025 59           defb 59h    
E026 20           defb 20h    
E027 0F           defb 0Fh    
E028 CD           defb CDh    
E029 41           defb 41h    
E02A E0           defb E0h    
E02B 1A           defb 1Ah    
E02C 13           defb 13h    
E02D CD           defb CDh    
E02E 41           defb 41h    
E02F E0           defb E0h    
E030 1A           defb 1Ah    
E031 13           defb 13h    
E032 CD           defb CDh    
E033 41           defb 41h    
E034 E0           defb E0h    
E035 18           defb 18h    
E036 E2           defb E2h    
E037 FE           defb FEh    
E038 24           defb 24h    
E039 CA           defb CAh    
E03A 5F           defb 5Fh    
E03B E0           defb E0h    
E03C CD           defb CDh    
E03D 41           defb 41h    
E03E E0           defb E0h    
E03F 18           defb 18h    
E040 D8           defb D8h    
E041 D5           defb D5h    
E042 5F           defb 5Fh    
E043 0E           defb 0Eh    
E044 02           defb 02h    
E045 CD           defb CDh    
E046 5B           defb 5Bh    
E047 E1           defb E1h    
E048 D1           defb D1h    
E049 C9           defb C9h    
E04A D5           defb D5h    


             org E8B4h


E8B4 LE8B4:
E8B4 CD 1C 00     CALL L001C  
E8B7 18 0E        JR   LE8C7  


E8B9 08           defb 08h    
E8BA F1           defb F1h    
E8BB DD           defb DDh    
E8BC E5           defb E5h    
E8BD DD           defb DDh    
E8BE 21           defb 21h    
E8BF 80           defb 80h    
E8C0 01           defb 01h    
E8C1 CD           defb CDh    
E8C2 DC           defb DCh    
E8C3 F1           defb F1h    
E8C4 DD           defb DDh    
E8C5 E1           defb E1h    
E8C6 08           defb 08h    


E8C7 LE8C7:
E8C7 08           EX   AF,AF' 
E8C8 3A 6B F3     LD   A,(LF36B) 
E8CB CD FF E8     CALL LE8FF  
E8CE 08           EX   AF,AF' 
E8CF C9           RET         


E8D0 F1           defb F1h    
E8D1 CD           defb CDh    
E8D2 C7           defb C7h    
E8D3 E8           defb E8h    
E8D4 FD           defb FDh    
E8D5 E5           defb E5h    
E8D6 D5           defb D5h    
E8D7 CD           defb CDh    
E8D8 2D           defb 2Dh    
E8D9 40           defb 40h    
E8DA F5           defb F5h    
E8DB CD           defb CDh    
E8DC EB           defb EBh    
E8DD EB           defb EBh    
E8DE F5           defb F5h    
E8DF CD           defb CDh    
E8E0 27           defb 27h    
E8E1 E9           defb E9h    
E8E2 FD           defb FDh    
E8E3 2A           defb 2Ah    
E8E4 47           defb 47h    
E8E5 F3           defb F3h    
E8E6 DD           defb DDh    
E8E7 2A           defb 2Ah    
E8E8 DC           defb DCh    
E8E9 F2           defb F2h    
E8EA CD           defb CDh    
E8EB 1C           defb 1Ch    
E8EC 00           defb 00h    
E8ED CD           defb CDh    
E8EE 48           defb 48h    
E8EF E9           defb E9h    
E8F0 F1           defb F1h    
E8F1 CD           defb CDh    
E8F2 E5           defb E5h    
E8F3 EB           defb EBh    
E8F4 F1           defb F1h    
E8F5 26           defb 26h    
E8F6 40           defb 40h    
E8F7 CD           defb CDh    
E8F8 24           defb 24h    
E8F9 00           defb 00h    
E8FA D1           defb D1h    
E8FB FD           defb FDh    
E8FC E1           defb E1h    
E8FD 3E           defb 3Eh    
E8FE C9           defb C9h    


E8FF LE8FF:
E8FF 32 68 F3     LD   (LF368),A 
E902 D9           EXX         
E903 21 4F F2     LD   HL,F24Fh 
E906 11 16 E9     LD   DE,E916h 
E909 06 03        LD   B,03h  
E90B LE90B:
E90B 4E           LD   C,(HL) 
E90C 1A           LD   A,(DE) 
E90D 77           LD   (HL),A 
E90E 79           LD   A,C    
E90F 12           LD   (DE),A 
E910 23           INC  HL     
E911 13           INC  DE     
E912 10 F7        DJNZ LE90B  
E914 D9           EXX         
E915 C9           RET         


E916 C9           defb C9h    
E917 C9           defb C9h    


             org E924h


E924 LE924:
E924 CD 05 00     CALL L0005  
E927 F3           DI          
E928 F5           PUSH AF     
E929 00           NOP         
E92A 00           NOP         
E92B 3A EB F2     LD   A,(LF2EB) 
E92E 32 C8 FC     LD   (LFCC8),A 
E931 32 FF FF     LD   (LFFFF),A 
E934 3A EA F2     LD   A,(LF2EA) 
E937 D3 A8        OUT  (00A8h),A 
E939 3A CB F2     LD   A,(LF2CB) 
E93C CD D1 EB     CALL LEBD1  
E93F 3A CD F2     LD   A,(LF2CD) 
E942 CD E5 EB     CALL LEBE5  
E945 F1           POP  AF     
E946 FB           EI          
E947 C9           RET         


E948 F3           defb F3h    
E949 F5           defb F5h    
E94A 00           defb 00h    
E94B 00           defb 00h    
E94C 3A           defb 3Ah    
E94D FF           defb FFh    
E94E FF           defb FFh    
E94F 2F           defb 2Fh    
E950 32           defb 32h    
E951 EB           defb EBh    
E952 F2           defb F2h    
E953 E6           defb E6h    
E954 CC           defb CCh    
E955 F6           defb F6h    
E956 22           defb 22h    
E957 32           defb 32h    
E958 C8           defb C8h    
E959 FC           defb FCh    
E95A 32           defb 32h    
E95B FF           defb FFh    
E95C FF           defb FFh    
E95D DB           defb DBh    
E95E A8           defb A8h    
E95F 32           defb 32h    
E960 EA           defb EAh    
E961 F2           defb F2h    
E962 E6           defb E6h    
E963 CC           defb CCh    
E964 F6           defb F6h    
E965 33           defb 33h    
E966 D3           defb D3h    
E967 A8           defb A8h    
E968 CD           defb CDh    
E969 D7           defb D7h    
E96A EB           defb EBh    
E96B 32           defb 32h    
E96C CB           defb CBh    
E96D F2           defb F2h    
E96E CD           defb CDh    
E96F E1           defb E1h    
E970 EB           defb EBh    
E971 32           defb 32h    
E972 CC           defb CCh    
E973 F2           defb F2h    
E974 CD           defb CDh    
E975 EB           defb EBh    
E976 EB           defb EBh    
E977 32           defb 32h    
E978 CD           defb CDh    
E979 F2           defb F2h    
E97A 3A           defb 3Ah    
E97B D0           defb D0h    
E97C F2           defb F2h    
E97D CD           defb CDh    
E97E D1           defb D1h    
E97F EB           defb EBh    
E980 3A           defb 3Ah    
E981 CF           defb CFh    
E982 F2           defb F2h    
E983 CD           defb CDh    
E984 E5           defb E5h    
E985 EB           defb EBh    
E986 F1           defb F1h    
E987 FB           defb FBh    


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
F3AE 50           defb 50h    
F3AF 1D           defb 1Dh    
F3B0 50           defb 50h    
F3B1 18           defb 18h    
F3B2 0E           defb 0Eh    
F3B3 00           defb 00h    
F3B4 00           defb 00h    
F3B5 00           defb 00h    
F3B6 08           defb 08h    
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
F3DB FF           defb FFh    
F3DC 05           defb 05h    
F3DD 01           defb 01h    
F3DE 00           defb 00h    
F3DF 04           defb 04h    
F3E0 70           defb 70h    
F3E1 03           defb 03h    
F3E2 27           defb 27h    
F3E3 02           defb 02h    
F3E4 36           defb 36h    
F3E5 07           defb 07h    
F3E6 F4           defb F4h    
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