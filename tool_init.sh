#!/bin/bash
#set -e
##################################################################################################################
# Written to be used on 64 bits computers
# Author 	: 	DarkXero
# Website 	: 	http://xerolinux.xyz
##################################################################################################################
tput setaf 5
echo "############################################################################"
echo "#                           Initial System Setup                           #"
echo "############################################################################"
tput sgr0
echo
echo "Hello $USER, Please Select What To Do."
echo
echo "############ Initial Setup Section ############"
echo
echo "x.  Activate XeroLinux Repo."
echo "b.  Install & Activate Bluetooth (Bluez)."
echo "p.  Install Essential System Packages (Native & AUR)."
echo "f.  Add & Activate Flathub Repositories (Req. for OBS)."
echo
echo "Type Your Selection. To Exit, just close Window."
echo

while :; do

read CHOICE

case $CHOICE in

    x )
      echo
      echo "###########################################"
      echo "             Adding & Xero Repo            "
      echo "###########################################"
      sleep 3
      sudo cp /etc/pacman.conf /etc/pacman.conf.backup && \
      echo -e '\n[xerolinux]\nSigLevel = Optional TrustAll\nServer = https://repos.xerolinux.xyz/$repo/$arch' | sudo tee -a /etc/pacman.conf
      echo
      sudo pacman -Syy
      sleep 3
      echo "#######################################"
      echo "                 Done !                "
      echo "#######################################"
            clear && sh $0
      ;;

    b )
      echo
	  sleep 2
	  echo "#################################"
      echo "       Installing & Activating Bluetooth       "
      echo "#################################"
      sleep 1.5
      sudo pacman -S --needed --noconfirm bluez bluez-utils bluez-plugins bluez-hid2hci bluez-cups bluez-libs bluez-tools
      sudo systemctl enable --now  bluetooth.service
      sleep 1.5
      echo
      echo "#################################"
      echo "        All Done, Try now       "
      echo "#################################"
	  sleep 2
      clear && sh $0

      ;;
    
    p )
      echo
      clear && sh $SCRIPTS_PATH/pkgs.sh
      ;;

    f )
      echo
      echo "##########################################"
      echo "       Adding & Activating Flatpaks       "
      echo "##########################################"
      sleep 3
      echo
      sudo pacman -S --noconfirm flatpak
      sleep 3
      echo "#######################################"
      echo "                 Done !                "
      echo "#######################################"
            clear && sh $0
      ;;

    * )
      echo "#################################"
      echo "    Choose the correct number    "
      echo "#################################"
      ;;
esac
done
