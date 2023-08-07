#!/bin/sh

#QEMU_BIN=/usr/bin/qemu-system-x86_64
#QEMU_BIN=/home/akashi/.local_gpu/bin/qemu-system-x86_64
QEMU_BIN=/home/akashi/.local_gpu_v4/bin/qemu-system-x86_64

#export LD_LIBRARY_PATH=/home/akashi/.local_gpu/lib/x86_64-linux-gnu
export LD_LIBRARY_PATH=/home/akashi/.local_gpu_v4/lib/x86_64-linux-gnu
#export LD_LIBRARY_PATH=/home/akashi/x86/Vulkan-Loader/build/loader:$LD_LIBRARY_PATH
#export LIBGL_DRIVERS_PATH=/lib/x86_64-linux-gnu/dri

#IMG=/opt/disk/ubuntu_gpu.qcow2
#IMG=/opt/disk/ubuntu_gpu_new.qcow2
IMG=/media/akashi/9c294da6-3517-431a-9c23-057662ab07b6/disk/ubuntu_gpu_new2.qcow2
ISO=/opt/disk/ubuntu-22.04.2-desktop-amd64.iso

#ECHO="echo"
#ECHO="gdb --args"

#DEBUG="-s -S"
#DEBUG="-S -gdb tcp::1234"
NETDEV="-net nic,model=virtio -net user,hostfwd=tcp::2222-:22"

# Only for installation
#    -display gtk                    \
#    -boot d -cdrom $ISO

#    -vga virtio			    \
#    -vga std -display gtk	    \

#    -device virtio-gpu-pci	    \
#    -device virtio-gpu-gl-pci \
#    -device virtio-vga-gl,context_init=true,blob=true,hostmem=4G \

#    -M q35                          \
#    -machine memory-backend=mem1                                 \
#    -object memory-backend-memfd,id=mem1,size=4G                 \
#    -machine memory-backend=mem1                                 \

# For NVIDIA, see
# https://github.com/clearlinux/distribution/issues/2718
# use -display sdl instead of -display gtk
# but virtio-gpu-gl-pci doesn't work even with this option


#    -device virtio-vga-gl,iommu_platform=on,hostmem=4G,blob=true,context_init=true           \

#export VK_DEBUG=1
export VK_LOADER_DEBUG=warn,err
export LIBGL_DEBUG=verbose

#export MESA_DEBUG=1
#export MESA_LOG=file
#export MESA_LOG_FILE=stderr
#export MESA_DEBUG_FILE=1

#export VREND_DEBUG=cmd,obj
#export VREND_DEBUG=all
#export VREND_DEBUG=caller,obj

#export LD_DEBUG=symbols,bindings

#export AMD_VULKAN_ICD=AMDVLK
export AMD_VULKAN_ICD=RADV

export VK_DRIVER_FILES=/home/akashi/.local_gpu_v4/share/vulkan/icd.d/radeon_icd.x86_64.json
export VK_ICD_FILENAMES=/home/akashi/.local_gpu_v4/share/vulkan/icd.d/radeon_icd.x86_64.json

#lld ${QEMU_BIN}
#${QEMU_BIN}                  \

#gdb ${QEMU_BIN} 
#exit

#    -device virtio-vga-gl,iommu_platform=on,hostmem=4G,blob=true,context_init=true           \

${ECHO} ${QEMU_BIN} ${DEBUG}        \
    -enable-kvm                     \
    -smp 1                          \
    -m 4G                           \
    -hda $IMG			    \
    -serial mon:stdio		    \
    -device virtio-vga-gl,iommu_platform=on,hostmem=16G,blob=true,context_init=true           \
    -display gtk,gl=on              \
    -object memory-backend-memfd,id=mem1,size=4G,share=on                 \
    -machine q35,accel=kvm,kernel-irqchip=split,memory-backend=mem1                   \
    -device intel-iommu,intremap=on \
    -device virtio-balloon \
    ${NETDEV} \
    -d guest_errors		    \
    -boot d
