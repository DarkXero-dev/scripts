#!/bin/bash
#set -e
##################################################################################################################
# Written to be used on 64 bits computers
# Author 	: 	DarkXero
# Website 	: 	http://xerolinux.xyz
##################################################################################################################
tput setaf 3
echo "##############################################################################"
echo "#                               Device Drivers                               #"
echo "##############################################################################"
tput sgr0
echo
echo "Hello $USER, Please Select What Drivers to install."
echo
echo "1. AMD/ATI FOSS GPU Drivers."
echo "2. nVidia Proprietary GPU Drivers."
echo "3. HP/Epson/Brother Printing Drivers."
echo "4. DualShock 4 Controller Driver (AUR)."
echo "5. PS5 DualSense Controller Driver (AUR)."
echo "6. Xbox One Wireless Gamepad Driver (AUR)."
echo
echo "Type Your Selection. To Exit, just close Window."
echo

while :; do

read CHOICE

case $CHOICE in

    1 )
      echo
      sleep 2
      clear && sh $SCRIPTS_PATH/amd_drivers.sh
      sleep 3
      echo
      clear && sh $0
      ;;

    2 )
      echo
      sleep 2
      clear && sh $SCRIPTS_PATH/nVidia_drivers.sh
      sleep 3
      echo
      clear && sh $0
      ;;


    3 )
      echo
      sleep 2
      clear && sh $SCRIPTS_PATH/printing.sh
      sleep 3
     echo
      sleep 2
      clear && sh $0
      ;;

    4 )
      echo
      echo "#################################################"
      echo "#          Installing DualShock 4 Driver        #"
      echo "#################################################"
      echo
      $aur_helper -S --noconfirm aur/ds4drv aur/game-devices-udev
      echo
      echo "#################################################"
      echo "#        Done ! Returning to main menu..        #"
      echo "#################################################"
      clear && sh $0

      ;;

    5 )
      echo
      echo "#################################################"
      echo "#  Installing PS-5 DualSense controller Driver  #"
      echo "#################################################"
      echo
      $aur_helper -S --noconfirm aur/dualsensectl
      echo
      echo "#################################################"
      echo "#        Done ! Returning to main menu..        #"
      echo "#################################################"
      clear && sh $0

      ;;
    
    6 )
      echo
      echo "#################################################"
      echo "#  Installing Xbox One Wireless Gamepad Driver  #"
      echo "#################################################"
      echo
      $aur_helper -S --noconfirm aur/xpadneo-dkms
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
