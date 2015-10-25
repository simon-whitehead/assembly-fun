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

    msg1                 db "Hello ", 0
    msg1.len             equ $-msg1

    msg2                 db "World!", 10, 0
    msg2.len             equ $-msg2

section .bss

empty               resd 1

section .text

start:

    sub rsp,0x28	; Allocate 32 bytes of Shadow Space + align it to 16 bytes (8 byte return address already on stack, so 8 + 40 = 16*3)

    mov rcx,msg1
    mov rdx,msg1.len
    call write

    mov rcx,msg2
    mov rdx,msg2.len
    call write

    mov rcx,NULL
    call ExitProcess

    add rsp,0x28	; Restore the stack pointer before exiting

    ret

write:

    ; Allocate another 40 bytes of stack space (the return address makes 48 total). Its 32
    ; bytes of Shadow Space for the WinAPI calls + 8 more bytes for the fifth argument
    ; to the WriteFile API call.
    sub rsp,0x28

    mov [rsp+0x38],rcx		; Argument 1 is 56 bytes back in the stack (40 above, 8 for return address, then 8 more for where it is)
    mov [rsp+0x40],rdx		; Argument 2 is just after Argument 1

    mov rcx,STD_OUTPUT_HANDLE	; Get handle to StdOut
    call GetStdHandle

    mov rcx,rax				; hFile
    mov rdx,[rsp+0x38]		; lpBuffer
    mov r8,[rsp+0x40]		; nNumberOfBytesToWrite
    mov r9,empty			; lpNumberOfBytesWritten

    ; Move the 5th argument directly behind the Shadow Space
    mov qword [rsp+0x58],0	; lpOverlapped, Argument 5 (just after the Shadow Space)
    call WriteFile

    add rsp,0x28		; Restore the stack pointer (remove the Shadow Space)

    ret

