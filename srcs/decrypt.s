BITS 64

segment .text
	global decrypt

decrypt:
    lea     rdi, [rel routine]
    xor     rsi, rsi
    xor     rdx, rdx
    xor     eax, eax
    add     rsi, 0x1000
    add     rdx, 0x1 | 0x2 | 0x4 ; PROT_READ | PROT_WRITE | PROT_EXEC
    add     eax, 0xa ; mprotect
    syscall
	mov rcx, 42 ; text_size
	mov rsi, 32 ; key_size 
	lea rdx, [rel routine] ; text
	xor r8, r8 ; key_index
	xor rax, rax ; key_offset
	jmp key
back_key:
	pop rdi ; key
routine:
	mov al, byte [rdi + r8]
	add al, ah
	xor [rdx], al
	inc rdx
	inc r8
	cmp r8, rsi
	jne loopinstr
	add ah, byte 42
	xor r8, r8
loopinstr:
	loop routine
	jmp 42

key:
	call back_key
	key_str: db ''