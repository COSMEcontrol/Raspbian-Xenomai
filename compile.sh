#!/bin/bash
#####################################################
#### Alberto Azuara
#### Versión 1.0
#### 05/01/15
#### Descarga y compilacion de kernel Raspbian aplicando los parches de Xenomai
#####################################################

TOOLS_COMMIT="108317fde2ffb56d1dc7f14ac69c42f34a49342a"
#TOOLS_COMMIT="master"

DIR="$(pwd)"
cd "$DIR"
THREADS=$(($(cat /proc/cpuinfo | grep processor | wc -l) * 2))
if [ `getconf LONG_BIT` == "64" ]; then
	echo "[*] Maquina actual es 64-bit"
	MACHINE_BITS="64"
else
	echo "[*] Maquina actual es 32-bit"
	MACHINE_BITS="32"
fi

mkdir data/ > /dev/null 2>&1
mkdir build/ > /dev/null 2>&1

echo -n "[*] Comprobando utilidades de compilacion... "
type make > /dev/null 2>&1 || { echo >&2 "[!] Instalar \"make\""; read -p "Press [Enter] to continue..."; exit 1; }
type gcc > /dev/null 2>&1 || { echo >&2 "[!] Instalar \"gcc\""; read -p "Press [Enter] to continue..."; exit 1; }
type g++ > /dev/null 2>&1 || { echo >&2 "[!] Instalar \"g++\""; read -p "Press [Enter] to continue..."; exit 1; }

if [ "$(dpkg --get-selections | grep -w libncurses5-dev | grep -w install)" = "" ]; then
	echo "[!] Instalar \"libncurses5-dev\""
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
	echo -n "descargando cross-compile tools... "
	cd data
	wget --no-check-certificate -q -O - "https://github.com/raspberrypi/tools/archive/$TOOLS_COMMIT.tar.gz" | tar -zx
	cd ..
fi

echo "ok! "

set -e

echo "[*] Actualizando/comprobando modulo Raspbian..."
git submodule update --init --recursive

echo -n "[*] Comprobando git... "

if [ "$(git config user.email)" == "" ]; then
	echo -n "creando usuario falso... "
	git config --global user.email "raspbianrt@example.com"
	git config --global user.name "RaspbianRT"
fi

echo "ok!"

echo "[*] Limpiando datos antiguos..."
rm -rf data/linux-kernel
rm -rf build/*
mkdir data/linux-kernel

echo "[*] Aplicando parches..."
./applyPatches.sh
if [ "$?" != "0" ]; then
	echo "[!] Error al aplicar parches Xenomai"
else
	echo "[+] Parches Xenomai aplicados correctamente"
fi
echo "[*] Copiando kernel..."
cp -r Raspbian/* data/linux-kernel

cd data/linux-kernel

echo "[*] Usando $THREADS hilos"
echo "[*] Limpiando kernel..."
make mrproper


mv rpi_xenomai_config.txt .config
#ARCH=arm CROSS_COMPILE=${CCPREFIX} make -j $THREADS oldconfig

echo "[*] Creando menuconfig..."
ARCH=arm CROSS_COMPILE=${CCPREFIX} make -j $THREADS menuconfig

echo "[*] Compilando kernel..."
ARCH=arm CROSS_COMPILE=${CCPREFIX} make bzImage -j $THREADS

echo "[*] Compilando modulos..."
ARCH=arm CROSS_COMPILE=${CCPREFIX} make -j $THREADS modules

echo "[*] Instalando modulos de kernel..."
rm -rf ../modules
mkdir ../modules
ARCH=arm CROSS_COMPILE=${CCPREFIX} INSTALL_MOD_PATH=../modules/ make -j $THREADS modules_install

echo "[*] Copiando imagen resultante..."
cp arch/arm/boot/zImage ../../build/kernel.img

echo "[*] Archivando modulos..."
cd ../modules
tar -czf ../../build/modules.tar.gz .

echo "[*] Listo!"

exit 0
