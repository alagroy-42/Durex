%define BUFF_SIZE 0x20

section .rodata
    prompt_pass: db "Password: ", 0
        .len: equ $ - prompt_pass
    password: db "sqrxwuv|=<?>", 23, 0
        .len: equ $ - password
    auth_den: db "Authentication denied !", 10, 0
        .len: equ $ - auth_den
    auth_succ: db "Authentication successful !", 10, 0
        .len: equ $ - auth_succ

section .text
    global  auth
    global  strcmp

encrypt_pass:
    push    rbp
    mov     rbp, rsp
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
    leave
    ret

strcmp:
    push    rbp
    mov     rbp, rsp
compare:
    mov     al, [rdi]
    mov     bl, [rsi]
    cmp     al, bl
    jne     nequ
    inc     rdi
    inc     rsi
    cmp     al, 0
    jne     compare
    mov     rax, 0
    jmp     endcmp
nequ:
    mov     rax, 1
endcmp:
    leave
    ret

auth:
    push    rbp
    mov     rbp, rsp
    sub     rsp, BUFF_SIZE + 0x10
    mov     DWORD [rsp], edi
    mov     QWORD [rbp - 0x8], 0
    mov     QWORD [rbp - 0x10], 0
    mov     QWORD [rbp - 0x18], 0
    mov     QWORD [rbp - 0x20], 0
    lea     rsi, [rel prompt_pass]
    mov     rdx, prompt_pass.len
    mov     rax, 0x1 ; write
    syscall
    mov     edi, [rsp]
    lea     rsi, [rbp - BUFF_SIZE]
    mov     rdx, BUFF_SIZE - 1
    mov     rax, 0 ; read
    syscall
    mov     BYTE [rbp - BUFF_SIZE + rax], 0
    mov     r8, rax
    lea     rdi, [rbp - BUFF_SIZE]
    call    encrypt_pass
    lea     rdi, [rbp - BUFF_SIZE]
    lea     rsi, [rel password]
    call    strcmp
    cmp     rax, 0
    jne     denied
    mov     edi, [rsp]
    lea     rsi, [rel auth_succ]
    mov     rdx, auth_succ.len
    mov     rax, 0x1 ; write
    syscall
    mov     rax, 0x0
    jmp     end_auth
denied:
    mov     edi, [rsp]
    lea     rsi, [rel auth_den]
    mov     rdx, auth_den.len
    mov     rax, 0x1 ; write
    syscall
    mov     rax, 0x1
end_auth:
    leave
    ret