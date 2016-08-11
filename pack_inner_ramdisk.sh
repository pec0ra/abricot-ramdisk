#!/bin/sh
mv abricot_ramdisk_recovery/sbin/ramdisk.cpio.bz2 ramdisk.cpio.bz2.bak
cd ramdisk
rm *~
shopt -s dotglob
rm .*swp
find . | cpio --owner root:root -o -H newc | bzip2 > ../abricot_ramdisk_recovery/sbin/ramdisk.cpio.bz2
