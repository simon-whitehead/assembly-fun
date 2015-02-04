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

%include "io.s"
%include "strings.s"
%include "malloc.s"

section .data

    sys_exit equ 1

    ; Set up some constants we will use throughout the application

    welcome_msg db "This program will add two numbers together.", 10
    welcome_msg.len equ $-welcome_msg

    newline_spacer db 10, 10

    ; Prompts for the user
    prompt_one db "Enter your first number: ", 0
    prompt_one.len equ $-prompt_one

    prompt_two db "Enter your second number: ", 0
    prompt_two.len equ $-prompt_two

    ; The response
    answer db "The sum of the numbers is: ", 0

section .text

global _start

_start:

    enter 16,0

    call _welcome

    mov rdi,prompt_one
    mov rsi,prompt_one.len
    call _prompt

    mov [rbp-8],rax

    mov rdi,prompt_two
    mov rsi,prompt_two.len
    call _prompt

    add rax,[rbp-8]

    mov rdi,rax
    call _itoa
    push rax

    ; allocate some memory

    mov rdi,16384
    call _malloc

    mov r9,rax	; Store its base

    mov rdi,r9
    mov rsi,answer
    pop rdx
    call _strcat

    mov rdi,r9
    call _strlen

    mov rdi,r9
    mov rsi,rax
    call _print

    mov rdi,newline_spacer
    mov rsi,2
    call _print

;    mov [rbp-16],rax
;    mov rdi,rax
;    call _strlen
;
;    mov rdi,[rbp-16]
;    mov rsi,rax
;    call _print

    call _exit

    leave
    ret

_welcome:

    mov rdi,welcome_msg
    mov rsi,welcome_msg.len

    call _print

    mov rdi,newline_spacer
    mov rsi,2

    call _print

    ret

_prompt:

    call _print
    call _readline
    
    mov rdi,rax
    call _atoi

    ret

_exit:

    mov rax,sys_exit
    mov rbx,0

    int 0x80

    ret
