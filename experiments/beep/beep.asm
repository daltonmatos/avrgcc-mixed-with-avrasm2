.include "../m644Pdef.inc"

.def	treg			=r14	;temp reg for ISR

.def	SregSaver		=r15	;Storage of the SREG, used in ISR

.def	t			=r16	;Main temporary register

					;R17-R24 is the local variables pool

.def	tt			=r25	;Temp reg for ISR

WaitXms:
  ldi yl, 10
  rcall wms
  sbiw x, 1
  brne WaitXms
  ret

wms:    
  ldi t, 250              ;wait yl *0.1 ms at 20MHz
wm1:    
  dec t
  nop
  nop
  nop
  nop
  nop
  brne wm1
  dec yl
  brne wms
  ret

.include "macros.inc"
;.include "hardware.asm"
;.include "setuphw.asm"


beep:
  ldx 500
  call WaitXms
  ;call SetupHardware
  ;BuzzerOn
  ret


