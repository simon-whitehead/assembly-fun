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

    enter 16,0			; Allocate 16 bytes of stack space

    call _welcome		; Call the welcome function

    mov rdi,prompt_one		; Push our prompts onto registers and call the prompt function
    mov rsi,prompt_one.len
    call _prompt

    mov [rbp-8],rax		; Store what the user entered on the stack

    mov rdi,prompt_two		; Prompt for the second number
    mov rsi,prompt_two.len
    call _prompt

    add rax,[rbp-8]		; Add the first result to the result of the second prompt

    mov rdi,rax			; Call itoa to convert the number to a string
    call _itoa
    push rax			; Store this for later

    ; allocate some memory

    mov rdi,16384
    call _malloc

    mov r9,rax	; Store its base

    ; Concatenate the answer prompt with the sum of the entered numbers
    mov rdi,r9
    mov rsi,answer
    pop rdx
    call _strcat

    ; Calculate the total length of the resulting string
    mov rdi,r9
    call _strlen

    ; Print the result to the screen
    mov rdi,r9
    mov rsi,rax
    call _print

    ; Add a space between the answer and the end
    mov rdi,newline_spacer
    mov rsi,2
    call _print

    ; Exit
    call _exit

    leave		; Restore the stack
    ret

_welcome:

    ; Print the welcome message to the screen
    mov rdi,welcome_msg
    mov rsi,welcome_msg.len

    call _print

    ; Add a space underneath
    mov rdi,newline_spacer
    mov rsi,2

    call _print

    ret

_prompt:

    call _print		; Print the prompt that was passed in
    call _readline	; Read the user's input
    
    ; Call atoi to convert the users input to a number and return the number in rax
    mov rdi,rax
    call _atoi

    ret

_exit:

    ; execute the exit interrupt
    mov rax,sys_exit
    mov rbx,0

    int 0x80

    ret
