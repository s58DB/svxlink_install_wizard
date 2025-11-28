#!/usr/bin/env bash

## Author: Danilo - S58DB
## E-mail: s58db.danilo@gmail.com
##
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
                sudo apt update && sudo apt upgrade -y
		sudo apt-get install --reinstall build-essential wget g++ ladspa-sdk libogg-dev cmake make libsigc++-2.0-dev libgsm1-dev libpopt-dev tcl-dev libgcrypt20-dev libspeex-dev libasound2-dev libopus-dev librtlsdr-dev doxygen groff alsa-utils vorbis-tools curl libcurl4-openssl-dev git rtl-sdr libjsoncpp-dev speedtest-cli mutt mc libgpiod-dev gpiod libssl-dev libgpiod-dev gpiod apache2 apache2-bin apache2-data apache2-utils php8.2 python3-serial sqlite3 libssl-dev php8.2-sqlite3 toilet --fix-missing -y
                sudo useradd -m -U -r -G audio,plugdev,daemon,dialout,gpio svxlink
                cd ~
		wget https://github.com/sm0svx/svxlink/archive/refs/tags/25.05.1.tar.gz
		tar -xzf 25.05.1.tar.gz
		mv svxlink-25.05.1 svxlink
		cd svxlink
		#git clone https://github.com/sm0svx/svxlink.git
  		##cd svxlink
    		##git reset --hard 12c9d9b
      		##cd  ~
                mkdir ~/svxlink/src/build
                cd ~/svxlink/src/build 
                cmake -DUSE_QT=OFF -DCMAKE_INSTALL_PREFIX=/usr -DSYSCONF_INSTALL_DIR=/etc -DLOCAL_STATE_DIR=/var -DWITH_SYSTEMD=ON ..
                make
		make doc
		sudo make install
                sudo ldconfig
                cd /usr/share/svxlink/sounds/
                sudo wget https://github.com/sm0svx/svxlink-sounds-en_US-heather/releases/download/24.02/svxlink-sounds-en_US-heather-16k-24.02.tar.bz2
                sudo tar -xaf svxlink-sounds-en_US-heather-16k-24.02.tar.bz2
                sudo mv en_US-heather-16k en_US
                sudo rm svxlink-sounds-en_US-heather-16k-24.02.tar.bz2
		cd ~
	 whiptail --msgbox "Install is complite..." 10 50
}

function svxlinkInstallPC() {

		cd ~
        sudo apt-get update && sudo apt upgrade -y 
		sudo apt-get install --reinstall build-essential wget g++ cmake ladspa-sdk libogg-dev make libsigc++-2.0-dev libgsm1-dev libpopt-dev tcl-dev libgcrypt20-dev libspeex-dev libasound2-dev libopus-dev librtlsdr-dev doxygen groff alsa-utils vorbis-tools curl libssl-dev libcurl4-openssl-dev git rtl-sdr libjsoncpp-dev speedtest-cli mutt mc alsa-utils apache2 apache2-bin apache2-data apache2-utils php8.2 python3-serial sqlite3 libssl-dev php8.2-sqlite3 toilet --fix-missing -y
        sudo useradd -m -U -r -G audio,plugdev,daemon,dialout svxlink
        cd ~
		wget https://github.com/sm0svx/svxlink/archive/refs/tags/25.05.1.tar.gz
		tar -xzf 25.05.1.tar.gz
		mv svxlink-25.05.1 svxlink
		cd svxlink
		#git clone https://github.com/sm0svx/svxlink.git
  		##cd svxlink
    		##git reset --hard 12c9d9b
      		##cd  ~
                mkdir ~/svxlink/src/build
                cd ~/svxlink/src/build
                cmake -DUSE_QT=OFF -DCMAKE_INSTALL_PREFIX=/usr -DSYSCONF_INSTALL_DIR=/etc -DLOCAL_STATE_DIR=/var -DWITH_SYSTEMD=ON ..
                make
		make doc
                sudo make install
                sudo ldconfig
                cd /usr/share/svxlink/sounds/
                sudo wget https://github.com/sm0svx/svxlink-sounds-en_US-heather/releases/download/24.02/svxlink-sounds-en_US-heather-16k-24.02.tar.bz2
                sudo tar -xaf svxlink-sounds-en_US-heather-16k-24.02.tar.bz2
                sudo mv en_US-heather-16k en_US
		sudo rm svxlink-sounds-en_US-heather-16k-24.02.tar.bz2
	 whiptail --msgbox "Install is complite..." 10 50
}

function svxlinkUninstall() {

                sudo rm -rf ~/svxlink/
                echo ~/svxlink/
		sleep 1
                sudo rm -rf /etc/svxlink/
		echo /etc/svxlink/
		sleep 1
                sudo rm -rf /var/spool/svxlink/
		echo /var/spool/svxlink/
                sleep 1
                sudo rm -rf /usr/share/svxlink/
		echo /usr/share/svxlink/
                sleep 1
	whiptail --msgbox "Delite all files is complite..." 10 50
}

function svxlinkcopyall() {
    cd ~
    BACKUP_DIR="Kopija_SVXLink_$(date +"%d_%m_%Y")"
    mkdir "$BACKUP_DIR"

    # Ustvari potrebne mape
    mkdir -p "$BACKUP_DIR/etc/svxlink"
    mkdir -p "$BACKUP_DIR/usr/share/svxlink"
    mkdir -p "$BACKUP_DIR/var/spool/svxlink"

    # Kopiraj datoteke
    cp -f -r /etc/svxlink/* "$BACKUP_DIR/etc/svxlink/"
    cp -f -r /usr/share/svxlink/* "$BACKUP_DIR/usr/share/svxlink/"
    cp -f -r /var/spool/svxlink/* "$BACKUP_DIR/var/spool/svxlink/"
    cp -f /etc/rc.local "$BACKUP_DIR/etc/"

    # Nastavi lastništvo
    chown -hR pi:pi "$BACKUP_DIR"

    # Ustvari TAR.GZ arhiv
    tar -czf "${BACKUP_DIR}.tar.gz" "$BACKUP_DIR"

    # Pobriši začasno mapo
    rm -rf "$BACKUP_DIR"

    # Obvestilo uporabniku
    echo "Your backup is here: /home/$USER/${BACKUP_DIR}.tar.gz"
    whiptail --msgbox "Backup and TAR.GZ creation completed." 10 50
}


main
