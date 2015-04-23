
.include "m328Pdef.inc"

.org 0x0000

_blinks:
  rjmp _add
_ret:
  ret
 
_add:
  call _ldi
_add1:
  add r24, r23
  call _clear
  rjmp _ret

_clear:
  clr r1
  clr r25
  ret
  
_ldi:
  ldi r23, 0x5
  jmp _add1 
