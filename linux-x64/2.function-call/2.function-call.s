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
    msg1.len equ $-msg1		; Length of the first string

    msg2 db "world!", 10, 0	; The second string to print
    msg2.len equ $-msg2		; Length of the second string

    sys_write equ 4		; long sys_write(unsigned int fd, const char __user *buf, size_t count);
    sys_exit equ 1

    stdout equ 1

section .text

global _start

_start:

    mov rdi,msg1
    mov rsi,msg1.len
    call .write_with_register

    push msg2.len
    push msg2
    call .write_with_stack

    mov rax,sys_exit
    mov rbx,0

    int 0x80

; Args: (rdi: char*, rsi: int)
.write_with_register:

    ; This is straight forward

    mov rax,sys_write
    mov rbx,stdout
    mov rcx,rdi
    mov rdx,rsi

    int 0x80

    ret

; Args: (char*, int)
.write_with_stack:

    ; Preserve the stack pointer .. just to be safe (not technically needed since we don't alter the stack in this routine)
    push rbp
    mov rbp,rsp

    mov rax,sys_write
    mov rbx,stdout
    mov rcx,[rbp+16]		; First argument on the stack starts at +16 bytes (+8 for 32-bit - +0 = SP, +4 = return address, +8 = argument start)
    mov rdx,[rbp+24]		; Second argument is 8 bytes later

    pop rbp			; Restore the stack pointer

    int 0x80

    ret
