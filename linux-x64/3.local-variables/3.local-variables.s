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
    msg.len equ $-msg

    sys_write equ 4
    sys_exit equ 1

    stdout equ 1

section .text

global _start

_start:

    mov rdi,msg		; Move msg into rdi
    mov rsi,msg.len	; Move the length of msg into rsi
    call print

    mov rax,sys_exit
    mov rbx,0

    int 0x80

print:

    push rbp
    mov rbp,rsp
    sub rsp,16		; Allocate space for two local variables (2*8, one pointer and one integer)

    mov [rbp-8],rdi	; Store our string pointer
    mov [rbp-16],rsi	; Store our integer

    mov rax,sys_write
    mov rbx,stdout
    mov rcx,[rbp-8]		; Local string pointer
    mov rdx,[rbp-16]		; Local string length integer

    int 0x80

    leave
    ret
