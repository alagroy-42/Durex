BITS 64

%define BUFF_SIZE 0x20

section .text
    global  auth
    global  strcmp

encrypt_pass:
    xor     rbx, rbx
crypt:
    mov     al, [rdi]
    cmp     al, 0
    je      end_crypt
    inc     rbx
    add     BYTE [rdi], bl
    inc     rdi
    jmp     crypt
end_crypt:
    ret

strcmp:
    mov     al, [rdi]
    mov     bl, [rsi]
    cmp     al, bl
    jne     nequ
    inc     rdi
    inc     rsi
    cmp     al, 0
    jne     strcmp
    xor     al, al
    jmp     endcmp
nequ:
    xor     al, al
    add     al, 1
endcmp:
    ret

auth:
    push    rbp
    mov     rbp, rsp
    sub     rsp, BUFF_SIZE + 0x10
auth_loop:
    mov     DWORD [rsp], edi
    xor     rax, rax
    mov     QWORD [rbp - 0x8], rax
    mov     QWORD [rbp - 0x10], rax
    mov     QWORD [rbp - 0x18], rax
    mov     QWORD [rbp - 0x20], rax
    lea     rsi, [rel prompt_pass]
    mov     rdx, prompt_pass.len
    add     al, 0x1 ; write
    syscall
    mov     edi, [rsp]
    lea     rsi, [rbp - BUFF_SIZE]
    xor     edx, edx
    add     edx, BUFF_SIZE - 1
    xor     eax, eax ; read
    syscall
    cmp     eax, 0
    jle     returnctrlc
    xor     dl, dl
    mov     BYTE [rbp - BUFF_SIZE + rax], dl
    mov     r8, rax
    lea     rdi, [rbp - BUFF_SIZE]
    call    encrypt_pass
    lea     rdi, [rbp - BUFF_SIZE]
    lea     rsi, [rel password]
    call    strcmp
    cmp     eax, 0
    jne     denied
    mov     edi, [rsp]
    lea     rsi, [rel auth_succ]
    mov     edx, auth_succ.len
    xor     eax, eax
    inc     eax ; write
    syscall
    xor     eax, eax
    jmp     end_auth
denied:
    mov     edi, [rsp]
    lea     rsi, [rel auth_den]
    mov     rdx, auth_den.len
    xor     eax, eax
    inc     eax ; write
    syscall
    jmp     auth_loop
returnctrlc:
    xor     eax, eax
    inc     eax
end_auth:
    leave
    ret

    prompt_pass: db "Password: ", 0
        .len: equ $ - prompt_pass
    password: db "sqrxwuv|=<?>", 23, 0
        .len: equ $ - password
    auth_den: db "Authentication denied !", 10, 0
        .len: equ $ - auth_den
    auth_succ: db "Authentication successful !", 10, 0
        .len: equ $ - auth_succ