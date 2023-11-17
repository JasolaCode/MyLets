# change the configuration in the file **/etc/dphys-swapfile **:
sudo sed -i '' 's/CONF_SWAPSIZE=100/SWAP_SIZE=1024/g' /etc/dphys-swapfile
# The default value in Raspbian is:
# CONF_SWAPSIZE=100
# We will need to change this to:
# CONF_SWAPSIZE=1024
# Then you need to stop and start the service that manages the swapfile own Rasbian:
sudo /etc/init.d/dphys-swapfile stop
sudo /etc/init.d/dphys-swapfile start
# You can then verify the amount of memory + swap by issuing the following command:
free -m
# Install the Bettercap dependencies
sudo apt-get install build-essential libpcap-dev libusb-1.0-0-dev libnetfilter-queue-dev git
# Next we'll get the bettercap repo into the /usr/local/bin/bettercap
# go get github.com/bettercap/bettercap... This one didn't work
git clone https://github.com/bettercap/bettercap.git
cd bettercap
# idk how the below line works... kinda neat!
make build
# idk how this one works either... also neat!
make install
