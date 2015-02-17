; Simon Whitehead, 2015
; ---------------------
;
; 10. includes
;
;     This application demonstrates separating code
;     into multiple files for clarity/organisation.
;     Functionally, this application will ask the user
;     for two numbers, add them, then print them to
;     stdout.

section .data

    stdin equ 0
    stdout equ 1
	
    sys_read equ 3
    sys_write equ 4

section .bss

    readline_buffer resb 1024	; A buffer for readline to store its result

section .text

global _print, _readline

_print:

    ; Call the sys_write syscall
    mov rax,sys_write
    mov rbx,stdout
    mov rcx,rdi
    mov rdx,rsi

    int 0x80

    ret

_readline:

    ; Read a line of input from stdin into a 1024 byte buffer
    mov rax,sys_read
    mov rbx,stdin
    mov rcx,readline_buffer
    mov rdx,1024

    int 0x80

    mov rax,readline_buffer

    ret
