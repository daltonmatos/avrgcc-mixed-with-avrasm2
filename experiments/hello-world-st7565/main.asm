.include "../../Source/m644Pdef.inc"


null:       .db 0, 0


.org 0x0000

        jmp main               ; Reset
        jmp unused            ; External Interrupt Request 0
        jmp unused             ; External Interrupt Request 1
        jmp unused              ; External Interrupt Request 2
        jmp unused              ; Pin Change Interrupt Request 0
        jmp unused           ; Pin Change Interrupt Request 1
        jmp unused              ; Pin Change Interrupt Request 2
        jmp unused     ; Pin Change Interrupt Request 3
        jmp unused              ; Watchdog Time-out Interrupt
        jmp unused              ; Timer/Counter2 Compare Match A
        jmp unused              ; Timer/Counter2 Compare Match B
        jmp unused         ; Timer/Counter2 Overflow
        jmp unused              ; Timer/Counter1 Capture Event
        jmp unused         ; Timer/Counter1 Compare Match A
        jmp unused           ; Timer/Counter1 Compare Match B
        jmp unused              ; Timer/Counter1 Overflow
        jmp unused              ; Timer/Counter0 Compare Match A
        jmp unused              ; Timer/Counter0 Compare Match B
        jmp unused              ; Timer/Counter0 Overflow
        jmp unused              ; SPI Serial Transfer Complete
        jmp unused         ; USART0, Rx Complete
        jmp unused              ; USART0 Data register Empty
        jmp unused              ; USART0, Tx Complete
        jmp unused              ; Analog Comparator
        jmp unused              ; ADC Conversion Complete
        jmp unused              ; EEPROM Ready
        jmp unused              ; 2-wire Serial Interface
        jmp unused              ; Store Program Memory Read
        jmp unused              ; USART1 RX complete
        jmp unused              ; USART1 Data Register Empty
        jmp unused              ; USART1 TX complete

unused: reti



font6x8:
.include "../../Source/font6x8.asm"
font8x12:
;.include "font8x12.asm"
font12x16:
.include "../../Source/font12x16.asm"
symbols16x16:
.include "../../Source/symbols16x16.asm"
font4x6:
.include "../../Source/font4x6.asm"

.include "../../Source/constants.asm"
.include "../../Source/macros.inc"
.include "../../Source/miscmacros.inc"
.include "../../Source/variables.asm"

.include "../../Source/hardware.asm"
.include "../../Source/setuphw.asm"

.include "miscsubs.asm"
.include "contrast.asm"
.include "ST7565.asm"


main:
  ldx 100
	call WaitXms

	call SetupHardware
  
;call LoadLcdContrast
  ;BuzzerOn
  ;BuzzerOff
  ;ldi t, 0x30
  ;sts LcdContrast, t

  lrv FontSelector, f6x8
  call SetDefaultLcdContrast
  call LcdUpdate
  call LcdClear
  call LcdUpdate
  lrv X1, 0
  lrv Y1, 0
  ldz hello*2
  call PrintString

  lrv X1, 20
  lrv Y1, 12
  ldi t, 3

  ;call PrintHeader
  ldz sqz6*2
  call PrintStringArray
  

  call LcdUpdate

  ;BuzzerOn
  ;ldx 50
  ;BuzzerOff
_loop:
  jmp _loop


hello:  .db "HELLO", 0
sqz3:   .db "ACC Trim Roll", 0
sqz4:   .db "ACC Trim Pitch", 0 ;, 0
sqz5:   .db "SL Mixing Rate", 0 ;, 0

sqz6:   .dw sqz3*2, sqz4*2, sqz5*2
