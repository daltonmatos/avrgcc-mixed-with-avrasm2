.def TargetY		=r17

HilightRectangle:
;	PushAll
	push r17

	lds TargetY, Y2

Hili1:	lds t, Y1
	sts Y2, t

	call Bresenham

	lds t, Y1
	inc t
	sts Y1, t

	cp t, TargetY
	brlo Hili1

;	PopAll
	pop r17
	ret

.undef TargetY


PrintSelector:
	lpm t, z+
	sts X1, t
	lpm t, z+
	sts Y1, t
	lpm t, z+
	sts X2, t
	lpm t, z
	sts Y2, t
	lrv PixelType, 0
	rcall HilightRectangle
	ret


.def	X1r = r17
.def 	Y1r = r18
.def	X2r = r19
.def 	Y2r = r20

Rectangle:
;	PushAll
	push r17
	push r18
	push r19
	push r20

	lds X1r, X1
	lds Y1r, Y1
	lds X2r, X2
	lds Y2r, Y2

	sts Y2, Y1r
	call Bresenham

	sts X1, X2r
	sts Y1, Y2r
	call Bresenham

	sts X2, X1r
	sts Y2, Y2r
	call Bresenham

	sts X1, X1r
	sts Y1, Y1r
	call Bresenham

;	PopAll
	pop r20
	pop r19
	pop r18
	pop r17
	ret


.undef X1r
.undef Y1r
.undef X2r
.undef Y2r



.def flagLeadingZero	=r17
.def Counter		=r18
.def Digit		=r19

Print16Signed:
;	PushAll
	push xl
	push xh
	push yl
	push yh
	push zl
	push zh
	push r17
	push r18
	push r19

	mov t, xl
	or t, xh
	brne print14		;is X zero?

	ldi t, '0'		;yes, print a zero and exit
	call PrintChar
	rjmp print13

print14:clr flagLeadingZero	;no

	tst xh
	brpl print7		;negative?

	com xl			;yes, negate x
	com xh
	ldi t, 1
	add xl, t
	clr t
	adc xh, t

	ldi t, '-'		;print minus sign
	rcall PrintChar

print7: my_ldz convt*2
	ldi Counter, 5	

print8:	ldi Digit, 0xff
	lpm yl, Z+
	lpm yh, Z+

print9:	sub xl, yl		; digit = int(X / Y) ;  X = frac(X / Y)
	sbc xh, yh

	inc Digit	

	brcc print9	

	add xl, yl
	adc xh, yh

	tst Digit		;is digit zero?
	brne print10

	brflagfalse flagLeadingZero, print11	;yes, skip it if no nonzero digits have been printed
	rjmp print12

print10:ser flagLeadingZero	;no, set flag

print12:mov t, Digit		;Digit to ASCII
	subi t, -0x30

	rcall PrintChar		;print digit

print11:dec Counter		;more digits?
	brne print8

;print13:PopAll			;no, exit
print13:pop r19
	pop r18
	pop r17
	pop zh
	pop zl
	pop yh
	pop yl
	pop xh
	pop xl

	ret




convt:	.dw 10000
	.dw 1000
	.dw 100
	.dw 10
	.dw 1

.undef flagLeadingZero
.undef Counter
.undef Digit


PrintNumberLF:
	rcall Print16Signed

LineFeed:			;OBSERVE: This subroutine must follow immediately after 'PrintNumberLF'!
	rvadd Y1, 9
	ret


PrintHeader:
	rcall PrintString
	lrv FontSelector, f6x8
	lrv Y1, 17
	ret


PrintWarningHeader:

	lrv X1, 16
	my_ldz warning*2
	rcall PrintHeader
	ret


PrintMotto:
	lrv X1, 0
	my_ldz motto*2
	call PrintString
	ret


PrintColonAndSpace:
	ldi t, ':'
	rcall PrintChar
	ldi t, ' '
	rcall PrintChar
	ret


PrintCCW:
	ldi t, 'C'
	rcall PrintChar

