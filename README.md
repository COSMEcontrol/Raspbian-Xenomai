Raspbian-Xenomai
=================
Patch Raspbian OS with official Xenomai patches, compile and run into Raspberry Pi.

Features
========
* Raspbian Linux 3.8.13

* Patch Xenomai-2.6

* Configure Xenomai

* Enable/Disable Xenomai RT drivers
  
  ![Config RT](screenshots/raspbian_logo.png)
  ![Config drivers](screenshots/xenomai-config.png)
  ![Config RT](screenshots/config-drivers.png)

Usage
=====
To run and compile Raspbian RT:

```groovy
  ./compile.sh
```
This generates two files:
  
    build/
        *|---> kernel.img   
        *|---> modules.tar.gz
        
  *Replace kernel.img in the boot partition
  
  *Unzip the modules in file system partition

```groovy
uname -a 
  Linux raspberrypi 3.8.13xenomai #1 Mon Jan 5 01:35:34 CET 2015 armv6l GNU/Linux
```
Building Xenomai libraries for Raspberry Pi
============================================

Download source code

```groovy
  git clone http://git.xenomai.org/xenomai-2.6.git
```
Configure

```groovy
  cd xenomai-2.6/
  ./configure
```
Compile code
```groovy
  make
```
Install libraries

```groovy
  sudo make install
```

# High resolution test with cyclictest

All tests have been run on Raspberry Pi 1 model B

* To generate synthetic load on the Raspberry Pi has used the command: 
```groovy
      cat / dev / zero> / dev / null
```
  This command writes zeros in null device, and puts the CPU 100% load.

Test case: clock_nanosleep(TIME_ABSTIME), Interval 10000 microseconds,. 10000 loops, no load.
```groovy
pi@raspberrypi ~/xenomai-2.6 $ sudo /usr/xenomai/bin/cyclictest  -t1 -p 80 -n -i 10000 -l 10000
T: 0 (16088) P:80 I:   10000 C:   10000 Min:      19 Act:      36 Avg:      15 Max:      50
```
Test case: clock_nanosleep(TIME_ABSTIME), Interval 10000 micro seconds,. 10000 loops, 100% load.
```groovy
pi@raspberrypi ~/xenomai-2.6 $ sudo /usr/xenomai/bin/cyclictest -t1 -p 80 -n -i 10000 -l 10000         
T: 0 (16125) P:80 I:   10000 C:   10000 Min:      17 Act:      36 Avg:      15 Max:      51
```
Test case: POSIX interval timer, Interval 10000 micro seconds,. 10000 loops, no load.
```groovy
sudo /usr/xenomai/bin/cyclictest -t1 -p 80 -i 10000 -l 10000
T: 0 (16129) P:80 I:   10000 C:   10000 Min:      17 Act:      37 Avg:      17 Max:      51
```
Test case: POSIX interval timer, Interval 10000 micro seconds,. 10000 loops, 100% load.
```groovy
pi@raspberrypi ~/xenomai-2.6 $ sudo /usr/xenomai/bin/cyclictest -t1 -p 80 -i 10000 -l 10000
T: 0 (16134) P:80 I:   10000 C:   10000 Min:      18 Act:      28 Avg:      15 Max:      50
```
