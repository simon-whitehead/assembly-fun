; Simon Whitehead, 2015
; ---------------------
;
; 2. Function calls
;
;    This program prints "Hello world!" to stdout
;    by calling two functions, then exits. One function
;    call uses the stack, the other uses registers

section .data

    msg1 db "Hello ", 0		; The first string to print,
    msg2 db "world!", 10, 0	; The second string to print

    sys_write equ 4		; long sys_write(unsigned int fd, const char __user *buf, size_t count);
    sys_exit equ 1

    stdout equ 1

section .text

global _start

_start:

    mov rcx,msg1
    call .write_with_register

    push msg2
    call .write_with_stack

    mov rax,sys_exit
    mov rbx,0

    int 0x80

.write_with_register:

    ; This is straight forward

    mov rax,sys_write
    mov rbx,stdout
    mov rdx,6

    int 0x80

    ret

.write_with_stack:

    ; Preserve the stack pointer .. just to be safe (not technically needed since we don't alter the stack in this routine)
    push rbp
    mov rbp,rsp

    mov rcx,[rbp+16]		; First argument on the stack starts at +16 bytes (+8 for 32-bit - +0 = SP, +4 = return address, +8 = argument start)

    mov rax,sys_write
    mov rbx,stdout
    mov rdx,7

    pop rbp			; Restore the stack pointer

    int 0x80

    ret
