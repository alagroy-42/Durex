# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: alagroy- <alagroy-@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2021/04/23 13:46:17 by alagroy-          #+#    #+#              #
#    Updated: 2021/11/09 17:27:30 by vscode           ###   ########.fr        #
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
SRC_SERVICE = service.c
OBJ_SERVICE_FILES = $(SRC_SERVICE:.c=.o)
OBJS_SERVICE = $(addprefix $(OBJS_DIR), $(OBJ_SERVICE_FILES))
SERVICE_DIR = $(SRCS_DIR)service/
HEADERS_SERVICE = $(INCLUDES_DIR)service.h

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

$(OBJS_DIR):
	mkdir -p $@

service: $(OBJS_DIR) $(LIBFT) $(OBJS_SERVICE) $(HEADERS_SERVICE) Makefile
	$(CC) $(CFLAGS) -o $@ $(OBJS_SERVICE) -L $(LIB_DIR) -lft 
	printf "\n\033[0;32m[service] Linking [OK]\n\033[0;0m"

clean:
	$(RM) -Rf $(OBJS_DIR)
	make -C $(LIB_DIR) $@
	printf "\033[0;31m[$(NAME)] Clean [OK]\n"

fclean: clean
	$(RM) $(NAME)
	printf "\033[0;31m[$(NAME)] Fclean [OK]\n"

re: fclean all

.PHONY: clean re fclean all
.SILENT:
