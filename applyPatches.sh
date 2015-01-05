#!/bin/bash
#####################################################
#### Alberto Azuara
#### Versión 1.0
#### 05/01/15
#### Descarga y compilacion de kernel Raspbian aplicando los parches de Xenomai
#####################################################

cd data/linux-kernel
echo "Aplicando pre patch especifico Raspy ...."
patch -Np1 < ../../Xenomai-2.6/ksrc/arch/arm/patches/raspberry/ipipe-core-3.8.13-raspberry-pre-2.patch
echo "ok! "
echo "Aplicando parche principal..."
../../Xenomai-2.6/scripts/./prepare-kernel.sh --arch=arm --linux=./ --adeos=../../Xenomai-2.6/ksrc/arch/arm/patches/ipipe-core-3.8.13-arm-3.patch
echo "ok! "
echo "Aplicando post patch especifico Raspy ...."
patch -Np1 < ../../Xenomai-2.6/ksrc/arch/arm/patches/raspberry/ipipe-core-3.8.13-raspberry-post-2.patch
echo "ok! "
echo "Aplicando parche usb Raspy ...."
patch -p1 < ../../usb_fiq.patch
echo "ok! "
cd ..
cd ..

