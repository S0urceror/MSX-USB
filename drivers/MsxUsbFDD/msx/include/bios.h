//----------------------------------------------------------
//		msxbios.h - by Danilo Angelo 2020
//		Adapted from http ://www.konamiman.com/msx/msx2th/th-ap.txt
//
//		Standard MSX variables and routines addresses
//----------------------------------------------------------

#ifndef  __MSXBIOS_H__
#define  __MSXBIOS_H__

// Adapted from https://raw.githubusercontent.com/samsaga2/js80/master/msx/bios.asm

// --- system variables
#define BIOS_HWVER	    0x002D

// --- main bios calls ---
#define BIOS_CHKRAM	    0x0000
#define BIOS_SYNCHR     0x0008
#define BIOS_RDSLT      0x000c
#define BIOS_CHRGTR     0x0010
#define BIOS_WRSLT      0x0014
#define BIOS_OUTDO      0x0018
#define BIOS_CALSLT     0x001c
#define BIOS_DCOMPR     0x0020
#define BIOS_ENASLT     0x0024
#define BIOS_GETYPR     0x0028
#define BIOS_CALLF      0x0030
#define BIOS_KEYINT     0x0038

// I/O initialisation
#define BIOS_INITIO     0x003b
#define BIOS_INIFNK     0x003e

// VDP access
#define BIOS_DISSCR     0x0041
#define BIOS_ENASCR     0x0044
#define BIOS_WRTVDP     0x0047
#define BIOS_RDVRM      0x004a
#define BIOS_WRTVRM     0x004d
#define BIOS_SETRD      0x0050
#define BIOS_SETWRT     0x0053
#define BIOS_FILVRM     0x0056
#define BIOS_LDIRMV     0x0059
#define BIOS_LDIRVM     0x005c
#define BIOS_CHGMOD     0x005f
#define BIOS_CHGCLR     0x0062
#define BIOS_NMI        0x0066
#define BIOS_CLRSPR     0x0069
#define BIOS_INITXT     0x006c
#define BIOS_INIT32     0x006f
#define BIOS_INIGRP     0x0072
#define BIOS_INIMLT     0x0075
#define BIOS_SETTXT     0x0078
#define BIOS_SETT32     0x007b
#define BIOS_SETGRP     0x007e
#define BIOS_SETMLT     0x0081
#define BIOS_CALPAT     0x0084
#define BIOS_CALATR     0x0087
#define BIOS_GSPSIZ     0x008a
#define BIOS_GRPPRT     0x008d

// PSG
#define BIOS_GICINI     0x0090
#define BIOS_WRTPSG     0x0093
#define BIOS_RDPSG      0x0096
#define BIOS_STRTMS     0x0099

// Keyboard, CRT, printer input-output
#define BIOS_CHSNS      0x009c
#define BIOS_CHGET      0x009f
#define BIOS_CHPUT      0x00a2
#define BIOS_LPTOUT     0x00a5
#define BIOS_LPTSTT     0x00a8
#define BIOS_CNVCHR     0x00ab
#define BIOS_PINLIN     0x00ae
#define BIOS_INLIN      0x00b1
#define BIOS_QINLIN     0x00b4
#define BIOS_BREAKX     0x00b7
#define BIOS_BEEP       0x00c0
#define BIOS_CLS        0x00c3
#define BIOS_POSIT      0x00c6
#define BIOS_FNKSB      0x00c9
#define BIOS_ERAFNK     0x00cc
#define BIOS_DSPFNK     0x00cf
#define BIOS_TOTEXT     0x00d2

// Game I/O access
#define BIOS_GTSTCK     0x00d5
#define BIOS_GTTRIG     0x00d8
#define BIOS_GTPAD      0x00db
#define BIOS_GTPDL      0x00de

// Cassette input-output routine
#define BIOS_TAPION     0x00e1
#define BIOS_TAPIN      0x00e4
#define BIOS_TAPIOF     0x00e7
#define BIOS_TAPOON     0x00ea
#define BIOS_TAPOUT     0x00ed
#define BIOS_TAPOOF     0x00f0
#define BIOS_STMOTR     0x00f3

