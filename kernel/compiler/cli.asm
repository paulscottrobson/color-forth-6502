; ******************************************************************************
; ******************************************************************************
;
;		Name : 		cli.asm
;		Purpose : 	Command Line Interpreter
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	10th October 2019
;
; ******************************************************************************
; ******************************************************************************

; ******************************************************************************
;
;							Command Line Interpreter
;
; ******************************************************************************

CommandLine:
		ldx 	DefaultStackPointer 		; reset the stack pointer
		txs		;
		;		Clear information area.
		;
		lda 	#3 							; erase bottom 3 lines.
		jsr 	CLMove
_CLIErase: 									; clear till come round.
		lda 	#' '
		jsr 	XPrint
		jsr 	XGetCursor
		tya
		bne 	_CLIErase
		;
		;		Print Stack
		;
		lda 	#2 							; 2 up from the bottom is the
		jsr 	CLMove 						; stack display area.
		lda 	#3 							; cyan
		sta 	SCColour
		lda 	CurrentIndex 				; display stack elements
		beq 	_CLIEndStack
		cmp 	#$FF
		beq 	_CLIEndStack
		ldx 	#0 							; stacked elements.
_CLIPrintStack:
		inx
		lda 	lStack,x
		ldy 	hStack,x
		jsr 	CLPrint
		cpx 	CurrentIndex
		bne 	_CLIPrintStack
_CLIEndStack:
		lda 	CurrentIndex
		cmp 	#$FF
		beq 	_CLIEmptyStack
		lda 	CurrentTOS 					; the YA in its saved slot
		ldy 	CurrentTOS+1
		jsr 	CLPrint
_CLIEmptyStack:
		;
		;		Print message, or ok if none.
		;
		lda 	#4 							; colour
		sta 	SCColour
		lda 	ErrorBuffer 				; check empty
		bne 	_CLIHasMsg
		lda 	#"O" & $3F 					; if so show "ok"
		sta 	ErrorBuffer
		lda 	#"K" & $3F
		sta 	ErrorBuffer+1
		stz 	ErrorBuffer+2
_CLIHasMsg:
		lda 	#1 							; position cursor
		jsr 	CLMove
		ldx 	#0 							; print out.
_CLIDisplay:
		lda 	ErrorBuffer,x
		jsr 	XPrint
		inx
		lda 	ErrorBuffer,x
		bne 	_CLIDisplay
		stz 	ErrorBuffer 				; erase message
		;
		;		Input.
		;
		lda 	#3 							; 3rd line
		jsr 	CLMove
		lda 	#7
		sta 	SCColour
		stz 	InputBuffer
_CLIInput:
		phx 								; save pos
		jsr 	XGetCursor 					; save screen pos
		lda 	#$A0 						; print reverse space
		jsr 	XPrint
		jsr 	XGetKey 					; get keystroke
		jsr 	XSetCursor 					; restore screen pos
		plx
		cmp 	#$0D 						; return execute
		beq 	_CLIExecute
		cmp 	#' ' 						; space execute
		beq 	_CLIExecute
		bcc		_CLICommandLine	 			; other controls clear
		cpx 	SCWidth 					; off RHS
		bcs 	_CLIInput 				
		cpx 	#BUFFERSIZE-1 				; won't fit
		bcs 	_CLIInput
		and 	#63 						; 6 bit ASCII
		jsr 	XPrint 						; print
		ora 	#COL_EXEC 					; make executable word
		sta 	InputBuffer,x 				; store
		stz 	InputBuffer+1,x
		inx
		bra 	_CLIInput	

_CLIExecute
		ldx 	#InputBuffer & $FF 			; execute the buffer.
		ldy 	#InputBuffer >> 8
		jsr 	BufferProcess
		lda 	CurrentIndex 				; check stack underflow
		inc 	a
		cmp 	#248
		bcs 	_CLIUnderflow
_CLICommandLine:
		jmp 	CommandLine

_CLIUnderflow:
		lda 	#$FF 						; clear stack.
		sta 	CurrentIndex
		ferror	"UNDERFLOW"

ReportError:
		plx
		ply
		sty 	zTemp0+1
		stx 	zTemp0
		ldy 	#0
_CopyError:
		lda 	(zTemp0),y
		sta 	ErrorBuffer-1,y
		iny
		cmp 	#0
		bne 	_CopyError
		jmp 	CommandLine

; ******************************************************************************
;
;						Move to position 0, row Height-A
;
; ******************************************************************************

CLMove:	eor 	#$FF
		sec
		adc		SCHeight
		tay
		ldx 	#0
		jmp 	XSetCursor

; ******************************************************************************
;
;					    Print YA as integer (temporary)
;
; ******************************************************************************

CLPrint:pha
		phx
		phy
		jsr 	XGetCursor
		txa
		clc
		adc 	#6
		cmp 	SCWidth
		bcs 	_CLNoPrint
		ply
		plx
		tya
		jsr 	_CLByte
		pla
		jsr 	_CLByte
		lda 	#" "
		jmp 	XPrint
_CLByte:pha
		lsr	 	a
		lsr	 	a
		lsr	 	a
		lsr	 	a
		jsr 	_CLNibble
		pla
_CLNibble:
		and 	#15
		clc
		adc 	#'0'
		cmp 	#58
		bcc 	_CLPX
		adc 	#6
_CLPX:	jmp		XPrint
_CLNoPrint:
		ply
		plx
		pla
		rts
