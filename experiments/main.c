#include <avr/io.h>
#include <util/delay.h>

// Arduino Pin13 is mapped to PORTB, bit 5
// See: http://www.arduino.cc/en/Reference/PortManipulation

//extern char _binary_blinks_bin_start(char n);
extern char ASM_SYM(char n);

int main(void){

  uint8_t total_blinks =  ASM_SYM(0);
  DDRB |= _BV(PB5); /* PIN13 (internal led) as output*/

  PORTB |= _BV(PB5); /* HIGH */
  for (;;){
    uint8_t i;
    for (i = 0; i < total_blinks; i++){
      PORTB |= _BV(PB5); /* HIGH */
      _delay_ms(200);
      
      PORTB &= ~_BV(PB5); /* LOW */
        _delay_ms(200);
    }
    _delay_ms(1000);
  }

  return 0;
}
