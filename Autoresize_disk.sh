# If you have 3 boot device sda1 sda2 sda5 or more, put '1' in BDS
# if you have only 2 boot device sda1 sda2 put '2' in BDS
BDS="1"
# Rescan your device
echo 1 > /sys/class/scsi_device/1\:0\:0\:0/device/rescan
echo 1 > /sys/class/scsi_device/2\:0\:0\:0/device/rescan
# Find new sector end 
end_size=$(cat /sys/block/sda/size)
# If you need you can found start sector
start_sector=$(sudo fdisk -l | grep ^/dev/sda1 |  awk -F" "  '{ print $3 }')
# Found last sector for sda1
last_sector_sda1=$(($end_size - 2095104))
# Found start sector for sda2 (if u need)
start_sector_sda2=$((last_sector_sda1 + 1))

# Magic :D
case "$BDS" in
	"1" )
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/sda
	d
	1
	d
	2
	n
	p
	1
	 # default value
	$last_sector_sda1
	n
	p
	2
	 # default value
	 # default value
	t
	2
	82
	w
EOF
	;;
	"2" )
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/sda
	d 
	1
	d
	n
	p
	1
	 # default value
	$last_sector_sda1
	n
	p
	2
	 # default value
	 # default value
	t
	2
	82
	w
EOF
	;;
esac
# We've made the changes to the partition table, they haven't taken effect; we need to do < partprobe -s > for read new map on fly.
echo -e "Your old df -h\n"
df -h > /tmp/dfh
cat /tmp/dfh
echo -e "\n"
# Remap on fly
partprobe -s
# Resize /dev/sda1 (it's our /)
resize2fs /dev/sda1
df -h > /tmp/dfh
echo -e " "
echo -e "!!!!Done, check your size!!!!\n"
cat /tmp/dfh
##Anton Stefiienko