; Simon Whitehead, 2015
; ---------------------
;
; 6. strlen
;
;    This program prints "Hello world!" but it figures out the length
;    of the string all by itself.
;
;    The strlen function is a hand rolled function to find the null
;    terminator. The strlen_scasb function uses the scasb instruction
;    to search for the null terminator.

section .data

    msg db "Hello world!", 10, 0	; The input string - including a newline character

    ; Syscall information
    sys_write equ 4
    stdout equ 1
    sys_exit equ 1

section .text

global _start

_start:

    mov rax,msg		; Move the string into rax
    call strlen

    ; print it to stdout
    mov rdx,rax		; strlen returns the length in rax
    mov rax,sys_write
    mov rbx,stdout
    mov rcx,msg

    int 0x80

    push msg
    call strlen_scasb

    mov rdx,rax
    mov rax,sys_write
    mov rbx,stdout
    mov rcx,msg

    int 0x80

    mov rax,sys_exit
    mov rbx,0

    int 0x80


; This version of strlen manually loops over 
; the input string to find the null terminator

strlen:

    enter 4,0		; Setup the local stack

    lea r8,[rax]	; Obtain a pointer to the start of the string
    mov qword [rbp-4],0 ; Initialize our counter to zero

.searchloop:
    
    cmp byte [r8],0x00	; Is this a null byte?
    je .endloop		; It is .. end it

    inc r8 		; Its not a null byte .. increment the pointer to the string to move to the next character
    inc qword [rbp-4]	; .. and increase the value in our local counter

    jmp .searchloop	; Jump up to the loop and try the next character

.endloop:

    mov rax,[rbp-4]	; Store the value of our local counter in rax

    leave
    ret

; This version of strlen uses the scasb instruction
; to scan the input string for the null terminator.
; It also utilises the stack so we can allow the scasb
; operator to use the rax register without fiddling.

strlen_scasb:

    enter 0,0		; Initialize the stack frame nicely for us

    xor rax,rax		; Set the value that scasb will search for. In this case it is zero (the null terminator byte)
    mov rcx,-1		; Store -1 in rcx so that scasb runs forever (or until it finds a null terminator). scasb DECREMENTS rcx each iteration
    mov rdi,[rbp+16]	; Move the input string on the stack to rdi
    cld			; Clear the direction flag so scasb iterates forward through the input string

    repne scasb		; Execute the scasb instruction. This goes up to and includes the null terminator plus another decrement of rcx. The length is rcx-2.

    not rcx		; Invert the value of rcx so that we get the two's complement value of the count. E.g, a count of -25 results in 24.
    lea rax,[rcx-1]	; The above inversion includes the null terminator, so return the count-1 to strip it

    leave
    ret
