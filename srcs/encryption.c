/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   encryption.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: alagroy- <alagroy-@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2021/12/01 09:13:34 by alagroy-          #+#    #+#             */
/*   Updated: 2021/12/06 10:40:29 by alagroy-         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "durex.h"

static void     get_key(byte *key)
{
    int     fd;

    if ((fd = open("/dev/urandom", O_RDONLY)) == -1)
        return ;
    read(fd, key, KEY_LEN);
    close(fd);
}

static void     format_routine(byte *routine, int text_size)
{   
    uint32_t    rel_mprotect;
    uint32_t    rel_text;
    uint32_t    rel_entry;

    rel_mprotect = 0 - (text_size + HEADERS_SIZE + TEXT_MPROTECT_OFF + sizeof(uint32_t));
    rel_text = 0 - (text_size + TEXT_REL_OFF + sizeof(uint32_t));
    rel_entry = 0 - (text_size + JMP_ADDR_OFF + sizeof(uint32_t));
    text_size = text_size;
    memcpy(routine + TEXT_MPROTECT_OFF, &rel_mprotect, sizeof(uint32_t));
    memcpy(routine + TEXT_LEN_OFF, &text_size, sizeof(uint32_t));
    memcpy(routine + TEXT_REL_OFF, &rel_text, sizeof(uint32_t));
    memcpy(routine + JMP_ADDR_OFF, &rel_entry, sizeof(uint32_t));
}

static byte     *insert_decryption_routine(byte *payload, int len, byte *key)
{
    int     total_len;
    byte    *exec;
    byte    routine[SHELLCODE_LEN];

    memcpy(routine, SHELLCODE_DECRYPT, SHELLCODE_LEN);
    total_len = len + SHELLCODE_LEN + KEY_LEN;
    format_routine(routine, len - HEADERS_SIZE);
    if (!(exec = malloc(total_len)))
        exit(EXIT_FAILURE);
    memcpy(exec, payload, len);
    memcpy(exec + len, routine, SHELLCODE_LEN);
    memcpy(exec + len + SHELLCODE_LEN, key, KEY_LEN);
    ((Elf64_Ehdr *)exec)->e_entry += (len - HEADERS_SIZE);
    ((Elf64_Phdr *)(exec + sizeof(Elf64_Ehdr)))->p_filesz += SHELLCODE_LEN + KEY_LEN;
    ((Elf64_Phdr *)(exec + sizeof(Elf64_Ehdr)))->p_memsz = ((Elf64_Phdr *)(exec + sizeof(Elf64_Ehdr)))->p_filesz;
    return (exec);
}

byte            *encrypt_binary(byte *payload, int len)
{
    byte    key[KEY_LEN];
    off_t   offset;
    int     i;
    byte    *final_exec;

    get_key(key);
    offset = HEADERS_SIZE;
    i = -1;
    while (++i + offset < len)
        payload[i + offset] ^= (key[i % KEY_LEN] + (42 * ((i) / KEY_LEN)));
    final_exec = insert_decryption_routine(payload, len, key);
    return (final_exec);
}