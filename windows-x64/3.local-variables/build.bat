nasm -f win64 3.local-variables.s
GoLink /console /entry start 3.local-variables.obj kernel32.dll
