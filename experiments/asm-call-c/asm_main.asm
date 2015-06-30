 .org 0x0000

_pad:
  nop
; This funcions is just a stub. It's implementation will be in C
call_me_maybe:
  nop


internal_to_asm:
  ret

asm_main:
  call internal_to_asm
  call call_me_maybe
  ret
