; Simon Whitehead, 2015
; ---------------------
;
; 1. Hello world
;
;    This program prints "Hello world!" to stdout
;    then exits

section .data

    msg db "Hello world!", 10, 0	; The string to print

    sys_write equ 4			; long sys_write(unsigned int fd, const char __user *buf, size_t count);
    sys_exit equ 1

    stdout equ 1

section .text

global _start

_start:

    mov rax,sys_write	; syscall
    mov rbx,stdout	; fd
    mov rcx,msg		; buf
    mov rdx,13    	; count

    int 0x80

    mov rax,sys_exit

    int 0x80
