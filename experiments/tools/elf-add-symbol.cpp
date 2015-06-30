#include <elfio/elfio.hpp>
#include <sstream>
#include <vector>

using namespace ELFIO;

#define R_AVR_CALL 18

int strhex_to_int(std::string value){

  int v;
  std::stringstream ss;
  ss << value;
  ss >> std::hex >> v;
  return v;

}


void add_sym(symbol_section_accessor &syma,
             string_section_accessor &stra,
             section *text_sec,
             section *null_sec,
             relocation_section_accessor &rela,
             const char *name, 
             const int &addr, 
             bool reloc,
             std::string sym_usage,
             std::string sym_type){

  std::cout << "Adding Symbol: " << name << " " << std::hex << addr <<  " reloc=" << reloc << " (" << sym_usage << ")" << "type=" << sym_type << std::endl;

  Elf_Half _real_code_to_adjust;
  
  if (sym_type == "I"){
    _real_code_to_adjust = syma.add_symbol(stra, name, addr, 0, STB_GLOBAL, STT_NOTYPE, 0, text_sec->get_index()); 
  }else{
    _real_code_to_adjust = syma.add_symbol(stra, name, 0, 0, STB_GLOBAL, STT_NOTYPE, 0, null_sec->get_index()); 
  }
 
  if (reloc){
    std::string buf;
    std::stringstream ss(sym_usage);
    std::vector<std::string> tokens;

    while (ss >> buf){
      tokens.push_back(buf);
    }

    std::vector<int>::size_type sz = tokens.size();
    for (int i=0; i < sz; i++){
      rela.add_entry( strhex_to_int(tokens[i]), _real_code_to_adjust, (unsigned char) R_AVR_CALL);
    }
  }

}



int main(int argc, char** argv){
  elfio elf_src;

  elf_src.load(argv[1]);
  std::string output_file(argv[1]);

  section *text_sec, *strtab_sec, *shstrtab_sec, *symtab_sec, *null_sec;

  /*std::cout << "class=";
  if (elf_src.get_class() == ELFCLASS32){
    std::cout << "ELFCLASS32"<< std::endl;
  }*/

  Elf_Half total_sections = elf_src.sections.size();
  //std::cout << "Sections: " << total_sections << std::endl;


  section *psec;
  bool rela_sec_found = false;
  int section_idx = 0;

  for ( int i = 0; i < total_sections; ++i ) {
    psec = elf_src.sections[i];
    //std::cout << psec->get_name() <<  " (" << psec << ")" << std::endl;

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
      case SHT_NULL:
        null_sec = psec;
        break;
    }
  }

  std::string sym_name;
  std::string addr_str;
  std::string sym_usage; // Which instructions use this symbol?

  int sym_addr;
  std::string sym_type; // I=Internal, E=External
  
  std::stringstream ss;
  //ss << addr_str;
  //ss >> std::hex >> sym_addr;



  /*if (argc > 4){
    int i;
    for (i=4; i< argc; i++){
      sym_usage += argv[i];
      sym_usage += " ";
    }
  }*/

  symbol_section_accessor syma(elf_src, symtab_sec);
  string_section_accessor stra(strtab_sec);
  
  // Create relocation table section
  section* rel_sec = elf_src.sections.add( ".rel.text" );
  rel_sec->set_type      ( SHT_REL );
  rel_sec->set_info      ( text_sec->get_index() );
  rel_sec->set_addr_align( 0x4 );
  rel_sec->set_entry_size( elf_src.get_default_entry_size( SHT_REL ) );
  rel_sec->set_link      ( symtab_sec->get_index() );

  // Create relocation table writer
  relocation_section_accessor rela( elf_src, rel_sec );

  std::string s;
  while (std::cin >> sym_name){
    std::cin >> sym_type;
    std::cin >> std::hex >> sym_addr;
    std::getline(std::cin, sym_usage);

    //std::cout << sym_name << sym_addr << sym_usage << std::endl;
    add_sym(syma, stra, text_sec, null_sec, rela, sym_name.c_str(), sym_addr, (sym_usage != ""), sym_usage, sym_type);
    
  }


    //syma.add_symbol(stra, "_blinks", 0x0, 9, STB_GLOBAL, STT_NOTYPE, 0, text_sec->get_index()); 
    //Elf_Word _real_code_to_adjust = syma.add_symbol(stra, "_real_code", 0xa, 0, STB_GLOBAL, STT_NOTYPE, 0, text_sec->get_index()); 
    //Elf_Word _clear_to_adjust = syma.add_symbol(stra, "_clear", 0x10, 0, STB_GLOBAL, STT_NOTYPE, 0, text_sec->get_index()); 
    

    //std::cout << "Saving elf." << std::endl;  
    //elf_src.save("with_symbols_" + output_file.substr(output_file.find_last_of("/")+1));
    elf_src.save(argv[1]);
 
  return 0;
}






