# Reusable x86_64 assembly code

This simple guide will describe how to store assembly functions and code in relocatable files and reuse them in executable binaries.
The tutorial is written with following characteristics and environment in mind:

  - Linux OS
  - x86_64 assembly
  - Intel syntax

## Write a reusable exit function

For the purpose of the tutorial we write a simple function invoking exit syscall, we are sure this one will be used a lot.

```
; 

global asm_exit     ; declare the symbol global to allow relocation

section	.text

asm_exit:           ; our function invoking sysexit
	mov eax, 0x1
	int 0x80

```

create the relocatable object file:

`nasm -f elf64 asm_exit.S`

Show its properties:

```
file asm_exit.o

asm_exit.o: ELF 64-bit LSB relocatable, x86-64, version 1 (SYSV), not stripped
```

## Write main code calling external function

Here is our main code declaring the symbol for our function as external, and invoking it with `call` instruction. 

```
extern asm_exit   ; specify our function symbol as external
global _start

section .text

_start:
	mov edx, 0x2
	call asm_exit   ; call externally defined asm_exit function

```

Now we need to produce object file from this assembly source:

`nasm -f elf64 main.S`

```
file main.o

main.o: ELF 64-bit LSB relocatable, x86-64, version 1 (SYSV), not stripped
```

Look at relocation entries, this will tell the linker to recompute the address of `asm_exit` function when this file is turned into an executable.

```
readelf main.o --relocs

Relocation section '.rela.text' at offset 0x2a0 contains 1 entry:
  Offset          Info           Type           Sym. Value    Sym. Name + Addend
000000000006  000300000002 R_X86_64_PC32     0000000000000000 asm_exit - 4
```

## Create an executable

Let's produce an executable binary and verify it correctly make use of external defined functions:

`ld -o main asm_exit.o main.o`

```
main: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, not stripped
```

And finally let's execute it:

```
./main
```