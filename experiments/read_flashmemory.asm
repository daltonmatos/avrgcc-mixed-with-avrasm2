.include "m328Pdef.inc"

.equ offset = 0x40

.macro ldz

  ldi zl, low(@0 + (offset * 2))
  ldi zh, high(@0 + (offset * 2))


.endmacro


_blinks:
  ldz ((number) * 2)
  lpm 
  clr r25
  mov r24, r0
  ret
number:
.db 12, 2
