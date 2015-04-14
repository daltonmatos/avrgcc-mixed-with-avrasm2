
.include "m328Pdef.inc"

.org 0x000

_blinks:
  call _real_code
  ret

_real_code:
  ldi r23, 0xa
  add r24, r23
  clr r1
  clr r25
  ret 
