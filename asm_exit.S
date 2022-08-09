global asm_exit

section	.text

asm_exit:
	mov eax, 0x1
	int 0x80
