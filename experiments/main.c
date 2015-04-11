#include <avr/io.h>
#include <util/delay.h>

// Arduino Pin13 is mapped to PORTB, bit 5
// See: http://www.arduino.cc/en/Reference/PortManipulation


int main(void){

  DDRB |= (1 << PB5); /* PIN13 (internal led) as output*/

  for (;;){
    PORTB |= (1 << PB5); /* HIGH */
    _delay_ms(2000);
    
    PORTB &= ~(1 << PB5); /* LOW */
    _delay_ms(2000);
  }

  return 0;
}
