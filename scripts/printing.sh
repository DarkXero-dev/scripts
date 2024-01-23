#!/bin/bash
#set -e
##################################################################################################################
# Written to be used on 64 bits computers
# Author 	: 	DarkXero
# Website 	: 	http://xerolinux.xyz
##################################################################################################################
tput setaf 5
echo "###########################################################################"
echo "#                             Printer Drivers                             #"
echo "###########################################################################"
tput sgr0
echo
echo "Hello $USER, This covers HP/Epson Printers, for Brother Printers consult the AUR."
echo
echo "############# Essential #############"
echo
echo "p. Install Printing Essentials."
echo
echo "############ HP Printers ############"
echo
echo "h. Install HP Drivers & Tools (AUR)."
echo
echo "########## Epson Printers ###########"
echo
echo "e. Install Epson Drivers & Tools (AUR)."
echo
echo "Type Your Selection. To Exit, just close Window."
echo

while :; do

read CHOICE

case $CHOICE in

    p )
      echo
      echo "###########################################"
      echo "      Installing Printing Essentials       "
      echo "###########################################"
      sleep 3
      echo
      echo "Please wait while packages install... "
      sudo pacman -S --needed --noconfirm ghostscript gsfonts cups cups-filters cups-pdf system-config-printer avahi system-config-printer foomatic-db-engine foomatic-db foomatic-db-ppds foomatic-db-nonfree foomatic-db-nonfree-ppds gutenprint foomatic-db-gutenprint-ppds > /dev/null 2>&1
      echo
      sudo systemctl enable --now avahi-daemon cups.socket
      echo
      sudo groupadd lp && sudo groupadd cups && sudo usermod -aG sys,lp,cups $(whoami)
      sleep 3
      echo
      echo "#######################################"
      echo "                 Done !                "
      echo "#######################################"
            clear && sh $0
      ;;

    h )
      echo
      echo "###########################################"
      echo "        Installing HP Drivers/Tools        "
      echo "###########################################"
      sleep 3
      echo
      $aur_helper -S --needed python-pyqt5 hplip hplip-plugin
      sleep 3
      echo
      echo "#######################################"
      echo "                 Done !                "
      echo "#######################################"
            clear && sh $0
      ;;

    e )
      echo
      echo "############################################"
      echo "       Installing Epson Drivers/Tools       "
      echo "############################################"
      sleep 3
      echo
      $aur_helper -S --needed epson-inkjet-printer-escpr epson-inkjet-printer-escpr2 epson-inkjet-printer-201310w epson-inkjet-printer-201204w imagescan
      sleep 3
      echo
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
