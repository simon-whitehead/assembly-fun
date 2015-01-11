; Simon Whitehead, 2015
; ---------------------
;
; 4. Read input
;
;    This program echos what the user types into
;    the console back to them.

section .data

    sys_read equ 3
    sys_write equ 4
    stdin equ 0
    stdout equ 1
    sys_exit equ 1

section .bss

    buffer resb 1024	; max of 1024 characters

section .text

global _start

_start:

    ; Call sys_read and store the result in buffer
    mov rax,sys_read
    mov rbx,stdin
    mov rcx,buffer
    mov rdx,1024

    int 0x80

    ; Call sys_write and print the buffer
    mov rax,sys_write
    mov rbx,stdout
    mov rcx,buffer
    mov rdx,1024

    int 0x80

    ; Exit
    mov rax,sys_exit
    mov rbx,0

    int 0x80
