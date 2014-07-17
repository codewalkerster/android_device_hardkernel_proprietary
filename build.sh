#!/bin/bash

CPU_JOB_NUM=$(grep processor /proc/cpuinfo | awk '{field=$NF};END{print field+1}')
CLIENT=$(whoami)

ROOT_DIR=$(pwd)

if [ $# -lt 1 ]
then
	echo "Usage: ./build.sh <PRODUCT> [ kernel | platform | all ]"
	exit 0
fi

if [ ! -f device/hardkernel/$1/build-info.sh ]
then
	echo "NO PRODUCT to build!!"
	exit 0
fi

source device/hardkernel/$1/build-info.sh
BUILD_OPTION=$2

OUT_DIR="$ROOT_DIR/out/target/product/$PRODUCT_BOARD"
OUT_HOSTBIN_DIR="$ROOT_DIR/out/host/linux-x86/bin"
KERNEL_CROSS_COMPILE_PATH="$ROOT_DIR/prebuilts/gcc/linux-x86/arm/arm-eabi-4.6/bin/arm-eabi-"

function check_exit()
{
	if [ $? != 0 ]
	then
		exit $?
	fi
}

function build_kernel()
{
	echo
	echo '[[[[[[[ Build android kernel ]]]]]]]'
	echo

	START_TIME=`date +%s`
	pushd $KERNEL_DIR
	echo "set defconfig for $PRODUCT_BOARD"
	echo
	make ARCH=arm $PRODUCT_BOARD"_defconfig"
	check_exit
	echo "make"
	echo
	make -j$CPU_JOB_NUM > /dev/null ARCH=arm CROSS_COMPILE=$KERNEL_CROSS_COMPILE_PATH
	check_exit
	END_TIME=`date +%s`

	let "ELAPSED_TIME=$END_TIME-$START_TIME"
	echo "Total compile time is $ELAPSED_TIME seconds"

	popd
}

function build_android()
{
        echo
        echo '[[[[[[[ Build android platform ]]]]]]]'
        echo

        START_TIME=`date +%s`
        echo "source build/envsetup.sh"
        source build/envsetup.sh
        echo
        echo "lunch $PRODUCT_BOARD-eng"
        lunch $PRODUCT_BOARD-eng
        echo
        echo "make -j$CPU_JOB_NUM"
        echo
        make -j$CPU_JOB_NUM
        check_exit

        END_TIME=`date +%s`
        let "ELAPSED_TIME=$END_TIME-$START_TIME"
        echo "Total compile time is $ELAPSED_TIME seconds"
}

function make_uboot_img()
{
	pushd $OUT_DIR

	echo
	echo '[[[[[[[ Make ramdisk image for u-boot ]]]]]]]'
	echo

	mkimage -A arm -O linux -T ramdisk -C none -a 0x40800000 -n "ramdisk" -d ramdisk.img ramdisk-uboot.img
	check_exit

	rm -f ramdisk.img

	echo
	popd
}

function make_fastboot_img()
{
	echo
	echo '[[[[[[[ Make additional images for fastboot ]]]]]]]'
	echo

	if [ ! -f $KERNEL_DIR/arch/arm/boot/zImage ]
	then
		echo "No zImage is found at $KERNEL_DIR/arch/arm/boot"
		echo
		return
	fi

	echo 'boot.img ->' $OUT_DIR
	cp $KERNEL_DIR/arch/arm/boot/zImage $OUT_DIR/zImage
	$OUT_HOSTBIN_DIR/mkbootimg --kernel $OUT_DIR/zImage --ramdisk $OUT_DIR/ramdisk.img -o $OUT_DIR/boot.img
	check_exit

	echo 'update.zip ->' $OUT_DIR
	zip -j $OUT_DIR/update.zip $OUT_DIR/android-info.txt $OUT_DIR/boot.img $OUT_DIR/system.img
	check_exit

	echo
}

SYSTEMIMAGE_PARTITION_SIZE=$(grep "BOARD_SYSTEMIMAGE_PARTITION_SIZE " device/hardkernel/odroidxu/BoardConfig.mk | awk '{field=$NF};END{print field}')

function copy_root_2_system()
{
	echo
    echo '[[[[[[[ copy ramdisk rootfs to system ]]]]]]]'
	echo

    rm -rf $OUT_DIR/system/init
    rm -rf $OUT_DIR/system/sbin/adbd
    rm -rf $OUT_DIR/system/sbin/healthd
	cp -arp $OUT_DIR/root/* $OUT_DIR/system/
	mv $OUT_DIR/system/init $OUT_DIR/system/bin/
	mv $OUT_DIR/system/sbin/adbd $OUT_DIR/system/bin/
	mv $OUT_DIR/system/sbin/healthd $OUT_DIR/system/bin/

    cd $OUT_DIR/system
    ln -s bin/init init
    cd $OUT_DIR/system/sbin
    ln -s ../bin/adbd adbd
    ln -s ../bin/healthd healthd

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

    echo '$PRODUCT_BOARD'

	cp $ROOT_DIR/device/hardkernel/$PRODUCT_BOARD/zImage $OUT_DIR/update/
	cp $OUT_DIR/system.img $OUT_DIR/update/
	cp $OUT_DIR/userdata.img $OUT_DIR/update/
	cp $OUT_DIR/cache.img $OUT_DIR/update/

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
echo '                Build android for '$PRODUCT_BOARD''
echo

case "$BUILD_OPTION" in
	kernel)
		build_kernel
		;;
	platform)
		build_android
        copy_root_2_system
		make_update_zip
		;;
	all)
		build_kernel
		build_android
        copy_root_2_system
		make_update_zip
		;;
	*)
        build_android
        copy_root_2_system
		make_update_zip
		;;
esac

echo ok success !!!

exit 0
