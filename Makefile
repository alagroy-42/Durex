# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: alagroy- <alagroy-@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2021/04/23 13:46:17 by alagroy-          #+#    #+#              #
#    Updated: 2021/11/24 09:13:48 by alagroy-         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME = Durex

CC = gcc
NASM = /usr/bin/nasm
CFLAGS = -g #-Wall -Werror -Wextra -g #-fsanitize=address
CFLAGS += $(addprefix -I , $(INCLUDES))

INCLUDES_DIR = ./includes/
SRCS_DIR = ./srcs/
INCLUDES = $(INCLUDES_DIR)
OBJS_DIR = ./.objs/

SRC_FILES = main.c 
OBJ_FILES = $(SRC_FILES:.c=.o)
OBJS = $(addprefix $(OBJS_DIR), $(OBJ_FILES))
SRC_SERVICE = service.s server.s auth.s shell.s remote.s
OBJ_SERVICE = $(SRC_SERVICE:.s=.o)
OBJS_SERVICE = $(addprefix $(OBJS_DIR), $(OBJ_SERVICE))
HEADERS = $(INCLUDES_DIR)durex.h

all: $(OBJS_DIR) $(NAME)

$(NAME): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS)
	printf "\n\033[0;32m[$(NAME)] Linking [OK]\n\033[0;0m"

service: $(OBJS_SERVICE) Makefile
	ld -o service $(OBJS_SERVICE) # -s
	printf "\n\033[0;32m[service] Linking [OK]\n\033[0;0m"

tiny:
	./scripts/tiny.py $(SRC_SERVICE)

$(OBJS_DIR)%.o: $(SRCS_DIR)%.c $(HEADERS) Makefile
	$(CC) $(CFLAGS) -o $@ -c $<
	printf "\033[0;32m[$(NAME)] Compilation [$<]                 \r\033[0m"

$(OBJS_DIR)%.o: $(SRCS_DIR)%.s Makefile
	$(NASM) -f elf64 -o $@ $<

	printf "\033[0;32m[$(NAME)] Compilation [$<]                 \r\033[0m"

$(OBJS_DIR):
	mkdir -p $@

clean:
	$(RM) -Rf $(OBJS_DIR)
	printf "\033[0;31m[$(NAME)] Clean [OK]\n"

fclean: clean
	$(RM) $(NAME)
	printf "\033[0;31m[$(NAME)] Fclean [OK]\n"

re: fclean all

.PHONY: clean re fclean all
.SILENT:
