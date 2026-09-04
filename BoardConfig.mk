#
# Copyright (C) 2021-2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

USE_PREBUILT_KERNEL ?= false

# Partitions
BOARD_SUPER_PARTITION_SIZE := 17062428672

# Include the common OEM chipset BoardConfig.
include device/oneplus/sm8850-common/BoardConfigCommon.mk

DEVICE_PATH := device/oneplus/infiniti

# Assert
TARGET_OTA_ASSERT_DEVICE := OP60FFL1,OP611FL1

# Display
TARGET_SCREEN_DENSITY := 540

# Kernel
ifeq ($(USE_PREBUILT_KERNEL), true)
include device/oneplus/infiniti-kernel/BoardConfig.mk
endif

# Properties
TARGET_ODM_PROP += $(DEVICE_PATH)/odm.prop
TARGET_SYSTEM_EXT_PROP += $(DEVICE_PATH)/system_ext.prop
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop

# Recovery
TARGET_RECOVERY_UI_MARGIN_HEIGHT := 103

# Include the proprietary files BoardConfig.
include vendor/oneplus/infiniti/BoardConfigVendor.mk

# Source-built DTB/DTBO generation
TARGET_KERNEL_DTB_TARGET := canoe_perf_dtb_build
TARGET_KERNEL_DTB_REPACK_SCRIPT := device/oneplus/infiniti/repack_dtb_oem_order.sh
TARGET_KERNEL_DTB_PREBUILT_SOURCE := device/oneplus/infiniti-kernel/images/infiniti.dtb
TARGET_KERNEL_DTBO_REPACK_SCRIPT := device/oneplus/infiniti/repack_dtbo_oem_order.sh

TARGET_KERNEL_EXT_DTBO_DIRS := \
    vendor/qcom/opensource/audio-devicetree \
    vendor/qcom/opensource/bt-devicetree \
    vendor/qcom/opensource/camera-devicetree \
    vendor/qcom/opensource/data-devicetree \
    vendor/qcom/opensource/display-devicetree \
    vendor/qcom/opensource/dsp-devicetree \
    vendor/qcom/opensource/eSE-devicetree \
    vendor/qcom/opensource/eva-devicetree \
    vendor/qcom/opensource/graphics-devicetree \
    vendor/qcom/opensource/mm-devicetree \
    vendor/qcom/opensource/mmrm-devicetree \
    vendor/qcom/opensource/nfc-devicetree \
    vendor/qcom/opensource/synx-devicetree \
    vendor/qcom/opensource/video-devicetree \
    vendor/qcom/opensource/wlan/wlan-devicetree \
    vendor/qcom/proprietary/display-devicetree \
    vendor/qcom/proprietary/mm-devicetree

# Canoe's source build produces zram and zsmalloc in a dedicated
# collision-module distribution.
TARGET_KERNEL_COLLISION_MODULES_DIST_TARGET := \
    //soc-repo:canoe_perf_lineage_collision_modules_dist
TARGET_KERNEL_COLLISION_MODULES_OUT_DIR := lineage-canoe-modules
TARGET_KERNEL_COLLISION_MODULES := \
    zram.ko \
    zsmalloc.ko

# These proprietary modules are incompatible with debug stripping.
TARGET_KERNEL_MODULES_PRESERVE_DEBUG_INFO := \
    oplus_bsp_ex_gpio.ko \
    oplus_icc_mcu.ko \
    oplus_network_702_satellite.ko \
    oplus_network_data_module.ko \
    oplus_network_dns_cache.ko \
    oplus_network_dns_optimizer.ko \
    oplus_network_fast_bwe.ko \
    oplus_network_kernel_state_monitor.ko \
    oplus_network_satellite.ko \
    oplus_network_satellite_hl7603.ko \
    oplus_network_satellite_rpc.ko \
    oplus_network_satellite_rsmc.ko \
    oplus_network_sched.ko \
    oplus_network_sk_predict.ko \
    oplus_network_snapshot.ko \
    oplus_network_tcpdump_enhance.ko \
    oplus_network_vip_task.ko \
    qbt_handler.ko \
    qts.ko \
    st_fts.ko

# Stock game_first differs from released OSS source and crashes recovery.
TARGET_KERNEL_MODULE_PREBUILT_OVERRIDE_NAME := oplus_network_game_first.ko
TARGET_KERNEL_MODULE_PREBUILT_OVERRIDE_PATH := \
    device/oneplus/infiniti-kernel/modules/vendor_ramdisk/oplus_network_game_first.ko
