# Input device calibration files
PRODUCT_COPY_FILES += \
        device/hardkernel/proprietary/bin/odroid-ts.idc:vendor/usr/idc/odroid-ts.idc \
        device/hardkernel/proprietary/bin/odroid-ts.idc:vendor/usr/idc/usbio-keypad.idc \
        device/hardkernel/proprietary/bin/odroid-ts.kl:vendor/usr/keylayout/odroid-ts.kl \
        device/hardkernel/proprietary/bin/odroid-ts.kcm:vendor/usr/keylayout/odroid-ts.kcm \
        device/hardkernel/proprietary/bin/odroid-keypad.kl:vendor/usr/keylayout/odroid-keypad.kl \
        device/hardkernel/proprietary/bin/odroid-keypad.kcm:vendor/usr/keychars/odroid-keypad.kcm

# for USB HID MULTITOUCH
PRODUCT_COPY_FILES += \
        device/hardkernel/proprietary/bin/Vendor_0eef_Product_0005.idc:vendor/usr/idc/Vendor_0eef_Product_0005.idc \
        device/hardkernel/proprietary/bin/Vendor_03fc_Product_05d8.idc:vendor/usr/idc/Vendor_03fc_Product_05d8.idc \
        device/hardkernel/proprietary/bin/Vendor_1870_Product_0119.idc:vendor/usr/idc/Vendor_1870_Product_0119.idc \
        device/hardkernel/proprietary/bin/Vendor_1870_Product_0100.idc:vendor/usr/idc/Vendor_1870_Product_0100.idc \
        device/hardkernel/proprietary/bin/Vendor_2808_Product_81c9.idc:vendor/usr/idc/Vendor_2808_Product_81c9.idc \
        device/hardkernel/proprietary/bin/Vendor_16b4_Product_0704.idc:vendor/usr/idc/Vendor_16b4_Product_0704.idc \
        device/hardkernel/proprietary/bin/Vendor_16b4_Product_0705.idc:vendor/usr/idc/Vendor_16b4_Product_0705.idc \
        device/hardkernel/proprietary/bin/Vendor_04d8_Product_0c03.idc:vendor/usr/idc/Vendor_04d8_Product_0c03.idc

# XBox 360 Controller kl keymaps
PRODUCT_COPY_FILES += \
        device/hardkernel/proprietary/bin/Vendor_045e_Product_0291.kl:vendor/usr/keylayout/Vendor_045e_Product_0291.kl \
        device/hardkernel/proprietary/bin/Vendor_045e_Product_0719.kl:vendor/usr/keylayout/Vendor_045e_Product_0719.kl \
        device/hardkernel/proprietary/bin/Vendor_0c45_Product_1109.kl:vendor/usr/keylayout/Vendor_0c45_Product_1109 \
        device/hardkernel/proprietary/bin/Vendor_045e_Product_0719.kcm:vendor/usr/keychars/Vendor_045e_Product_0719.kcm
