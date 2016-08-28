#!/bin/sh
DoExitAsm ()
{ echo "An error occurred while assembling $1"; exit 1; }
DoExitLink ()
{ echo "An error occurred while linking $1"; exit 1; }
echo Linking ltk
OFS=$IFS
IFS="
"
/usr/bin/ld -b elf64-x86-64 -m elf_x86_64  --build-id --dynamic-linker=/lib64/ld-linux-x86-64.so.2    -L. -o ltk link.res
if [ $? != 0 ]; then DoExitLink ltk; fi
IFS=$OFS
echo Linking ltk
OFS=$IFS
IFS="
"
/usr/bin/objcopy --only-keep-debug ltk ltk.dbg
if [ $? != 0 ]; then DoExitLink ltk; fi
IFS=$OFS
echo Linking ltk
OFS=$IFS
IFS="
"
/usr/bin/objcopy --add-gnu-debuglink=ltk.dbg ltk
if [ $? != 0 ]; then DoExitLink ltk; fi
IFS=$OFS
echo Linking ltk
OFS=$IFS
IFS="
"
/usr/bin/strip --strip-unneeded ltk
if [ $? != 0 ]; then DoExitLink ltk; fi
IFS=$OFS
