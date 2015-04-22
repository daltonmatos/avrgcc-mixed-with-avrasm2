#include <elfio/elfio.hpp>


using namespace ELFIO;

int main(int argc, char** argv){
  elfio elf_src;

  elf_src.load(argv[1]);
  std::string output_file(argv[1]);

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

  syma.add_symbol(stra, "_blinks", 0x0, 9, STB_GLOBAL, STT_NOTYPE, 0, text_sec->get_index()); 
  Elf_Word _real_code_to_adjust = syma.add_symbol(stra, "_real_code", 0xa, 0, STB_GLOBAL, STT_NOTYPE, 0, text_sec->get_index()); 
  Elf_Word _clear_to_adjust = syma.add_symbol(stra, "_clear", 0x10, 0, STB_GLOBAL, STT_NOTYPE, 0, text_sec->get_index()); 

  
    // Create relocation table section
    section* rel_sec = elf_src.sections.add( ".rel.text" );
    rel_sec->set_type      ( SHT_REL );
    rel_sec->set_info      ( text_sec->get_index() );
    rel_sec->set_addr_align( 0x4 );
    rel_sec->set_entry_size( elf_src.get_default_entry_size( SHT_REL ) );
    rel_sec->set_link      ( symtab_sec->get_index() );

    // Create relocation table writer
    relocation_section_accessor rela( elf_src, rel_sec );

    /* 18 is R_AVR_CALL (relocatin type) */
    rela.add_entry( 0x4, _real_code_to_adjust, (unsigned char) 18 );
    rela.add_entry( 0x0, _clear_to_adjust, (unsigned char) 18 );

    // Another method to add the same relocation entry at one step is:
    // rela.add_entry( stra, "msg",
    //                 syma, 29, 0,
    //                 ELF_ST_INFO( STB_GLOBAL, STT_OBJECT ), 0,
    //                 text_sec->get_index(),
    //                 place_to_adjust, (unsigned char)R_386_RELATIVE );


  std::cout << "Saving elf." << std::endl;  
  elf_src.save("with_symbols_" + output_file.substr(output_file.find_last_of("/")+1));
 
  return 0;
}
