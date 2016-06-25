#!/sbin/sh
export work=/sbin
byname="/dev/block/bootdevice/by-name"
fstab="/sbin/boot/ramdisk/fstab.qcom"

boot_delete() {
	rm -r boot
	rm -r boot.img
	rm -r bootdw.img
}

boot_unpack() {
	cat ${byname}\/boot>$work/boot.img
	$work/mkboot $work/boot.img $work/boot
}

boot_repack() {
	$work/mkboot $work/boot $work/bootdw.img
	cat $work/bootdw.img>${byname}\/boot
	echo $(date)>$work/dwdone
}

boot_dmverity() {
	echo "Removing dm-verity ..."
	sed -i 's/,verify=\/dev\/block\/bootdevice\/by-name\/metadata//' $fstab
	sed -i 's/,verify=\/dev\/block\/bootdevice\/by-name//' $fstab
	sed -i 's/,verify//' $fstab
	sed -i 's/verify//' $fstab
}

boot_forcee() {
	echo "Removing forceencrypt ..."
	sed -i "s/forceencrypt/encryptable/" $fstab
	sed -i '/ro.secureboot.devicelock/d' $work/boot/ramdisk/default.prop
}

boot_main() {
	boot_delete
	boot_unpack
	boot_dmverity
	boot_forcee
	boot_repack
}

boot_main
