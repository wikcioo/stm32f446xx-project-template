#!/bin/bash

RED_COLOR='\033[0;31m'
GREEN_COLOR='\033[0;32m'
NO_COLOR='\033[0m'

function echo_color() {
    echo -e "$1$2${NO_COLOR}"
}

files_to_change=(
    "Makefile"
    ".vscode/launch.json"
)

read -p "Enter project name: " project_name

for file in "${files_to_change[@]}"; do
    sed -i "s/__project_name__/${project_name}/g" "$file"
done

packages=()
missing=()
package_finder=""
package_installer=""

function detect_system() {
    if command -v pacman &>/dev/null; then
        package_finder="pacman -Q"
        package_installer="pacman -S"
        packages=(
            "arm-none-eabi-gcc"
            "arm-none-eabi-gdb"
            "arm-none-eabi-binutils"
            "clang" # for clang-format
            "stlink"
            "make"
        )
    elif command -v apt &>/dev/null; then
        package_finder="dpkg-query -W -f='\${Status}'"
        package_installer="apt install"
        packages=(
            "gcc-arm-none-eabi"
            "gdb-multiarch"
            "binutils-arm-none-eabi"
            "clang" # for clang-format
            "stlink-tools"
            "make"
        )
    else
        echo "This script only supports Debian and Arch \
based distributions for installing packages"
        exit 1
    fi
}

detect_system

echo "Checking for required packages:"
for pkg in "${packages[@]}"; do
    eval "$package_finder $pkg &>/dev/null"
    return_value=$?
    if [ $return_value -eq 0 ]; then
        echo_color "$GREEN_COLOR" "\"$pkg\" found"
    else
        echo_color "$RED_COLOR" "\"$pkg\" not found"
        missing+=("$pkg")
    fi
done

if [ ${#missing[@]} -ne 0 ]; then
    echo "The following packages are missing: ${missing[@]}"
    read -p "Do you want to install them now? (Y/n) " answer

    if [ "$answer" = "y" ] || [ "$answer" = "Y" ] || [ "$answer" = "" ]; then
        eval "sudo $package_installer ${missing[@]}"
    fi
fi
