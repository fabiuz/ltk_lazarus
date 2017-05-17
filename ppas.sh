#!/bin/sh
DoExitAsm ()
{ echo "An error occurred while assembling $1"; exit 1; }
DoExitLink ()
{ echo "An error occurred while linking $1"; exit 1; }
echo Linking ltk_debug
OFS=$IFS
IFS="
"
/usr/bin/ld -b elf64-x86-64 -m elf_x86_64  --dynamic-linker=/lib64/ld-linux-x86-64.so.2    -L. -o ltk_debug link.res
if [ $? != 0 ]; then DoExitLink ltk_debug; fi
IFS=$OFS
echo Linking ltk_debug
OFS=$IFS
IFS="
"
/usr/bin/objcopy --only-keep-debug ltk_debug ltk_debug.dbg
if [ $? != 0 ]; then DoExitLink ltk_debug; fi
IFS=$OFS
echo Linking ltk_debug
OFS=$IFS
IFS="
"
/usr/bin/objcopy --add-gnu-debuglink=ltk_debug.dbg ltk_debug
if [ $? != 0 ]; then DoExitLink ltk_debug; fi
IFS=$OFS
echo Linking ltk_debug
OFS=$IFS
IFS="
"
/usr/bin/strip --strip-unneeded ltk_debug
if [ $? != 0 ]; then DoExitLink ltk_debug; fi
IFS=$OFS
