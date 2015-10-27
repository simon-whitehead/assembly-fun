# 64-bit Windows Assembly
-------

This folder contains NASM that is designed to run on a 64-bit Windows platform.

64-bit Windows is an interesting beast because it is both slightly, and largely different
to 64-bit Assembly on other platforms. I will try and outline the oddities that I am
now aware of as I understand them. Please feel free to correct anything that is incorrect.

### Stack alignment

As with the AMD64/SystemV ABI, the Windows ABI dictates that the stack should be aligned on a 16-byte boundary. What this means is that, at the conclusion of the prologue of a function, the memory address that `rsp` points to should be aligned on a memory address that is a multiple of 16.

The simple act of calling a function misaligns the stack by placing an 8 byte return address on the stack when entering a function.

For example, assuming that the stack is aligned perfectly prior to this line:

    call SomeFunction

After that line executes, the stack is misaligned by 8 bytes. To align it again, we can let the normal prologue happen and align it there:

    push rbp		; The stack is actually aligned after this to 16
    mov rbp,rsp
    sub rsp,0x20	; This allocates 32 bytes of space. 32 + the 16 bytes its already aligned to makes 48 which is a muiltiple of 16, so it is aligned properly

or, align it manually (I _think_ this is okay.. I can't see any issue with it)

    SomeFunction:

        sub rsp,0x08

### Parameter passing

First, 64-bit Windows uses 4 registers to pass parameters to functions. Any more than 4
and the stack comes in to play <sup>1</sup>.

The registers are (in order): `rcx`, `rdx`, `r8`, `r9`. This means that, given a function
whose signature is similar to this:

    int add(int a, int b, int c, int d);

You would call it as such:

    mov rcx,a
    mov rdx,b
    mov r8,c
    mov r9,d

    call add

### Shadow space

The 64-bit Windows ABI specifies that _every single non-leaf function_ must allocate
32 bytes of stack space for "register spill". This is commonly referred to as "Shadow 
Space" and must be adjacent to the return address to the previous function. The ABI
 states that it is the _callers_ job to allocate this stack space, and
not the callee. The stack must also always be 16 byte aligned, which can be confusing
because on entry to a function the last entry in the stack is the return address of
the preview function - which is already 8 bytes. Therefore, for a function to allocate
32 bytes of "Shadow Space" and keep the stack aligned, it must allocate 40 bytes
(40 + 8 = 48, which is a multiple of 16). A simple example would be:

    start:

        sub rsp,0x28	; Reserve 32 + 8 + 8 (return address) bytes on the stack for the next functions "Shadow Space"

        call otherfunction

    otherfunction:

        push rbp		; Preserve rbp again, which means the top of the stack is now what rbp was
        mov rbp,rsp	 ; Store our stack pointer
        sub rsp,0x20	; Allocate 32 + 8 + 8 (return address + push rbp above) bytes of Shadow Space if this function calls another. Again, the return address being on the stack misaligns it so we need to align it again)

        ; Shadow Space of start function is accessible like this:
        mov [rbp+0x10],rcx	; Store Argument #1 in the start of the Shadow Space (at +16 because RBP is as above, and RBP+8 is the return address because of the call instruction)
        mov [rbp+0x18]

If you disregard any local stack space assignments, then your stack alignment can be of the form `16n+8`. In hex that is simple, its `0xn8`.

