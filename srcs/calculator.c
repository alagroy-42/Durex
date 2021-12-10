/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   calculator.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: alagroy- <alagroy-@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2021/12/09 12:27:24 by alagroy-          #+#    #+#             */
/*   Updated: 2021/12/10 11:36:41 by alagroy-         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "durex.h"

static int  count_digits(int nb)
{
    unsigned int    abs;
    int             count;

    count = 1;
    abs = nb;
    if (nb < 0)
    {
        count++;
        abs *= -1;
    }
    while ((nb /= 10))
        count++;
    return (count);
}

static char *skip_spaces(char *buf)
{
    while (isblank(*buf) && *buf)
        buf++;
    return (buf);
}

static t_op get_op(char *buf)
{
    switch (*buf)
    {
        case '+':
            return (OP_PLUS);
        case '-':
            return (OP_MINUS);
        case '*':
            return (OP_MULT);
        case '/':
            return (OP_DIV);
        case '%':
            return (OP_MOD);
        default:
            return (OP_INVALID);
    }
    return (OP_INVALID);
}

static void do_calc(int member1, t_op op, int member2)
{
    long long   result;

    if (!member1 || !member2 || op == OP_INVALID)
    {
        dprintf(2, "Parsing Error.\n");
        return ;
    }
    switch (op)
    {
        case OP_PLUS:
            result = member1 + member2;
            break ;
        case OP_MINUS:
            result = member1 - member2;
            break ;
        case OP_MULT:
            result = member1 * member2;
            break ;
        case OP_DIV:
            result = member1 / member2;
            break ;
        case OP_MOD:
            result = member1 % member2;
            break ;
        case OP_INVALID:
            break ;
    }
    printf("result : %lld\n", result);
}

static void process_expr(char *buf)
{
    long     member1;
    long     member2;
    t_op    op;

    buf = skip_spaces(buf);
    member1 = atoi(buf);
    buf += count_digits(member1);
    buf = skip_spaces(buf);
    op = get_op(buf);
    buf++;
    buf = skip_spaces(buf);
    member2 = atoi(buf);
    buf += count_digits(member2);
    do_calc(member1, op, member2);
}

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
        process_expr(buf);
    }
}