// Miscellaneous
#define BIOS_CHGCAP     0x0132
#define BIOS_CHGSND     0x0135
#define BIOS_RSLREG     0x0138
#define BIOS_WSLREG     0x013b
#define BIOS_RDVDP      0x013e
#define BIOS_SNSMAT     0x0141
#define BIOS_PHYDIO     0x0144
#define BIOS_ISFLIO     0x014a
#define BIOS_OUTDLP     0x014d
#define BIOS_KILBUF     0x0156
#define BIOS_CALBAS     0x0159

// Entries appended for MSX2
#define BIOS_SUBROM     0x015c
#define BIOS_EXTROM     0x015f
#define BIOS_EOL        0x0168
#define BIOS_NSETRD     0x016e
#define BIOS_NSTWRT     0x0171
#define BIOS_NRDVRM     0x0174
#define BIOS_NWRVRM     0x0177

// --- subrom bios calls ---
#define BIOS_GRPRT      0x0089
#define BIOS_NVBXLN     0x00c9
#define BIOS_NVBXFL     0x00cd
#define BIOS_CLSSUB     0x0115
#define BIOS_VDPSTA     0x0131
#define BIOS_SETPAG     0x013d
#define BIOS_INIPLT     0x0141
#define BIOS_RSTPLT     0x0145
#define BIOS_GETPLT     0x0149
#define BIOS_SETPLT     0x014d
#define BIOS_PROMPT     0x0181
#define BIOS_NEWPAD     0x01ad
#define BIOS_CHGMDP     0x01b5
#define BIOS_KNJPRT     0x01bd
#define BIOS_REDCLK     0x01f5
#define BIOS_WRTCLK     0x01f9

#define BDOS_HIMSAV     0xf349

// --- work area ---
#define BIOS_RDPRIM     0xf380
#define BIOS_WRPRIM     0xf385
#define BIOS_CLPRIM     0xf38c

// Starting address of assembly language program of USR function, text screen
#define BIOS_USRTAB     0xf39a
#define BIOS_LINL40     0xf3ae
#define BIOS_LINL32     0xf3af
#define BIOS_LINLEN     0xf3b0
#define BIOS_CRTCNT     0xf3b1
#define BIOS_CLMLST     0xf3b2

// SCREEN 0
#define BIOS_TXTNAM     0xf3b3
#define BIOS_TXTCOL     0xf3b5
#define BIOS_TXTCGP     0xf3b7
#define BIOS_TXTATR     0xf3b9
#define BIOS_TXTPAT     0xf3bb

// SCREEN 1
#define BIOS_T32NAM     0xf3bd
#define BIOS_T32COL     0xf3bf
#define BIOS_T32CGP     0xf3c1
#define BIOS_T32ATR     0xf3c3
#define BIOS_T32PAT     0xf3c5

// SCREEN 2
#define BIOS_GRPNAM     0xf3c7
#define BIOS_GRPCOL     0xf3c9
#define BIOS_GRPCGP     0xf3cb
#define BIOS_GRPATR     0xf3cd
#define BIOS_GRPPAT     0xf3cf

// SCREEN 3
#define BIOS_MLTNAM     0xf3d1
#define BIOS_MLTCOL     0xf3d3
#define BIOS_MLTCGP     0xf3d5
#define BIOS_MLTATR     0xf3d7
#define BIOS_MLTPAT     0xf3d9

// Other screen settings
#define BIOS_CLIKSW     0xf3db
#define BIOS_CSRY       0xf3dc
#define BIOS_CSRX       0xf3dd
#define BIOS_CNSDFG     0xf3de

// Area to save VDP registers
#define BIOS_RG0SAV     0xf3df
#define BIOS_RG1SAV     0xf3e0
#define BIOS_RG2SAV     0xf3e1
#define BIOS_RG3SAV     0xf3e2
#define BIOS_RG4SAV     0xf3e3
#define BIOS_RG5SAV     0xf3e4
#define BIOS_RG6SAV     0xf3e5
#define BIOS_RG7SAV     0xf3e6
#define BIOS_RG8SAV     0xffe7
#define BIOS_RG9SAV     0xffe8
#define BIOS_STATFL     0xf3e7
#define BIOS_TRGFLG     0xf3e8
#define BIOS_FORCLR     0xf3e9
#define BIOS_BAKCLR     0xf3ea
#define BIOS_BDRCLR     0xf3eb
#define BIOS_MAXUPD     0xf3ec
#define BIOS_MINUPD     0xf3ef
#define BIOS_ATRBYT     0xf3f2

// Work area for PLAY statement
#define BIOS_QUEUES     0xf3f3
#define BIOS_FRCNEW     0xf3f5

