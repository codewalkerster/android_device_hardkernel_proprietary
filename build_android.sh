#!/bin/bash

CPU_JOB_NUM=$(grep processor /proc/cpuinfo | awk '{field=$NF};END{print field+1}')
CLIENT=$(whoami)

ROOT_DIR=$(pwd)
KERNEL_DIR="$ROOT_DIR/../TC4_Kernel_3.0"
export KERNEL_DIR
export ANDROID_JAVA_HOME="/opt/sun-jdk-1.6.0.33"

#SEC_PRODUCT='generic' #Enable for generic build
SEC_PRODUCT=$1
WIFI_CROSS_COMPILER=/usr/local/arm/arm-2009q3/bin/arm-none-linux-gnueabi-
export WIFI_CROSS_COMPILER 

IMAGE_OUT_DIR="$ROOT_DIR/$SEC_PRODUCT-img"

OUT_DIR="$ROOT_DIR/out/target/product/$SEC_PRODUCT"
OUT_HOSTBIN_DIR="$ROOT_DIR/out/host/linux-x86/bin"

export OUT=$OUT_DIR

option="recovery"

function check_exit()
{
	if [ $? != 0 ]
	then
		exit $?
	fi
}
# SEMCO wifi module build
function build_wifi()
{
	echo
	echo '[[[[[[[ Build wifi ]]]]]]]'
	echo

	cd $ROOT_DIR/compat-wireless
	make
  cd ..
}

function build_android()
{
	echo
	echo '[[[[[[[ Build android platform ]]]]]]]'
	echo

	START_TIME=`date +%s`
	if [ $SEC_PRODUCT = "generic" ]
	then
		echo make -j$CPU_JOB_NUM
		echo
		make -j$CPU_JOB_NUM
	else
		echo make -j$CPU_JOB_NUM PRODUCT-$SEC_PRODUCT-eng
		echo
		make -j$CPU_JOB_NUM PRODUCT-$SEC_PRODUCT-eng
#echo make -j$CPU_JOB_NUM otapackage TARGET_PRODUCT=$SEC_PRODUCT
#make -j$CPU_JOB_NUM otapackage TARGET_PRODUCT=$SEC_PRODUCT
	fi
	check_exit

	END_TIME=`date +%s`
	let "ELAPSED_TIME=$END_TIME-$START_TIME"
	echo "Total compile time is $ELAPSED_TIME seconds"
}

function make_uboot_img()
{
	cd $OUT_DIR

	echo
	echo '[[[[[[[ Make ramdisk image for u-boot ]]]]]]]'
	echo

	mkimage -A arm -O linux -T ramdisk -C none -a 0x40800000 -n "ramdisk" -d ramdisk.img ramdisk-uboot.img
	check_exit
	rm -f ramdisk.img

	echo
	cd ../../../..
}
#----------NOTICE--------------------------------------------------------
#before compile the recovery image, please setting the option likes below
#	TARGET_NO_KERNEL := false
#in file BoardConfig.mk
#------------------------------------------------------------------------
function make_recovery_img()
{
	echo "MAKE RECOVERY IMAGE----"
	#chmod 777 build/tools/releasetools/ota_from_target_files
	#mkimage -A arm -O linux -T ramdisk -C none -a 0x40800000 -n "ramdisk" -d ramdisk-recovery.img ramdisk-recovery-uboot.img
	echo make -j$CPU_JOB_NUM otapackage PRODUCT-$SEC_PRODUCT-eng
	make -j$CPU_JOB_NUM otapackage TARGET_PRODUCT=$SEC_PRODUCT
}

function make_fastboot_img()
{
	echo
	echo '[[[[[[[ Make additional images for fastboot ]]]]]]]'
	echo

	if [ ! -f $KERNEL_DIR/arch/arm/boot/zImage ]
	then
		echo "No zImage is found at $KERNEL_DIR/arch/arm/boot"
		echo '  Please set KERNEL_DIR if you want to make additional images'
		echo "  Ex.) export KERNEL_DIR=~ID/android_kernel_$SEC_PRODUCT"
		echo
		return
	fi

	echo 'boot.img ->' $OUT_DIR
	cp $KERNEL_DIR/arch/arm/boot/zImage $OUT_DIR/zImage
	$OUT_HOSTBIN_DIR/mkbootimg --kernel $OUT_DIR/zImage --ramdisk $OUT_DIR/ramdisk-uboot.img -o $OUT_DIR/boot.img
	check_exit

	echo 'update.zip ->' $OUT_DIR
	zip -j $OUT_DIR/update.zip $OUT_DIR/android-info.txt $OUT_DIR/boot.img $OUT_DIR/system.img
	check_exit

	echo
}

