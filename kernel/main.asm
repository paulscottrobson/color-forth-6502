; ******************************************************************************
; ******************************************************************************
;
;		Name : 		main.asm
;		Purpose : 	Kernel Main Program
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	1st October 2019
;
; ******************************************************************************
; ******************************************************************************

		.include "compiler/data.asm"		; data definitions.

		.include "layouts/simple.inc"
		* = BuildAddress

		tsx 								; save entry SP
		stx 	DefaultStackPointer
		jmp 	ColdStart
		;
		;		This is first so this code can be copied to another bank if the
		;		Kernel and Dictionary are in different banks, same address range.
		;		If this code is copied to both banks, then it will operate the same.		
		;
		.include "compiler/dictionary.asm"

ColdStart:
		ldx 	DefaultStackPointer 		; reset the stack pointer
		txs

		jsr 	DictionaryReset
		jsr 	System_ResetStack 			; clear stack.
		stx 	CurrentIndex 				; save that state in 'current' variables
		sta 	CurrentTOS 					; which is X (stack) and YA (top of stack)
		sty 	CurrentTOS+1

		jsr 	XClearScreen

		ldx 	#TestBuffer & $FF
		ldy 	#TestBuffer >> 8		
		jsr 	BufferProcess

		lda 	#255
x1:
		jsr 	XPrint
		dec 	a
		bne 	x1
h1:		bra 	h1

		.include "testing/buffer.inc"

		.include "compiler/macros.inc"

		.include "system/extern.asm"

		.include "compiler/buffer.asm"
		.include "compiler/define.asm"
		.include "compiler/execute.asm"
		.include "compiler/compile.asm"
		.include "compiler/utilities.asm"
		.include "compiler/support.asm"

		.include "vocabulary/system.voc"
		.include "generated/constants.voc"
		.include "vocabulary/unary.voc"
		.include "vocabulary/binary.voc"
		.include "vocabulary/stack.voc"
		.include "vocabulary/memory.voc"

		.include "generated/dictionary.inc"

;
;	TODO:
;
;		Command line working.
;		Write and test string handler (missing)
;
;	FIXES:
;		Upper limit on dictionary space (page boundary)
;		Execute does not work if code called in a bank.
; 		Compile does not compile banked code.
;		Support for hexadecimal constants ?
;		Limit checks on stack ?
;
