#!/bin/bash
# This is a script for the setup and install of rtl-sdr packages for sdr-server (on the rpi)

#sdr-pi-server-install

HMDIR=$(echo ~)

# install dependencies, creating dir for the server to be in
sudo apt-get install git cmake libusb-1.0-0.dev build-essential
mkdir /usr/local/bin/sdr-server && cd /usr/local/bin/sdr-server

#clone git repo to run the sdr-server operations
git clone git://git.osmocom.org/rtl-sdr.git $HMDIR/repos/
cd $HMDIR/repos/rtl-sdr/
# installation process according to repo instructions
mkdir build
cd build
cmake ../ -DINSTALL_UDEV_RULES=ON -DDETACH_KERNEL_DRIVER=ON
make
sudo make install
sudo ldconfig


# expect output of 'lsusb' to include: Bus 001 Device 003: ID 0bda:2838 Realtek Semiconductor Corp. RTL2838 DVB-T
echo $(lsusb)

# the below line need to be injected into the file being mentioned 
sudo echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", GROUP="adm", MODE="0666", SYMLINK+="rtl_sdr"' >> /etc/udev/rules.d/20.rtlsdr.rules

echo $(id jasola)

# Add a symlink when dongle is attached
udevadm control --reload-rules
udevadm trigger

# ensure that this is created by udev
echo $(ls -la /dev/rtl_sdr)

#test the device
echo $(rtl_test)


# run 'rtl_tcp -a 192.168.0.154'
# use 'lsusb' to lsit the currently plugged in devices
# in gqrx, for I/O device, put in 'rtl_tcp=192.168.0.154:1234'
