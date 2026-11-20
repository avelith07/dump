#!/usr/bin/env bash
set -Eeuo pipefail

TANGGAL=$(date +"%Y%m%d-%H")

compile() {

   echo "Setting up ligma environment"

    # Environment
    source "$HOME/.bashrc" 2>/dev/null || true
    source "$HOME/.profile" 2>/dev/null || true

    # Architecture
    export LC_ALL=C
    export ARCH=arm64
    export SUBARCH=arm64

    # Clang 20
    export PATH="/usr/lib/llvm-20/bin:$PATH"
    export CC='ccache clang'
    export LD=ld.lld
    export LLVM=1

    # Cross-compilers
    export CROSS_COMPILE=aarch64-linux-gnu-
    export CROSS_COMPILE_COMPAT=arm-linux-gnueabi-
    export COMPATCC=arm-linux-gnueabi-gcc

    echo "Checking toolchain..."
    clang --version
    ld.lld --version

    echo "Generating RM6785 base ligma config..."
    make O=out ARCH=arm64 nemo_defconfig

    # echo "Merging droidspaces_config..."
    # ./scripts/kconfig/merge_config.sh \
    #  -O out \
    #   out/.config \
    #  arch/arm64/configs/droidspaces_config

    echo "Resolving configuration dependencies..."
    make O=out ARCH=arm64 olddefconfig

    echo "Checking final configuration..."
    cat out/.config | grep -E "DRM|VGEM|KSU|CONFIGFS|NOMOUNT|NETFILTER_XT_TARGET_HL|CHECKPOINT_RESTORE|KALLSYMS|DEBUG_KERNEL|POSIX_MQUEUE|USER_NS|CGROUP|PARANOID|MEMCG|LOCALVERSION"

    echo "Ahh kernel release:"
    make O=out ARCH=arm64 kernelrelease

    echo "Building nigma kernel..."
    make -j"$(nproc)" O=out \
        ARCH=arm64 \
        SUBARCH=arm64 \
        CC='ccache clang' \
        LLVM=1 \
        LD=ld.lld \
        CROSS_COMPILE=aarch64-linux-gnu- \
        CROSS_COMPILE_COMPAT=arm-linux-gnueabi- \
        COMPATCC=arm-linux-gnueabi-gcc

    echo "Checking ahh kernel image..."
    if [[ ! -s "out/arch/arm64/boot/Image.gz" ]]; then
        echo "ERROR: Image.gz was not generated."
        echo "Check whether this kernel builds Image.gz, Image.gz-dtb, or another format."
        exit 1
    fi

    echo "Build finished successfully."
}

zipping() {
    echo "Creating flashable zip..."

    rm -rf AnyKernel
    git clone --depth=1 https://github.com/kardebayan/AnyKernel3.git AnyKernel

    cp out/arch/arm64/boot/Image.gz AnyKernel

    cd AnyKernel
    zip -r9 Kernel-nemo-${TANGGAL}.zip . \
        --exclude=".git/*" --exclude="*.zip"

    echo "Zip created: Kernel-nemo-${TANGGAL}.zip"

}

compile
zipping
