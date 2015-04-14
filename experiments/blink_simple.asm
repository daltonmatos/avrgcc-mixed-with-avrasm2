
.include "m328Pdef.inc"

.org 0x000

_blinks:
  ldi r23, 0xa
  add r24, r23
  clr r1
  clr r25
  ret 
