.include "m328Pdef.inc"

.equ n = 0x46

_blinks:
  ldi zl, low(n*2)
  ldi zh, high(n*2)
  lpm 
  clr r25
  mov r24, r0
  ret
number:
.db 17, 2
