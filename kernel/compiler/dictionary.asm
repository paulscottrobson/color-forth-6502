; ******************************************************************************
; ******************************************************************************
;
;		Name : 		dictionary.asm
;		Purpose : 	Dictionary Handling Functions
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	1st October 2019
;
; ******************************************************************************
; ******************************************************************************
;
;		These functions should all be relocatable, so they can be copied
;		to other places, in case we want to (say) store the kernel in one
;		RAM bank and the dictionary in another.
;
; ******************************************************************************

DictionaryReset:
		bra 	XDictionaryReset
DictionarySearch:		
		bra 	XDictionarySearch
DictionaryCreate:
		bra 	XDictionaryCreate
DictionaryXorTypeByte:
		bra 	XDictionaryXorTypeByte

; ******************************************************************************
;
;					  Dictionary Reset, Code Pointer Reset
;
; ******************************************************************************

XDictionaryReset:
		pha

		lda 	#0 							; reset the next free code byte position.
		sta 	freeCodeBank
		lda 	#CodeSpace & $FF
		sta 	freeCode
		lda 	#CodeSpace >> 8
		sta 	freeCode+1

		.switchDictionary					; access the dictionary
		lda 	#0
		sta 	DictionaryBase
		.switchKernel

		lda 	#DictionaryBase & $FF 		; set the next free byte pointer
		sta 	freeDictionary
		lda 	#DictionaryBase >> 8
		sta 	freeDictionary+1

		pla
		rts

; ******************************************************************************
;
;		Search dictionary at zTemp0 for text at SearchBuffer. 
;
;		If found, return CS	address, bank, bits in data area.
;		If not found, CC.
;
; ******************************************************************************

XDictionarySearch:
		.switchDictionary					; access the dictionary
		;
		;		Compare next element.
		;
_XDSLoop:
		lda 	(zTemp0)					; look at length
		clc 								; clear carry, return CC if failed.
		beq		_XDSExit					; exit ?
		;
		;		Name compare
		;
		ldy 	#5 							; where comparison starts in dictionary
		ldx 	#0 							; comparison starts in SearchBuffer
_XDSCompare:
		lda 	SearchBuffer,x 				; compare characters
		cmp 	(zTemp0),y
		bne 	_XDSNext 					; did not match, try next.
		;
		inx 								; advance pointers
		iny
		asl 	a 							; shift bit 7 into Carry
		bcc 	_XDSCompare 				; found it !		
		;
		;		Successful match
		;
		ldy 	#1 							; copy 1,2,3,4 to zTemp
_XDSCopy:
		lda 	(zTemp0),y
		sta 	dictAddr-1,y
		iny
		cpy 	#5
		bne 	_XDSCopy
		sec 								; return CS
		bra 	_XDSExit
		;
		;		Go to next entry
		;
_XDSNext:
		clc 								; add offset to zTemp0
		lda 	zTemp0
		adc 	(zTemp0)
		sta 	zTemp0
		bcc 	_XDSLoop 					; no carry
		inc 	zTemp0+1 					; carry forward.
		bra 	_XDSLoop		
		;
		;		Exit dictionary search.
		;
_XDSExit:
		php									; switch bank bank, preserving carry.
		.switchkernel
		plp
		rts		

; ******************************************************************************
;
;			Exclusive OR the type byte of the newest record with A
;
; ******************************************************************************

XDictionaryXorTypeByte:
		.switchDictionary					; access the dictionary
		phy
		ldy 	#4 							; offset to type
		eor 	(newDictRecord),y
		sta 	(newDictRecord),y
		ply
		.switchkernel
		rts

; ******************************************************************************
;
;		Create new entry in ram dictionary using SearchBuffer, 
;		freeCode, and freeCodeBank, and set the type = 0. Sets newDictRecord
;
; ******************************************************************************

XDictionaryCreate:
		.switchDictionary					; access the dictionary

		lda 	freeDictionary 				; copy address to new dictionary record pointer
		sta 	newDictRecord
		lda 	freeDictionary+1
		sta 	newDictRecord+1

		ldy 	#5 							; copy the name in, also calculates offset
		ldx 	#0
_XDCCopyName:
		lda 	SearchBuffer,x 				; copy over name
		sta 	(freeDictionary),y		
		inx
		iny
		asl 	a 							; until bit 7 is copied.
		bcc 	_XDCCopyName
		tya 								; Y is now offset to next
		sta 	(freeDictionary)

		ldy 	#1 							; copy code address & bank in.
		lda 	freeCode
		sta 	(freeDictionary),y
		iny
		lda 	freeCode+1
		sta 	(freeDictionary),y
		iny
		lda 	freeCodeBank
		sta 	(freeDictionary),y
		iny
		lda 	#0 							; set the type byte to zero.
		sta 	(freeDictionary),y

		clc 								; adjust freedictionary ptr up
		lda 	freeDictionary
		adc 	(freeDictionary)
		sta 	freeDictionary
		bcc 	_XDCNoCarry
		inc 	freeDictionary+1
_XDCNoCarry:		
		lda 	#0 							; write end of dictionary marker
		sta 	(freeDictionary)

		.switchkernel
		rts

