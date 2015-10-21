# Assembly Fun

This is a collection of NASM code I have written while learning Assembly. It provides
custom implementations of some of the standard C library functionality. I am
not trying to be a "purist" here nor am I attempting to teach anyone Assembly. 
This is merely a repository for me to dump code while I re-learn/refresh 
my Assembly knowledge. Use at your own risk.

This repository is starting off with code written for 64-bit Ubuntu. I have
begun the process of porting it to other Operating Systems/Architectures; namely, 
64-bit Windows. I will aim to port at least one of the original 10 folders per
week starting today, 2015-10-22.

## Contributing

I am not an Assembly expert. Far from it. Now that is out of the way - can anything here be improved? I
am certainly open to improvements or suggestions. Whether they be README, code or
comment improvements. This repository is just a bit of fun and purely for learning
purposes .. but that doesn't mean I want it to be incorrect.

-----

## The road so far

This repository currently contains the following pieces of code:

### 1. Hello World (64-bit: Linux, Windows)
      
This project simply writes "Hello world!" to StdOut. The Linux version
uses interrupts while the Windows version calls Windows APIs.

### 2. Function call (64-bit: Linux)

This project demonstrates how to call a function and use an argument
passed to it. How this is achieved changes for each system/architecture
the code is targeting and each folder complies with the specified
systems' ABI..

This project also demonstrates stack frame initialization and tear down.

### 3. Local variables (64-bit: Linux)

This project demonstrates using a local variable by storing a function argument
in it then printing the string pointed to by the local variable. This isn't
the best example of local variables .. but it was the first attempt (better
examples are in #6. strlen, etc).

### 4. Read input (64-bit: Linux)

This project reads the user input from StdIn and echoes it back to StdOut.
The project itself demonstrates the use of the data segment to pre-allocate
a block of memory. This block of memory is used as the buffer for user input.

### 5. Numbers to strings (itoa) (64-bit: Linux)

This project demonstrates an `itoa` algorithm to print numbers
to StdOut. The algorithm and code is [explained in detail on my blog](https://simonsdotnet.wordpress.com/2015/01/13/converting-numbers-to-strings-in-nasm-a-basic-itoa-implementation/).

### 6. String length (strlen) (64-bit: Linux)

This project demonstrates two ways to determine the length of a null terminated
string. The first example manually loops through a block of memory looking
for a null byte. The second examples uses the `scasb` instruction to search
for the null byte.

### 7. Dynamic memory allocation (malloc) (64-bit: Linux)

This project demonstrates asking the host operating system for some 
dynamically allocated memory. It then fills the memory in with "Hello World!"
and prints it to StdOut. This is not a full implementation of `malloc`, but
it demonstrates dynamic memory allocation.

### 8. String concatentation (strcat) (64-bit: Linux)

This project concatenates the strings "Hello " and "World!" before printing them
to StdOut. It does so by allocating 16 kilobytes of memory and using it as a
string buffer with which to place the result. 

### 9. Strings to numbers (atoi) (64-bit: Linux)

This project demonstrates an algorithm for converting ASCII strings to integers. It makes good use of varying register sizes and seems small for what it does. It converts the strings "23" and "32", adds the integer result to 100, then attempts to compare the result to the integer `123`. It then prints "Equal" or "Not equal". The tests are performed in the above order.

### 10. Includes (64-bit: Linux)

This project demonstrates separating code into individual files for reuse. It contains a `strings` and `io` file for common string and IO operations such as `strlen`, `strcat`, `readline`, `print`, etc. It makes a few improvements to previous implementations of these and will continue to be used throughout the rest of the learning process (unless significant improvements can be made .. in which case newer versions will be written).

The code itself prompts the user to enter two numbers, adds them together and prints the result to StdOut.

### Reading material

- MSDN: [Overview of x64 Calling Conventions](https://msdn.microsoft.com/en-us/library/ms235286.aspx)
