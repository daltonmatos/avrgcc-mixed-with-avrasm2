
;.include "m328Pdef.inc"

;.org 0x000

.global _blinks

.section .text

_blinks:
  call _real_code
  ret

_real_code:
  ;ldi %r23, 0xa
  ;add %r23, %r24
  ;clr %r1
  ;clr %r25
  ret 
