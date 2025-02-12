#!/usr/bin/env bash
set -e  # Ustavi skripto, če pride do napake

## Prikaz sporočila v terminalu
function display_message() {
    echo "[INFO] $1: $2"
}

## Glavni meni
function main() {
    while true; do
        echo "[INFO] Prikaz glavnega menija..."
        echo "1) Install SVXLink on RPi"
        echo "2) Install SVXLink on PC"
        echo "3) Copy important SVXLink folders"
        echo "4) Remove SVXLink folder from system"
        echo "5) Exit"

        read -p "Izberi možnost: " menusvxlink
        case ${menusvxlink} in
            1) install_svxlink_rpi ;;
            2) install_svxlink_pc ;;
            3) copy_svxlink_files ;;
            4) uninstall_svxlink ;;
            5) exit ;;
            *) echo "[NAPAKA] Napačna izbira!";;
        esac
    done
}

## Ustvari ali posodobi uporabnika 'svxlink' z ustreznimi skupinami
function create_svxlink_user() {
    local user_groups="$1"  # Sprejme seznam skupin kot argument (različne za PC/RPi)

    if id "svxlink" &>/dev/null; then
        echo "[INFO] User 'svxlink' already exists, updating groups..."
        sudo usermod -aG $user_groups svxlink
    else
        echo "[INFO] Creating user 'svxlink'..."
        sudo useradd -U -r -G $user_groups svxlink
    fi
}

## Namestitev SVXLink na Raspberry Pi
function install_svxlink_rpi() {
    echo "[INFO] Začenjam namestitev SVXLink na RPi..."

    cd ~
    sudo apt update && sudo apt full-upgrade -y
    sudo apt-get install -y build-essential wget g++ cmake make libsigc++-2.0-dev libgsm1-dev \
        libpopt-dev tcl-dev libgcrypt20-dev libspeex-dev libasound2-dev libopus-dev librtlsdr-dev \
        doxygen groff alsa-utils vorbis-tools curl libcurl4-openssl-dev git rtl-sdr libjsoncpp-dev \
        speedtest-cli mutt mc libssl-dev libgpiod-dev gpiod

    # Ustvari uporabnika (RPi verzija - VSE skupine, vključno z gpio)
    create_svxlink_user "audio,plugdev,daemon,gpio"

    if [ ! -d "$HOME/svxlink" ]; then
        git clone https://github.com/sm0svx/svxlink.git
    else
        echo "[INFO] SVXLink repozitorij že obstaja. Preskakujem kloniranje..."
    fi

    cd ~/svxlink
    git reset --hard 12c9d9b
    mkdir -p ~/svxlink/src/build
    cd ~/svxlink/src/build

    cmake -DUSE_QT=OFF -DCMAKE_INSTALL_PREFIX=/usr -DSYSCONF_INSTALL_DIR=/etc \
        -DLOCAL_STATE_DIR=/var -DWITH_SYSTEMD=ON ..
    make || { echo "[NAPAKA] Make ni uspel! Izhod..."; exit 1; }
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
    echo "[INFO] Začenjam namestitev SVXLink na PC..."

    cd ~
    sudo apt update && sudo apt full-upgrade -y
    sudo apt-get install -y build-essential wget g++ cmake make libsigc++-2.0-dev libgsm1-dev \
        libpopt-dev tcl-dev libgcrypt20-dev libspeex-dev libasound2-dev libopus-dev librtlsdr-dev \
        doxygen groff alsa-utils vorbis-tools curl libcurl4-openssl-dev git rtl-sdr libjsoncpp-dev \
        speedtest-cli mutt mc libssl-dev

    # Ustvari uporabnika (PC verzija - BREZ skupine gpio)
    create_svxlink_user "audio,plugdev,daemon"

    if [ ! -d "$HOME/svxlink" ]; then
        git clone https://github.com/sm0svx/svxlink.git
    else
        echo "[INFO] SVXLink repozitorij že obstaja. Preskakujem kloniranje..."
    fi

    cd ~/svxlink
    git reset --hard 12c9d9b
    mkdir -p ~/svxlink/src/build
    cd ~/svxlink/src/build

    cmake -DUSE_QT=OFF -DCMAKE_INSTALL_PREFIX=/usr -DSYSCONF_INSTALL_DIR=/etc \
        -DLOCAL_STATE_DIR=/var -DWITH_SYSTEMD=ON ..
    make || { echo "[NAPAKA] Make ni uspel! Izhod..."; exit 1; }
    sudo make install
    sudo ldconfig

    cd /usr/share/svxlink/sounds/
    sudo wget -q https://github.com/sm0svx/svxlink-sounds-en_US-heather/releases/download/24.02/svxlink-sounds-en_US-heather-16k-24.02.tar.bz2
    sudo tar xvjf svxlink-sounds-en_US-heather-16k-24.02.tar.bz2
    sudo mv en_US-heather-16k en_US
    sudo rm svxlink-sounds-en_US-heather-16k-24.02.tar.bz2

    display_message "Installation Complete" "SVXLink has been successfully installed on PC."
}

## Zagon glavnega menija
main
