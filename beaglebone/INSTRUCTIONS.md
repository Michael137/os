# Connect serial cable
Pin 2: white
Pin 3: pink
Pin 5: black

# Connect over serial
1. `sudo cu -s 115200 -l /dev/ttyU0`
2. Plug in power
3. Will boot into FreeBSD on SD card

# Connect over ssh
1. Connect ethernet (can also check the log while connecting using `tail -F /var/log/messages`)
2. Check ethernet interface (`cpsw0`) IP with `ifconfig`
3. On client run `ssh <user>@<ethernet inet>`
