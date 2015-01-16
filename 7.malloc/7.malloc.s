; Simon Whitehead, 2015
; ---------------------
;
; 7. malloc
;
;    This program prints "Hello World!" but it
;    points to a string that is allocated in the
;    virtual memory of the process at runtime. It
;    does this by calling sys_brk to ask the OS
;    to allocate some more memory for the process
;    and return a pointer to the memory. It does not
;    handle any potential errors from sys_brk.

section .data

    sys_brk equ 45
    sys_write equ 4
    
    stdout equ 1
    sys_exit equ 1

section .text

global _start

_start:

    ; Allocate 16 bytes
    push 16
    call malloc

    call create_string	; helper function to create the string in the buffer located at rax

    ; Write the dynamically allocated string to stdout

    mov rcx,rax
    mov rax,sys_write
    mov rbx,stdout
    mov rdx,13		; Note, could call the strlen function defined in #6 here

    int 0x80

    ; Exit
    mov rax,sys_exit
    mov rbx,0

    int 0x80

malloc:

    ; Find the end of the data segment (passing zero returns the current location)
    mov rax,sys_brk
    xor rbx,rbx
    
    int 0x80

    ; Allocate the specified number of bytes passed in
    add rax,[rsp+16]
    
    mov rbx,rax
    mov rax,sys_brk

    int 0x80

    sub rax,[rsp+16]	; rax points to the HIGHEST address available. We need to subtract the original number of bytes so we point back at the start of the new region

    ret

create_string:

    mov [rax],byte 72	; H

    inc rax
    mov [rax],byte 101	; e

    inc rax
    mov [rax],byte 108	; l

    inc rax
    mov [rax],byte 108	; l

    inc rax
    mov [rax],byte 111	; o

    inc rax
    mov [rax],byte 32	; (space)

    inc rax
    mov [rax],byte 87	; W

    inc rax
    mov [rax],byte 111	; o

    inc rax
    mov [rax],byte 114	; r

    inc rax
    mov [rax],byte 108	; l

    inc rax
    mov [rax],byte 100	; d

    inc rax
    mov [rax],byte 33	; !

    inc rax
    mov [rax],byte 10	; NewLine

    inc rax
    mov [rax],byte 0	; Null terminator

    sub rax,13

    ret
