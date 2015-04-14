
source ~/.zshrc

ASM_SRC=${1}
SYMBOL_NAME="_binary_build_${ASM_SRC:r}_asm_bin_start"


echo ${ASM_SRC}
echo ${SYMBOL_NAME}
wine ~/bin/AvrAssembler2/avrasm2.exe ${ASM_SRC} -fI -o build/${ASM_SRC}.hex -l build/${ASM_SRC}.lst -m build/${ASM_SRC}.map
avr-objcopy -j .sec1 -I ihex -O binary build/${ASM_SRC}.hex build/${ASM_SRC}.bin

#avr-objcopy --rename-section .data=.progmem.data,contents,alloc,load,readonly,data  -I binary -O elf32-avr build/${ASM_SRC}.bin build/${ASM_SRC}.elf
avr-objcopy --rename-section .data=.text,contents,alloc,load,readonly,code -I binary -O elf32-avr build/${ASM_SRC}.bin build/${ASM_SRC}.elf


avr-gcc -mmcu=atmega328p -Os -DF_CPU=16000000 -DASM_SYM=${SYMBOL_NAME} -o build/main_${ASM_SRC}.elf main.c build/${ASM_SRC}.elf
avr-objcopy -I elf32-avr -O ihex -j .text -j .data build/main_${ASM_SRC}.elf build/main_${ASM_SRC}.hex

sudo /usr/share/arduino/hardware/tools/avrdude -C /usr/share/arduino/hardware/tools/avrdude.conf -patmega328p -cusbasp -Uflash:w:build/main_${ASM_SRC}.hex:i

