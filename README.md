
# DDS665_Ctrl

**A simple tool to monitor and control DDS665 wattmeter**

DDS665 is a bi-directional compact and affordable energy meter compatible with DIN rails installation.  
This device can be very useful in case of grid feeding solar plants. 
Sold on line (ali-xxx or amaz-xxx), it can be purchased with a remote control switch option.

In both cases (with or without switch), it offers a RS485 interface that can communicate with a computer like RPi-zero using a RS485 to TTL adapter.  
RS485 comms are based on MODBUS-RTU protocol. Comms baud rate, and modbus slave_id can be configured on DDS665 (default to bauds=9600, id=1)

![DDS665 picture](/Docs/DDS665_1.png)


## Features
**Shows DDS metrics:**
- Frequency (Hz)
- Voltage (V)
- Current (A)
- Active Power (W)
- Power factor (cos)
- Total energy (kWh)
- Total negative energy (kWh)
- Total positive energy (kWh)

**Turns DDS ON or OFF**  
When used with -s option on DDS665 w/ remote switch.


## Documentation

[DDS665 Modbus communication protocol](./Docs/DDS665%20Single%20Phase%20Multifunctional%20Energy%20Meter%20ModBus%20RS485%20Communication%20Protocol.pdf)


## Installation

Install mobdus perl module

```bash
  perl -MCPAN -e shell install Device::Modbus
```
Install DDS665_Ctrl with git

```bash
  git clone https://github.com/Christophe-Jouan/DDS665_ctrl
```


## Usage/Examples
**Usage:**
```
./DDS665_ctrl.pl   [-h] [-d] [-s ON|OFF] [-p port] [-i modbus_id] [-b baud_rate]
        -p port      port to use for RS485 (default=/dev/ttyUSB0)
        -b baud      baud rate to use for RS485 (default=9600)
        -i id        modbus id to use (default=1)
        -s ON|OFF    switch DDS665 ON or OFF
        -d           activate debug mode
        -h           display help message
```

Example 1: **Monitor DDS665**
```shell
$ ./DDS665_ctrl.pl
Value of Power factor (cos) = 1
Value of Total energy (kWh) = 0.529999971389771
Value of Active Power (W) = 0
Value of Total negative energy (kWh) = 0.0199999995529652
Value of Current (A) = 0
Value of Voltage (V) = 234.600006103516
Value of Frequency (Hz) = 50
Value of Total positive energy (kWh)) = 0.509999990463257
```

Example 2: **Switch DDS665 OFF**
```shell
$ ./DDS665_ctrl.pl -s OFF
```

## Authors

- [@Christophe Jouan](https://www.github.com/Christophe-Jouan)

