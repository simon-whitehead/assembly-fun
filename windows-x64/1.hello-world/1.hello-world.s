; Simon Whitehead, 2015
; ---------------------
;
; 1. Hello world
;
;    This program prints "Hello world!" to the Console
;    then exits

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

    STD_OUTPUT_HANDLE   equ -11
    NULL                equ 0

    msg                 db "Hello World!", 10, 0
    msg.len             equ $-msg

section .bss
empty               resd 1

section .text

start:

    ; Allocate 32 bytes of Shadow Space + 8 for firth argument to WriteFile + 8 already on the stack makes 48 (a multiple of 16)
    sub rsp,0x28

    ; Get a handle to stdout
    mov rcx,STD_OUTPUT_HANDLE
    call    GetStdHandle

    mov rcx,rax			; hFile
    mov rdx,msg			; lpBuffer
    mov r8,msg.len		; nNumberOfBytesToWrite
    mov r9,empty		; lpNumberOfBytesWritten
    mov qword [rsp+0x20],NULL		; lpOverlapped (space for Argumtn 5 is 32 bytes back, adjacent the Shadow space we just allocated)
    call    WriteFile

    mov rcx,NULL
    call    ExitProcess

    add rsp,0x28		; Fix the stack pointer
    ret