This however does not work if you `push rbp` in your prologue, as that adds another 8 bytes to the stack. To fix it, you need to pad it out to the nearest multiple of 16 (in our case it perfectly hits 48 .. 32 + 8 + 8, so we don't have to do anything).

### Don't push

So what happens when you have a method with 5 arguments? Well this is a bit tricky.. but makes sense
when you see it in action.

Recall that the rule is, the first 4 (integer) arguments passed to a function must be placed
in the `rcx`, `rdx`, `r8` and `r9` registers. Anything else must be placed on the stack. Lets try that now:

    sub rsp,0x20

    ...

    mov rcx,a
    mov rdx,b
    mov r8,c
    mov r9,d
    push e

    call add

If you take in to account the fact that we've allocated Shadow Space for the call, then you
essentially have (on entry to the `add` function), a stack that looks like this:

    +-----------------+
    |  r9 Shadow (8)  |
    +-----------------+
    |  r8 Shadow (8)  |
    +-----------------+
    | rdx Shadow (8)  |
    +-----------------+
    | rcx Shadow (8)  |
    +-----------------+
    |        e        |  
    +-----------------+
    |   Return Addr   | 
    +-----------------+
    |    Saved RBP    | <--- RSP
    +-----------------+

The problem with this, is the Shadow Space is no longer adjacent to the return address. Your fifth argument sits
between the Shadow Space and the return address. So how do you fix that?

You allocate more stack space and move data in to it manually. Essentially, instead of allocating 32 bytes
 of Shadow Space on the stack, you can allocate the 32 + 8 + 8 (Shadow Space, `push rbp` and return address) + 8 more for
 the fifth parameter:

    sub rsp,0x30

32 + 8 = 40. The return address being on the stack adds another 8 bytes, so 40 + 8 = 48. The `push rbp` in the prologue adds another 8 which makes 56. This is not a multiple of 16 and so we pad it out to 64. The stack is aligned and the ABI is satisfied, now you just need to put the fifth argument where it needs to be:

    mov [rsp+20],e

This moves the `e` value 32 bytes above the stack pointer. Essentially making the stack look like this:


    +-----------------+
    |        e        |
    +-----------------+
    |  r9 Shadow (8)  |
    +-----------------+
    |  r8 Shadow (8)  |
    +-----------------+
    | rdx Shadow (8)  |
    +-----------------+
    | rcx Shadow (8)  | 
    +-----------------+
    |   Return Addr   | 
    +-----------------+
    |    Saved RBP    | <--- RSP
    +-----------------+

Now the calling function can locate the parameters in order:

    Return Address = [rbp+0x08]

    a = [rbp+0x10]
    b = [rbp+0x18]
    c = [rbp+0x20]
    d = [rbp+0x28]
    e = [rbp+0x30]

### Register Usage

The 64-bit Windows ABI decides how certain registers should be used. It describes registers and their volatility.

For example, the following (non floating point) registers are considered _volatile_. That is, their value can freely change between function calls and callers should not rely on their values being preserved across function calls:

* `rax`
* `rcx`
* `rdx`
* `r8`
* `r9`
* `r10:r11`

The following (not floating point) registers are considered _non volatile_. That is, their value must remain across the boundary of a function call. This means that the callee must preserve their value in order to use them in their body (by pushing them on the stack or otherwise).

* `r12:r15`
* `rdi`
* `rsi`
* `rbx`
* `rbp`
* `rsp`

A simple example of handling non volatile register is in the prologue and epilogue of a function with some allocated/aligned stack space:

    push rbp			; <--- rbp is non volatile and must be the same value when it leaves as when it came in
    mov rbp,rsp		; Overwrite rbp just for this method

    ...

    leave		; <-- this is shorthand for mov rsp,rbp + pop rbp, so it will restore rbp to what it was when it entered
    ret


### Remembering it all

There are a couple of shortcuts that you can memorise to help with this stuff, rather than work it out each time manually.

#### The Caller

On the caller side, you basically want to allocate enough space for the following:

    sub rsp, (highestParameterCount * 8)

Where `highestParameterCount` is at least 4, or the highest number of parameters in any function you call from
within the current function. For example, in Windows #2 we call a function called `write` and the highest 
number of function arguments for a function it calls is 5 (`WriteFile` has 5 arguments, the rest have less).
 Therefore, we `sub rsp, 0x28` (40). This just so happens to align the stack because of the return address already on
 the stack (40 + 8 = 48). If it doesn't align the stack on a 16 byte boundary, then just round it upward until you
hit a multiple of 16. This allocates enough space for the Shadow Space plus the fifth parameter to `WriteFile`.

To move (not push) arguments _after_ the Shadow Space, you just need to start at an offset `0x20` bytes from `rsp`.

    mov rcx,arg1
    mov rdx,arg2
    mov r8,arg3
    mov r9,arg4

    ; 5th argument always starts at 0x20
    mov qword [rsp+0x20],arg5

#### The Callee

When you have a prologue that includes a `push rbp`, then your Shadow Space always starts at `[rbp+0x10]`.

On the callee side, you need to use an offset from `rbp` (if you can...), otherwise the distance from `rsp` will
 change because of the local frame. This means, your fifth argument that is adjacent to the Shadow Space is always
 located 32+8+8 bytes away from `rbp`where your prologue includes a `push rbp`.

    mov rax,[rbp+0x30]	; Move the 5th argument to this function in to rax


<sup>1</sup> You don't generally see many manual calls to `push` when dealing with function calls in 64-bit Windows Assembly. See "Don't push" above.


