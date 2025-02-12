#!/usr/bin/env bash

## Author: Danilo - S58DB
## E-mail: s58db.danilo@gmail.com

## Preveri, ali je whiptail nameščen
if ! command -v whiptail &> /dev/null; then
    echo "Whiptail ni nameščen. Namesti ga s: sudo apt install whiptail"
    exit 1
fi

## Funkcija za prikaz sporočila v Whiptail
function displayMessage() {
    whiptail --title "$1" --msgbox "$2" 8 78
}

## Namestitev SVXLink na RPi
function install_svxlink_rpi() {
    cd ~
    sudo apt update && sudo apt full-upgrade -y
    sudo apt-get install -y build-essential wget g++ cmake make libsigc++-2.0-dev \
        libgsm1-dev libpopt-dev tcl-dev libgcrypt20-dev libspeex-dev libasound2-dev \
        libopus-dev librtlsdr-dev doxygen groff alsa-utils vorbis-tools curl \
        libcurl4-openssl-dev git rtl-sdr libjsoncpp-dev speedtest-cli mutt mc \
        libgpiod-dev gpiod libssl-dev 

    sudo useradd -U -r -G audio,plugdev,daemon,gpio svxlink || echo "User already exists."

    cd ~
    git clone https://github.com/sm0svx/svxlink.git
    cd svxlink
    git reset --hard 12c9d9b
    mkdir ~/svxlink/src/build
    cd ~/svxlink/src/build 
    cmake -DUSE_QT=OFF -DCMAKE_INSTALL_PREFIX=/usr -DSYSCONF_INSTALL_DIR=/etc \
          -DLOCAL_STATE_DIR=/var -DWITH_SYSTEMD=ON ..
    make && make doc
    sudo make install
    sudo ldconfig

    cd /usr/share/svxlink/sounds/
    sudo wget https://github.com/sm0svx/svxlink-sounds-en_US-heather/releases/download/24.02/svxlink-sounds-en_US-heather-16k-24.02.tar.bz2
    sudo tar xvjf svxlink-sounds-en_US-heather-16k-24.02.tar.bz2
    sudo mv en_US-heather-16k en_US
    sudo rm svxlink-sounds-en_US-heather-16k-24.02.tar.bz2

    displayMessage "Namestitev dokončana" "SVXLink je uspešno nameščen na RPi!"
}

## Namestitev SVXLink na PC
function install_svxlink_pc() {
    cd ~
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get install -y build-essential wget g++ cmake make libsigc++-2.0-dev \
        libgsm1-dev libpopt-dev tcl-dev libgcrypt20-dev libspeex-dev libasound2-dev \
        libopus-dev librtlsdr-dev doxygen groff alsa-utils vorbis-tools curl \
        libcurl4-openssl-dev git rtl-sdr libjsoncpp-dev speedtest-cli mutt mc alsa-utils 

    sudo useradd -U -r -G audio,plugdev,daemon svxlink || echo "User already exists."

    cd ~
    git clone https://github.com/sm0svx/svxlink.git
    cd svxlink
    git reset --hard 12c9d9b
    mkdir ~/svxlink/src/build
    cd ~/svxlink/src/build 
    cmake -DUSE_QT=OFF -DCMAKE_INSTALL_PREFIX=/usr -DSYSCONF_INSTALL_DIR=/etc \
          -DLOCAL_STATE_DIR=/var -DWITH_SYSTEMD=ON ..
    make && make doc
    sudo make install
    sudo ldconfig

    cd /usr/share/svxlink/sounds/
    sudo wget https://github.com/sm0svx/svxlink-sounds-en_US-heather/releases/download/24.02/svxlink-sounds-en_US-heather-16k-24.02.tar.bz2
    sudo tar xvjf svxlink-sounds-en_US-heather-16k-24.02.tar.bz2
    sudo mv en_US-heather-16k en_US
    sudo rm svxlink-sounds-en_US-heather-16k-24.02.tar.bz2

    displayMessage "Namestitev dokončana" "SVXLink je uspešno nameščen na PC!"
}

## Brisanje SVXLink iz sistema
function uninstall_svxlink() {
    sudo rm -rf ~/svxlink/ /etc/svxlink/ /var/spool/svxlink/ /usr/share/svxlink/
    displayMessage "Brisanje dokončano" "SVXLink je bil odstranjen iz sistema!"
}

## Kopiranje pomembnih datotek SVXLink
function copy_svxlink_files() {
    cd ~
    backup_dir="Kopija_SVXLink_$(date +"%d_%m_%Y")"
    mkdir -p "$backup_dir/etc/svxlink" "$backup_dir/usr/share/svxlink" "$backup_dir/var/spool/svxlink"

    cp -r /etc/svxlink/* "$backup_dir/etc/svxlink/"
    cp -r /usr/share/svxlink/* "$backup_dir/usr/share/svxlink/"
    cp -r /var/spool/svxlink/* "$backup_dir/var/spool/svxlink/"

    chown -hR pi:pi "$backup_dir"

    displayMessage "Varnostna kopija končana" "Varnostna kopija se nahaja v: $HOME/$backup_dir"
}

## Glavni meni z Whiptail
function main() {
    while true; do
        menusvxlink=$(whiptail --title "...::::: SVXLink Namestitveni čarovnik :::::..." \
            --ok-button "Izberi" --cancel-button "Izhod" \
            --menu "Izberi namestitev" 20 78 10 \
            "1" "..:: Namesti SVXLink na RPi ::.." \
            "2" "..:: Namesti SVXLink na PC ::.." \
            "3" "..:: Ustvari varnostno kopijo SVXLink ::.." \
            "4" "..:: Odstrani SVXLink iz sistema ::.." \
            "5" "..:: Izhod ::.." \
            3>&1 1>&2 2>&3)

        exitstatus=$?
        if [ ${exitstatus} = 0 ]; then
            case ${menusvxlink} in
                1) install_svxlink_rpi ;;
                2) install_svxlink_pc ;;
                3) copy_svxlink_files ;;
                4) uninstall_svxlink ;;
                5) exit ;;
            esac
        else
            exit
        fi
    done
}

## Zaženi glavni meni
main
