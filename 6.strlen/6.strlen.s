; Simon Whitehead, 2015
; ---------------------
;
; 6. strlen
;
;    This program prints "Hello world!" but it figures out the length
;    of the string all by itself. This can be done wish scasb too (which I
;    may also implement as an example), but it is actually quicker to
;    handle roll this than to use the scasX functions.

section .data

    msg db "Hello world!", 10, 0

    ; Syscall information
    sys_write equ 4
    stdout equ 1
    sys_exit equ 1

section .text

global _start

_start:

    mov rax,msg		; Move the string into rax
    call strlen

    ; print it to stdout
    mov rdx,rax		; strlen returns the length in rax
    mov rax,sys_write
    mov rbx,stdout
    mov rcx,msg

    int 0x80

    mov rax,sys_exit
    mov rbx,0

    int 0x80

strlen:

    enter 4,0		; Setup the local stack

    lea r8,[rax]	; Obtain a pointer to the start of the string
    mov qword [rbp-4],0 ; Initialize our counter to zero

.searchloop:
    
    cmp byte [r8],0x00	; Is this a null byte?
    je .endloop		; It is .. end it

    inc r8 		; Its not a null byte .. increment the pointer to the string to move to the next character
    inc qword [rbp-4]	; .. and increase the value in our local counter

    jmp .searchloop	; Jump up to the loop and try the next character

.endloop:

    mov rax,[rbp-4]	; Store the value of our local counter in rax

    leave
    ret
