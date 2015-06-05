#include <avr/io.h>


extern void beep();

int main(){

  for (;;){
    beep();
  }

  return 0;
}