PrintCW:			;OBSERVE: This subroutine must follow immediately after 'PrintCCW'!
	ldi t, 'C'
	rcall PrintChar
	ldi t, 'W'
	rcall PrintChar
	ret


PrintMenuFooter:
	lrv X1, 0
	lrv Y1, 57
	my_ldz updown*2
	rcall PrintString
	ret


PrintSelectFooter:
	lrv X1, 0
	lrv Y1, 57
	my_ldz bckprev*2
	rcall PrintString
	my_ldz nxtsel*2
	rcall PrintString
	ret


PrintStdFooter:
	lrv X1, 0
	lrv Y1, 57
	pushz
	my_ldz bckprev*2
	rcall PrintString
	my_ldz nxtchng*2
	rcall PrintString
	popz
	ret


PrintBackFooter:
	lrv X1, 0
	lrv Y1, 57
	pushz
	my_ldz back*2
	rcall PrintString
	popz
	ret


PrintChangeFooter:

	lrv X1, 90
	lrv Y1, 57
	my_ldz change*2
	rcall PrintString
	ret


PrintOkFooter:
	lrv X1, 114
	lrv Y1, 57
	pushz
	my_ldz ok*2
	rcall PrintString
	popz
	ret


PrintContinueFooter:
	lrv X1, 78
	lrv Y1, 57
	pushz
	my_ldz cont*2
	rcall PrintString
	popz
	ret


PrintFromStringArray:
	lsl t
	add zl, t
	clr t
	adc zh, t
	lpm xl, z+
	lpm xh, z
	movw z, x
	rcall PrintString
	ret


PrintStringArray:
	pushy
	mov yl, t			;register T = Array size (i.e. Number of strings)
	clr t

psa1:	push t
	pushz				;register Z = Array pointer (16 bit)
	clr yh
	sts X1, yh
	call PrintFromStringArray
	rcall LineFeed
	popz
	pop t
	inc t
	cp t, yl
	brlt psa1

	popy
	ret


PrintString:
print2:	lpm t, z+
	tst t
	breq print1
	rcall PrintChar
	rjmp print2

print1: ret


.def	CharWidth	=r17
.def	CharHeight	=r18
.def	CharBytes	=r19


PrintChar:
;	PushAll
	push xl
	push xh
	push yl
	push zl
	push zh
	push r17
	push r18
	push r19

	lds xl, FontSelector	;Z = address of TabCh * 2 + FontSelector * 6
	ldi xh, 6
	mul xl, xh

	my_ldz TabCh*2
	add zl, r0
	adc zh, r1

	lpm xl, Z+
	lpm xh, Z+

	lpm CharWidth, Z+
	lpm CharHeight, Z+
	lpm CharBytes, Z

	movw Z, X

	rcall pp1

;	PopAll
	pop r19
	pop r18
	pop r17
	pop zh
	pop zl
	pop yl
	pop xh
	pop xl
	ret

TabCh:	.db low(font4x6*2), high(font4x6*2), 4, 6, 4, 0
	.db low(font6x8*2 + offset), high(font6x8*2 + offset), 6, 8, 6, 0
	.db low(font8x12*2), high(font8x12*2), 8, 12, 12, 0
	.db low(font12x16*2), high(font12x16*2), 12, 16, 24, 0
	.db low(symbols16x16*2), high(symbols16x16*2), 16, 16, 32, 0



pp1:	mov xl,t	;
	mov xh,t
	andi xl,0b00011111
	andi xh,0b01100000

	cpi xh, 0b01000000	;ABCDEF
	brne pp2
	subi xl,-0x20
	jmp pp3

pp2:	cpi xh, 0b01100000	;abcdef
	brne pp3
	subi xl,-0x40

pp3:	mul xl, CharBytes	;Find address of char
	add zl, r0
	adc zh, r1

	mov xl, CharWidth
	mov yl, CharHeight

	rcall Sprite		;draw char

	lds t, X1		;advance to next position
	add t, CharWidth
	sts X1, t

	ret

.undef	CharWidth
.undef	CharHeight
.undef	CharBytes






Sprite:			;Z = bitmap address
			;xl = x size
			;yl = y size
			;X1, Y1 = start pos

