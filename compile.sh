#!/bin/bash
#####################################################
#### Alberto Azuara
#### Versión 1.0
#### 05/01/15
#### Download and compile Raspbian applying Xenomai patches
#####################################################

TOOLS_COMMIT="108317fde2ffb56d1dc7f14ac69c42f34a49342a"
#TOOLS_COMMIT="master"

DIR="$(pwd)"
cd "$DIR"
THREADS=$(($(cat /proc/cpuinfo | grep processor | wc -l) * 2))
if [ `getconf LONG_BIT` == "64" ]; then
	echo "[*] 64-bit Machine"
	MACHINE_BITS="64"
else
	echo "[*] 32-bit Machine"
	MACHINE_BITS="32"
fi

mkdir data/ > /dev/null 2>&1
mkdir build/ > /dev/null 2>&1

echo -n "[*] Checking utilities compilation ... "
type make > /dev/null 2>&1 || { echo >&2 "[!] Install \"make\""; read -p "Press [Enter] to continue..."; exit 1; }
type gcc > /dev/null 2>&1 || { echo >&2 "[!] Install \"gcc\""; read -p "Press [Enter] to continue..."; exit 1; }
type g++ > /dev/null 2>&1 || { echo >&2 "[!] Install \"g++\""; read -p "Press [Enter] to continue..."; exit 1; }

if [ "$(dpkg --get-selections | grep -w libncurses5-dev | grep -w install)" = "" ]; then
	echo "[!] Install \"libncurses5-dev\""
	read -p "Press [Enter] to continue..."
	exit 1
fi

export USE_PRIVATE_LIBGCC=yes

TOOLS_PATH="$DIR/data/tools-$TOOLS_COMMIT"

if [ "$MACHINE_BITS" == "64" ]; then
	export CCPREFIX="$TOOLS_PATH/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin/arm-linux-gnueabihf-"
else
	export CCPREFIX="$TOOLS_PATH/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin/arm-linux-gnueabihf-"
fi

if [ ! -f "${CCPREFIX}gcc" ]; then
	echo -n "Download cross-compile tools... "
	cd data
	wget --no-check-certificate -q -O - "https://github.com/raspberrypi/tools/archive/$TOOLS_COMMIT.tar.gz" | tar -zx
	cd ..
fi

echo "ok! "

set -e

echo "[*] Updating / checking Raspbian module..."
git submodule update --init --recursive

echo -n "[*] Comprobando git... "

if [ "$(git config user.email)" == "" ]; then
	echo -n "creando usuario falso... "
	git config --global user.email "raspbianrt@example.com"
	git config --global user.name "RaspbianRT"
fi

echo "ok!"

echo "[*] Cleaning old data..."
rm -rf data/linux-kernel
rm -rf build/*
mkdir data/linux-kernel

echo "[*] Copy kernel..."
cp -r Raspbian/* data/linux-kernel

echo "[*] Patching ..."
./applyPatches.sh
if [ "$?" != "0" ]; then
	echo "[!] Error patching"
else
	echo "[+]Xenomai patches applied correctly"
fi


cd data/linux-kernel

echo "[*] Usando $THREADS hilos"
echo "[*] Cleaning kernel..."
make mrproper


cp ../../rpi_xenomai_config.txt .config
#ARCH=arm CROSS_COMPILE=${CCPREFIX} make -j $THREADS oldconfig

echo "[*] Creating menuconfig ..."
ARCH=arm CROSS_COMPILE=${CCPREFIX} make -j $THREADS menuconfig

echo "[*] Compiling kernel ..."
ARCH=arm CROSS_COMPILE=${CCPREFIX} make bzImage -j $THREADS

echo "[*] Compilando modulos..."
ARCH=arm CROSS_COMPILE=${CCPREFIX} make -j $THREADS modules

echo "[*] Compiling modules ..."
rm -rf ../modules
mkdir ../modules
ARCH=arm CROSS_COMPILE=${CCPREFIX} INSTALL_MOD_PATH=../modules/ make -j $THREADS modules_install

echo "[*] Copying resulting image ..."
cp arch/arm/boot/zImage ../../build/kernel.img

echo "[*] Archiving modules ..."
cd ../modules
tar -czf ../../build/modules.tar.gz .

echo "[*] Ready!"

exit 0
