# Assembly Fun

This is a collection of custom NASM code that performs basic tasks. It provides
custom implementations of some of the standard C library functionality. I am
not trying to be a "purist" here - this is merely a repository for me to dump
code while I re-learn/refresh my Assembly knowledge. Use at your own risk.

This repository is starting off with just NASM code written for 64-bit Ubuntu. Eventually,
I would like to port each individual directory to other operating systems
and word sizes. Maybe once I hit the tenth directory I will start porting them
to Windows and Mac OSX.

-----

## The road so far

This repository currently contains the following pieces of code:

### 1. Hello World
      
This project simply writes "Hello world!" to stdout. It demonstrates two basic
syscall operations; namely, `sys_write` and `sys_exit`.

### 2. Function call

This project demonstrates two ways to call a function and use an argument
passed to it. The first example places a value into a register and print
the argument to stdout. The second example uses an argument that is pushed
on to the stack.

This project also demonstrates stack frame initialization and tear down.

### 3. Local variables

This project demonstrates the `enter` and `leave` instructions for stack
frame initialization. It then pushes a string into a local pointer variable
and prints the string at the address held by the local variable. This isn't
the best example of local variables .. but it was the first attempt (better
examples are in #6. strlen, etc).

### 4. Read input

This project reads the user input from stdin and echoes it back to stdout.
The project itself demonstrates the use of the data segment to pre-allocate
a block of memory. This block of memory is used as the buffer for user input.

### 5. Numbers to strings (itoa)

This project demonstrates an `itoa` algorithm to print numbers
to stdout. The algorithm and code is [explained in detail on my blog](https://simonsdotnet.wordpress.com/2015/01/13/converting-numbers-to-strings-in-nasm-a-basic-itoa-implementation/).

### 6. String length (strlen)

This project demonstrates two ways to determine the length of a null terminated
string. The first example manually loops through a block of memory looking
for a null byte. The second examples uses the `scasb` instruction to search
for the null byte.

### 7. Dynamic memory allocation (malloc)

This project demonstrates asking the host operating system for some 
dynamically allocated memory. It then fills the memory in with "Hello World!"
and prints it to stdout. It should be noted that this is nowhere near as
complicated as the implementations of `malloc` are. This simply asks for a 
block of memory and utilizes it - there is no memory management involved.

### 8. String concatentation (strcat)

This project concatenates the strings "Hello " and "World!" before printing them
to the console. It does so by allocating 16 kilobytes of memory (yes that is over-
kill, but oh well) and using it as a string buffer with which to place the result.
This project also demonstrates better use of registers and the 64-bit C-compliant
calling convention using the `rdi`, `rsi` and `rdx` registers for passing arguments
to functions.

### 9. Strings to numbers (atoi)

This project demonstrates an algorithm for converting ASCII strings to integers. It makes good use of varying register sizes and seems small for what it does. It converts the strings "23" and "32", adds the integer result to 100, then attempts to compare the result to the integer `123`. It then prints "Equal" or "Not equal". The tests are performed in the above order.
