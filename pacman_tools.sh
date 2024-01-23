#!/bin/bash
#set -e
##################################################################################################################
# Written to be used on 64 bits computers
# Author 	: 	DarkXero
# Website 	: 	http://xerolinux.xyz
##################################################################################################################
tput setaf 5
echo "#########################################################################"
echo "#                             Pacman Tweaks                             #"
echo "#########################################################################"
tput sgr0
echo
echo "Hello $USER, Please Select What To Do. (Pure Arch Only)."
echo
echo "########## Buiding/Cache Tweaks. ##########"
echo
echo "t.  Enable multithread compilation."
echo "p.  Enable pacman cache cleaning timer."
echo
echo "########## Key/Mirrorlist Fixes ##########"
echo
echo "1. Fix Arch Mirrorlist, in case of issues."
echo "2. Fix Arch GnuPG Keyring signature issues."
echo
echo "Type Your Selection. To Exit, just close Window."
echo

while :; do

read CHOICE

case $CHOICE in

    t )
      echo
      echo "###########################################"
      echo "      Enabling multithread compilation     "
      echo "###########################################"
      sleep 3
      echo
      numberofcores=$(grep -c ^processor /proc/cpuinfo)

      if [ $numberofcores -gt 1 ]
      then
        echo "You have " $numberofcores" cores."
        echo "Changing the makeflags for "$numberofcores" cores."
        sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j'$(($numberofcores+1))'"/g' /etc/makepkg.conf;
        echo
        echo "Changing the compression settings for "$numberofcores" cores."
        echo
        sudo sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -z - --threads=0)/g' /etc/makepkg.conf
        sudo sed -i 's/COMPRESSZST=(zstd -c -z -q -)/COMPRESSZST=(zstd -c -z -q - --threads=0)/g' /etc/makepkg.conf
        sudo sed -i "s/PKGEXT='.pkg.tar.xz'/PKGEXT='.pkg.tar.zst'/g" /etc/makepkg.conf
      else
        echo
        echo "No change."
      fi
      sleep 3
      echo
      echo "#######################################"
      echo "                 Done !                "
      echo "#######################################"
            clear && sh $0
      ;;

    p )
      echo
      echo "##########################################"
      echo "          Enabling paccache timer         "
      echo "##########################################"
      sleep 3
      sudo systemctl enable --now paccache.timer
      sleep 3
      echo "#######################################"
      echo "                 Done !                "
      echo "#######################################"
            clear && sh $0
      ;;

    1 )
      echo
      echo "#################################"
      echo "#   Fixing Pacman Databases..   #"
      echo "#################################"
      sleep 2
      echo
      echo "Step 1 - Deleting Existing Keys.. "
      echo "#######################"
      echo
      sudo rm -r /etc/pacman.d/gnupg/*
      sleep 2
      echo
      echo "Step 2 - Populating Keys.."
      echo "##################"
      echo
      sudo pacman-key --init && sudo pacman-key --populate
      sleep 2
      echo
      echo "Step 3 - Adding Ubuntu keyserver.."
      echo "#########################"
      echo
      echo "keyserver hkp://keyserver.ubuntu.com:80" | sudo tee --append /etc/pacman.d/gnupg/gpg.conf
      echo
      echo "Step 4 - Updating ArchLinux Keyring.."
      echo "###########################"
      echo
      sudo pacman -Syy --noconfirm archlinux-keyring
      sleep 3
      echo
      echo "#######################################"
      echo "                 Done ! Try Update now & Report               "
      echo "#######################################"
            clear && sh $0
      ;;


    2 )
      echo
      echo "##########################################"
      echo "         Updating Mirrors To Fastest Ones        "
      echo "##########################################"
	  sleep 3
	  echo
	  sudo reflector --verbose -phttps -f10 -l10 --sort rate --save /etc/pacman.d/mirrorlist && sudo pacman -Syy
	  sleep 3
	  echo
      echo "#######################################"
      echo "                 Done ! Updating should go faster                "
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
