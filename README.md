# avrgcc-mixed-with-avrasm2
Proof o concept code made for a series of blog posts about mixing avrasm2 and avr-gcc code


The code pushed here were produced for a series os blog posts, demonstrating how it's possible do fully mix a Legacy Assembly AVR project (written with avrasm2) with a modern project (written with avr-gcc).

All Assembly code presented here belongs to a firmware written by RC911 for the KK2 flight controller board. His project was extremelly important for this research, as I could test all hypotesis with a real Legacy Assembly code, written with avrasm2.

To be able to build the ``experiments/hello-world-st7565`` code, you will need to compile ``tools/elf-add-symbol.cpp`` with the following line:


``g++ -ggdb -o elf-add-symbol elf-add-symbol.cpp -I elfio-3.1/``

You need to be inside the ``tools`` folder, so make sure you ``cd`` into it before running ``g++``.

Also to run this example, which demonstrates all interactions between C and Assembly, you will need a KK2 flight controller board. =D

To compile this example run the following command:

``AVR_CHIP=atmega644p ../build-ihex.sh hello.asm``

This will compile all Assembly and C codes, link them, extract the final ``.hex`` file and call avrdude to flash it into the chip memory.


The series os posts can be read here: https://daltonmatos.com/avr/
