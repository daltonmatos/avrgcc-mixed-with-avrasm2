#include <elfio/elfio.hpp>
#include <stdio.h>


using namespace ELFIO;

int main(int argc, char** argv){
  elfio elf_src;

  elf_src.load(argv[1]);

  std::cout << "class=";
  if (elf_src.get_class() == ELFCLASS32){
    std::cout << "ELFCLASS32"<< std::endl;
  }

  Elf_Half total_sections = elf_src.sections.size();
  std::cout << "Sections: " << total_sections << std::endl;


  section *psec;
  bool rela_sec_found = false;

  for ( int i = 0; i < total_sections; ++i ) {
    psec = elf_src.sections[i];
    if (psec->get_type() == SHT_SYMTAB){
      std::cout << "symtab found " << psec->get_name() << std::endl;
      rela_sec_found = true;
      break;
    }
  }

  //if (psec != NULL){
    std::cout << psec << std::endl;
    //section* rela_sec = elf_src.sections.add(".rela.text");
    //section* rela_sec = elf_src.create_section;
    //rela_sec->set_name(".rela.text");
    //rela_sec->set_type(SHT_RELA);
    symbol_section_accessor rela_symbols( elf_src, psec );

    Elf_Word name;
    Elf64_Addr addr;
    Elf_Xword size;
    unsigned char bind;
    unsigned char type;
    Elf_Half section_index;
    unsigned char other;
   
    string_section_accessor str_acc(psec);
    //ssor::add_symbol(ELFIO::Elf_Word, ELFIO::Elf64_Addr, ELFIO::Elf_Xword, unsigned char, unsigned char, unsigned char, ELFIO::Elf_Half)
    name = str_acc.add_string("_name");

    addr = 0x6;
    size = 0;
    bind = STB_GLOBAL;
    type = STT_NOTYPE;
    section_index = 0x6;

    rela_symbols.add_symbol(name, addr, size, bind, type, 0, section_index);
    
    std::cout << "Saving elf." << std::endl;  
    elf_src.save("saved.elf");

  //}
 
  return 0;
}
