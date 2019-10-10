; ******************************************************************************
; ******************************************************************************
;
;		Name : 		macros.inc
;		Purpose : 	Macros
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	1st October 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;						Save the current YA TOS values
;
; ******************************************************************************

savestack:	.macro
		inx 								; X points to TOS always
		sta 	lStack,x 					; save current YA on stack
		tya
		sta 	hStack,x
		.endm

; ******************************************************************************
;
;		  Creates a constant pushing the given constant value on the stack
;
; ******************************************************************************

pushconst:	.macro
		.savestack 							; save current stack values
		lda 	#(\1) & $FF					; load new constant into YA
		ldy 	#(\1) >> 8
		rts
		.endm

; ******************************************************************************
;
;						Inc YA as if it was a 16 bit entity
;
; ******************************************************************************

incya: 	.macro
		inc 	a
		bne		*+3
		iny
		.endm		

; ******************************************************************************
;
;				 Drop 1 / 2 values off the stack, patches up YA
;
; ******************************************************************************

drop1:	.macro
		lda 	hStack,x					; high -> Y
		tay
		lda 	lStack,x 					; low -> A
		dex 								; fix up stack
		.endm

drop2:	.macro
		dex 								; throw one away
		.drop1 								; drop the next, fixing up YA
		.endm
		
; ******************************************************************************
;
;									Report Error
;
; ******************************************************************************
				
ferror:	.macro
_		.byte $FF
		.text \1,0
		.endm				