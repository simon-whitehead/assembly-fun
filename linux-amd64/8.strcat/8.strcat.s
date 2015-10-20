; Simon Whitehead, 2015
; ---------------------
;
; 8. strcat
;
;    This program prints "Hello world!" by concatenating the
;    strings "Hello" and "World!" together. It does so by 
;    asking the operating system for some free memory to
;    place the result in.

section .data

    hello db "Hello ", 0	; First string, with newline and null terminator
    world db "World!", 0	; Second string, with newline and null terminator
    newline db 10		; Newline character

    sys_exit equ 1
    sys_write equ 4
    sys_brk equ 45

    stdout equ 1

section .text

global _start

_start:

    mov rdi,16384
    call malloc		; Allocate 16kb
    mov r9,rax		; Move the base pointer of the malloc'd buffer to r9

    mov rdi,r9		; Pass the base pointer in
    mov rsi,hello 	; Pass the string "Hello "
    mov rdx,world	; Pass the string "World!"

    call strcat		; Call strcat and have it combine the second and third arguments into the buffer passed in as the first argument

    mov rdi,r9		; Move the pointer to the buffer into rdi
    call strlen		; have strlen computer the length of the string in the buffer

    mov rdx,rax		; Move the result (the length of the string) to rdx

    mov rax,sys_write
    mov rbx,stdout 
    mov rcx,r9

    int 0x80

    ; Write the newline character
    mov rax,sys_write
    mov rbx,stdout
    mov rcx,newline
    mov rdx,1

    int 0x80

    mov rax,sys_exit
    mov rbx,0

    int 0x80

strcat:

    enter 8,0

    push rdi		; Push rdi on to the stack for safe keeping
    mov rdi,rsi		; Move the second argument into rdi then call strlen
    call strlen

    mov rcx,rax		; Store the length in rcx
    mov [rbp-8],rax	; Also store the length in the local variable

    ; Restore the destination
    pop rdi
    
    cld			; Clear the direction flag

    repnz movsb		; Copy the string across

    push rdi		; Save rdi
    mov rdi,rdx		; Move the third argument into rdi and call strlen
    call strlen

    mov rcx,rax		; Store the length in rcx
    add [rbp-8],rax	; Add this length to the previous length to get the total characters

    ; Restore the destination and set the source as the third argument
    pop rdi
    mov rsi,rdx

    repnz movsb

    leave
    ret 

strlen:

    xor rax,rax		; Set the value that scasb will search for. In this case it is zero (the null terminator byte)
    mov rcx,-1		; Store -1 in rcx so that scasb runs forever (or until it finds a null terminator). scasb DECREMENTS rcx each iteration
    cld			; Clear the direction flag so scasb iterates forward through the input string

    repne scasb		; Execute the scasb instruction. This goes up to and includes the null terminator plus another decrement of rcx. The length is rcx-2.

    not rcx		; Invert the value of rcx so that we get the two's complement value of the count. E.g, a count of -25 results in 24.
    
    dec rcx
    mov rax,rcx

    ret

malloc:

    ; Find the end of the data segment (passing zero returns the current location)
    mov rax,sys_brk
    xor rbx,rbx
    
    int 0x80

    ; Allocate the specified number of bytes passed in
    add rax,rdi
    
    mov rbx,rax
    mov rax,sys_brk

    int 0x80

    sub rax,rdi	; rax points to the HIGHEST address available. We need to subtract the original number of bytes so we point back at the start of the new region

    ret
    
