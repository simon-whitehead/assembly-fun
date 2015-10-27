nasm -f win64 4.read-input.s
GoLink /console /entry start 4.read-input.obj kernel32.dll
