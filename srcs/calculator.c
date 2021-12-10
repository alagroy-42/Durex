/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   calculator.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: alagroy- <alagroy-@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2021/12/09 12:27:24 by alagroy-          #+#    #+#             */
/*   Updated: 2021/12/09 13:05:37 by alagroy-         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "durex.h"

void        calc(void)
{
    char    buf[128];

    puts(STR_INTRO);
    while (1)
    {
        fputs("> ", stdout);
        if (!(fgets(buf, 128, stdin)))
            exit(EXIT_FAILURE);
        if (!strcmp(buf, "exit\n"))
        {
            puts("Bye ! Hope to see you son :)");
            exit(EXIT_SUCCESS);
        }
    }
}