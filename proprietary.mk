PACKAGE_KODI = kodi-20160124-a545667-master-armeabi-v7a.apk

# Prebuild packages
PRODUCT_COPY_FILES += \
	device/hardkernel/proprietary/apk/$(PACKAGE_KODI):cache/$(PACKAGE_KODI) \
        device/hardkernel/proprietary/apk/Ultra_Explorer.apk:system/app/Ultra_Explorer.apk \
        device/hardkernel/proprietary/apk/jackpal.androidterm.apk:system/app/jackpal.androidterm.apk \
        device/hardkernel/proprietary/lib/libjackpal-androidterm5.so:system/lib/libjackpal-androidterm5.so \
        device/hardkernel/proprietary/lib/libjackpal-termexec2.so:system/lib/libjackpal-termexec2.so

# Companion libraries for prebuild packages
PRODUCT_COPY_FILES += \
        device/hardkernel/proprietary/apk/DicePlayer.apk:system/app/DicePlayer.apk \
        device/hardkernel/proprietary/lib/libSoundTouch.so:system/lib/libSoundTouch.so \
        device/hardkernel/proprietary/lib/libdice_kk.so:system/lib/libdice_kk.so \
        device/hardkernel/proprietary/lib/libdice_loadlibrary.so:system/lib/libdice_loadlibrary.so \
        device/hardkernel/proprietary/lib/libdice_software.so:system/lib/libdice_software.so \
        device/hardkernel/proprietary/lib/libdice_software_kk.so:system/lib/libdice_software_kk.so \
        device/hardkernel/proprietary/lib/libffmpeg_dice.so:system/lib/libffmpeg_dice.so \
        device/hardkernel/proprietary/lib/libsonic.so:system/lib/libsonic.so

# Input device calibration files
PRODUCT_COPY_FILES += \
        device/hardkernel/proprietary/bin/odroid-ts.idc:system/usr/idc/odroid-ts.idc \
        device/hardkernel/proprietary/bin/odroid-ts.kl:system/usr/keylayout/odroid-ts.kl \
        device/hardkernel/proprietary/bin/odroid-ts.kcm:system/usr/keylayout/odroid-ts.kcm \
        device/hardkernel/proprietary/bin/odroid-keypad.kl:system/usr/keylayout/odroid-keypad.kl \
        device/hardkernel/proprietary/bin/odroid-keypad.kcm:system/usr/keychars/odroid-keypad.kcm

# for USB HID MULTITOUCH
PRODUCT_COPY_FILES += \
        device/hardkernel/proprietary/bin/Vendor_03fc_Product_05d8.idc:system/usr/idc/Vendor_03fc_Product_05d8.idc \
        device/hardkernel/proprietary/bin/Vendor_1870_Product_0119.idc:system/usr/idc/Vendor_1870_Product_0119.idc \
        device/hardkernel/proprietary/bin/Vendor_1870_Product_0100.idc:system/usr/idc/Vendor_1870_Product_0100.idc \
        device/hardkernel/proprietary/bin/Vendor_2808_Product_81c9.idc:system/usr/idc/Vendor_2808_Product_81c9.idc

# XBox 360 Controller kl keymaps
PRODUCT_COPY_FILES += \
        device/hardkernel/proprietary/bin/Vendor_045e_Product_0291.kl:system/usr/keylayout/Vendor_045e_Product_0291.kl \
        device/hardkernel/proprietary/bin/Vendor_045e_Product_0719.kl:system/usr/keylayout/Vendor_045e_Product_0719.kl \
        device/hardkernel/proprietary/bin/Vendor_0c45_Product_1109.kl:system/usr/keylayout/Vendor_0c45_Product_1109 \
        device/hardkernel/proprietary/bin/Vendor_1b8e_Product_0cec_Version_0001.kl:system/usr/keylayout/Vendor_1b8e_Product_0cec_Version_0001 \
        device/hardkernel/proprietary/bin/Vendor_045e_Product_0719.kcm:system/usr/keychars/Vendor_045e_Product_0719.kcm
