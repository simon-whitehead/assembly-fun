; Simon Whitehead, 2015
; ---------------------
;
; 9. atoi
;
;    This program prints "Equal" or "Not equal"
;    depending on whether the numerical value
;    contained in a string adds up to a predetermined
;    sum.

section .data

    equal db "Equal", 10, 0
    equal.len equ $-equal

    notequal db "Not equal", 10, 0
    notequal.len equ $-notequal

    sum equ 123
    base equ 100

    test_one db "23",0		; Should pass
    test_two db "32",0		; Should fail

    sys_write equ 4
    sys_exit equ 1
    
    stdout equ 1

section .text

global _start

_start:

    lea rdi,[test_one]	; Move our first test string into rdi
    call atoi

    add rax,base	; Add 100 to the result
    cmp rax,sum		; Should equal 123
    jne .notequal

    mov rax,sys_write
    mov rbx,stdout
    mov rcx,equal
    mov rdx,equal.len

    int 0x80

    lea rdi,[test_two]
    call atoi

    add rax,base	; Add 100 to the result
    cmp rax,sum		; Will equal 132 .. but not 123
    jne .notequal


    ; Add the "equal" code anyway .. just to make sure (but this second print should never be "Equal")
    mov rax,sys_write
    mov rbx,stdout
    mov rcx,equal
    mov rdx,equal.len

    int 0x80

    mov rax,sys_exit
    mov rbx,0

    int 0x80
    
    
.notequal:

    mov rax,sys_write
    mov rbx,stdout
    mov rcx,notequal
    mov rdx,notequal.len

    int 0x80

    mov rax,sys_exit
    mov rbx,0

    int 0x80

atoi:

    push rbp
    mov rbp,rsp
    sub rsp,16

    xor rcx,rcx		; Zero out our counter

    mov rbx,10		; Setup the multiplier

.multiplyLoop:
    mov dl,[rdi+rcx]	; Select the character
    sub dl,0x30		; Subtract ASCII 48 from the character so that it equals its actual value
    mov [rbp-8],rdx	; Preserve rdx
    mul rbx		; Multiply the current result by 10
    mov rdx,[rbp-8]	; Bring rdx back
    add al,dl		; Add the result to the value in al
    
    inc rcx		; Increase the counter
    cmp byte [rdi+rcx],0 ; Have we reached a null terminator?
    jne .multiplyLoop	 ; If not.. jump back and continue on

    ; The result will be in in rax

    leave
    ret
