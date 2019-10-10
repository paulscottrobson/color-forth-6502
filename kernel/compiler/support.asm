; ******************************************************************************
; ******************************************************************************
;
;		Name : 		support.asm
;		Purpose : 	Vocabulary Support Functions
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	1st October 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;		Extract a 1 or 2 byte value from the code immediately following call
;
;		These are used to push constants that are not standard. A value from
;		0-255 uses Constant_1Byte, others use Constant_2Byte
;
; ******************************************************************************

Constant_2Byte:
		.savestack 							; save current stack values.
		pla 								; get return address into YA
		ply

		.incya 								; advance pointer
		sta 	zPage0 						; save address in zero page
		sty 	zPage0+1
		.incya 								; advance pointer again.
		phy 								; push it back
		pha

		ldy 	#1 							; load the constant into YA
		lda 	(zPage0),y 
		tay
		lda 	(zPage0)
		rts

Constant_1Byte:
		.savestack 							; save current stack values.
		pla 								; get return address into YA
		ply

		.incya 								; advance pointer
		sta 	zPage0 						; save address in zero page
		sty 	zPage0+1
		phy 								; push it back
		pha

		lda 	(zPage0)
		ldy 	#0
		rts		

; ******************************************************************************
;
;			Length prefixed string follows, push address on stack
;
; ******************************************************************************

Constant_String:
		.savestack 							; save current TOS
		;
		;	TODO: Get string address, skip it.
		;
		rts
