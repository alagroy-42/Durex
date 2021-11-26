# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: alagroy- <alagroy-@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2021/04/23 13:46:17 by alagroy-          #+#    #+#              #
#    Updated: 2021/11/26 10:01:18 by alagroy-         ###   ########.fr        #
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

SRC_FILES = main.c payload.c
OBJ_FILES = $(SRC_FILES:.c=.o)
OBJS = $(addprefix $(OBJS_DIR), $(OBJ_FILES))
SRC_SERVICE = service.s server.s auth.s shell.s remote.s
SRCS_SERVICE = $(addprefix $(SRCS_DIR), $(SRC_SERVICE))
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

$(OBJS_DIR)%.o: $(SRCS_DIR)%.c $(HEADERS) Makefile
	$(CC) $(CFLAGS) -o $@ -c $<
	printf "\033[0;32m[$(NAME)] Compilation [$<]                 \r\033[0m"

$(OBJS_DIR)%.o: $(SRCS_DIR)%.s Makefile
	$(NASM) -f elf64 -o $@ $<

	printf "\033[0;32m[$(NAME)] Compilation [$<]                 \r\033[0m"

tiny_service: $(SRCS_SERVICE)
	./scripts/tiny.py $(SRCS_SERVICE)
	printf "\033[0;32m[service] Tinying [OK]\n\033[0;0m"
	$(NASM) -f bin -o tiny_service $(SRCS_DIR)tiny.s
	chmod +x $@
	printf "\033[0;32m[service] Tiny compiled [OK]\n\033[0;0m"

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
