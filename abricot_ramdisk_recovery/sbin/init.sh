#!/sbin/busybox sh
set +x
_PATH="$PATH"
export PATH=/sbin

busybox cd /
busybox date >>boot.txt
exec >>boot.txt 2>&1
busybox rm /init

# include device specific vars
source /sbin/bootrec-device

# create directories
busybox mkdir -m 755 -p /dev/block
busybox mkdir -m 755 -p /dev/input
busybox mkdir -m 555 -p /proc
busybox mkdir -m 755 -p /sys

# create device nodes
busybox mknod -m 600 /dev/block/mmcblk0 b 179 0
busybox mknod -m 600 ${BOOTREC_EVENT_NODE}
busybox mknod -m 666 /dev/null c 1 3

# mount filesystems
busybox mount -t proc proc /proc
busybox mount -t sysfs sysfs /sys

if [ -e /cache/recovery/boot ] || busybox grep -q warmboot=0x77665502 /proc/cmdline ; then
	busybox echo "found reboot into recovery flag"  >>boot.txt
else
	if ! busybox grep -q warmboot=0x77665502 /proc/cmdline ; then
		# keycheck
		busybox cat ${BOOTREC_EVENT} > /dev/keycheck&

		source /sbin/led.sh

		#vol up
		busybox hexdump /dev/keycheck | busybox grep -e '^.* 0001 0073 .... ....$' > /dev/keycheck_up
		#vol down
		busybox hexdump /dev/keycheck | busybox grep -e '^.* 0001 0072 .... ....$' > /dev/keycheck_down
		#camera
		busybox hexdump /dev/keycheck | busybox grep -e '^.* 0001 02fe .... ....$' > /dev/keycheck_camera

		# kill the keycheck process
		busybox pkill -f "busybox cat ${BOOTREC_EVENT}"
	fi
fi


# boot decision
if [ -s /dev/keycheck_up -a -n "busybox" ]; then
	busybox echo 'Volume Up' >>boot.txt
	busybox echo 'FOTA BOOT' >>boot.txt
	# orange led for recoveryboot
	busybox echo 255 > ${BOOTREC_LED_RED}
	busybox echo 0 > ${BOOTREC_LED_GREEN}
	busybox echo 0 > ${BOOTREC_LED_BLUE}
	# recovery ramdisk
	busybox mknod -m 600 ${BOOTREC_FOTA_NODE}
	busybox mount -o remount,rw /
	busybox ln -sf /sbin/busybox /sbin/sh
	extract_elf_ramdisk -i ${BOOTREC_FOTA} -o /sbin/ramdisk-recovery.cpio -t / -c
	busybox rm /sbin/sh
	if [ -f /sbin/ramdisk-recovery.cpio ]; then
		load_image=/sbin/ramdisk-recovery.cpio
		# unpack the ramdisk image
		busybox cpio -i < ${load_image}
	else
		load_image=/sbin/twrp.cpio.bz2
		# unpack the ramdisk image
		busybox bzcat ${load_image} | busybox cpio -i
	fi

elif [ -s /dev/keycheck_down -a -n "busybox" ] || busybox grep -q warmboot=0x77665502 /proc/cmdline; then
	busybox echo 'Volume DOWN' >>boot.txt
	busybox echo 'RECOVERY BOOT' >>boot.txt
	# orange led for recoveryboot
	busybox echo 0 > ${BOOTREC_LED_RED}
	busybox echo 0 > ${BOOTREC_LED_GREEN}
	busybox echo 255 > ${BOOTREC_LED_BLUE}
	# recovery ramdisk
	busybox mount -o remount,rw /
	load_image=/sbin/twrp.cpio.bz2
	# unpack the ramdisk image
	busybox bzcat ${load_image} | busybox cpio -i

elif [ -s /dev/keycheck_camera -a -n "busybox" ]; then
	busybox echo 'Camera button' >>boot.txt
	busybox echo 'FOTA BOOT' >>boot.txt
	# orange led for recoveryboot
	busybox echo 255 > ${BOOTREC_LED_RED}
	busybox echo 0 > ${BOOTREC_LED_GREEN}
	busybox echo 0 > ${BOOTREC_LED_BLUE}
	# recovery ramdisk
	busybox mknod -m 600 ${BOOTREC_FOTA_NODE}
	busybox mount -o remount,rw /
	busybox ln -sf /sbin/busybox /sbin/sh
	extract_elf_ramdisk -i ${BOOTREC_FOTA} -o /sbin/ramdisk-recovery.cpio -t / -c
	busybox rm /sbin/sh
	if [ -f /sbin/ramdisk-recovery.cpio ]; then
		load_image=/sbin/ramdisk-recovery.cpio
		# unpack the ramdisk image
		busybox cpio -i < ${load_image}
	else
		load_image=/sbin/twrp.cpio.bz2
		# unpack the ramdisk image
		busybox bzcat ${load_image} | busybox cpio -i
	fi
else
	# android ramdisk
	load_image=/sbin/ramdisk.cpio.bz2
	# unpack the ramdisk image
	busybox bzcat ${load_image} | busybox cpio -i
fi

# poweroff LED
busybox echo 0 > ${BOOTREC_LED_RED}
busybox echo 0 > ${BOOTREC_LED_GREEN}
busybox echo 0 > ${BOOTREC_LED_BLUE}



busybox umount /proc
busybox umount /sys

busybox rm -fr /dev/*
busybox date >>boot.txt
export PATH="${_PATH}"
exec /init

exit 0

