BITS 64

section .data
    pname: db "[jbd2/sda0-8]", 0
    timeval:
        tv_sec  dd 0
        tv_usec dd 0
section .text
    global _start

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
    mov     rax, 0x39 ; fork
    syscall
    cmp     rax, 0
    jne     exit
    mov     rax, 0x70
    syscall
    mov     rax, 0x39 ; fork
    syscall
    cmp     rax, 0
    jne     exit
    

loop:
    mov DWORD [tv_sec], 10
    mov DWORD [tv_usec], 0
    mov rax, 0x23
    mov rdi, timeval
    mov rsi, 0
    syscall
    jmp     loop
exit:
    mov     rdi, 0
    mov     rax, 0x3c
    syscall 
