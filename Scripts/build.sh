#!/bin/bash
set -e

TANGGAL=$(date +"%Y%m%d-%H")

compile() {
    echo "Cleaning..."
    rm -rf AnyKernel out

    source ~/.bashrc 2>/dev/null || true
    source ~/.profile 2>/dev/null || true

    export LC_ALL=C
    export USE_CCACHE=1
    export ARCH=arm64
    export SUBARCH=arm64

    # Toolchain
    export CC=clang
    export LLVM=1
    export LLVM_IAS=1
    export LD=ld.lld
    export CROSS_COMPILE=aarch64-linux-gnu-
    export CROSS_COMPILE_ARM32=arm-linux-gnueabi-

    # Host tools
    export HOSTCC=gcc
    export HOSTCXX=g++

    # Kernel string customization
    export KBUILD_BUILD_HOST=localhost
    export KBUILD_BUILD_USER=ptcm
    export KBUILD_COMPILER_STRING="Clang 19.1.7"

    echo "Generating ligma base config..."
    make O=out ARCH=arm64 nemo_defconfig

    echo "Merging droidspace.config..."
    ./scripts/kconfig/merge_config.sh -O out out/.config arch/arm64/configs/droidspace.config

    echo "Resolving dependencies..."
    make O=out ARCH=arm64 olddefconfig

    echo "Final config check..."
    grep -E "CONFIG_(DRM|KSU|SYSCTL|SYSVIPC|POSIX_MQUEUE|NAMESPACES|PID_NS|UTS_NS|IPC_NS|USER_NS|SECCOMP|SECCOMP_FILTER|CGROUPS|CGROUP_DEVICE|CGROUP_PIDS|DEVTMPFS|OVERLAY_FS|FW_LOADER|FW_LOADER_USER_HELPER|FW_LOADER_COMPRESS|NET_NS|VETH|BRIDGE|NETFILTER|BRIDGE_NETFILTER|NETFILTER_ADVANCED|NF_CONNTRACK|IP_NF_IPTABLES|IP_NF_FILTER|NF_NAT|NF_TABLES|IP_NF_TARGET_MASQUERADE|NETFILTER_XT_TARGET_MASQUERADE|NETFILTER_XT_TARGET_TCPMSS|NETFILTER_XT_MATCH_ADDRTYPE|NF_CONNTRACK_NETLINK|NF_NAT_REDIRECT|IP_ADVANCED_ROUTER|IP_MULTIPLE_TABLES|ANDROID_PARANOID_NETWORK|DRM_GEM_SHMEM_HELPER|DRM_SCHED|ION|DMABUF_HEAPS|DMA_SHARED_BUFFER|PM_DEVFREQ|DEVFREQ_GOV_SIMPLE_ONDEMAND|SYNC_FILE|SW_SYNC|DRM|HDMI|FB_CMDLINE|I2C|I2C_ALGOBIT|DRM_KMS_HELPER|SYNC_FILE|IOMMU_SUPPORT|IOMMU_IO_PGTABLE|IOMMU_IO_PGTABLE_LPAE)" out/.config

    echo "Building kernel..."
    make -j$(nproc --all) O=out \
        ARCH=arm64 \
        SUBARCH=arm64 \
        CC=clang \
        LLVM=1 \
        LLVM_IAS=1 \
        LD=ld.lld \
        CROSS_COMPILE=aarch64-linux-gnu- \
        CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
        HOSTCC=gcc \
        HOSTCXX=g++

    echo "Build finished"
}

zipping() {
    echo "Creating flashable zip..."

    rm -rf AnyKernel
    git clone --depth=1 https://github.com/kardebayan/AnyKernel3.git AnyKernel

    cp out/arch/arm64/boot/Image.gz AnyKernel

    cd AnyKernel
    zip -r9 Kernel-RMX2001L1-${TANGGAL}.zip . \
        --exclude=".git/*" --exclude="*.zip"

    echo "Zip created: Kernel-RMX2001L1-${TANGGAL}.zip"
}

compile
zipping
