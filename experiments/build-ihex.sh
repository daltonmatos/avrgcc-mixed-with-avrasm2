
source ~/.zshrc
RELOC=1

ASM_SRC=${1}
SYMBOL_NAME="_binary_build_${ASM_SRC:r}_asm_bin_start"

if [ ${RELOC} -eq 1 ]; then
  SYMBOL_NAME="_blinks"
fi



echo ${ASM_SRC}
echo ${SYMBOL_NAME}
wine ~/bin/AvrAssembler2/avrasm2.exe ${ASM_SRC} -fI -o build/${ASM_SRC}.hex -l build/${ASM_SRC}.lst -m build/${ASM_SRC}.map
avr-objcopy -j .sec1 -I ihex -O binary build/${ASM_SRC}.hex build/${ASM_SRC}.bin

#avr-objcopy --rename-section .data=.progmem.data,contents,alloc,load,readonly,data  -I binary -O elf32-avr build/${ASM_SRC}.bin build/${ASM_SRC}.elf
avr-objcopy --rename-section .data=.text,contents,alloc,load,readonly,code -I binary -O elf32-avr build/${ASM_SRC}.bin build/${ASM_SRC}.elf

if [ ${RELOC} -eq 1 ]; then
  avr-strip -N _binary_build_${ASM_SRC:r}_asm_bin_start build/${ASM_SRC}.elf
  avr-strip -N _binary_build_${ASM_SRC:r}_asm_bin_end build/${ASM_SRC}.elf
  avr-strip -N _binary_build_${ASM_SRC:r}_asm_bin_size build/${ASM_SRC}.elf
fi

#Generate output to reconstruct the symbol table and relocation table
avr-objdump -d build/${ASM_SRC}.elf| python2 tools/extract-symbols-metadata.py build/${ASM_SRC}.map > build/${ASM_SRC}.symtab

if [ ${RELOC} -eq 1 ]; then
  cat build/${ASM_SRC}.symtab | tools/elf-add-symbol build/${ASM_SRC}.elf
fi
avr-gcc -mmcu=atmega328p -Os -DF_CPU=16000000 -DASM_SYM=${SYMBOL_NAME} -o build/main_${ASM_SRC}.elf main.c build/${ASM_SRC}.elf
avr-objcopy -I elf32-avr -O ihex -j .text -j .data build/main_${ASM_SRC}.elf build/main_${ASM_SRC}.hex

sudo /usr/share/arduino/hardware/tools/avrdude -C /usr/share/arduino/hardware/tools/avrdude.conf -patmega328p -cusbasp -Uflash:w:build/main_${ASM_SRC}.hex:i

