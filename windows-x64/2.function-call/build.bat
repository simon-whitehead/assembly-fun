nasm -f win64 2.function-call.s
GoLink /console /entry start 2.function-call.obj kernel32.dll
