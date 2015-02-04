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

section .bss

    itoa_buffer resb 10

section .text

global _atoi, _itoa, _strlen

_atoi:

    push rbp
    mov rbp,rsp
    sub rsp,16

    xor rcx,rcx		; Zero out our counter
    xor rax,rax
    mov rbx,10		; Setup the multiplier

.multiplyLoop:
    mov dl,[rdi+rcx]	; Select the character
    sub dl,0x30		; Subtract ASCII 48 from the character so that it equals its actual value
    mov [rbp-8],rdx	; Preserve rdx
    mul rbx		; Multiply the current result by 10
    mov rdx,[rbp-8]	; Bring rdx back
    add al,dl		; Add the result to the value in al
    
    inc rcx		; Increase the counter

    cmp byte [rdi+rcx],32 ; Have we reached a non-printable character?
    jge .multiplyLoop	 ; If not.. jump back and continue on

    ; The result will be in in rax

    leave
    ret

_itoa:

    enter 4,0		; allocate 4 bytes for our local string length counter
    lea r8,[itoa_buffer+10]	; load the end address of the buffer (past the very end)
    mov byte [r8], 0x00		; Store a null terminator
    mov rcx,10		; divisor
    mov [rbp-4],dword 0	; rbp-4 will contain 4 bytes representing the length of the string - start at zero

.divloop:
    xor rdx,rdx		; Zero out rdx (where our remainder goes after idiv)
    idiv rcx		; divide rax (the number) by 10 (the remainder is placed in rdx)
    add rdx,0x30	; add 0x30 to the remainder so we get the correct ASCII value
    dec r8		; move the pointer backwards in the buffer
    mov byte [r8],dl	; move the character into the buffer
    inc dword [rbp-4]	; increase the length
    
    cmp rax,0		; was the result zero?
    jnz .divloop	; no it wasn't, keep looping

    mov rax,r8		; r8 now points to the beginning of the string - move it into rax
    mov rcx,[rbp-4]	; rbp-4 contains the length - move it into rcx

    leave		; clean up our stack
    ret

_strlen:

    enter 0,0		; Initialize the stack frame nicely for us

    xor rax,rax		; Set the value that scasb will search for. In this case it is zero (the null terminator byte)
    mov rcx,-1		; Store -1 in rcx so that scasb runs forever (or until it finds a null terminator). scasb DECREMENTS rcx each iteration
    cld			; Clear the direction flag so scasb iterates forward through the input string

    repne scasb		; Execute the scasb instruction. This goes up to and includes the null terminator plus another decrement of rcx. The length is rcx-2.

    not rcx		; Invert the value of rcx so that we get the two's complement value of the count. E.g, a count of -25 results in 24.
    lea rax,[rcx-1]	; The above inversion includes the null terminator, so return the count-1 to strip it

    leave
    ret

_strcat:

    enter 8,0

    push rdi		; Push rdi on to the stack for safe keeping
    mov rdi,rsi		; Move the second argument into rdi then call strlen
    call _strlen

    mov rcx,rax		; Store the length in rcx
    mov [rbp-8],rax	; Also store the length in the local variable

    ; Restore the destination
    pop rdi
    
    cld			; Clear the direction flag

    repnz movsb		; Copy the string across

    push rdi		; Save rdi
    mov rdi,rdx		; Move the third argument into rdi and call strlen
    call _strlen

    mov rcx,rax		; Store the length in rcx
    add [rbp-8],rax	; Add this length to the previous length to get the total characters

    ; Restore the destination and set the source as the third argument
    pop rdi
    mov rsi,rdx

    repnz movsb

    leave
    ret 

