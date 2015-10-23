# 64-bit Windows Assembly
-------

This folder contains NASM that is designed to run on a 64-bit Windows platform.

64-bit Windows is an interesting beast because it is both slightly, and largely different
to 64-bit Assembly on other platforms. I will try and outline the oddities that I am
now aware of as I understand them. Please feel free to correct anything that is incorrect.

### Parameter passing

First, 64-bit Windows uses 4 registers to pass parameters to functions. Any more then 4
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
Space". The ABI states that it is the _callers_ job to allocate this stack space, and
not the callee. The stack must also always be 16 byte aligned, which can be confusing
because on entry to a function the last entry in the stack is the return address of
the preview function - which is already 8 bytes. Therefore, for a function to allocate
32 bytes of "Shadow Space" and keep the stack aligned, it must allocate 40 bytes
(40 + 8 = 48, which is a multiple of 16). A simple example would be:

    start:

        push rbp		; Preserve rbp
        push rbp,rsp	; Save our stack pointer location
        sub rsp,0x28	; Reserve 40 bytes on the stack for the next functions "Shadow Space"

        call otherfunction

    otherfunction:

        push rbp		; Preserve rbp again, which means the top of the stack is now what rbp was
        mov rbp,rsp	 ; Store our stack pointer
        sub rsp,0x28	; Allocate another 40 bytes of Shadow Space if this function calls another. Again, the return address being on the stack misaligns it so we need to align it again)

        ; Shadow Space of start function is accessible like this:
        mov [rbp+0x10],rcx	; Store Argument #1 in the start of the Shadow Space (at +16 because RBP is as above, and RBP+8 is the return address because of the call instruction)
        mov [rbp+0x18]

### Don't push

So what happens when you have a method with 5 arguments? Well this is a bit tricky.. but makes sense
when you see it in action.

Recall that the rule is, the first 4 (integer) arguments passed to a function must be placed
in the `rcx`, `rdx`, `r8` and `r9` registers. Anything else must be placed on the stack. Lets try that now:

    mov rcx,a
    mov rdx,b
    mov r8,c
    mov r9,d
    push e

    call add

If you take in to account the fact that we've allocated Shadow Space for the call, then you
essentially have (on entry to the `add` function), a stack that looks like this:

    +-----------------+
    |   Return Addr   |
    +-----------------+
    |  r9 Shadow (8)  |
    +-----------------+
    |  r8 Shadow (8)  |
    +-----------------+
    | rdx Shadow (8)  |
    +-----------------+
    | rcx Shadow (8)  |
    +-----------------+
    |        e        |  <--- RSP
    +-----------------+
     
The problem with this, is now where the functions assume the first Shadow Space slot is (recall the example above uses `[rbp+0x10]` which is + 16 bytes from the stack pointer at the top of the function. This isn't shadow space anymore ... its what you've pushed to the stack as the fifth parameter (`e`). So how do you fix that?

You allocate more stack space and move data in to it manually. Essentially, instead of allocating 32 bytes of Shadow Space on the stack, you can allocate the 32 + 8 more for the fifth parameter:

    sub rsp,0x28

32 + 8 = 40. The return address being on the stack adds another 8 bytes, so 40 + 8 = 48 - a multiple of 16. The stack is aligned and the ABI is satisfied, now you just need to put the fifth argument where it needs to be:

    mov [rsp+20],e

This moves the `e` value 32 bytes above the stack pointer. Essentially making the stack look like this:


    +-----------------+
    |   Return Addr   |
    +-----------------+
    |        e        |
    +-----------------+
    |  r9 Shadow (8)  |
    +-----------------+
    |  r8 Shadow (8)  |
    +-----------------+
    | rdx Shadow (8)  |
    +-----------------+
    | rcx Shadow (8)  | <--- RSP
    +-----------------+

Now the calling function can locate the parameters in order:

    Return Address = [rbp+0x08]

    a = [rbp+0x10]
    b = [rbp+0x18]
    c = [rbp+0x20]
    d = [rbp+0x28]
    e = [rbp+0x30]

<sup>1</sup> You don't generally see many manual calls to `push` when dealing with function calls in 64-bit Windows Assembly. See "Don't push" above.


