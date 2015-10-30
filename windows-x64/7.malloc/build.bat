nasm -f win64 7.malloc.s
GoLink /console /entry start 7.malloc.obj kernel32.dll
