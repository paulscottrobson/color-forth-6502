; ******************************************************************************
; ******************************************************************************
;
;		Name : 		utilities.asm
;		Purpose : 	Support Utilities
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	2nd October 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;		Search all dictionaries. As DictionarySearch but checks first the
;		user dictionary then the system one.
;
; ******************************************************************************

UtilSearchAll:
		lda 	#DictionaryBase & $FF		; search the user dictionary
		ldx 	#DictionaryBase >> 8
		sta 	zPage0
		stx 	zPage0+1
		jsr 	DictionarySearch
		bcs 	_BSAExit
		;
		lda 	#KernelDictionary & $FF		; search the system dictionary
		ldx 	#KernelDictionary >> 8
		sta 	zPage0
		stx 	zPage0+1
		jsr 	DictionarySearch
_BSAExit:		
		rts

; ******************************************************************************
;
;		Try to convert the search buffer to an integer, return the value
;		in YA with CS if okay, CC if not.
;
; ******************************************************************************

UtilConvertInteger:
		stz 	zPage0 						; zero the result
		stz 	zPage0+1 					
		ldx 	#255 						; start position-1
_BCILoop:
		inx 								; next character
		jsr 	UtilTimes10 				; zPage0 x 10
		;
		lda 	SearchBuffer,x 				; look at character
		and 	#$7F  						; drop end character bit
		cmp 	#'0'						; is it an integer character
		bcc 	_BCIFail 					; if not, then exit.
		cmp 	#'9'+1
		bcs 	_BCIFail
		and 	#15 						; now constant 0-9
		clc 								; add to current
		adc 	zPage0
		sta 	zPage0
		bcc 	_BCINoCarry
		inc 	zPage0+1
_BCINoCarry:
		lda 	SearchBuffer,x 				; check if was last character
		bmi 	_BCISucceed 				; if so, then it's okay.
		lda 	SearchBuffer+1,x 			; is the next char -+End
		cmp 	#"-"+$80
		bne 	_BCILoop 					; no, go round again.
		;
_BCINegateExit:								; it's a negative number.		
		sec
		lda 	#0 							; do the arithmetic adjustment
		sbc 	zPage0
		sta 	zPage0
		lda 	#0
		sbc 	zPage0+1
		sta 	zPage0+1
		;
_BCISucceed: 								; done, return in YA and CS
		sec
		lda 	zPage0
		ldy 	zPage0+1
		rts

_BCIFail:
		clc
		rts

; ******************************************************************************
;
;								Multiply ZPage by 10
;
; ******************************************************************************

UtilTimes10:
		lda 	zPage0+1 					; save in YA
		tay
		lda 	zPage0
		asl 	zPage0 						; x 4
		rol 	zPage0+1		
		asl 	zPage0
		rol 	zPage0+1		
		adc 	zPage0 						; add YA value gives x 5
		sta 	zPage0
		tya
		adc 	zPage0+1
		sta 	zPage0+1
		asl 	zPage0	 					; x 10
		rol 	zPage0+1		
		rts

; ******************************************************************************
;
;				 Compile call to function in dictAddr,dictBank
;
; ******************************************************************************

UtilCompileCall:
		pha
		phy
		lda 	#$20 						; JSR
		jsr 	UtilCompileByte
		lda 	dictAddr
		ldy 	dictAddr+1
		jsr 	UtilCompileWord
		ply
		pla
		rts

; ******************************************************************************
;
;					  Compile a byte A/word YA to code space
;
; ******************************************************************************

UtilCompileWord:
		pha
		phy
		jsr 	UtilCompileByte
		tya
		jsr 	UtilCompileByte
		ply
		pla
		rts

UtilCompileByte:
		sta 	(freeCode)
		inc 	freeCode
		bne 	_UCBNoCarry
		inc 	freeCode+1
_UCBNoCarry:	
		rts				