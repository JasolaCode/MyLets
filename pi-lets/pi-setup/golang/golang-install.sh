sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install vim
mkdir ~/golang && cd ~/golang
# version will change, alter the URL to match the new URL
wget https://dl.google.com/go/go1.14.4.linux-armv6l.tar.gz 
# Extract the package into your local folder
sudo tar -C /usr/local -xzf go1.14.4.linux-armv61.tar.gz
# not necessary to remove the .tar after install if you want to keep it
rm go1.14.4.linux-armv61.tar.gz
# Append the following lines to the end of the file
echo 'GOPATH=$HOME/golang' >> ~/.profile
echo 'PATH=$PATH:$GOROOT/bin:$GOPATH/bin' >> ~/.profile
# Update the shell with the changes
source ~/.profile
# and check your version
go version
# EXPECTED OUTPUT: go version go1.20.2 linux/arm
# Permanently add $GOPATH to $PATH
# Append the following lines to the end of the file
echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc
# Run the following to implement the changes
source ~/.bashrc
# To check that it implemented fine
echo $PATH
# change the configuration in the file **/etc/dphys-swapfile **:
sudo nano /etc/dphys-swapfile
# The default value in Raspbian is:
CONF_SWAPSIZE=100
# We will need to change this to:
CONF_SWAPSIZE=1024
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
