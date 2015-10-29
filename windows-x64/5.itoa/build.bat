nasm -f win64 5.itoa.s
GoLink /console /entry start 5.itoa.obj kernel32.dll
