#!/usr/bin/env bash
set -e  # Prekini izvajanje ob napaki

## Author: Danilo - S58DB
## E-mail: s58db.danilo@gmail.com

## Prikaz sporočila
function display_message() {
    whiptail --title "$1" --msgbox "$2" 8 78
}

## Glavni meni
function main() {
    while true; do
        menusvxlink=$(whiptail --title "...::::: SVXlink Installing Wizard :::::..." --ok-button "Select" --cancel-button "Quit" --menu "Izberi namestitev" 20 78 10 \
            "1" "..:: Install SVXLink on RPi ::.." \
            "2" "..:: Install SVXLink on PC ::.." \
            "3" "..:: Copy important SVXLink folders ::.." \
            "4" "..:: Remove SVXLink folder from system ::.." \
            3>&1 1>&2 2>&3)

        if [ $? -eq 0 ]; then
            case ${menusvxlink} in
                1) install_svxlink_rpi ;;
                2) install_svxlink_pc ;;
                3) copy_svxlink_files ;;
                4) uninstall_svxlink ;;
            esac
        else
            exit
        fi
    done
}

## Namestitev SVXLink na Raspberry Pi
function install_svxlink_rpi() {
    cd ~
    sudo apt update && sudo apt full-upgrade -y
    sudo apt-get install -y build-essential wget g++ cmake make libsigc++-2.0-dev libgsm1-dev \
        libpopt-dev tcl-dev libgcrypt20-dev libspeex-dev libasound2-dev libopus-dev librtlsdr-dev \
        doxygen groff alsa-utils vorbis-tools curl libcurl4-openssl-dev git rtl-sdr libjsoncpp-dev \
        speedtest-cli mutt mc libgpiod-dev gpiod libssl-dev

    sudo useradd -U -r -G audio,plugdev,daemon,gpio svxlink || echo "User already exists."

    if [ ! -d "$HOME/svxlink" ]; then
        git clone https://github.com/sm0svx/svxlink.git
    else
        echo "SVXLink already exists. Skipping clone..."
    fi

    cd ~/svxlink
    git reset --hard 12c9d9b
    mkdir -p ~/svxlink/src/build
    cd ~/svxlink/src/build

    cmake -DUSE_QT=OFF -DCMAKE_INSTALL_PREFIX=/usr -DSYSCONF_INSTALL_DIR=/etc \
        -DLOCAL_STATE_DIR=/var -DWITH_SYSTEMD=ON ..
    make || { echo "Make failed! Exiting..."; exit 1; }
    sudo make install
    sudo ldconfig

    cd /usr/share/svxlink/sounds/
    sudo wget -q https://github.com/sm0svx/svxlink-sounds-en_US-heather/releases/download/24.02/svxlink-sounds-en_US-heather-16k-24.02.tar.bz2
    sudo tar xvjf svxlink-sounds-en_US-heather-16k-24.02.tar.bz2
    sudo mv en_US-heather-16k en_US
    sudo rm svxlink-sounds-en_US-heather-16k-24.02.tar.bz2

    display_message "Installation Complete" "SVXLink has been successfully installed on Raspberry Pi."
}

## Namestitev SVXLink na PC
function install_svxlink_pc() {
    install_svxlink_rpi  # Koda je skoraj enaka, zato pokličemo isto funkcijo
}

## Odstranitev SVXLink
function uninstall_svxlink() {
    sudo rm -rf ~/svxlink /etc/svxlink /var/spool/svxlink /usr/share/svxlink
    display_message "Uninstall Complete" "All SVXLink files have been removed."
}

## Kopiranje SVXLink datotek
function copy_svxlink_files() {
    backup_dir="$HOME/Kopija_SVXLink_$(date +"%d_%m_%Y")"
    mkdir -p "$backup_dir"/{etc/svxlink,usr/share/svxlink,var/spool/svxlink}

    rsync -a /etc/svxlink/ "$backup_dir/etc/svxlink/"
    rsync -a /usr/share/svxlink/ "$backup_dir/usr/share/svxlink/"
    rsync -a /var/spool/svxlink/ "$backup_dir/var/spool/svxlink/"

    chown -R pi:pi "$backup_dir"
    display_message "Backup Complete" "Backup is saved in: $backup_dir"
}

## Zaženemo glavni meni
main
