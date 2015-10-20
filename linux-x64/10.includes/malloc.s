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

    sys_brk equ 45

section .text

global _malloc

_malloc:

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
    
