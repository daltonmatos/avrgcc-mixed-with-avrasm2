.include "m328Pdef.inc"

.equ offset = 0x40

_blinks:
  ldi zl, low((number+offset) * 2)
  ldi zh, high((number+offset) * 2)
  lpm 
  clr r25
  mov r24, r0
  ret
number:
.db 4, 2
