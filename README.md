# STM32F446xx project template

The purpose of this repository is to quickly get started writing firmware for STM32F446xx based microcontrollers.\
**Note** that this repository has only been tested on Arch Linux.

## Get started

### Clone the repository
```shell
git clone https://github.com/wikcioo/stm32f446xx-project-template.git
cd stm32f446xx-project-template
```

### Execute the configure script to set the project name and install required packages
```shell
chmod +x configure.sh
./configure.sh
```

### Compile
```shell
make all -j4
```

### Flash the firmware onto the target
```shell
make flash
```

## Check the status

The project template contains an example to make sure that the firmware is working correctly.\
After flashing the firmware onto the target, it will start printing "The application is running..." through the serial connection.\
You can check out the output using **minicom** program.

```shell
sudo minicom -D /dev/ttyACM0 -b 115200
```