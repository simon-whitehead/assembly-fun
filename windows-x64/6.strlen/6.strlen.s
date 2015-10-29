; Simon Whitehead, 2015
; ---------------------
;
; 6. strlen
;
;    This program prints "Hello world!" but it figures out the length
;    of the string all by itself.


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

    msg			db "Hello World!", 10, 0

section .bss

    empty	resb 1

section .text

start:

    sub rsp,0x28 ; Shadow space

    ; Call strlen to put the length of the string in rax
    mov rcx,msg
    call strlen

    ; Write the string
    mov rcx,msg
    mov rdx,rax		; using the returned string length from strlen
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

; This version of strlen uses the scasb instruction
; to scan the input string for the null terminator.

strlen:

    mov rdi,rcx

    xor rax,rax		; Set the value that scasb will search for. In this case it is zero (the null terminator byte)
    mov rcx,-1		; Store -1 in rcx so that scasb runs forever (or until it finds a null terminator). scasb DECREMENTS rcx each iteration
    cld			; Clear the direction flag so scasb iterates forward through the input string

    repne scasb		; Execute the scasb instruction. This leaves rdi pointing at the base of the null terminator.

    not rcx		; Invert the value of rcx so that we get the two's complement value of the count. E.g, a count of -25 results in 24.
    mov rax,rcx		; Move the length of the string into rax

    ret
