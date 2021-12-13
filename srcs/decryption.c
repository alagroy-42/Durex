/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   decryption.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: alagroy- <alagroy-@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2021/11/29 10:38:06 by alagroy-          #+#    #+#             */
/*   Updated: 2021/12/13 08:24:06 by alagroy-         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "durex.h"

static int      get_payload_len(char *payload)
{
    size_t     len;
    size_t     i;
    size_t     nb_pc;

    len = strlen(payload);
    i = -1;
    nb_pc = 0;
    while (payload[++i])
        if (payload[i] == '%')
            nb_pc++;
    return (len - (nb_pc * 2));
}

static void     url_decode(byte *decrypted_payload, char *payload)
{
    int     i;
    int     i_decrypt;

    i = -1;
    i_decrypt = 0;
    while (payload[++i])
    {
        if (payload[i] == '%')
        {
            decrypted_payload[i_decrypt] = HEX_TO_CHAR(payload + i + 1);
            i += 2;
        }
        else
            decrypted_payload[i_decrypt] = payload[i];
        i_decrypt++;
    }
}

static byte     *unxor_payload(byte *payload_xored, int len)
{
    byte    *final_payload;
    byte    key[KEY_LEN];
    int     len_final;
    int     i;

    memcpy(key, payload_xored + len - KEY_LEN, KEY_LEN);
    i = -1;
    len_final = len - KEY_LEN;
    if (!(final_payload = malloc(len_final)))
        return (NULL);
    i = -1;
    while (++i < len_final)
        final_payload[i] = payload_xored[i] ^ key[i % KEY_LEN];
    free(payload_xored);
    return (final_payload);
}

byte            *decrypt_payload(char *payload, int *final_len)
{
    int     len;
    byte    *decrypted_payload;

    len = get_payload_len(payload);
    if (!(decrypted_payload = malloc(len)))
        return (NULL);
    url_decode(decrypted_payload, payload);
    if (!(decrypted_payload = unxor_payload(decrypted_payload, len)))
        return (NULL);
    *final_len = len - 32;
    return (decrypted_payload);
}
