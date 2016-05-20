# Abricot kernel's ramdisk

## About

This repository contains the source code for the ramdisk of abricot kernel.


## Content

`ramdisk` :	This folder contains the ramdisk used to boot system. It is based on the stock ramdisk from Sony

`abricot_ramdisk_recovery` :	This folder contains the actual ramdisk for the abricot kernel.

`abricot_ramdisk_recovery/sbin/ramdisk.cpio.bz2` :	This is the content of the folder `ramdisk` packed into cpio and bzip2

`abricot_ramdisk_recovery/sbin/twrp.cpio.bz2` :	The recovery from TWRP team packed into cpio and bzip2

`abricot_ramdisk_recovery/sbin/init.sh` :	The init script to light up the leds and make boot decision

`abricot_ramdisk_recovery/sbin/led.sh` :	A script to easily light up the leds or make them glow

`pack_inner_ramdisk.sh` :	The script to pack the content of the folder `ramdisk` into cpio and bzip2. The packed file will be saved to `abricot_ramdisk_recovery/sbin/ramdisk.cpio.bz2`. The old `ramdisk.cpio.bz2` will be backed up to `ramdisk.cpio.bz2.bak`

`pack_ramdisk.sh` :	The script to pack the content of the folder `abricot_ramdisk_recovery` into cpio and gzip. The packed file will be saved to `ramdisk.cpio.gz`. This is the file that you will use in the kernel.


## Instructions

1. Run

        ```
        ./pack_inner_ramdisk.sh
        ```
        This will backup `abricot_ramdisk_recovery/sbin/ramdisk.cpio.bz2` to `ramdisk.cpio.bz2.bak`, pack the content of `ramdisk` and save it to `abricot_ramdisk_recovery/sbin/ramdisk.cpio.bz2`.
2. Then run

        ```
        ./pack_ramdisk.sh
        ```
        This will pack the content of `abricot_ramdisk_recovery` and save it to `ramdisk.cpio.gz`.
3. Use the file `ramdisk.cpio.gz` inside your kernel.
