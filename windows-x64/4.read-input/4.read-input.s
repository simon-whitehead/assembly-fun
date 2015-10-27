; Simon Whitehead, 2015
; ---------------------
;
; 2. Function calls
;
;    This program prints "Hello World!" to StdOut
;    by calling a function twice. It follows the
;    64-bit Windows ABI by passing the arguments
;    via the RCX and RDX registers while also
;    respecting the "Shadow Space" requirement of
;    64-bit Windows.

; Windows APIs

; GetStdHandle
; ------------
; HANDLE WINAPI GetStdHandle(
;     _In_ DWORD nStdHandle
; ); 
extern GetStdHandle

; ReadFile
; ------------
; BOOL WINAPI ReadFile(
;   _In_        HANDLE       hFile,
;   _Out_       LPVOID       lpBuffer,
;   _In_        DWORD        nNumberOfBytesToRead,
;   _Out_opt_   LPDWORD      lpNumberOfBytesRead,
;   _Inout_opt_ LPOVERLAPPED lpOverlapped
; );
extern ReadFile

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
    STD_INPUT_HANDLE	equ -10
    NULL                equ 0

    BUFFER_SIZE		equ 1024

section .bss

    buffer		resb BUFFER_SIZE
    empty               resd 1

section .text

start:

    sub rsp,0x28	; Allocate 32 bytes of Shadow Space + align it to 16 bytes (8 byte return address already on stack, so 8 + 40 = 16*3)

    mov rcx,buffer
    mov rdx,BUFFER_SIZE
    call read

    mov rdx,rcx		; rcx contains number of bytes read
    mov rcx,buffer
    call write

    mov rcx,NULL
    call ExitProcess

    add rsp,0x28	; Restore the stack pointer before exiting

    ret

read:

    push rbp
    mov rbp,rsp
    sub rsp,0x30

    mov [rbp+0x10],rcx
    mov [rbp+0x18],rdx

    mov rcx,STD_INPUT_HANDLE	; Get handle to StdIn
    call GetStdHandle

    mov rcx,rax			; hFile
    mov rdx,[rbp+0x10]		; lpBuffer
    mov r8,[rbp+0x18]		; nNumberOfBytesToRead
    lea r9,[rbp+0x20]		; lpNumberOfBytesRead

    mov qword[rsp+0x20],0	; lpOverlapped
    call ReadFile

    mov rcx,[rbp+0x20]		; Put the number of bytes read in to rcx

    add rsp,0x30

    leave
    ret

write:

    push rbp
    mov rbp,rsp
    sub rsp,0x30

    mov [rbp+0x10],rcx
    mov [rbp+0x18],rdx

    mov rcx,STD_OUTPUT_HANDLE	; Get handle to StdOut
    call GetStdHandle

    mov rcx,rax			; hFile
    mov rdx,[rbp+0x10]		; lpBuffer
    mov r8,[rbp+0x18]		; nNumberOfBytesToWrite
    mov r9,empty		; lpNumberOfBytesWritten

    ; Move the 5th argument directly behind the Shadow Space
    mov qword [rsp+0x20],0	; lpOverlapped, Argument 5 (just after the Shadow Space 32 bytes back)
    call WriteFile

    add rsp,0x30

    leave
    ret