.def	BitCounter	=r17
.def	XCounter	=r18
.def	YCounter	=r19
.def	Bits		=r20


;	PushAll
	push xl
	push yl
	push r17
	push r18
	push r19
	push r20

	ldi BitCounter, 1

	mov YCounter, yl
	lds t, Y1
	sts YPos, t

sp1:	mov XCounter, xl
	lds t, X1
	sts XPos, t

sp4:	dec BitCounter		;more bits?
	brne sp2

	ldi Bitcounter, 8	;no, get next byte

	lpm Bits, Z+

sp2:	lsl Bits		;yes, is next bit set?
	brcc sp3

	rcall SetPixel		;yes, plot it

sp3:	lds t, XPos		;XPos = XPos + 1
	inc t
	sts Xpos, t

	dec XCounter		;More X pixels?
	brne sp4		

	lds t, YPos		;YPos = YPos + 1
	inc t
	sts Ypos, t

	dec YCounter		;More Y pixels?
	brne sp1		

;	PopAll
	pop r20
	pop r19
	pop r18
	pop r17
	pop yl
	pop xl

	ret


.undef	BitCounter
.undef	XCounter
.undef	YCounter
.undef	Bits



Bresenham:		;line from (X1,Y1) to (Y2,Y2)



.def	prx1	=r17
.def	prx2	=r18
.def	pry1	=r19
.def	pry2	=r20
.def	xd	=r21
.def	yd	=r22
.def	step	=r23
.def	errorl	=r2
.def	errorh	=r3


	PushAll

	ldi prx1, 1
	ldi prx2, 1
	ldi pry1, 1
	ldi pry2, 1

	lds xd, X2	;xd=x2-x1
	lds t, X1
	sub xd, t

	brpl op1

	neg xd
	ldi prx1, -1
	ldi prx2, -1

op1:	lds yd, Y2
	lds t, Y1
	sub yd, t

	brpl op2

	neg yd
	ldi pry1, -1
	ldi pry2, -1

op2:	cp xd, yd
	brsh op3

	ldi prx1, 0

	mov t, xd
	mov xd, yd
	mov yd, t

	rjmp op4

op3:	ldi pry1, 0

op4:	mov step, xd
	add step, yd

	mov errorl, xd
	clr errorh

	lds t, X1
	sts Xpos, t

	lds t, Y1
	sts Ypos, t

	lsl xd

	lsl yd

op5:	rcall SetPixel

	tst step
	breq op6
	brmi op6

	sub errorl, yd
	clr t
	sbc errorh, t
	brpl op7

	lds t, Xpos
	add t, prx2
	sts Xpos, t

	lds t, Ypos
	add t, pry2
	sts Ypos, t

	add errorl, xd
	clr t
	adc errorh, t

	subi step, 2

	rjmp op5

op7:	lds t, Xpos
	add t, prx1
	sts Xpos, t

	lds t, Ypos
	add t, pry1
	sts Ypos, t

	subi step, 1

	rjmp op5

op6:	PopAll
	ret


.undef	prx1
.undef	prx2
.undef	pry1
.undef	pry2
.undef	xd
.undef	yd
.undef	step
.undef	errorl
.undef	errorh









SetPixel:				; Destroys: t
;	PushAll
	push zl
	push zh
	push xl
	push xh

	;ldi zl, low(LcdBuffer)		;Z = LcdBuffer + int(Ypos/8)*128 + Xpos
	;ldi zh, high(LcdBuffer)
  my_ldz LcdBuffer

	lds xl, Ypos
	ldi xh, 0
	andi xl, 0b00111000
	lsl xl
	lsl xl
	lsl xl
	rol xh
	lsl xl
	rol xh

	add zl, xl
	adc zh, xh

	lds t, Xpos
	andi t, 0x7f
	add zl, t
	clr t
	adc zh, t

	lds xl, Ypos			;xl = (Ypos mod 8) + 1
	andi xl, 0b00000111
	inc xl

	ldi xh,  0b00000000		;xh = 2 ^ (xl - 1)
	sec 	
