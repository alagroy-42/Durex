#!/usr/bin/python3

import sys

def get_ELF_header():
    return '''
BITS 64

org         0x400000

ehdr:                                                 ; Elf64_Ehdr
            db      0x7F, "ELF", 2, 1, 1, 0         ;   e_ident
    times 8 db      0
            dw      2                               ;   e_type
            dw      62                               ;   e_machine
            dd      1                               ;   e_version
            dq      _start                          ;   e_entry
            dq      phdr - $$                       ;   e_phoff
            dq      0                               ;   e_shoff
            dd      0                               ;   e_flags
            dw      ehdrsize                        ;   e_ehsize
            dw      phdrsize                        ;   e_phentsize
            dw      1                               ;   e_phnum
            dw      0                               ;   e_shentsize
            dw      0                               ;   e_shnum
            dw      0                               ;   e_shstrndx

ehdrsize      equ     $ - ehdr

phdr:                                                 ; Elf64_Phdr
            dd      1                               ;   p_type
            dd      5                               ;   p_flags
            dq      0                               ;   p_offset
            dq      $$                              ;   p_vaddr
            dq      $$                              ;   p_paddr
            dq      filesize                        ;   p_filesz
            dq      filesize                        ;   p_memsz
            dq      0x1000                          ;   p_align

phdrsize      equ     $ - phdr
'''

def process_file(stream):
    code = []
    for line in stream.readlines():
        keep = True
        for keyword in ['section', 'global', 'extern', 'BITS']:
            if keyword in line:
                keep = False
                break
        if keep:
            code.append(line)
    return code


if __name__ == '__main__':
    files = sys.argv[1:]
    output_file = './srcs/tiny.s'
    code = {}

    for f in files:
        with open(f, 'r') as stream:
            code[f] = process_file(stream)
            stream.close()
    with open(output_file, 'w') as output:
        output.write(get_ELF_header())
        for lines in code.values():
            for line in lines:
                output.write(line)
        output.write('\n  filesize      equ     $ - $$')
        output.close()
