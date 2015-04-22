#include <elfio/elfio.hpp>
#include <stdio.h>


using namespace ELFIO;

int main(int argc, char** argv){
  elfio elf_src;

  elf_src.load(argv[1]);


  section *text_sec, *strtab_sec, *shstrtab_sec, *symtab_sec;

  std::cout << "class=";
  if (elf_src.get_class() == ELFCLASS32){
    std::cout << "ELFCLASS32"<< std::endl;
  }

  Elf_Half total_sections = elf_src.sections.size();
  std::cout << "Sections: " << total_sections << std::endl;


  section *psec;
  bool rela_sec_found = false;
  int section_idx = 0;

  for ( int i = 0; i < total_sections; ++i ) {
    psec = elf_src.sections[i];
    std::cout << psec->get_name() <<  " (" << psec << ")" << std::endl;

    switch (psec->get_type()){
      case SHT_SYMTAB:
        symtab_sec = psec;
        break;
      case SHT_STRTAB:
        if (psec->get_name() == ".strtab") {
          strtab_sec = psec;
        }else{
          shstrtab_sec = psec;        
        }
        break;
      case SHT_PROGBITS:
        text_sec = psec;
        break;
    }
  }

  std::cout << "========================" << std::endl <<
    "text_sec " << text_sec << std::endl <<
    "strtab_sec " << strtab_sec << std::endl <<
    "shstrtab_sec " << shstrtab_sec << std::endl <<
    "symtab_sec " << symtab_sec << std::endl;

  symbol_section_accessor syma(elf_src, symtab_sec);
  string_section_accessor stra(strtab_sec);

  syma.add_symbol(stra, "_add_10", 0x6, 0, STB_GLOBAL, STT_NOTYPE, 0, text_sec->get_index()); 
  syma.add_symbol(stra, "_main", 0x0, 0, STB_GLOBAL, STT_NOTYPE, 0, text_sec->get_index()); 


  std::cout << "Saving elf." << std::endl;  
  elf_src.save("saved.elf");
 
  return 0;
}