qq7:	rol xh	
	dec xl
	brne qq7

	ld xl, z

	lds t, PixelType
	tst t
	breq qq8
	cpi t, 2
	breq qq10

	or xl, xh
	rjmp qq9

qq10:	com xh
	and xl, xh
	rjmp qq9

qq8: 	eor xl, xh

qq9:	st z, xl


;	PopAll
	pop xh
	pop xl
	pop zh
	pop zl

	ret






LcdUpdate:
;	PushAll
	push xl
	push xh
	push yl
	push yh
	push zl
	push zh

	;ldi zl, low(lcd_cd*2)	;refresh LCD control registers
	;ldi zh, high(lcd_cd*2)
  my_ldz lcd_cd*2

qq2:	lpm yl, z+
	cpi yl, 0xff
	breq qq1
	rcall LcdCommand
	rjmp qq2

qq1:	ldi yl, 0x81		;set contrast
	rcall LcdCommand
	lds yl, LcdContrast
	rcall LcdCommand


	;Transfer image data


	ldi xl, 0xb0	

	;ldi zl, low(LcdBuffer)
	;ldi zh, high(LcdBuffer)
  my_ldz LcdBuffer


qq3:	mov yl, xl		;set page address
	rcall LcdCommand

	ldi yl, 0x10		;set column address
	rcall LcdCommand
	ldi yl, 0x00
	rcall LcdCommand

	ldi xh, 128		;transfer one page
qq4:	ld yl, z+
	rcall LcdData
	dec xh
	brne qq4

	inc xl
	cpi xl, 0xb8
	brne qq3

;	PopAll
	pop zh
	pop zl
	pop yh
	pop yl
	pop xh
	pop xl
	ret

lcd_cd:
	.db 0xaf, 0x40		;LCD ON		Display start line set
	.db 0xa0, 0xa6		;ADC		nor/res
	.db 0xa4, 0xa2		;disp normal	bias 1/9
	.db 0xee, 0xc8		;end		COM
	.db 0x2f, 0x24		;power control	Vreg int res ratio
	.db 0xac, 0x00		;static off
	.db 0xf8, 0x00		;booster ratio
	.db 0xe3, 0xff		;NOP



LcdClear:
;	PushAll
	push xl
	push xh
	push zl
	push zh

	ldi zl, low(LcdBuffer)
	ldi zh, high(LcdBuffer)

	ldi xl, low(0x0400)
	ldi xh, high(0x0400)

	ldi t,0x00

qq5:	st z+, t
	sbiw xh:xl, 1 
	brne qq5

;	PopAll
	pop zh
	pop zl
	pop xh
	pop xl
	ret


LcdClear6x8:
	rcall LcdClear
	lrv PixelType, 1
	lrv FontSelector, f6x8
	lrv X1, 0
	lrv Y1, 1
	ret


LcdClear12x16:
	rcall LcdClear
	lrv PixelType, 1
	lrv FontSelector, f12x16
	lrv Y1, 0
	ret


LcdCommand:
	cbi lcd_a0
	rjmp se4

LcdData:
	sbi lcd_a0

se4:	cbi lcd_cs1
	rcall se5

	push xh

	ldi xh,8

se3:	lsl yl		;F T
	brcs se1	;1 2
	nop		;1
	cbi lcd_si	;2
	rjmp se2	;2
se1:	sbi lcd_si	;  2
	nop		;  1
	nop		;  1

se2:	rcall se5

	cbi lcd_scl
	rcall se5

	sbi lcd_scl
	rcall se5

	dec xh
	brne se3

	sbi lcd_cs1
	rcall se5

	pop xh
	ret

se5:	ldi t, 4	;1 us delay at 20MHz
se6:	dec t
	brne se6
	ret


