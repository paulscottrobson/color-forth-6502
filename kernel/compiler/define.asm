; ******************************************************************************
; ******************************************************************************
;
;		Name : 		define.asm
;		Purpose : 	Buffer processor (Define)
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	2nd October 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;								Define a new word
;
; ******************************************************************************

BPDefineWord:
		jsr 	UtilSearchAll 				; does it already exist
		bcs 	_BPDWDuplicate
		jsr 	DictionaryCreate 			; create new word in the dictionary.
		rts
		;
_BPDWDuplicate:
		.ferror 	"DUPLICATE DEF"			
