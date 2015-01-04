#!/bin/bash
#####################################################
#### Alberto Azuara
#### Versión 1.0
#### 05/01/15
#### Descarga y compilacion de kernel Raspbian aplicando los parches de Xenomai
#####################################################

cd data/linux-kernel

patch -Np1 < ../../Xenomai-2.6/ksrc/arch/arm/patches/raspberry/ipipe-core-3.8.13-raspberry-pre-2.patch

../../Xenomai-2.6/scripts/./prepare-kernel.sh --arch=arm --linux=./ --adeos=../../Xenomai-2.6/ksrc/arch/arm/patches/ipipe-core-3.8.13-arm-4.patch


patch -Np1 < ../../Xenomai-2.6/ksrc/arch/arm/patches/raspberry/ipipe-core-3.8.13-raspberry-post-2.patch

patch -p1 < ../../usb_fiq.patch

cd ..
cd ..

