; ******************************************************************************
; ******************************************************************************
;
;		Name : 		data.asm
;		Purpose : 	Kernel Data allocation.
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	1st October 2019
;
; ******************************************************************************
; ******************************************************************************

STACKSIZE = 32 								; maximum data stack depth
BUFFERSIZE = 40 							; word buffer size

COL_COMMENT = $00 							; White (comment)
COL_DEFINE = $40 							; Red (defining word)
COL_COMPILE = $80 							; Green (compiling word)
COL_EXEC = $C0 								; Yellow (executing word)

DTP_IMMEDIATE = $01 						; Bit 0 type (immediate, cannot be executed)
DTP_COMPILEONLY = $02 						; Bit 1 type (cannot be execute, only compiled)

		* = $0010

zTemp0: .word ?								; temporary page zero pointers
zTemp1: .word ? 							; these must be consecutive.

freeDictionary: .word ? 					; current end of dictionary address
freeCode: .word ? 							; next free code byte.
freeCodeBank: .byte ?						; next free code byte bank (byte())
newDictRecord: .word ? 						; address of created dictionary record.
bufferPtr: .word ? 							; buffer pointer

		* = $0800
		
lStack: .fill STACKSIZE						; low and high byte stack areas. Note that
hStack: .fill STACKSIZE						; these do not have to be in page zero, it just
											; runs quicker and occupies less space if they are.
		* = $0A00

dictAddr: .word ? 							; these are copied when a search is successful
dictBank: .byte ? 							; (must be consecutive)
dictType: .byte ?

wordType: .byte ?							; type of word in buffer
SearchBuffer: .fill BUFFERSIZE				; buffer for word for compiler
InputBuffer: .fill BUFFERSIZE 				; input buffer
ErrorBuffer: .fill BUFFERSIZE 				; error message buffer

CurrentTOS: .word ? 						; current stack top value
CurrentIndex: .byte ? 						; current index value.

DefaultStackPointer: .byte ? 				; default value 6502 stack pointer.

SCWidth: .byte ? 							; width
SCHeight:.byte ?							; height
SCX: .byte ?								; screen position
SCY: .byte ?
SCColour: .byte ?							; drawing colour
