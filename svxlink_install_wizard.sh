#!/usr/bin/env bash

## Util Methods:
function displayMessage() {
    whiptail --title "$1" --msgbox "$2" 8 78
}


function main() {
while true; do
        menusvxlink=$(whiptail --title "Pomocnik za namesteitev SVXlink-a" --ok-button "Select" --cancel-button "Quit" --menu "Izberi namestitev" 20 78 10 \
            "1" "Namestitev SVXLink za RPi" \
			      "2" "Namestitev SVXLink za PC" \
			      "3" "Odstrani SVXLink za RPi in PC" \
            3>&1 1>&2 2>&3)

        exitstatus=$?

        if [ ${exitstatus} = 0 ]; then
            case ${menusvxlink} in
                1)
                    svxlinkInstallRpi
                ;;
				#2)
				#	svxlinkInstallPC
				#;;
				3)
					svxlinkUninstallRpi
				;;
        
            esac
        else
            exit
        fi
    done
}

function svxlinkInstallRpi() {
		{
				touch log
				sleep 1
                echo 0
                sudo apt update && sudo apt full-upgrade -y >> log
                sleep 0.2
                echo 5
                sudo apt-get install build-essential wget g++ cmake make libsigc++-2.0-dev libgsm1-dev libpopt-dev tcl-dev libgcrypt20-dev libspeex-dev libasound2-dev libopus-dev librtlsdr-dev doxygen groff alsa-utils vorbis-tools curl libcurl4-openssl-dev git rtl-sdr libjsoncpp-dev speedtest-cli mutt mc alsa-utils -y >> log
                sleep 0.2
                echo 10
                sudo apt-get install libgpiod-dev gpiod -y >> log
                sleep 0.2
                echo 14
                sudo useradd -U -r -G audio,plugdev,daemon,gpio svxlink >> log
                sleep 0.2
                echo 19
                sudo adduser svxlink audio >> log
                sleep 0.2
                echo 24
                sudo adduser svxlink gpio >> log
                sleep 0.2
                echo 29
                sudo adduser svxlink svxlink >> log
                sleep 0.2
                echo 33
                sudo adduser svxlink daemon >> log
                sleep 0.2
                echo 38
                cd ~
                sleep 0.2
                echo 43
                git clone https://github.com/sm0svx/svxlink.git >> log
                sleep 0.2
                echo 48
                mkdir ~/svxlink/src/build
                sleep 0.2
                echo 52
                cd ~/svxlink/src/build 
                sleep 57
                echo 4
                cmake -DUSE_QT=OFF -DCMAKE_INSTALL_PREFIX=/usr -DSYSCONF_INSTALL_DIR=/etc -DLOCAL_STATE_DIR=/var -DWITH_SYSTEMD=ON ..
                sleep 0.2
                echo 62
                make > log
				sleep 0.2
                echo 71
				make doc >> log
				sleep 0.2
				echo 74
                sudo make install >> log
                sleep 0.2
                echo 76
                sudo ldconfig 
                sleep 0.2
                echo 81
                cd /usr/share/svxlink/sounds/
                sleep 0.2
                echo 86
                sudo wget https://github.com/sm0svx/svxlink-sounds-en_US-heather/releases/download/19.09.99.2/svxlink-sounds-en_US-heather-16k-19.09.99.2.tar.bz2 >> log
                sleep 0.2
                echo 90
                sudo tar xvjf svxlink-sounds-en_US-heather-16k-19.09.99.2.tar.bz2 >> log
                sleep 0.2
                echo 95
               	sudo mv en_US-heather-16k en_US
		cd ~
		sleep 0.2
		echo 100
		rm -rf log
        } | whiptail --gauge "Prosim pocaka, poteka  namestitev SVXlink-a za RPi..." 6 50 0
}

function svxlinkInstallPC() {
		{
				touch log
				sleep 1
                echo 0
                sudo apt-get update && sudo upgrade -y > log
                sleep 0.2
                echo 5
                sudo apt-get install build-essential wget g++ cmake make libsigc++-2.0-dev libgsm1-dev libpopt-dev tcl-dev libgcrypt20-dev libspeex-dev libasound2-dev libopus-dev librtlsdr-dev doxygen groff alsa-utils vorbis-tools curl libcurl4-openssl-dev git rtl-sdr libjsoncpp-dev speedtest-cli mutt mc alsa-utils -y > log
                sleep 0.2
                echo 10
                sudo useradd -U -r -G audio,plugdev,daemon svxlink > log
                sleep 0.2
                echo 19
                sudo adduser svxlink svxlink > log
                sleep 0.2
                echo 33
                sudo adduser svxlink daemon > log
                sleep 0.2
                echo 38
                cd ~
                sleep 0.2
                echo 43
                git clone https://github.com/sm0svx/svxlink.git > log
                sleep 0.2
                echo 48
                mkdir ~/svxlink/src/build
                sleep 0.2
                echo 52
                cd ~/svxlink/src/build
                sleep 57
                echo 4
                cmake -DUSE_QT=OFF -DCMAKE_INSTALL_PREFIX=/usr -DSYSCONF_INSTALL_DIR=/etc -DLOCAL_STATE_DIR=/var -DWITH_SYSTEMD=ON ..
                sleep 0.2
                echo 62
                make > log
                sleep 0.2
                echo 71
				make doc > log
				sleep 0.2
				echo 74
                sudo make install > log
                sleep 0.2
                echo 76
                sudo ldconfig
                sleep 0.2
                echo 81
                cd /usr/share/svxlink/sounds/
                sleep 0.2
                echo 86
                sudo curl -LO https://github.com/sm0svx/svxlink-sounds-en_US-heather/releases/download/19.09.99.1/svxlink-sounds-en_US-heather-16k-19.09.99.1.tar.bz2 > log
                sleep 0.2
                echo 90
				sudo tar xvjf svxlink-sounds-en_US-heather-16k-19.09.99.1.tar.bz2 > log
				sleep 0.2
                echo 95
                sudo ln -s en_US-heather-16k en_US
                sleep 0.2
                echo 100
				rm -rf log

		} | whiptail --gauge "Prosim pocaka, poteka  namestitev SVXlink-a za PC..." 6 50 0
}


function svxlinkUninstallRpi() {
    {
				touch log
                sleep 1
                echo 0
                rm -rf ~/svxlink/
                sleep 0.2
                echo 56
                rm -rf ~/etc/svxlink/
				sleep 0.2
                echo 70
				rm -rf ~/var/spool/svxlink/
                sleep 0.2
                echo 84
                rm -rf ~/usr/share/svxlink/
                sleep 0.2
                echo 100
                rm -rf log

    } | whiptail --gauge "PRosim počakaj da se odstrani ključne elemnete..." 6 50 0

}

function progressGuageDemo() {
    {
	touch log
        sleep 1
	echo 50
	sleep 0.2
	sudo apt-get update > log
	sleep 0.2
	echo 100
	rm -rf log
    } | whiptail --gauge "Please wait while we are sleeping..." 6 50 0

}

main

#whiptail --title "Check list example" --checklist \
#"Choose user's permissions" 20 78 4 \
#"NET_OUTBOUND" "Allow connections to other hosts" ON \
#"NET_INBOUND" "Allow connections from other hosts" OFF \
#"LOCAL_MOUNT" "Allow mounting of local devices" OFF \
#"REMOTE_MOUNT" "Allow mounting of remote devices" OFF
#
#
#{
#    for ((i = 0 ; i <= 100 ; i+=5)); do
#        sleep .1
#        echo $i
#    done
#} | whiptail --gauge "Please wait while we are sleeping..." 6 50 0
