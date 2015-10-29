; Simon Whitehead, 2015
; ---------------------
;
; 5. itoa
;
;    This program converts numbers into ASCII characters and
;    prints them to stdout.

; Windows APIs

; GetStdHandle
; ------------
; HANDLE WINAPI GetStdHandle(
;     _In_ DWORD nStdHandle
; ); 
extern GetStdHandle

; WriteFile
; ------------
; BOOL WINAPI WriteFile(
;   _In_        HANDLE       hFile,
;   _In_        LPCVOID      lpBuffer,
;   _In_        DWORD        nNumberOfBytesToWrite,
;   _Out_opt_   LPDWORD      lpNumberOfBytesWritten,
;   _Inout_opt_ LPOVERLAPPED lpOverlapped
; );
extern WriteFile

; ExitProcess
; -----------
; VOID WINAPI ExitProcess(
;     _In_ UINT uExitCode
; );
extern ExitProcess

global start

section .data

    STD_OUTPUT_HANDLE	equ -11
    NULL		equ 0

    number		dd 1234567890

    BUFFER_SIZE		equ 10

section .bss
    empty resd 1
    numbuf resb BUFFER_SIZE

section .text

start:

    ; Allocate some Shadow Space
    sub rsp,0x28

    ; Put the number in rdi
    mov rcx,[number]
    call itoa

    ; The order of the two below instructions is important. RCX
    ; contains the length of the string returned from itoa, but
    ; its also a requirement that the first argument to write
    ; be passed via rcx. So we need to move rcx in to rdx before
    ; we overwrite rcx with rax.
    mov rdx,rcx
    lea rcx,[rax]
    call write

    mov rcx,NULL
    call ExitProcess

    add rsp,0x28

    ret

write:

    push rbp
    mov rbp,rsp
    ; Allocate shadow space for the WinAPI calls and a
    ; local variable. (32 + 8 (return address) + 8 (5th argument to
    ; WriteFile) + 8 (local variable) + 8 for push rbp above = 64
    sub rsp,0x30	; 48 here, because the return address + the push rbp above (8 + 8 = 16). 48 + 16 = 64.

    ; Store our message and its length in
    ; our local variables
    mov [rbp-0x08],rcx
    mov [rbp-0x10],rdx

    ; Get the handle to StdOut
    mov rcx,STD_OUTPUT_HANDLE
    call GetStdHandle

    ; Write the message, passing the local
    ; variable values to the WinAPI
    mov rcx,rax
    mov rdx,[rbp-0x08]
    mov r8,[rbp-0x10]
    mov r9,empty

    mov qword [rsp+0x20],0	; 5th argument to WriteFile, 32 bytes back (directly behind the Shadow Space)
    call WriteFile

    add rsp,0x30	; Deallocate Shadow space and local variable

    leave
    ret 

itoa:

    push rbp		
    mov rbp,rsp
    sub rsp,8		; Align the stack to 16 bytes (8 for return address + another 8 = 16)

    mov rax,rcx		; Move the passed in argument to rax
    lea rdi,[numbuf+10]	; load the end address of the buffer (past the very end)
    mov rcx,10		; divisor
    mov qword [rbp-8],0	; rbp-8 will contain 8 bytes representing the length of the string - start at zero

.divloop:
    xor rdx,rdx		; Zero out rdx (where our remainder goes after idiv)
    idiv rcx		; divide rax (the number) by 10 (the remainder is placed in rdx)
    add rdx,0x30	; add 0x30 to the remainder so we get the correct ASCII value
    dec rdi		; move the pointer backwards in the buffer
    mov byte [rdi],dl	; move the character into the buffer
    inc qword [rbp-8]	; increase the length
    
    cmp rax,0		; was the result zero?
    jnz .divloop	; no it wasn't, keep looping

    mov rax,rdi		; rdi now points to the beginning of the string - move it into rax
    mov rcx,[rbp-8]	; rbp-8 contains the length - move it into rcx

    leave		; clean up our stack
    ret
