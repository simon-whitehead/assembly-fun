nasm -f win64 8.strcat.s
GoLink /console /entry start 8.strcat.obj kernel32.dll
