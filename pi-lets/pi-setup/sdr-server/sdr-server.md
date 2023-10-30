# RPI SDR Server

This has been setup using a pre-existing github repo **git://git.osmocom.org/rtl-sdr.git**.
The setup is quite easy as I've put all the commands into an **install-sdr-server.sh** file. This can be run to setup a new RPI, operating as an SDR RTL_TCP Server.

Once this is properly installed, the server can be run with the following command:

```bash
rtl_tcp -a 192.168.0.154 # Input your own IP address already assigned to the RPI
```

