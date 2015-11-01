; Simon Whitehead, 2015
; ---------------------
;
; 7. malloc
;
;    This program prints "Hello World!" but it
;    points to a string that is allocated in the
;    virtual memory of the process at runtime. It
;    does this by calling HeapAlloc to ask the OS
;    to allocate some more memory for the process
;    and return a pointer to the memory. It does not
;    handle any potential errors from HeapAlloc. It does
;    however, free the memory using HeapFree.

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

; GetProcessHeap
; -----------
; HANDLE WINAPI GetProcessHeap(void);
extern GetProcessHeap

; HeapAlloc
; -----------
; LPVOID WINAPI HeapAlloc(
;   _In_ HANDLE hHeap,
;   _In_ DWORD  dwFlags,
;   _In_ SIZE_T dwBytes
; );
extern HeapAlloc

; HeapFree
; -----------
; BOOL WINAPI HeapFree(
;   _In_ HANDLE hHeap,
;   _In_ DWORD  dwFlags,
;   _In_ LPVOID lpMem
; );
extern HeapFree

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

    HEAP_ZERO_MEMORY	equ 0x08

    BUFFER_SIZE		equ 16
    message.length	equ 13

section .bss

    empty	resb 1

section .text

start:

    push rbp
    mov rbp,rsp
    sub rsp,0x40 ; Shadow space + 8 for the heap handle, 16 for two local variables (heap handle and buffer pointer)

    ; Get a handle to the process heap
    call GetProcessHeap

    ; Store the heap handle
    mov [rbp-0x08],rax

    ; Allocate 16 bytes of memory from the heap
    mov rcx,rax
    mov rdx,BUFFER_SIZE
    call malloc

    ; Store our buffer pointer
    mov [rbp-0x10],rax
   
    ; Store "Hello World!" in the buffer we've just allocated
    mov rcx,rax
    call create_string

    ; Write the string
    mov rcx,rax
    mov rdx,message.length
    call write

    ; Free up the space.. even though Windows does it for us
    mov rcx,[rbp-0x08]
    mov rdx,[rbp-0x10]
    call dealloc

    mov rcx,NULL
    call ExitProcess

    add rsp,0x40

    leave
    ret

; RCX: hHeap
; RDX: dwBytes
malloc:

    sub rsp,0x28	; 32 bytes for HeapAlloc + 8 for the return address makes 40, aligned to 48

    mov r8,rdx			; dwBytes
    mov rdx,HEAP_ZERO_MEMORY	; dwFlags
    call HeapAlloc

    add rsp,0x28

    ret

dealloc:

    sub rsp,0x28

    mov r8,rdx
    mov rdx,NULL
    call HeapFree

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

create_string:

    mov [rcx],byte 72	; H

    inc rcx
    mov [rcx],byte 101	; e

    inc rcx
    mov [rcx],byte 108	; l

    inc rcx
    mov [rcx],byte 108	; l

    inc rcx
    mov [rcx],byte 111	; o

    inc rcx
    mov [rcx],byte 32	; (space)

    inc rcx
    mov [rcx],byte 87	; W

    inc rcx
    mov [rcx],byte 111	; o

    inc rcx
    mov [rcx],byte 114	; r

    inc rcx
    mov [rcx],byte 108	; l

    inc rcx
    mov [rcx],byte 100	; d

    inc rcx
    mov [rcx],byte 33	; !

    inc rcx
    mov [rcx],byte 10	; NewLine

    inc rcx
    mov [rcx],byte 0	; Null terminator

    sub rcx,13

    ret
