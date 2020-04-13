; ---------------------------------------------------------
; Extensions that can be called from within MSX-BASIC
;
;
CALBAS	EQU		#159
ERRHAND EQU     #406F
FRMEVL  EQU     #4C64
FRESTR	EQU		#67D0
CHRGTR  EQU     #4666
VALTYP  EQU     #F663
PROCNM	EQU		#FD89

INIT_CALLS:
	PUSH    HL
	LD	HL,CMDS	        ; Table with "_" instructions
.CHKCMD:
	LD	DE,PROCNM
.LOOP1:	LD	A,(DE)
	CP	(HL)
	JR	NZ,.TONEXTCMD	; Not equal
	INC	DE
	INC	HL
	AND	A
	JR	NZ,.LOOP1	    ; No end of instruction name, go checking
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	POP	HL		        ; routine address
	CALL GETPREVCHAR
	CALL .CALLDE		; Call routine
	AND	A
	RET
.TONEXTCMD:
	LD	C,0FFH
	XOR	A
	CPIR			    ; Skip to end of instruction name
	INC	HL
	INC	HL		        ; Skip address
	CP	(HL)
	JR	NZ,.CHKCMD	    ; Not end of table, go checking
	POP	HL
    SCF
	RET

.CALLDE:
	PUSH	DE
	RET
 
;---------------------------
; List of available instructions (as ASCIIZ) and execute address (as word)
CMDS:
	db	"USBFILES",0      ; overview files in current directory
	dw	USBFILES
 
	db	"USBCD",0      ; change current directory
	dw	USBCD
 
	db	"INSERTDISK",0      ; mount a new .dsk
	dw	INSERTDISK

	db	"EJECTDISK",0      ; unmount .dsk
	dw	EJECTDISK
	
 	db	0               ; No more instructions
 
;---------------------------

	include "ch376s_helpers.asm"

USBFILES:
	push hl
	;; copy filename to path variable
	call MY_GWORK
	call _PRINTDIR
    pop hl
    or a
    ret

EJECTDISK:
    push hl
	call MY_GWORK
	call _CLOSE_DISK_FILE
	ld hl, TXT_FILECLOSED_OKAY
    call PRINT
    pop hl
    or a
    ret

USBCD:
	CALL	EVALTXTPARAM	; Evaluate text parameter
	PUSH	HL
    CALL    GETSTRPNT
    ld c, b
    ld b, 0
	call MY_GWORK
	call _STORE_DIR_NAME
    call CH_SET_FILE_NAME
    call CH_DIR_OPEN    
    jp nc, _CONTINUE1
    ld hl, TXT_CD_FAILED
    call PRINT
_CONTINUE1
	POP	HL
	OR A
	RET

INSERTDISK:
	CALL	EVALTXTPARAM	; Evaluate text parameter
	PUSH	HL
    CALL    GETSTRPNT
	ld c, b
    ld b, 0
	call MY_GWORK
	call _STORE_DISK_NAME
	call EJECTDISK
	call _OPEN_DISK_FILE
	POP	HL
	OR A ; clear Cy, no error
	ret
 
GETSTRPNT:
; OUT:
; HL = String Address
; B  = Length
	LD      HL,(#F7F8)
	LD      B,(HL)
	INC     HL
	LD      E,(HL)
	INC     HL
	LD      D,(HL)
	EX      DE,HL
	RET
 
EVALTXTPARAM:
	CALL	CHKCHAR
	db	    "("             ; Check for (
	LD		IX,FRMEVL
	CALL	CALBAS_B0		; Evaluate expression
	LD      A,(VALTYP)
	CP      3               ; Text type?
	JP      NZ,TYPE_MISMATCH
	PUSH	HL
	LD	    IX,FRESTR       ; Free the temporary string
	CALL	CALBAS_B0
	POP	    HL
	CALL	CHKCHAR
	db	    ")"             ; Check for )
    RET
 
CALBAS_B0:
	push hl
	ld hl, CALBAS
	ld (CODE_ADD), hl
	pop hl
	call CALLB0
	ret
 
CHKCHAR:
	CALL GETPREVCHAR	; Get previous basic char
	EX	(SP),HL
	CP	(HL) 	        ; Check if good char
	JR	NZ, SYNTAX_ERROR	; No, Syntax error
	INC	HL
	EX	(SP),HL
	INC	HL		; Get next basic char
 
GETPREVCHAR:
	DEC	HL
	LD	IX,CHRGTR
	JP  CALBAS_B0
 
TYPE_MISMATCH:
    LD  E,13
    LD	IX,ERRHAND	; Call the Basic error handler
	JP	CALBAS_B0
 
SYNTAX_ERROR:
    LD  E,2
	LD	IX,ERRHAND	; Call the Basic error handler
	JP	CALBAS_B0