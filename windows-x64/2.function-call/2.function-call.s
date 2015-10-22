; Simon Whitehead, 2015
; ---------------------
;
; 2. Function calls
;
;    This program prints "Hello World!" to StdOut
;    by calling a function twice. It follows the
;    64-bit Windows ABI by passing the arguments
;    via the RCX and RDX registers.

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

    msg1                 db "Hello ", 0
    msg1.len             equ $-msg1

    msg2                 db "World!", 10, 0
    msg2.len             equ $-msg2

section .bss
empty               resd 1

section .text

start:

    sub rsp,0x28

    mov rcx,msg1
    mov rdx,msg1.len
    call write

    add rsp,0x28

    mov rcx,NULL
    call ExitProcess

    ret

write:

    mov [rsp+0x08],rcx		; Argument 1
    mov [rsp+0x10],rdx		; Argument 2

    mov rcx,STD_OUTPUT_HANDLE	; Get handle to StdOut
    call GetStdHandle

    mov rcx,rax			; hConsoleOutput
    mov rdx,[rsp+0x08]		; lpBuffer
    mov r8,[rsp+0x10]		; nNumberOfCharsToWrite
    mov r9,empty		; lpNumberOfCharsWritten
    push NULL			; lpReserved
    call WriteConsoleA

    ret

