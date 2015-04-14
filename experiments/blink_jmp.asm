
.include "m328Pdef.inc"

.org 0x0040

_blinks:
  jmp _add

_add:
  clr r1
  clr r25
  ldi r23, 0xa
  add r24, r23
  ret 