// Work area for key input
#define BIOS_SCNCNT     0xf3f6
#define BIOS_REPCNT     0xf3f7
#define BIOS_PUTPNT     0xf3f8
#define BIOS_GETPNT     0xf3fa

// Parameters for Cassette
#define BIOS_CS120      0xf3fc
#define BIOS_LOW        0xf406
#define BIOS_HIGH       0xf408
#define BIOS_HEADER     0xf40a
#define BIOS_ASPCT1     0xf40b
#define BIOS_ASPCT2     0xf40d
#define BIOS_ENDPRG     0xf40f

// Work used by BASIC internally
#define BIOS_ERRFLG     0xf414
#define BIOS_LPTPOS     0xf415
#define BIOS_PRTFLG     0xf416
#define BIOS_NTMSXP     0xf417
#define BIOS_RAWPRT     0xf418
#define BIOS_VLZADR     0xf419
#define BIOS_VLZDAT     0xf41b
#define BIOS_CURLIN     0xf41c
#define BIOS_KBUF       0xf41f
#define BIOS_BUFMIN     0xf55d
#define BIOS_BUF        0xf55e
#define BIOS_ENDBUF     0xf660
#define BIOS_TTYPOS     0xf661
#define BIOS_DIMFLG     0xf662
#define BIOS_VALTYP     0xf663
#define BIOS_DORES      0xf664
#define BIOS_DONUM      0xf665
#define BIOS_CONTXT     0xf666
#define BIOS_CONSAV     0xf668
#define BIOS_CONTYP     0xf669
#define BIOS_CONLO      0xf66a
#define BIOS_MEMSIZ     0xf672
#define BIOS_STKTOP     0xf674
#define BIOS_TXTTAB     0xf676
#define BIOS_TEMPPT     0xf768
#define BIOS_TEMPST     0xf67a
#define BIOS_DSCTMP     0xf698
#define BIOS_FRETOP     0xf69b
#define BIOS_TEMP3      0xf69d
#define BIOS_TEMP8      0xf69f
#define BIOS_ENDFOR     0xf6a1
#define BIOS_SUBFLG     0xf6a5
#define BIOS_FLGINP     0xf6a6
#define BIOS_TEMP       0xf6a7
#define BIOS_PTRFLG     0xf6a9
#define BIOS_AUTFLG     0xf6aa
#define BIOS_AUTLIN     0xf6ab
#define BIOS_AUTINC     0xf6ad
#define BIOS_SAVTXT     0xf6af
#define BIOS_SAVSTK     0xF6B1
#define BIOS_ERRLIN     0xf6b3
#define BIOS_DOT        0xf6b5
#define BIOS_ERRTXT     0xf6b7
#define BIOS_ONELIN     0xf6b9
#define BIOS_ONEFLG     0xf6bb
#define BIOS_TEMP2      0xf6bc
#define BIOS_OLDLIN     0xf6be
#define BIOS_OLDTXT     0xf6c0
#define BIOS_VARTAB     0xf6c2
#define BIOS_ARYTAB     0xf6c4
#define BIOS_STREND     0xf6c6
#define BIOS_DATPTR     0xf6c8
#define BIOS_DEFTBL     0xf6ca
#define BIOS_PRMSTK     0xf6e4
#define BIOS_PRMLEN     0xf6e6
#define BIOS_PARM1      0xf6e8
#define BIOS_PRMPRV     0xf74c
#define BIOS_PRMLN2     0xf74e
#define BIOS_PARM2      0xf750
#define BIOS_PRMFLG     0xf7b4
#define BIOS_ARYTA2     0xf7b5
#define BIOS_NOFUNS     0xf7b7
#define BIOS_TEMP9      0xf7b8
#define BIOS_FUNACT     0xf7ba
#define BIOS_SWPTMP     0xf7bc
#define BIOS_TRCFLG     0xf7c4

// Work for Math-Pack
#define BIOS_FBUFFR     0xf7c5
#define BIOS_DECTMP     0xf7f0
#define BIOS_DECTM2     0xf7f2
#define BIOS_DECCNT     0xf7f4
#define BIOS_DAC        0xf7f6
#define BIOS_HOLD8      0xf806
#define BIOS_HOLD2      0xf836
#define BIOS_HOLD       0xf83e
#define BIOS_ARG        0xf847
#define BIOS_RNDX       0xf857

