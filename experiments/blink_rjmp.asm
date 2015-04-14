
.include "m328Pdef.inc"

.org 0x0040

_blinks:
  rjmp _add
_ret:
  ret
 
_add:
  ldi r23, 0xa
  add r24, r23
  rjmp _clear

_clear:
  clr r1
  clr r25
  rjmp _ret
