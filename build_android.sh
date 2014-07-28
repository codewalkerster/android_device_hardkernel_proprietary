#!/bin/bash

CPU_JOB_NUM=$(grep processor /proc/cpuinfo | awk '{field=$NF};END{print field+1}')
CLIENT=$(whoami)

ROOT_DIR=$(pwd)

#SEC_PRODUCT='generic' #Enable for generic build


SEC_PRODUCT=$1

OUT_DIR="$ROOT_DIR/out/target/product/$SEC_PRODUCT"
OUT_HOSTBIN_DIR="$ROOT_DIR/out/host/linux-x86/bin"
 
if [  -f $OUT_DIR/ramdisk.img ]
then
    rm -f $OUT_DIR/ramdisk.img
fi

option="recovery"
function check_exit()
{
	if [ $? != 0 ]
	then
		exit $?
	fi
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

SYSTEMIMAGE_PARTITION_SIZE=$(grep "BOARD_SYSTEMIMAGE_PARTITION_SIZE " device/hardkernel/$SEC_PRODUCT/BoardConfig.mk | awk '{field=$NF};END{print field}')
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

	cp $ROOT_DIR/device/hardkernel/$SEC_PRODUCT/zImage $OUT_DIR/update/zImage
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
	odroidu)
		. build/envsetup.sh
		lunch odroidu-eng
		build_android
        copy_root_2_system
        make_update_zip
		if [[ $2 = "otapackage" ]]
		then                            
		    ./build_otapackage.sh
		fi
		;;	
    odroidx2)
		. build/envsetup.sh
		lunch odroidx2-eng
		build_android
        copy_root_2_system
        make_update_zip
		if [[ $2 = "otapackage" ]]
		then                            
		    ./build_otapackage.sh
		fi
		;;	
    odroidx)
		. build/envsetup.sh
		lunch odroidx-eng
		build_android
        copy_root_2_system
        make_update_zip
		if [[ $2 = "otapackage" ]]
		then                            
		    ./build_otapackage.sh
		fi
		;;	
    odroidq2)
		. build/envsetup.sh
		lunch odroidq2-eng
		build_android
        copy_root_2_system
        make_update_zip
		if [[ $2 = "otapackage" ]]
		then                            
		    ./build_otapackage.sh
		fi
		;;	
	*)	
		echo "Please, add SEC_PRODUCT"
		echo "  ./build_android.sh odroidx2"
		
		exit 1
		;;
esac

echo ok success !!!

exit 0
