@echo off

echo Creating "spy3titles" executable...
tools\vasm -nomsg=2050 -nomsg=2054 -nomsg=2052 -quiet -devpac -Fhunk -o src\spy3titles.o src\spy3titles.asm
if errorlevel 1 goto error
tools\vlink -S -s -o spy3titles src\spy3titles.o
if errorlevel 1 goto error
del src\spy3titles.o

echo Creating "spy3" executable...
tools\vasm -nomsg=2050 -nomsg=2054 -nomsg=2052 -quiet -devpac -Fhunk -o src\spy3.o src\spy3.asm
if errorlevel 1 goto error
tools\vlink -S -s -o spy3 src\spy3.o
if errorlevel 1 goto error
del src\spy3.o

echo Done.
:error
