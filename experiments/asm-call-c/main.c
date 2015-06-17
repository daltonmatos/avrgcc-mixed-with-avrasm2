#include <avr/io.h>



void call_me_maybe(){

  return;
}

extern void asm_main();

int main(){
  
  //asm_main();
    
  DDRB |= _BV(PB5); /* PIN13 (internal led) as output*/
  PORTB |= _BV(PB5); /* HIGH */
  
  return 0;
}