;ShowConfirmationDlg:
;	pushz			;input parameter (text pointer)
;	rcall LcdClear12x16
;
;	lrv X1, 22		;header
;	ldz confirm*2
;	rcall PrintHeader
;
;	lrv X1, 0		;print input text
;	lrv Y1, 26
;	popz
;	rcall PrintString
;
;	lrv X1, 0		;print "Are you sure?"
;	lrv Y1, 35
;	ldz rusure*2
;	rcall PrintString
;
;	;footer
;	lrv X1, 0
;	lrv Y1, 57
;	ldz conf*2
;	rcall PrintString
;
;	rcall LcdUpdate
;
;scd2:	rcall GetButtonsBlocking
;
;	cpi t, 0x08		;CANCEL?
;	breq scd3
;
;	cpi t, 0x01		;YES?
;	brne scd2
;
;scd3:	ret


	;headers
confirm:.db "CONFIRM", 0
warning:.db "WARNING!", 0, 0
cerror:	.db "ERROR", 0
saved:	.db "SAVED", 0

	;footers
tunefn:	.db "BACK RATE SAVE CHANGE", 0
qtunefn:.db "BACK RATE NEXT CHANGE", 0
updown:	.db "BACK  UP  DOWN  ENTER", 0
conf:	.db "CANCEL            YES", 0
cont:	.db "CONTINUE", 0, 0
clear:	.db "CLEAR", 0
yn:	.db "YES  NO", 0
back:	.db "BACK", 0, 0
bckprev:.db "BACK PREV", 0		;used in combination with other footers (e.g. "NEXT CHANGE")
bckmore:.db "BACK MORE", 0		;also used in combination with other footers (e.g. "NEXT CHANGE")
nxtchng:.db " NEXT CHANGE", 0, 0
nxtsel:	.db " NEXT SELECT", 0, 0
change:	.db "CHANGE", 0, 0
ok:	.db "OK", 0, 0			;also used as status text (in sensortest.asm and flightdisplay.asm)

	;other texts
motto:	.db "Fly safe!       RC911", 0
rusure:	.db "Are you sure?", 0
off:	.db "Off", 0
on:	.db "On", 0, 0
no:	.db "No", 0, 0
yes:	.db "Yes", 0
acro:	.db "Acro", 0, 0
alarm:	.db "Alarm", 0
normsl:	.db "Normal SL", 0
slmix:	.db "SL Mix", 0, 0
sltrim:	.db "ACC Trim", 0, 0
slgain:	.db "SL Gain", 0
selflvl:.db "SL", 0, 0
gimbal:	.db "Gimbal", 0, 0
ailele:	.db "Ail+Ele", 0
ail:	.db "Aileron", 0
ele:	.db "Elevator", 0, 0
rudd:	.db "Rudder", 0, 0
thr:	.db "Throttle", 0, 0
aux:	.db "Aux", 0
ofs:	.db "Offset", 0, 0
pgain:	.db "P Gain", 0, 0
plimit:	.db "P Limit", 0
igain:	.db "I Gain", 0, 0
ilimit:	.db "I Limit", 0
locked:	.db "Locked", 0, 0
home:	.db "Home", 0, 0
pos1:	.db "Pos 1", 0
pos2:	.db "Pos 2", 0
pos3:	.db "Pos 3", 0
pos4:	.db "Pos 4", 0
pos5:	.db "Pos 5", 0
rate1:	.db "LOW", 0
rate2:	.db "MEDIUM", 0, 0
rate3:	.db "HIGH", 0, 0
ss0:	.db "SS +0", 0
ss20:	.db "SS +20", 0, 0
ss30:	.db "SS +30", 0, 0
ss50:	.db "SS +50", 0, 0

	;arrays
yesno:	.dw no*2, yes*2
tunmode:.dw off*2, ail*2, ele*2, rudd*2, slgain*2, sltrim*2, gimbal*2
lmh:	.dw null*2, rate1*2, rate2*2, rate3*2
auxtxt:	.dw pos1*2, pos2*2, pos3*2, pos4*2, pos5*2
auxfn:	.dw acro*2, slmix*2, normsl*2, alarm*2
auxss:	.dw ss0*2, ss20*2, ss30*2, ss50*2
aux4txt:.dw locked*2, off*2, home*2
rxch:	.dw ail*2, ele*2, thr*2, rudd*2, aux*2
