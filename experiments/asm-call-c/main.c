#include <avr/io.h>

static int a = 1;


void call_me_maybe(){
  a += 1;
  if (a > 3){
    return;
  }
  return;
}

extern void asm_main();

int main(){
  
  asm_main();
    
  DDRB |= _BV(PB5); /* PIN13 (internal led) as output*/
  PORTB |= _BV(PB5); /* HIGH */
  
  return 0;
}
