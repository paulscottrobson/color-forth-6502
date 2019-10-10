; ******************************************************************************
; ******************************************************************************
;
;		Name : 		execute.asm
;		Purpose : 	Buffer processor (Execute)
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	2nd October 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;								Execute a word
;
; ******************************************************************************

BPExecute:
		jsr 	UtilSearchAll 				; look for it in dictionaries
		bcs 	_BPEXFound 					; word found.
		jsr 	UtilConvertInteger 			; Try as integer
		bcs 	_BPEXInteger 				; if integer, push on stack, otherwise error
		.ferror 	"UNKNOWN EXECUTE"
		;
		;		Found a word that needs to be executed.
		;
_BPEXFound:
		bit 	dictType					; check if compile only
		bmi 	_BPEXCompileOnly
		;
		ldx 	CurrentIndex 				; load the index, and TOS into X and YA
		lda 	CurrentTOS
		ldy 	CurrentTOS+1
		;
		jsr 	_BPEXWord 					; call the word code (set by dictionary search)
		;
		stx 	CurrentIndex 				; save that state in 'current' variables
		sta 	CurrentTOS 					; which is X (stack) and YA (top of stack)
		sty 	CurrentTOS+1
		rts

_BPEXCompileOnly:
		ferror 	"COMPILE ONLY"

_BPEXWord:									; used to execute a word.
		jmp 	(dictAddr)		
		;
		;		Push integer on the stack.
		;
_BPEXInteger:		
		pha 								; save constant
		phy
		ldx 	CurrentIndex 				; load the index, and TOS into X and YA
		lda 	CurrentTOS
		ldy 	CurrentTOS+1
		.savestack 							; save TOS on the stack.
		ply 								; restore constant
		pla
		stx 	CurrentIndex 				; save that state in 'current' variables
		sta 	CurrentTOS 					; which is X (stack) and YA (top of stack)
		sty 	CurrentTOS+1
		rts
