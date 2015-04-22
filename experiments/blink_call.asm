
.include "m328Pdef.inc"

;.org 0x0080
.org 0x0000


_blinks:
  call _clear
  call _real_code
  ret

_real_code:
  ldi r23, 0xa
  add r24, r23
  ret

_clear:
  clr r1
  clr r25
  ret 
