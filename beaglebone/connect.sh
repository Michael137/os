$(cu -s 115200 -l /dev/ttyU0)
ifconfig ue0 192.168.141.101
ssh -i ~/.ssh/2018-2019-l41-insecure-private-key "root@192.168.141.100"
