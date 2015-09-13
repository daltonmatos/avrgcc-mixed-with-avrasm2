.include "../../Source/m644Pdef.inc"

.org 0x0000

;        jmp hello_main               ; Reset
;        jmp unused            ; External Interrupt Request 0
;        jmp unused             ; External Interrupt Request 1
;        jmp unused              ; External Interrupt Request 2
;        jmp unused              ; Pin Change Interrupt Request 0
;        jmp unused           ; Pin Change Interrupt Request 1
;        jmp unused              ; Pin Change Interrupt Request 2
;        jmp unused     ; Pin Change Interrupt Request 3
;        jmp unused              ; Watchdog Time-out Interrupt
;        jmp unused              ; Timer/Counter2 Compare Match A
;        jmp unused              ; Timer/Counter2 Compare Match B
;        jmp unused         ; Timer/Counter2 Overflow
;        jmp unused              ; Timer/Counter1 Capture Event
;        jmp unused         ; Timer/Counter1 Compare Match A
;        jmp unused           ; Timer/Counter1 Compare Match B
;        jmp unused              ; Timer/Counter1 Overflow
;        jmp unused              ; Timer/Counter0 Compare Match A
;        jmp unused              ; Timer/Counter0 Compare Match B
;        jmp unused              ; Timer/Counter0 Overflow
;        jmp unused              ; SPI Serial Transfer Complete
;        jmp unused         ; USART0, Rx Complete
;        jmp unused              ; USART0 Data register Empty
;        jmp unused              ; USART0, Tx Complete
;        jmp unused              ; Analog Comparator
;        jmp unused              ; ADC Conversion Complete
;        jmp unused              ; EEPROM Ready
;        jmp unused              ; 2-wire Serial Interface
;        jmp unused              ; Store Program Memory Read
;        jmp unused              ; USART1 RX complete
;        jmp unused              ; USART1 Data Register Empty
;        jmp unused              ; USART1 TX complete
;
;unused: reti

.equ offset = 0x9a

.macro my_ldz
  ldi zl, low(@0 + (offset))
  ldi zh, high(@0 + (offset))
.endmacro

_offset_check:
    my_ldz _offset_data*2

_offset_data:
  .db 01, 02  


font6x8:
.include "../../Source/font6x8.asm"
font8x12:
;.include "font8x12.asm"
font12x16:
;.include "../../Source/font12x16.asm"
symbols16x16:
;.include "../../Source/symbols16x16.asm"
font4x6:
;.include "../../Source/font4x6.asm"


.include "../../Source/constants.asm"
.include "../../Source/macros.inc"
.include "../../Source/miscmacros.inc"
.include "../../Source/variables.asm"

.include "../../Source/hardware.asm"
.include "../../Source/setuphw.asm"

.include "miscsubs.asm"
.include "contrast.asm"

null:       .db 0, 0
.include "ST7565.asm"


.macro print_addr
  ldi zl, low(@0)
  ldi zh, high(@0)
  movw x, z
  call PrintNumberLF
  lrv X1, 0
.endm


hello_main:
 ldx 100
	call WaitXms
	call SetupHardware
  
  ;BuzzerOn
  ;BuzzerOff
  
  lrv FontSelector, f6x8
  call SetDefaultLcdContrast
  ldi t, 0x50
  sts LcdContrast, t
  call LoadLcdContrast

  lrv X1, 0
  lrv Y1, 0
  my_ldz hello*2
  call PrintString
  

  lrv X1, 0
  lrv Y1, 20
  print_addr _offset_data
  ;ldi t, 1
  ;sts Xpos, t
  ;sts Ypos, t
  ;call SetPixel
  call LcdUpdate

  
;_loop:
;  LedOn
;  ldx 200
;  call WaitXms
;  LedOff
;  ldx 200
;  call WaitXms
;  inc r22
;  cp r22, r23
;  brne _loop

_loop2:
  jmp _loop2


hello:  .db "HELLO", 0
sqz3:   .db "ACC Trim Roll", 0
sqz4:   .db "ACC Trim Pitch", 0 ;, 0
sqz5:   .db "SL Mixing Rate", 0 ;, 0

sqz6:   .dw sqz3*2, sqz4*2, sqz5*2
