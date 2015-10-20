; Simon Whitehead, 2015
; ---------------------
;
; 3. Local variables
;
;    This program prints "Hello world!" to stdout
;    by pushing a global pointer onto the stack
;    of a called function. I am not sure if using
;    the stack pointer directly like this is okay..
;    - I assume its fine. I can't find documentation
;    that says it isn't.

section .data

    msg db "Hello world!", 10, 0	; Message to print

    sys_write equ 4
    sys_exit equ 1

    stdout equ 1

section .text

global _start

_start:

    call print

    mov rax,sys_exit
    mov rbx,0

    int 0x80

print:

    enter 8,0		; Make room for local pointer (64bit .. 8 bytes)

    mov qword rsp,msg	; Move msg address into the stack
    mov rax,sys_write
    mov rbx,stdout
    mov rcx,rsp		; Write whats at this address in the stack
    mov rdx,13

    int 0x80

    leave
    ret
