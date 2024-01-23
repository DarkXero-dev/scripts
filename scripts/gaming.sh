#!/bin/bash
#set -e
##################################################################################################################
# Written to be used on 64 bits computers
# Author 	: 	DarkXero
# Website 	: 	http://xerolinux.xyz
##################################################################################################################
tput setaf 3
echo "#################################################"
echo "#             The Gaming Essentials.            #"
echo "#################################################"
tput sgr0
echo
echo "Hello $USER, what would you like to install ?"
echo
echo "################# Game Launchers #################"
echo
echo "1. Steam (Native)."
echo "2. Lutris (Native)."
echo "3. Heroic (Flathub)."
echo "4. Bottles (Flathub)."
echo
echo "################### Game Tools ###################"
echo
echo "5.  Mangohud (Native)."
echo "6.  Goverlay (Flathub)."
echo "7.  Protonup-qt (Flathub)."
echo
echo "Type Your Selection. More tools available via our Package Installer."
echo

while :; do

read CHOICE

case $CHOICE in

    1 )
      echo
      echo "#################################################"
      echo "#            Installing Steam Launcher          #"
      echo "#################################################"
      echo
      sudo pacman -S --noconfirm steam
      sleep 3
      echo
      echo "Applying Download Speed Enhancement Patch (Insecure but works)"
      echo -e "@nClientDownloadEnableHTTP2PlatformLinux 0\n@fDownloadRateImprovementToAddAnotherConnection 1.0" > ~/.steam/steam/steam_dev.cfg
      echo
      echo "#################################################"
      echo "#        Done ! Returning to main menu..        #"
      echo "#################################################"
      clear && sh $0

      ;;

    2 )
      echo
      echo "#################################################"
      echo "#           Installing Lutris Launcher          #"
      echo "#################################################"
      echo
      sudo pacman -S --noconfirm lutris wine-staging
      echo
      echo "#################################################"
      echo "#        Done ! Returning to main menu..        #"
      echo "#################################################"
      clear && sh $0

      ;;

    3 )
      echo
      echo "#################################################"
      echo "#           Installing Heroic Launcher          #"
      echo "#################################################"
      echo
      flatpak install com.heroicgameslauncher.hgl
      echo
      echo "#################################################"
      echo "#        Done ! Returning to main menu..        #"
      echo "#################################################"
      clear && sh $0

      ;;

    4 )
      echo
      echo "#################################################"
      echo "#          Installing Bottles Launcher          #"
      echo "#################################################"
      echo
      flatpak install com.usebottles.bottles
      echo
      echo "#################################################"
      echo "#        Done ! Returning to main menu..        #"
      echo "#################################################"
      clear && sh $0

      ;;

    5 )
      echo
      echo "#################################################"
      echo "#               Installing Mangohud             #"
      echo "#################################################"
      echo
      sudo pacman -S --noconfirm mangohud
      echo
      echo "#################################################"
      echo "#        Done ! Returning to main menu..        #"
      echo "#################################################"
      clear && sh $0

      ;;

    6 )
      echo
      echo "#################################################"
      echo "#               Installing Goverlay             #"
      echo "#################################################"
      echo
      sudo pacman -S --noconfirm goverlay
      echo
      echo "#################################################"
      echo "#        Done ! Returning to main menu..        #"
      echo "#################################################"
      clear && sh $0

      ;;

    7 )
      echo
      echo "#################################################"
      echo "#             Installing ProtonUp-QT            #"
      echo "#################################################"
      echo
      flatpak install net.davidotek.pupgui2
      echo
      echo "#################################################"
      echo "#        Done ! Returning to main menu..        #"
      echo "#################################################"
      clear && sh $0

      ;;
    
    * )
      echo "#################################"
      echo "    Choose the correct number    "
      echo "#################################"
      ;;
esac
done
