; Simon Whitehead, 2015
; ---------------------
;
; 6. strlen
;
;    This program prints "Hello world!" but it figures out the length
;    of the string all by itself.

section .data

    msg db "Hello world!", 10, 0	; The input string - including a newline character

    ; Syscall information
    sys_write equ 4
    sys_exit equ 1

    stdout equ 1

section .text

global _start

_start:

    mov rdi,msg		; Move the string into rdi
    call strlen

    ; print it to stdout
    mov rdx,rax		; strlen returns the length in rax
    mov rax,sys_write
    mov rbx,stdout
    mov rcx,msg

    int 0x80

    ; exit
    mov rax,sys_exit
    mov rbx,0

    int 0x80

strlen:

    xor rax,rax		; Set the value that scasb will search for. In this case it is zero (the null terminator byte)
    mov rcx,-1		; Store -1 in rcx so that scasb runs forever (or until it finds a null terminator). scasb DECREMENTS rcx each iteration
    cld			; Clear the direction flag so scasb iterates forward through the input string

    repne scasb		; Execute the scasb instruction. This leaves rdi pointing at the base of the null terminator.

    not rcx		; Invert the value of rcx so that we get the two's complement value of the count. E.g, a count of -25 results in 24.
    mov rax,rcx		; Move the length of the string into rax

    ret
