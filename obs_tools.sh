#!/bin/bash
#set -e
##################################################################################################################
# Written to be used on 64 bits computers
# Author 	: 	DarkXero
# Website 	: 	http://xerolinux.xyz
##################################################################################################################
tput setaf 3
echo "###############################################################################"
echo "#                               OBS-Studio Tool                               #"
echo "###############################################################################"
tput sgr0
echo
echo "Hello $USER, Please Select What To Do."
echo
echo "1. Install OBS-Studo (Flathub)."
echo "2. Install Essential OBS Plugins (Flathub)."
echo "3. Activate v4l2loopback for OBS-VirtualCam."
echo
echo "Type Your Selection. To Exit, just close Window."
echo

while :; do

read CHOICE

case $CHOICE in

    1 )
      echo
      echo "###########################################"
      echo "           Installing OBS-Studio           "
      echo "###########################################"
      sleep 3
      flatpak install com.obsproject.Studio
      sleep 3
      echo "#######################################"
      echo "                 Done !                "
      echo "#######################################"
      clear && sh $0
      ;;

    2 )
      echo
      echo "###########################################"
      echo "       Installing Essential Plugins        "
      echo "###########################################"
      sleep 3
      flatpak install com.obsproject.Studio.Plugin.OBSVkCapture com.obsproject.Studio.Plugin.Gstreamer com.obsproject.Studio.Plugin.TransitionTable  com.obsproject.Studio.Plugin.waveform com.obsproject.Studio.Plugin.InputOverlay com.obsproject.Studio.Plugin.SceneSwitcher com.obsproject.Studio.Plugin.MoveTransition com.obsproject.Studio.Plugin.ScaleToSound com.obsproject.Studio.Plugin.WebSocket com.obsproject.Studio.Plugin.DroidCam com.obsproject.Studio.Plugin.BackgroundRemoval com.obsproject.Studio.Plugin.GStreamerVaapi com.obsproject.Studio.Plugin.VerticalCanvas org.freedesktop.Platform.VulkanLayer.OBSVkCapture
      sleep 3
      echo "#######################################"
      echo "                 Done !                "
      echo "#######################################"
      clear && sh $0
      ;;


    3 )
      echo
      echo "##########################################"
      echo "          Setting up v4l2loopback         "
      echo "##########################################"
      sleep 3
      sudo pacman -S --noconfirm v4l2loopback-dkms
      sleep 3
      # Create or append to /etc/modules-load.d/v4l2loopback.conf
      echo "v4l2loopback" | sudo tee /etc/modules-load.d/v4l2loopback.conf > /dev/null

      # Create /etc/modprobe.d/v4l2loopback.conf with specified content
      echo 'options v4l2loopback exclusive_caps=1 card_label="OBS Virtual Camera"' | sudo tee /etc/modprobe.d/v4l2loopback.conf > /dev/null

      # Prompt user to reboot
      echo "Please reboot your system for changes to take effect."
      sleep 2
      clear && sh $0
      ;;


    * )
      echo "#################################"
      echo "    Choose the correct number    "
      echo "#################################"
      ;;
esac
done
