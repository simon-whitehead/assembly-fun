nasm -f win64 1.hello-world.s
GoLink /console /entry start 1.hello-world.obj kernel32.dll
