; Simon Whitehead, 2015
; ---------------------
;
; 8. strcat
;
;    This program prints "Hello world!" by concatenating the
;    strings "Hello" and "World!" together. It does so by 
;    asking the operating system for some free memory to
;    place the result in.



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

    msg1		db "Hello", 0
    msg2		db " World!", 10, 0

    BUFFER_SIZE		equ 16

section .bss

    empty	resb 1

section .text

start:

    push rbp
    mov rbp,rsp
    sub rsp,0x40 ; Shadow space + 8 for the heap handle, 16 for two local variables (heap handle and buffer pointer)

    ; Get a handle to the process heap
    call GetProcessHeap

    ; Store a handle to the heap
    mov [rbp-0x08],rax

    ; Allocate 16 kilobytes of memory
    mov qword rcx,16384
    mov rdx,rax
    call malloc

    mov [rbp-0x10],rax	; Save pointer to our allocated memory

    mov rcx,rax
    mov rdx,msg1
    mov r8,msg2
    call strcat

    mov rdx,rcx
    mov rcx,rax
    call write

    ; Deallocate our memory
    mov rcx,[rbp-0x08]
    mov rdx,[rbp-0x10]	; Pointer to our malloc memory
    call dealloc

    mov rcx,NULL
    call ExitProcess

    add rsp,0x28

    leave
    ret

malloc:

    sub rsp,0x28	; 32 bytes for HeapAlloc + 8 for the return address makes 40, aligned to 48

    mov r8,rcx			; dwBytes
    mov rcx,rdx			; hHeap
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

strlen:

    mov rdi,rcx		; Move rcx in to rdi

    xor rax,rax		; Set the value that scasb will search for. In this case it is zero (the null terminator byte)
    mov rcx,-1		; Store -1 in rcx so that scasb runs forever (or until it finds a null terminator). scasb DECREMENTS rcx each iteration
    cld			; Clear the direction flag so scasb iterates forward through the input string

    repne scasb		; Execute the scasb instruction. This goes up to and includes the null terminator plus another decrement of rcx. The length is rcx-2.

    not rcx		; Invert the value of rcx so that we get the two's complement value of the count. E.g, a count of -25 results in 24.
    
    dec rcx
    mov rax,rcx

    ret

strcat:

    ; Local variables:
    ; ----------------
    ; 0x08 - Initial base pointer position
    ; 0x10 - Total Length
    ; 0x18 - Current position of RDI between repnz instructions

    push rbp
    mov rbp,rsp
    sub rsp,0x20	; Room for a local counter, base pointer and rdi storage

    mov qword [rbp-0x08],rcx	; Save our pointer to our buffer
    mov rcx,rdx		; Move the second argument into rdi then call strlen
    call strlen

    mov [rbp-0x10],rax	; Store the length
    mov rcx,rax		; Set how many bytes to copy

    ; Restore the destination
    mov rdi,[rbp-0x08]
    mov rsi,rdx

    cld			; Clear the direction flag

    repnz movsb		; Copy the string across

    mov [rbp-0x18],rdi	; Save our pointer again
    mov rcx,r8		; Move the third argument into rdi and call strlen
    call strlen

    add [rbp-0x10],rax	; Add this length to the previous length to get the total characters
    mov rcx,rax		; Set how many bytes to copy

    ; Restore the destination and set the source as the third argument
    mov rdi,[rbp-0x18]
    mov rsi,r8

    repnz movsb

    mov rax,[rbp-0x08]	; Save our base pointer to rax
    mov rcx,[rbp-0x10]	; Save our total length to rcx

    leave
    ret 
