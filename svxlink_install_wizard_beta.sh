#!/usr/bin/env bash

## Preverimo, ali je Whiptail nameščen
if ! command -v whiptail &>/dev/null; then
    echo "Whiptail ni nameščen! Namesti ga s: sudo apt install whiptail"
    exit 1
fi

## Funkcija za izbiro načina prikaza napredka
function should_show_progress() {
    whiptail --title "Izbira prikaza" --yesno \
        "Ali želite spremljati namestitev v živo?" 10 60
    return $?  # Vrne 0 za "Da", 1 za "Ne"
}

## Funkcija za izvajanje ukazov z ali brez prikaza napredka
function run_with_optional_progress() {
    local command="$1"
    local log_file="/tmp/install_log.txt"

    # Počisti prejšnje loge
    > "$log_file"

    if should_show_progress; then
        # Če uporabnik izbere "Da", prikažemo sprotni izpis
        bash -c "$command" &> "$log_file" &
        pid=$!
        while kill -0 $pid 2>/dev/null; do
            tail -n 10 "$log_file" | whiptail --title "Namestitev v teku..." --textbox - 15 80
            sleep 2
        done
        whiptail --title "Zaključek namestitve" --textbox "$log_file" 20 80
    else
        # Če izbere "Ne", se ukazi izvedejo brez prikaza
        bash -c "$command" &> "$log_file"
    fi
}

## Funkcija za namestitev SVXLink na Raspberry Pi
function install_svxlink_rpi() {
    run_with_optional_progress '
        cd ~
        sudo apt update && sudo apt full-upgrade -y
        sudo apt-get install -y build-essential wget g++ cmake make \
            libsigc++-2.0-dev libgsm1-dev libpopt-dev tcl-dev libgcrypt20-dev \
            libspeex-dev libasound2-dev libopus-dev librtlsdr-dev doxygen \
            groff alsa-utils vorbis-tools curl libcurl4-openssl-dev git rtl-sdr \
            libjsoncpp-dev speedtest-cli mutt mc libgpiod-dev gpiod libssl-dev

        sudo useradd -U -r -G audio,plugdev,daemon,dialout,gpio svxlink || echo "User already exists."

        git clone https://github.com/sm0svx/svxlink.git
        cd svxlink
        git reset --hard 12c9d9b
        mkdir -p ~/svxlink/src/build
        cd ~/svxlink/src/build
        cmake -DUSE_QT=OFF -DCMAKE_INSTALL_PREFIX=/usr -DSYSCONF_INSTALL_DIR=/etc \
              -DLOCAL_STATE_DIR=/var -DWITH_SYSTEMD=ON ..
        make
        make doc
        sudo make install
        sudo ldconfig

        cd /usr/share/svxlink/sounds/
        sudo wget https://github.com/sm0svx/svxlink-sounds-en_US-heather/releases/download/24.02/svxlink-sounds-en_US-heather-16k-24.02.tar.bz2
        sudo tar xvjf svxlink-sounds-en_US-heather-16k-24.02.tar.bz2
        sudo mv en_US-heather-16k en_US
        sudo rm svxlink-sounds-en_US-heather-16k-24.02.tar.bz2
    '
}

## Funkcija za namestitev SVXLink na PC
function install_svxlink_pc() {
    run_with_optional_progress '
        cd ~
        sudo apt-get update && sudo apt-get full-upgrade -y
        sudo apt-get install -y build-essential wget g++ cmake make \
            libsigc++-2.0-dev libgsm1-dev libpopt-dev tcl-dev libgcrypt20-dev \
            libspeex-dev libasound2-dev libopus-dev librtlsdr-dev doxygen \
            groff alsa-utils vorbis-tools curl libcurl4-openssl-dev git rtl-sdr \
            libjsoncpp-dev speedtest-cli mutt mc alsa-utils

        sudo useradd -U -r -G audio,plugdev,daemon,dialout svxlink || echo "User already exists."

        git clone https://github.com/sm0svx/svxlink.git
        cd svxlink
        git reset --hard 12c9d9b
        mkdir -p ~/svxlink/src/build
        cd ~/svxlink/src/build
        cmake -DUSE_QT=OFF -DCMAKE_INSTALL_PREFIX=/usr -DSYSCONF_INSTALL_DIR=/etc \
              -DLOCAL_STATE_DIR=/var -DWITH_SYSTEMD=ON ..
        make
        make doc
        sudo make install
        sudo ldconfig

        cd /usr/share/svxlink/sounds/
        sudo wget https://github.com/sm0svx/svxlink-sounds-en_US-heather/releases/download/24.02/svxlink-sounds-en_US-heather-16k-24.02.tar.bz2
        sudo tar xvjf svxlink-sounds-en_US-heather-16k-24.02.tar.bz2
        sudo mv en_US-heather-16k en_US
        sudo rm svxlink-sounds-en_US-heather-16k-24.02.tar.bz2
    '
}

## Glavni meni
function main() {
    while true; do
        menusvxlink=$(whiptail --title "...::::: SVXLink Namestitveni Čarovnik :::::..." \
            --ok-button "Izberi" --cancel-button "Izhod" \
            --menu "Izberi namestitev" 20 78 10 \
            "1" "..:: Namesti SVXLink na Raspberry Pi ::.." \
            "2" "..:: Namesti SVXLink na PC ::.." \
            "3" "..:: Izhod ::.." \
            3>&1 1>&2 2>&3)

        exitstatus=$?
        if [ ${exitstatus} = 0 ]; then
            case ${menusvxlink} in
                1) install_svxlink_rpi ;;
                2) install_svxlink_pc ;;
                3) exit ;;
            esac
        else
            exit
        fi
    done
}

## Zagon glavne funkcije
main
