BITS 64

extern asm_exit
global _start

section .text

_start:
	mov edx, 0x2
	call asm_exit
