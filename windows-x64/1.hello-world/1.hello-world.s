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

; WriteConsole
; ------------
; BOOL WINAPI WriteConsole(
;     _In_             HANDLE  hConsoleOutput,
;     _In_       const VOID    *lpBuffer,
;     _In_             DWORD   nNumberOfCharsToWrite,
;     _Out_            LPDWORD lpNumberOfCharsWritten,
;     _Reserved_       LPVOID  lpReserved
; );
extern WriteConsoleA

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

    ; Get a handle to stdout
    mov rcx,STD_OUTPUT_HANDLE
    call    GetStdHandle

    mov rcx,rax			; hConsoleOutput
    mov rdx,msg			; lpBuffer
    mov r8,msg.len		; nNumberOfCharsToWrite
    mov r9,empty		; lpNumberOfCharsWritten
    push    NULL		; lpReserved
    call    WriteConsoleA

    mov rcx,NULL
    call    ExitProcess

