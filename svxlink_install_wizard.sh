#!/usr/bin/env bash

## Util Methods:
function displayMessage() {
    whiptail --title "$1" --msgbox "$2" 8 78
}


function main() {
while true; do
        menusvxlink=$(whiptail --title "...::::: SVXlink Installing Wizard :::::..." --ok-button "Select" --cancel-button "Quit" --menu "Izberi namestitev" 20 78 10 \
		"1" "..:: Install SVXLink on RPi ::.." \
		"2" "..:: Install SVXLink on PC ::.." \
		"3" "..:: Copy importatnt folders SVXLink ::.." \
		"4" "..:: Remove SVXLink folder from system ::.." \
            3>&1 1>&2 2>&3)

        exitstatus=$?

        if [ ${exitstatus} = 0 ]; then
            case ${menusvxlink} in
                1)
			svxlinkInstallRpi
                ;;
		2)
			svxlinkInstallPC
		;;
		3)
			svxlinkcopyall
		;;
		4)
			svxlinkUninstall
		;;

            esac
        else
            exit
        fi
    done
}

function svxlinkInstallRpi() {
		cd ~
                sudo apt update && sudo apt full-upgrade -y
                sudo apt-get install build-essential wget g++ cmake make libsigc++-2.0-dev libgsm1-dev libpopt-dev tcl-dev libgcrypt20-dev libspeex-dev libasound2-dev libopus-dev librtlsdr-dev doxygen groff alsa-utils vorbis-tools curl libcurl4-openssl-dev git rtl-sdr libjsoncpp-dev speedtest-cli mutt mc alsa-utils -y
                sudo apt-get install libgpiod-dev gpiod -y
                sudo useradd -U -r -G audio,plugdev,daemon,gpio svxlink
                cd ~
                git clone https://github.com/sm0svx/svxlink.git
                mkdir ~/svxlink/src/build
                cd ~/svxlink/src/build 
                cmake -DUSE_QT=OFF -DCMAKE_INSTALL_PREFIX=/usr -DSYSCONF_INSTALL_DIR=/etc -DLOCAL_STATE_DIR=/var -DWITH_SYSTEMD=ON ..
                make
		make doc
		sudo make install
                sudo ldconfig
                cd /usr/share/svxlink/sounds/
                sudo wget https://github.com/sm0svx/svxlink-sounds-en_US-heather/releases/download/19.09.99.2/svxlink-sounds-en_US-heather-16k-19.09.99.2.tar.bz2
                sudo tar xvjf svxlink-sounds-en_US-heather-16k-19.09.99.2.tar.bz2
               	sudo mv en_US-heather-16k en_US
		cd ~
	 whiptail --msgbox "Namestitev je koncana..." 10 50
}

function svxlinkInstallPC() {

		cd ~
                sudo apt-get update && sudo upgrade -y 
                sudo apt-get install build-essential wget g++ cmake make libsigc++-2.0-dev libgsm1-dev libpopt-dev tcl-dev libgcrypt20-dev libspeex-dev libasound2-dev libopus-dev librtlsdr-dev doxygen groff alsa-utils vorbis-tools curl libcurl4-openssl-dev git rtl-sdr libjsoncpp-dev speedtest-cli mutt mc alsa-utils -y
                sudo useradd -U -r -G audio,plugdev,daemon svxlink
                cd ~
                git clone https://github.com/sm0svx/svxlink.git
                mkdir ~/svxlink/src/build
                cd ~/svxlink/src/build
                cmake -DUSE_QT=OFF -DCMAKE_INSTALL_PREFIX=/usr -DSYSCONF_INSTALL_DIR=/etc -DLOCAL_STATE_DIR=/var -DWITH_SYSTEMD=ON ..
                make
		make doc
                sudo make install
                sudo ldconfig
                cd /usr/share/svxlink/sounds/
                sudo wget https://github.com/sm0svx/svxlink-sounds-en_US-heather/releases/download/19.09.99.2/svxlink-sounds-en_US-heather-16k-19.09.99.2.tar.bz2
                sudo tar xvjf svxlink-sounds-en_US-heather-16k-19.09.99.2.tar.bz2
                sudo mv en_US-heather-16k en_US
	 whiptail --msgbox "Namestitev je koncana..." 10 50
}

function svxlinkUninstall() {

                rm -rf ~/svxlink/
                sleep 1
                rm -rf ~/etc/svxlink/
		sleep 1
                rm -rf ~/var/spool/svxlink/
                sleep 1
                rm -rf ~/usr/share/svxlink/
                sleep 1
	whiptail --msgbox "Odstranitev je koncana..." 10 50
}

function svxlinkcopyall() {

                cd ~
		mkdir "Kopija_SVXLink_$(date +"%d_%m_%Y")"
                cd Kopija_SVXLink_$(date +"%d_%m_%Y")
		mkdir etc
		mkdir etc/svxlink
		mkdir usr
		mkdir usr/share
		mkdir usr/share/svxlink
		mkdir var
		mkdir var/spool
		mkdir var/spool/svxlink
		cp -f -r /etc/svxlink/* etc/svxlink/ 
		cp -f -r /usr/share/svxlink/* usr/share/svxlink/
		cp -f -r /var/spool/svxlink/* var/spool/svxlink/
		cd ~
		chown -hR pi:pi Kopija_SVXLink_$(date +"%d_%m_%Y")
        whiptail --msgbox "Odstranitev je koncana..." 10 50
}

main
