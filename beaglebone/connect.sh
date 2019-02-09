sudo cu -s 115200 -l /dev/ttyU0
sudo ifconfig ue0 192.168.141.101
sudo ssh -i ~/.ssh/2018-2019-l41-insecure-private-key "root@192.168.141.100"