// Interface with BASIC USR Command
#define BIOS_USRDATA	0xf7f8

// Data area used by BASIC interpreter
#define BIOS_MAXFIL     0xf85f
#define BIOS_FILTAB     0xf860
#define BIOS_NULBUF     0xf862
#define BIOS_PTRFIL     0xf864
#define BIOS_RUNFLG     0xf866
#define BIOS_FILNAM     0xf866
#define BIOS_FILNM2     0xf871
#define BIOS_NLONLY     0xf87c
#define BIOS_SAVEND     0xf87d
#define BIOS_FNKSTR     0xf87f
#define BIOS_CGPNT      0xf91f
#define BIOS_NAMBAS     0xf922
#define BIOS_CGPBAS     0xf924
#define BIOS_PATBAS     0xf926
#define BIOS_ATRBAS     0xf928
#define BIOS_CLOC       0xf92a
#define BIOS_CMASK      0xf92c
#define BIOS_MINDEL     0xf92d
#define BIOS_MAXDEL     0xf92f

// Data area used by CIRCLE statement
#define BIOS_ASPECT     0xf931
#define BIOS_CENCNT     0xf933
#define BIOS_CLINEF     0xf935
#define BIOS_CNPNTS     0xf936
#define BIOS_CPLOTF     0xf938
#define BIOS_CPCNT      0xf939
#define BIOS_CPNCNT8    0xf93b
#define BIOS_CPCSUM     0xf93d
#define BIOS_CSTCNT     0xf93f
#define BIOS_CSCLXY     0xf941
#define BIOS_CSAVEA     0xf942
#define BIOS_CSAVEM     0xf944
#define BIOS_CXOFF      0xf945
#define BIOS_CYOFF      0xf947

// Data area used in PAINT statement
#define BIOS_LOHMSK     0xf949
#define BIOS_LOHDIR     0xf94a
#define BIOS_LOHADR     0xf94b
#define BIOS_LOHCNT     0xf94d
#define BIOS_SKPCNT     0xf94f
#define BIOS_MIVCNT     0xf951
#define BIOS_PDIREC     0xf953
#define BIOS_LFPROG     0xf954
#define BIOS_RTPROG     0xf955

// Data area used in PLAY statement
#define BIOS_MCLTAB     0xf956
#define BIOS_MCLFLG     0xf958
#define BIOS_QUETAB     0xf959
#define BIOS_QUEBAK     0xf971
#define BIOS_VOICAQ     0xf975
#define BIOS_VOICBQ     0xf9f5
#define BIOS_VOICCQ     0xfa75

// Work area added in MSX2
#define BIOS_DPPAGE     0xfaf5
#define BIOS_ACPAGE     0xfaf6
#define BIOS_AVCSAV     0xfaf7
#define BIOS_EXBRSA     0xfaf8
#define BIOS_CHRCNT     0xfaf9
#define BIOS_ROMA       0xfafa
#define BIOS_MODE       0xfafc
#define BIOS_NORUSE     0xfafd
#define BIOS_XSAVE      0xfafe
#define BIOS_YSAVE      0xfb00
#define BIOS_LOGOPR     0xfb02

// Data area used by RS-232C
#define BIOS_RSTMP      0xfb03
#define BIOS_TOCNT      0xfb03
#define BIOS_RSFCB      0xfb04
#define BIOS_RSIQLN     0xfb06
#define BIOS_MEXBIH     0xfb07
#define BIOS_OLDSTT     0xfb0c
#define BIOS_OLDINT     0xfb12
#define BIOS_DEVNUM     0xfb17
#define BIOS_DATCNT     0xfb18
#define BIOS_ERRORS     0xfb1b
#define BIOS_FLAGS      0xfb1c
#define BIOS_ESTBLS     0xfb1d
#define BIOS_COMMSK     0xfb1e
#define BIOS_LSTCOM     0xfb1f
#define BIOS_LSTMOD     0xfb20

// Data area used by PLAY statement
#define BIOS_PRSCNT     0xfb35
#define BIOS_SAVSP      0xfb36
#define BIOS_VOICEN     0xfb38
#define BIOS_SAVVOL     0xfb39
#define BIOS_MCLLEN     0xfb3b
#define BIOS_MCLPTR     0xfb3c
#define BIOS_QUEUEN     0xfb3e
#define BIOS_MUSICF     0xfc3f
#define BIOS_PLYCNT     0xfb40

