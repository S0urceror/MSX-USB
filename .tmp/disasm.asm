L0020:       equ  0020h
L7E1A:       equ  7E1Ah
L7FF5:       equ  7FF5h


             org 7C8Ch


7C8C L7C8C:
7C8C CD           defb CDh    
7C8D 5D           defb 5Dh    
7C8E 7D           defb 7Dh    
7C8F 22           defb 22h    
7C90 48           defb 48h    
7C91 FC           defb FCh    
7C92 01           defb 01h    
7C93 90           defb 90h    
7C94 00           defb 00h    
7C95 11           defb 11h    
7C96 80           defb 80h    
7C97 F3           defb F3h    
7C98 21           defb 21h    
7C99 27           defb 27h    
7C9A 7F           defb 7Fh    
7C9B ED           defb EDh    
7C9C B0           defb B0h    
7C9D CD           defb CDh    
7C9E 3E           defb 3Eh    
7C9F 00           defb 00h    
7CA0 AF           defb AFh    
7CA1 32           defb 32h    
7CA2 60           defb 60h    
7CA3 F6           defb F6h    
7CA4 32           defb 32h    
7CA5 7C           defb 7Ch    
7CA6 F8           defb F8h    
7CA7 3E           defb 3Eh    
7CA8 2C           defb 2Ch    
7CA9 32           defb 32h    
7CAA 5D           defb 5Dh    
7CAB F5           defb F5h    
7CAC 3E           defb 3Eh    
7CAD 3A           defb 3Ah    
7CAE 32           defb 32h    
7CAF 1E           defb 1Eh    
7CB0 F4           defb F4h    
7CB1 2A           defb 2Ah    
7CB2 04           defb 04h    
7CB3 00           defb 00h    
7CB4 22           defb 22h    
7CB5 20           defb 20h    
7CB6 F9           defb F9h    
7CB7 21           defb 21h    
7CB8 E4           defb E4h    
7CB9 F6           defb F6h    
7CBA 22           defb 22h    
7CBB 4C           defb 4Ch    
7CBC F7           defb F7h    
7CBD 22           defb 22h    
7CBE 74           defb 74h    
7CBF F6           defb F6h    
7CC0 01           defb 01h    
7CC1 C8           defb C8h    
7CC2 00           defb 00h    
7CC3 09           defb 09h    
7CC4 22           defb 22h    
7CC5 72           defb 72h    
7CC6 F6           defb F6h    
7CC7 3E           defb 3Eh    
7CC8 01           defb 01h    
7CC9 32           defb 32h    
7CCA C3           defb C3h    
7CCB F6           defb F6h    
7CCC CD           defb CDh    
7CCD 6B           defb 6Bh    
7CCE 7E           defb 7Eh    
7CCF CD           defb CDh    
7CD0 E5           defb E5h    
7CD1 62           defb 62h    
7CD2 2A           defb 2Ah    
7CD3 48           defb 48h    
7CD4 FC           defb FCh    
7CD5 AF           defb AFh    
7CD6 77           defb 77h    
7CD7 23           defb 23h    
7CD8 22           defb 22h    
7CD9 76           defb 76h    
7CDA F6           defb F6h    
7CDB CD           defb CDh    
7CDC 87           defb 87h    
7CDD 62           defb 62h    
7CDE CD           defb CDh    
7CDF 3B           defb 3Bh    
7CE0 00           defb 00h    
7CE1 18           defb 18h    
7CE2 31           defb 31h    
7CE3 CD           defb CDh    
7CE4 F4           defb F4h    
7CE5 FD           defb FDh    
7CE6 DD           defb DDh    
7CE7 21           defb 21h    
7CE8 79           defb 79h    
7CE9 01           defb 01h    
7CEA C3           defb C3h    
7CEB 5F           defb 5Fh    
7CEC 01           defb 01h    
7CED DD           defb DDh    
7CEE 21           defb 21h    
7CEF 85           defb 85h    


             org 7D63h


7D63 L7D63:
7D63 00           NOP         
7D64 00           NOP         
7D65 00           NOP         
7D66 00           NOP         
7D67 00           NOP         
7D68 00           NOP         
7D69 00           NOP         
7D6A 00           NOP         
7D6B 00           NOP         
7D6C 00           NOP         
7D6D 00           NOP         
7D6E 00           NOP         
7D6F 00           NOP         
7D70 00           NOP         
7D71 00           NOP         
7D72 00           NOP         
7D73 00           NOP         
7D74 00           NOP         
7D75 00           NOP         
7D76 00           NOP         
7D77 00           NOP         
7D78 11 C1 FC     LD   DE,FCC1h 
7D7B 21 C9 FC     LD   HL,FCC9h 
7D7E 1A           LD   A,(DE) 
7D7F B1           OR   C      
7D80 4F           LD   C,A    
7D81 D5           PUSH DE     
7D82 23           INC  HL     
7D83 E5           PUSH HL     
7D84 21 00 40     LD   HL,4000h 
7D87 CD 1A 7E     CALL L7E1A  
7D8A E5           PUSH HL     
7D8B 21 41 42     LD   HL,4241h 
7D8E E7           RST  20h    
7D8F E1           POP  HL     
7D90 06 00        LD   B,00h  
7D92 20 2A        JR   NZ,L7DBE 
7D94 CD 1A 7E     CALL L7E1A  
7D97 E5           PUSH HL     
7D98 C5           PUSH BC     
7D99 D5           PUSH DE     
7D9A DD E1        POP  IX     
7D9C 79           LD   A,C    
7D9D F5           PUSH AF     
7D9E FD E1        POP  IY     
7DA0 C4 F5 7F     CALL NZ,L7FF5 
7DA3 C1           POP  BC     
7DA4 E1           POP  HL     
7DA5 CD 1A 7E     CALL L7E1A  
7DA8 C6 FF        ADD  A,FFh  
7DAA CB 18        RR   B      
7DAC CD 1A 7E     CALL L7E1A  
7DAF C6 FF        ADD  A,FFh  
7DB1 CB 18        RR   B      
7DB3 CD 1A 7E     CALL L7E1A  
7DB6 C6 FF        ADD  A,FFh  
7DB8 CB 18        RR   B      
7DBA 11 F8 FF     LD   DE,FFF8h 
7DBD 19           ADD  HL,DE  
7DBE L7DBE:
7DBE E3           EX   (SP),HL 
7DBF 70           LD   (HL),B 
7DC0 23           INC  HL     
7DC1 E3           EX   (SP),HL 
7DC2 11 FE 3F     LD   DE,3FFEh 
7DC5 19           ADD  HL,DE  
7DC6 7C           LD   A,H    


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
F3DC 09           defb 09h    
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