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
    sys_exit equ 1
    sys_write equ 4

    ; Streams
    stdout equ 1

    ; Constants
    BUFFER_SIZE equ 10

section .bss

    numbuf resb BUFFER_SIZE		; A buffer to store our string of numbers in

section .text

global _start

_start:

    mov rdi,[number]	; Move the number (123456789) into rax
    call itoa		; call the function

    ; Write the string returned in rax out to stdout
    mov rdi,rax		; The string pointer is returned in rax - move it to rdi for the function call
    mov rsi,rcx
    call print

    ; Write the newline character to stdout
    mov rdi,newline
    mov rsi,1
    call print
    
   ; Exit
    mov rax,sys_exit
    mov rbx,0

    int 0x80

; Args: (rdi: char*, rsi: int)
print:
    
    mov rax,sys_write
    mov rbx,stdout
    mov rcx,rdi
    mov rdx,rsi

    int 0x80

    ret

itoa:

    push rbp		
    mov rbp,rsp
    sub rsp,4		; allocate 4 bytes for our local string length counter

    mov rax,rdi		; Move the passed in argument to rax
    lea rdi,[numbuf+10]	; load the end address of the buffer (past the very end)
    mov rcx,10		; divisor
    mov [rbp-4],dword 0	; rbp-4 will contain 4 bytes representing the length of the string - start at zero

.divloop:
    xor rdx,rdx		; Zero out rdx (where our remainder goes after idiv)
    idiv rcx		; divide rax (the number) by 10 (the remainder is placed in rdx)
    add rdx,0x30	; add 0x30 to the remainder so we get the correct ASCII value
    dec rdi		; move the pointer backwards in the buffer
    mov byte [rdi],dl	; move the character into the buffer
    inc dword [rbp-4]	; increase the length
    
    cmp rax,0		; was the result zero?
    jnz .divloop	; no it wasn't, keep looping

    mov rax,rdi		; rdi now points to the beginning of the string - move it into rax
    mov rcx,[rbp-4]	; rbp-4 contains the length - move it into rcx

    leave		; clean up our stack
    ret
