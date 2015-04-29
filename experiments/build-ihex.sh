
source ~/.zshrc
RELOC=1

AVR_CHIP="atmega644p"


ASM_SRC=${1}
ASM_FILE=`basename ${1}`
BUILD_DIR=`dirname ${ASM_SRC}`/build

SYMBOL_PREFIX="_binary_`echo ${BUILD_DIR}/${ASM_FILE} | tr / _ | tr - _ | tr . _`_bin"
SYMBOL_NAME="${SYMBOL_PREFIX}_start"


if [ ${RELOC} -eq 1 ]; then
  SYMBOL_NAME="_blinks"
fi

mkdir -p `dirname ${ASM_SRC}`/build


echo "building" ${ASM_SRC}
echo "Using symbolname="${SYMBOL_NAME}
echo "symbol prefix="${SYMBOL_PREFIX}

wine ~/bin/AvrAssembler2/avrasm2.exe ${ASM_SRC} -fI -o ${BUILD_DIR}/${ASM_FILE}.hex -l ${BUILD_DIR}/${ASM_FILE}.lst -m ${BUILD_DIR}/${ASM_FILE}.map
avr-objcopy -j .sec1 -I ihex -O binary ${BUILD_DIR}/${ASM_FILE}.hex ${BUILD_DIR}/${ASM_FILE}.bin

#avr-objcopy --rename-section .data=.progmem.data,contents,alloc,load,readonly,data  -I binary -O elf32-avr build/${ASM_SRC}.bin build/${ASM_SRC}.elf
avr-objcopy --rename-section .data=.text,contents,alloc,load,readonly,code -I binary -O elf32-avr ${BUILD_DIR}/${ASM_FILE}.bin ${BUILD_DIR}/${ASM_FILE}.elf

if [ ${RELOC} -eq 1 ]; then
  avr-strip -N ${SYMBOL_PREFIX}_start ${BUILD_DIR}/${ASM_FILE}.elf
  avr-strip -N ${SYMBOL_PREFIX}_end ${BUILD_DIR}/${ASM_FILE}.elf
  avr-strip -N ${SYMBOL_PREFIX}_size ${BUILD_DIR}/${ASM_FILE}.elf
fi

#Generate output to reconstruct the symbol table and relocation table
avr-objdump -d ${BUILD_DIR}/${ASM_FILE}.elf| python2 tools/extract-symbols-metadata.py ${BUILD_DIR}/${ASM_FILE}.map > ${BUILD_DIR}/${ASM_FILE}.symtab

if [ ${RELOC} -eq 1 ]; then
  cat ${BUILD_DIR}/${ASM_FILE}.symtab | tools/elf-add-symbol ${BUILD_DIR}/${ASM_FILE}.elf
fi
avr-gcc -mmcu=${AVR_CHIP} -Os -DF_CPU=1000000 -DASM_SYM=${SYMBOL_NAME} -o ${BUILD_DIR}/main_${ASM_FILE}.elf main.c ${BUILD_DIR}/${ASM_FILE}.elf
avr-objcopy -I elf32-avr -O ihex -j .text -j .data ${BUILD_DIR}/main_${ASM_FILE}.elf ${BUILD_DIR}/main_${ASM_FILE}.hex

sudo /usr/share/arduino/hardware/tools/avrdude -C /usr/share/arduino/hardware/tools/avrdude.conf -p${AVR_CHIP} -cusbasp -Uflash:w:${BUILD_DIR}/main_${ASM_FILE}.hex:i

