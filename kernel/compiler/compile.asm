; ******************************************************************************
; ******************************************************************************
;
;		Name : 		compile.asm
;		Purpose : 	Buffer processor (Compile)
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	2nd October 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;									Compile a word
;
; ******************************************************************************

; TODO: Word, String, Constant

BPCompile:
		jsr 	UtilSearchAll 				; look for it in dictionaries
		bcs 	_BPCOFound 					; word found.
		jsr 	UtilConvertInteger 			; is it a number
		bcs 	_BPCONumber 				; if so, do a number.
		lda 	SearchBuffer 				; is it a quoted string ?
		cmp 	#'"'		
		beq 	_BPCOString
		.ferror 	"UNKNOWN COMPILE"
		;
		;		Call compiler code.
		;
_BPCOFound:
		jsr 	UtilCompileCall 			; compile call to currently found element
		rts
		;
		;		Number compiler code (in YA)
		;
_BPCONumber:		
		cpy 	#0 							; check if 8 bit constant
		beq 	_BPCOShort
		;
		pha 								; 16 bit constant
		phy
		lda 	#$20 						; compile call
		jsr 	UtilCompileByte
		lda 	#Constant_2Byte & $FF
		ldy 	#Constant_2Byte >> 8
		jsr 	UtilCompileWord
		ply
		pla 
		jsr 	UtilCompileWord 			; compile the actual word
		rts
		;
_BPCOShort:
		pha		
		lda 	#$20 						; compile call
		jsr 	UtilCompileByte
		lda 	#Constant_1Byte & $FF
		ldy 	#Constant_1Byte >> 8
		jsr 	UtilCompileWord
		pla 
		jsr 	UtilCompileByte 			; compile the actual byte
		rts
		;
		;		String compiler code
		;
_BPCOString:
		lda 	#$20 						; compile call
		jsr 	UtilCompileByte
		lda 	#Constant_String & $FF
		ldy 	#Constant_String >> 8
		jsr 	UtilCompileWord
		;
		phx 								; find length of string.
		ldx 	#0
_BPCOSFindLength:
		inx
		lda 	SearchBuffer,x
		bpl 	_BPCOSFindLength
		txa
		jsr 	UtilCompileByte
		;
		ldx 	#1 							; compile the string
_BPCOSCompile:
		lda 	SearchBuffer,x
		cmp 	#"_" 						; map _ to space
		bne		_BPCOSNotSpace
		lda 	#" "
_BPCOSNotSpace:		
		jsr 	UtilCompileByte
		lda 	SearchBuffer,x
		asl 	a
		inx
		bcc 	_BPCOSCompile

		plx
		rts
