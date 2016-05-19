#!/sbin/busybox sh

## Set the color directly to led number <led_number>
# light_on <red> <green> <blue>
light_on(){
	busybox echo $1 > ${BOOTREC_LED_RED}
	busybox echo $2 > ${BOOTREC_LED_GREEN}
	busybox echo $3 ${BOOTREC_LED_BLUE}
}


## Fades led number <led_number> to the given values in ~ <time> / 100 seconds
# fade_to <red> <green> <blue> <time>
fade_to(){

	i=0
	length=$(($4 / 5)); # Reduces the step number

	red_start=$(busybox cat ${BOOTREC_LED_RED});
	green_start=$(busybox cat ${BOOTREC_LED_GREEN});
	blue_start=$(busybox cat ${BOOTREC_LED_BLUE});
	
	red_diff=$(($1 - red_start));
	green_diff=$(($2 - green_start));
	blue_diff=$(($3 - blue_start));
	
	frac=0;
	while [ $i -le $length ]; do
		frac=$((i * 100000 / $length));

		light_on $((red_start + red_diff * frac / 100000)) $((green_start + green_diff * frac / 100000)) $((blue_start + blue_diff * frac / 100000))
		
		i=$((i + 1))
		busybox sleep 0.03;
	done
}

fade_to 228 128 6 150
fade_to 0 0 0 150