function copy_output_data()
{
	echo 
	echo '[[[[[[[ OUTPUT FOLDER = '$IMAGE_OUT_DIR' ]]]]]]]'
	echo

	mkdir -p $IMAGE_OUT_DIR
	rm -rf $IMAGE_OUT_DIR/*
	
	cp -a $OUT_DIR/system.img $IMAGE_OUT_DIR
	cp -a $OUT_DIR/system $IMAGE_OUT_DIR
	cp -a $OUT_DIR/*.zip $IMAGE_OUT_DIR
	cd $IMAGE_OUT_DIR

	# deleted .svn .git folder
	find . -type d -name .svn -print0 | xargs -0 rm -rf
	find . -type d -name .git -print0 | xargs -0 rm -rf

#chmod 777 -R *
	sync
}

SYSTEMIMAGE_PARTITION_SIZE=$(grep "BOARD_SYSTEMIMAGE_PARTITION_SIZE " device/hardkernel/$SEC_PRODUCT/BoardConfig.mk | awk '{field=$NF};END{print field}')
function copy_root_2_system()
{
	echo
    echo '[[[[[[[ copy ramdisk rootfs to system ]]]]]]]'
	echo

    rm -rf $OUT_DIR/system/init
    rm -rf $OUT_DIR/system/sbin/adbd
	cp -arp $OUT_DIR/root/* $OUT_DIR/system/
	mv $OUT_DIR/system/init $OUT_DIR/system/bin/
	ln -sf $OUT_DIR/system/bin/init $OUT_DIR/system/init
	mv $OUT_DIR/system/sbin/adbd $OUT_DIR/system/bin/
	ln -sf $OUT_DIR/system/bin/adbd $OUT_DIR/system/sbin/adbd

    echo 'SYSTEMIMAGE_PARTITION_SIZE'
  	echo $SYSTEMIMAGE_PARTITION_SIZE

    find $OUT_DIR/system -name .svn | xargs rm -rf
	$OUT_HOSTBIN_DIR/make_ext4fs -s -l $SYSTEMIMAGE_PARTITION_SIZE -a system $OUT_DIR/system.img $OUT_DIR/system

	sync
}

function make_update_zip()
{
	echo
	echo '[[[[[[[ Make update zip ]]]]]]]'
	echo

	if [ ! -d $OUT_DIR/update ]
	then
		mkdir $OUT_DIR/update
	else
		rm -rf $OUT_DIR/update/*
	fi

	cp $ROOT_DIR/device/hardkernel/$SEC_PRODUCT/kernel $OUT_DIR/update/zImage
	cp $OUT_DIR/system.img $OUT_DIR/update/
	split -b 16M $OUT_DIR/system.img $OUT_DIR/update/system_
	rm -rf $OUT_DIR/update/system.img
	cp $OUT_DIR/userdata.img $OUT_DIR/update/
	split -b 16M $OUT_DIR/userdata.img $OUT_DIR/update/userdata_
	rm -rf $OUT_DIR/update/userdata.img
	cp $OUT_DIR/cache.img $OUT_DIR/update/cache_aa

	if [ -f $OUT_DIR/update.zip ]
	then
		rm -rf $OUT_DIR/update.zip
		rm -rf $OUT_DIR/update.zip.md5sum
	fi

	echo 'update.zip ->' $OUT_DIR
	pushd $OUT_DIR
	zip -r update.zip update/*
	md5sum update.zip > update.zip.md5sum
	check_exit

	echo
	popd
}

echo
echo '                Build android for '$SEC_PRODUCT''
echo

case "$SEC_PRODUCT" in
	smdkv310)
		build_android
		make_uboot_img
#make_fastboot_img
		;;
	smdk4x12)
		#build_wifi
		build_android
		make_uboot_img
#make_fastboot_img
		if [[ $1 = $option ]]
		then
			make_recovery_img
		fi
		;;
	odroidx)
		build_android
        copy_root_2_system
		make_update_zip
		make_uboot_img
		copy_output_data
#make_fastboot_img
		if [[ $1 = $option ]]
		then
			make_recovery_img
		fi
		;;
	odroidx2)
		build_android
        copy_root_2_system
		make_update_zip
		make_uboot_img
		copy_output_data
#make_fastboot_img
		if [[ $1 = $option ]]
		then
			make_recovery_img
		fi
		;;
	odroidq)
		build_android
        copy_root_2_system
		make_update_zip
		make_uboot_img
		copy_output_data
#make_fastboot_img
		if [[ $1 = $option ]]
		then
			make_recovery_img
		fi
		;;
	odroidq2)
		build_android
        copy_root_2_system
		make_update_zip
		make_uboot_img
		copy_output_data
#make_fastboot_img
		if [[ $2 = $option ]]
		then
			make_recovery_img
		fi
		;;
	odroidu)
		build_android
        copy_root_2_system
		make_update_zip
		make_uboot_img
		copy_output_data
#make_fastboot_img
		if [[ $1 = $option ]]
		then
			make_recovery_img
		fi
		;;
	smdk5250)
		build_android
		make_uboot_img
#make_fastboot_img
		;;
	generic)
		build_android
		make_uboot_img
		;;
	*)
		echo "Please, set SEC_PRODUCT"
		echo "  export SEC_PRODUCT=smdkv310 or SEC_PRODUCT=smdk4x12 or SEC_PRODUCT=smdk5250 SEC_PRODUCT=odroidq SEC_PRODUCT=odroidq2 SEC_PRODUCT=odroidx SEC_PRODUCT=odroidx2 SEC_PRODUCT=odroidu"
		echo "     or "
		echo "  export SEC_PRODUCT=generic"
		exit 1
		;;
esac

echo ok success !!!

exit 0
