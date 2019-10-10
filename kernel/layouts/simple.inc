; ******************************************************************************
; ******************************************************************************
;
;		Name : 		simple.inc
;		Purpose : 	Memory layout and usage file.
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	1st October 2019
;
; ******************************************************************************
; ******************************************************************************

DictionaryBase = $0810						; Dictionary address
CodeSpace = $2000							; Code start position.

BuildAddress = $A000 						; where the binary is built

switchDictionary .macro 					; switch bank to dictionary bank
		.endm
switchKernel .macro 						; switch bank to kernel bank
		.endm

