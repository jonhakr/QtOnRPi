# QtOnRPi

## Scripts for setting up Qt on RPi


### Cross-Compile toolchain for Rpi

1. Prepare your host by running `qtDeps_<host>.sh`

2. Prepare your RPi by running `qtCC_rpi.sh prep dirs` on your RPi

3. Configure IP-address, username and password for your RPi in **qtCC\_host.sh**

4. Run `**qtCC\_host.sh** all`

5. Run `qtCC_rpi.sh link libfix`
