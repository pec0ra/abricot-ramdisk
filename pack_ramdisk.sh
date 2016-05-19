#!/bin/sh
cd abricot_ramdisk_recovery
shopt -s dotglob
rm *~
rm *.swp
rm sbin/*~
rm sbin/.*swp
find . | cpio --owner root:root -o -H newc | gzip > ../ramdisk.cpio.gz