// Voice static data area
#define BIOS_VCBA       0xfb41
#define BIOS_VCBB       0xfb66
#define BIOS_VCBC       0xfb8b

// Data area
#define BIOS_ENSTOP     0xfbb0
#define BIOS_BASROM     0xfbb1
#define BIOS_LINTTB     0xfbb2
#define BIOS_FSTPOS     0xfbca
#define BIOS_CODSAV     0xfbcc
#define BIOS_FNKSW1     0xfbcd
#define BIOS_FNKFLG     0xfbce
#define BIOS_ONGSBF     0xfbd8
#define BIOS_CLIKFL     0xfbd9
#define BIOS_OLDKEY     0xfbda
#define BIOS_NEWKEY     0xfbe5
#define BIOS_KEYBUF     0xfbf0
#define BIOS_LINWRK     0xfc18
#define BIOS_PATWRK     0xfc40
#define BIOS_BOTTOM     0xfc48
#define BIOS_HIMEM      0xfc4a
#define BIOS_TRAPTBL    0xfc4c
#define BIOS_RTYCNT     0xfc9a
#define BIOS_INTFLG     0xfc9b
#define BIOS_PADY       0xfc9c
#define BIOS_PADX       0xfc9d
#define BIOS_JIFFY      0xfc9e
#define BIOS_INTVAL     0xfca0
#define BIOS_INTCNT     0xfca2
#define BIOS_LOWLIM     0xfca4
#define BIOS_WINWID     0xfca5
#define BIOS_GRPHED     0xfca6
#define BIOS_ESCCNT     0xfca7
#define BIOS_INSFLG     0xfca8
#define BIOS_CSRSW      0xfca9
#define BIOS_CSTYLE     0xfcaa
#define BIOS_CAPST      0xfcab
#define BIOS_KANAST     0xfcac
#define BIOS_KANAMD     0xfcad
#define BIOS_FLBMEM     0xfcae
#define BIOS_SCRMOD     0xfcaf
#define BIOS_OLDSCR     0xfcb0
#define BIOS_CASPRV     0xfcb1
#define BIOS_BRDATR     0xfcb2
#define BIOS_GXPOS      0xfcb3
#define BIOS_GYPOS      0xfcb5
#define BIOS_GRPACX     0xfcb7
#define BIOS_GRPACY     0xfcb9
#define BIOS_DRWFLG     0xfcbb
#define BIOS_DRWSCL     0xfcbc
#define BIOS_DRWANG     0xfcbd
#define BIOS_RUNBNF     0xfcbe
#define BIOS_SAVENT     0xfcbf
#define BIOS_ROMSLT     0xfcc0
#define BIOS_EXPTBL     0xfcc1
#define BIOS_SLTTBL     0xfcc5
#define BIOS_SLTATR     0xfcc9
#define BIOS_SLTWRK     0xfd09
#define BIOS_PROCNM     0xfd89
#define BIOS_DEVICE     0xfd99

