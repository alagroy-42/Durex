section .data
    shell: db "You will get a shell soon !!", 10, 0
        .len: equ $ - shell
    
section .text
    global shell_mode

shell_mode:
    push    rbp
    mov     rbp, rsp
    lea     rsi, [rel shell]
    mov     rdx, shell.len
    mov     rax, 0x1 ; write
    syscall
    leave
    ret
