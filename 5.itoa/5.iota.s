; Simon Whitehead, 2015
; ---------------------
;
; 5. itoa
;
;    This program converts numbers into ASCII characters and
;    prints them to stdout.

section .data

    newline db 10

    number dd 1234567890	; The number to print

    ; Syscall information
    sys_write equ 4
    stdout equ 1
    sys_exit equ 1

section .bss

    numbuf resb 10		; A buffer to store our string of numbers in

section .text

global _start

_start:

    mov rax,[number]	; Move the number (123456789) into rax
    call itoa		; call the function

    ; Write the string returned in rax out to stdout
    mov rdx,rcx		; The length is returned in rcx - move it to rdx for the syscall
    mov rcx,rax		; The string pointer is returned in rax - move it to rcx for the syscall
    mov rax,sys_write
    mov rbx,stdout

    int 0x80

    ; Write the newline character to stdout
    mov rax,sys_write
    mov rbx,stdout
    mov rcx,newline
    mov rdx,1
    
    int 0x80

    mov rax,sys_exit
    mov rbx,0

    int 0x80

itoa:

    enter 4,0		; allocate 4 bytes for our local string length counter
    lea r8,[numbuf+10]	; load the end address of the buffer (past the very end)
    mov rcx,10		; divisor
    mov [rbp],dword 0	; rbp will contain 4 bytes representing the length of the string - start at zero

.divloop:
    xor rdx,rdx		; Zero out rdx (where our remainder goes after idiv)
    idiv rcx		; divide rax (the number) by 10 (the remainder is placed in rdx)
    add rdx,0x30	; add 0x30 to the remainder so we get the correct ASCII value
    dec r8		; move the pointer backwards in the buffer
    mov byte [r8],dl	; move the character into the buffer
    inc dword [rbp]	; increase the length
    
    cmp rax,0		; was the result zero?
    jnz .divloop	; no it wasn't, keep looping

    mov rax,r8		; r8 now points to the beginning of the string - move it into rax
    mov rcx,[rbp]	; rbp contains the length - move it into rcx

    leave		; clean up our stack
    ret
