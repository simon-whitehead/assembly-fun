; Simon Whitehead, 2015
; ---------------------
;
; 3. Local variables
;
;    This program prints "Hello world!" to stdout
;    by pushing a global pointer onto the stack
;    of a called function. It also demonstrates
;    using the Shadow Space with regard to the
;    local frame.


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

    msg db "Hello World!", 10, 0	; Message to print
    msg.len equ $-msg

section .bss
    empty resd 1

section .text

start:

    ; Allocate some Shadow Space
    sub rsp,0x28

    mov rcx,msg
    mov rdx,msg.len
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
