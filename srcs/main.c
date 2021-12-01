/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: alagroy- <alagroy-@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2021/08/14 17:28:28 by vscode            #+#    #+#             */
/*   Updated: 2021/11/30 08:32:28 by alagroy-         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "durex.h"

int     main(void)
{
    char    *payload;

    puts("alagroy-");
    if (!(payload = decrypt_payload(g_payload)))
        return (-1);
    return (0);
}