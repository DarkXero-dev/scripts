#!/bin/bash
#set -e
##################################################################################################################
# Written to be used on 64 bits computers
# Author 	: 	DarkXero
# Website 	: 	http://xerolinux.xyz
##################################################################################################################
tput setaf 3
echo "#################################################"
echo "#      The Following Script is for KDE Only     #"
echo "#################################################"
tput sgr0
echo
echo "Hello $USER, please select a rice to apply..."
echo
echo "#################################################"
echo "#          Rices Currently Unavailable.         #"
echo "#      In Process Of Migrating to Plasma 6      #"
echo "#################################################"
echo
echo "################# Plasma Stuffs #################"
echo
echo "p. Install missing Plasma Packages."
echo "m. Apply AppMenu Meta-Key Fix (Kwin)."
echo "w. Apply xWayland Screen/Window Sharing Fix."
echo
echo "Type Your Selection. To Exit, just close Window."
echo

while :; do

read CHOICE

case $CHOICE in

    p )
      echo
	  sleep 2
	  echo "Installing Missing Plasma Packages..."
	  echo
      sleep 3
      yay -S --noconfirm flatpak-kcm systemd-kcm kdeplasma-addons keditbookmarks kgpg kwalletmanager print-manager yakuake tesseract-data-eus dolphin-plugins gwenview kamera okular spectacle svgpart plasmatube dwayland egl-wayland qt6-wayland glfw-wayland lib32-wayland wayland-protocols kwayland-integration plasma-wayland-session plasma-wayland-protocols
      echo
      sleep 2
      echo "All done, please reboot for good measure !"
	  sleep 3
      clear && sh $0

      ;;

    m )
      echo
	  sleep 2
	  echo "Applying Meta-Key AppMenu fix..."
      echo
      kwriteconfig5 --file ~/.config/kwinrc --group ModifierOnlyShortcuts --key Meta "org.kde.plasmashell,/PlasmaShell,org.kde.PlasmaShell,activateLauncherMenu"
      sleep 3
      echo "Relaunching Kwin..."
      qdbus org.kde.KWin /KWin reconfigure
      echo
      echo "All done, should work now !"
	  sleep 3
      clear && sh $0

      ;;

    w )
      echo
	  sleep 2
	  echo "Installing XWayland Bridge..."
	  echo
      sleep 3
      sudo pacman -S --noconfirm xwaylandvideobridge
      echo
      sleep 2
      echo "All done, please reboot for good measure !"
	  sleep 3
      clear && sh $0

      ;;
    
    * )
      echo "#################################"
      echo "    Choose the correct number    "
      echo "#################################"
      ;;
esac
done