// Hooks
#define BIOS_H_KEYI     0xfd9a
#define BIOS_H_TIMI     0xfd9f
#define BIOS_H_CHPH     0xfda4
#define BIOS_H_DSPC     0xfda9
#define BIOS_H_ERAC     0xfdae
#define BIOS_H_DSPF     0xfdb3
#define BIOS_H_ERAF     0xfdb8
#define BIOS_H_TOTE     0xfdbd
#define BIOS_H_CHGE     0xfdc2
#define BIOS_H_INIP     0xfdc7
#define BIOS_H_KEYC     0xfdcc
#define BIOS_H_KYEA     0xfdd1
#define BIOS_H_NMI      0xfdd6
#define BIOS_H_PINL     0xfddb
#define BIOS_H_QINL     0xfde0
#define BIOS_H_INLI     0xfde5
#define BIOS_H_ONGO     0xfdea
#define BIOS_H_DSKO     0xfdef
#define BIOS_H_SETS     0xfdf4
#define BIOS_H_NAME     0xfdf9
#define BIOS_H_KILL     0xfdfe
#define BIOS_H_IPL      0xfe03
#define BIOS_H_COPY     0xfe08
#define BIOS_H_CMD      0xfe0d
#define BIOS_H_DSKF     0xfe12
#define BIOS_H_DSKI     0xfe17
#define BIOS_H_ATTR     0xfe1c
#define BIOS_H_LSET     0xfe21
#define BIOS_H_RSET     0xfe26
#define BIOS_H_FIEL     0xfe2b
#define BIOS_H_MKI      0xfe30
#define BIOS_H_MKS      0xfe35
#define BIOS_H_MKD      0xfe3a
#define BIOS_H_CVI      0xfe3f
#define BIOS_H_CVS      0xfe44
#define BIOS_H_CVD      0xfe49
#define BIOS_H_GETP     0xfe4e
#define BIOS_H_SETF     0xfe53
#define BIOS_H_NOFO     0xfe58
#define BIOS_H_NULO     0xfe5d
#define BIOS_H_NTFL     0xfe62
#define BIOS_H_MERG     0xfe67
#define BIOS_H_SAVE     0xfe6c
#define BIOS_H_BINS     0xfe71
#define BIOS_H_BINL     0xfe76
#define BIOS_H_FILE     0xfd7b
#define BIOS_H_DGET     0xfe80
#define BIOS_H_FILO     0xfe85
#define BIOS_H_INDS     0xfe8a
#define BIOS_H_RSLF     0xfe8f
#define BIOS_H_SAVD     0xfe94
#define BIOS_H_LOC      0xfe99
#define BIOS_H_LOF      0xfe9e
#define BIOS_H_EOF      0xfea3
#define BIOS_H_FPOS     0xfea8
#define BIOS_H_BAKU     0xfead
#define BIOS_H_PARD     0xfeb2
#define BIOS_H_NODE     0xfeb7
#define BIOS_H_POSD     0xfebc
#define BIOS_H_DEVN     0xfec1
#define BIOS_H_GEND     0xfec6
#define BIOS_H_RUNC     0xfecb
#define BIOS_H_CLEAR    0xfed0
#define BIOS_H_LOPD     0xfed5
#define BIOS_H_STKE     0xfeda
#define BIOS_H_ISFL     0xfedf
#define BIOS_H_OUTD     0xfee4
#define BIOS_H_CRDO     0xfee9
#define BIOS_H_DSKC     0xfeee
#define BIOS_H_DOGR     0xfef3
#define BIOS_H_PRGE     0xfef8
#define BIOS_H_ERRP     0xfefd
#define BIOS_H_ERRF     0xff02
#define BIOS_H_READ     0xff07
#define BIOS_H_MAIN     0xff0c
#define BIOS_H_DIRD     0xff11
#define BIOS_H_FINI     0xff16
#define BIOS_H_FINE     0xff1b
#define BIOS_H_CRUN     0xff20
#define BIOS_H_CRUS     0xff25
#define BIOS_H_ISRE     0xff2a
#define BIOS_H_NTFN     0xff2f
#define BIOS_H_NOTR     0xff34
#define BIOS_H_SNGF     0xff39
#define BIOS_H_NEWS     0xff3e
#define BIOS_H_GONE     0xff43
#define BIOS_H_CHRG     0xff48
#define BIOS_H_RETU     0xff4d
#define BIOS_H_PRTF     0xff52
#define BIOS_H_COMP     0xff57
#define BIOS_H_FINP     0xff5c
#define BIOS_H_TRMN     0xff61
#define BIOS_H_FRME     0xff66
#define BIOS_H_NTPL     0xff6b
#define BIOS_H_EVAL     0xff70
#define BIOS_H_OKNO     0xff75
#define BIOS_H_FING     0xff7a
#define BIOS_H_ISMI     0xff7f
#define BIOS_H_WIDT     0xff84
#define BIOS_H_LIST     0xff89
#define BIOS_H_BUFL     0xff8e
#define BIOS_H_FRQI     0xff93
#define BIOS_H_SCNE     0xff98
#define BIOS_H_FRET     0xff9d
#define BIOS_H_PTRG     0xffa2
#define BIOS_H_PHYD     0xffa7
#define BIOS_H_FORM     0xffac
#define BIOS_H_ERRO     0xffb1
#define BIOS_H_LPTO     0xffb6
#define BIOS_H_LPTS     0xffbb
#define BIOS_H_SCRE     0xffc0
#define BIOS_H_PLAY     0xffc5

// For expanded BIOS
#define BIOS_FCALL      0xffca
#define BIOS_DISINT     0xffcf
#define BIOS_ENAINT     0xffd4

#endif  // __MSXBIOS_H__