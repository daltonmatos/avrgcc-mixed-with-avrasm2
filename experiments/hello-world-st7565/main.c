#include <avr/io.h>
#include <avr/pgmspace.h>

const char p[] PROGMEM = {"Hello from C."};

extern void hello_main(const char []);
extern void my_print_string(const char p[]);

int f(){
  return 0;
}

void flashdata_from_asm(char p[]){
  my_print_string(p); 
}

char c_read_flashbyte(char c[]){
  return pgm_read_byte_near(c);
}


void main(){
  f();
  hello_main(p); 
}
