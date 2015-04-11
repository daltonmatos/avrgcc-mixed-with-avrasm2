#include <avr/io.h>
#include <util/delay.h>

// Arduino Pin13 is mapped to PORTB, bit 5
// See: http://www.arduino.cc/en/Reference/PortManipulation


int main(void){

  DDRB |= _BV(PB5); /* PIN13 (internal led) as output*/

  for (;;){
    PORTB |= _BV(PB5); /* HIGH */
    //_delay_ms(2000);
    
    PORTB &= ~_BV(PB5); /* LOW */
    _delay_ms(5000);
  }

  return 0;
}
