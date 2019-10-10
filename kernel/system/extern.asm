; ******************************************************************************
; ******************************************************************************
;
;		Name : 		extern.asm
;		Purpose : 	External Interface
;		Author : 	Paul Robson (paul@robsons.org.uk)
;		Created : 	10th October 2019
;
; ******************************************************************************
; ******************************************************************************

Vera_Lo = $9F20
Vera_Mid = $9F21
Vera_High = $9F22
Vera_Data = $9F23

; $FFE4


; ******************************************************************************
;
;							Clear Screen / Home Cursor
;
; ******************************************************************************

XClearScreen:
		pha
		phx
		phy
		lda 	#14 						; switch to l/c
		jsr 	$FFD2
		lda 	#$01 						; set fractional scale to 2
		sta 	Vera_Lo
		stz 	Vera_Mid
		lda 	#$1F
		sta 	Vera_High
		lda		#64
		sta 	Vera_Data		
		sta 	Vera_Data		
		lda 	#40 						; set size and current draw colour
		sta 	SCWidth
		lda 	#30
		sta 	SCHeight
		lda 	#1
		sta 	SCColour
		stz 	Vera_Lo 					; clear memory to spaces
		stz 	Vera_Mid
		lda 	#$10
		sta 	Vera_High
		lda 	SCHeight
		lsr 	a
		tay
		ldx 	#0
_XCSLoop:
		lda 	#$20
		sta 	Vera_Data
		stz 	Vera_Data
		dex 	
		bne 	_XCSLoop
		dey
		bne 	_XCSLoop
		ply
		plx
		pla 								; fall through to home

; ******************************************************************************
;
;								Home Cursor
;
; ******************************************************************************

XHomeCursor:
		stz 	SCX
		stz 	SCY
		rts

; ******************************************************************************
;
;							 Print Character A
;
; ******************************************************************************

XPrint:	pha
		pha
		lda 	SCX 						; 2 bytes / char
		asl 	a
		sta 	Vera_Lo 					; low address
		lda 	SCY 
		sta 	Vera_Mid 					; mid address
		lda 	#$10
		sta 	Vera_High
		;
		pla 								; characters are PETSCII
		and 	#$BF
		sta		Vera_Data
		lda 	SCColour
		sta 	Vera_Data

		inc 	SCX 						; one right
		lda 	SCX
		cmp 	SCWidth 					; reached RHS
		bne 	_XPR0
		jsr 	XNewLine 					; yes, do a new line
_XPR0:
		pla
		rts

; ******************************************************************************
;
;								Print a new line
;
; ******************************************************************************

XNewLine:
		pha
		stz 	SCX 						; start of line
		inc 	SCY 						; next line down
		lda 	SCY 						; wrap around the bottom.
		cmp 	SCHeight
		bne 	_XNL0
		stz 	SCY
_XNL0:	pla
		rts
