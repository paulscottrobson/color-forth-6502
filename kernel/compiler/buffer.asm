; ******************************************************************************
; ******************************************************************************
;
;		Name : 		buffer.asm
;		Purpose : 	Buffer processor
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	1st October 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;								Process Buffer at YX
;
; ******************************************************************************

BufferProcess:
		sty 	bufferPtr+1 				; save buffer pointer
		stx 	bufferPtr
		;
		;		Process next word
		;		
_BPNextWord:
		lda 	(bufferPtr) 				; check the next byte
		beq 	_BPExit
		and 	#$3F						; is it a space ?
		cmp 	#' '
		bne 	_BPFound 					; no, found a word.
		inc 	bufferPtr 					; bump pointer over space
		bne 	_BPNextWord
		inc 	bufferPtr+1
		bra 	_BPNextWord
		;
_BPExit:	
		rts	
		;
		;		Found a word. Copy its type and name into the buffer.
		;			
_BPFound:
		lda 	(bufferPtr) 				; start by getting the type bits off first character
		and 	#$C0						; bits 6 & 7
		sta 	wordType
		ldy 	#0 							; copy the word.
_BPCopy:
		lda 	(bufferPtr),y 				; copy byte over, dropping the type bits
		and 	#$3F
		sta 	SearchBuffer,y
		iny
		cpy 	#64 						; too long a word ?
		beq 	_BPFoundEnd
		lda 	(bufferPtr),y 				; get next
		beq 	_BPFoundEnd 				; if zero, then it's the end of the word
		and 	#$3F 						; if not space, keep going.
		cmp 	#' '
		bne 	_BPCopy
_BPFoundEnd:
		lda 	SearchBuffer-1,y 			; set bit 7 of the last character
		ora 	#$80
		sta 	SearchBuffer-1,y
		;
		tya 								; add offset to space/zero to buffer pointer
		clc
		adc 	bufferPtr
		sta 	bufferPtr
		bcc 	_BPNoCarry
		inc 	bufferPtr+1
_BPNoCarry:
		;
		;		Do something with the word dependent on the type
		;		
		lda 	wordType 					; look at type	
		cmp 	#COL_COMMENT 			 	; comment (white), just go round again
		beq 	_BPNextWord
		cmp 	#COL_DEFINE					; word definition (red)
		beq 	_BPDefineWord
		cmp 	#COL_EXEC 					; execute word immediately (yellow)
		beq 	_BPExecute
		jsr 	BPCompile 					; must be compile (green)
		bra 	_BPNextWord

_BPDefineWord:
		jsr 	BPDefineWord
		bra 	_BPNextWord
_BPExecute:
		jsr 	BPExecute
		bra 	_BPNextWord





