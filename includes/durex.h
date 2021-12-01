/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   durex.h                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: alagroy- <alagroy-@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2021/08/14 17:29:19 by vscode            #+#    #+#             */
/*   Updated: 2021/12/01 08:03:33 by alagroy-         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef DUREX_H
# define DUREX_H

# include <stdio.h>
# include <string.h>
# include <stdlib.h>
# include <ctype.h>

# define KEY_LEN 32
# define HEX_TO_CHAR(hex) ((isalpha(*(hex)) ? *(hex) - 'A' + 10 : *(hex) - '0') << 4 | (isalpha(*(hex + 1)) ? *(hex + 1) - 'A' + 10 : *(hex + 1) - '0'))


typedef unsigned char   byte;

extern char             *g_payload;

char                    *decrypt_payload(char *payload);

#endif