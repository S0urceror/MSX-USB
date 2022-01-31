;
;-----------------------------------------------------------------------
;
;   This is a manufacturer-supplied bank switching module.   This module
; is placed at the tail of every local banks of DOS2-ROM.
;
;   This is a sample  program.   DOS2-ROM  has  no  assumptions  on  the
; mechanism  of bank switching, for example, where the bank register is,
; which bits are assigned to bank switching,  etc.   The  bank  register
; does not have to be readable.
;
; Entry:  Acc = 0 --- switch to bank #0
;		1 --- switch to bank #1
;		2 --- switch to bank #2
;		3 --- switch to bank #3
; Exit:   None
;
; Only AF can be modified
;
; *** CODE STRTS HERE ***	CAUTION!!  This must be the first module.
;
CHGBNK:
	db	0FFh	;Header for MKNEXROM
	dw	5000h
	rlca ; bank number multiplied times 2 to select right 8k segment
	ld	(5000h),a
	inc	a ; plus 1
	ld	(7000h),a
	ret
;
	defs	(8000h-7FD0h)-($-CHGBNK),0FFh
;
	end
