#!/bin/bash
#set -e
##################################################################################################################
# Written to be used on 64 bits computers
# Author 	: 	DarkXero
# Website 	: 	http://xerolinux.xyz
##################################################################################################################
tput setaf 3
echo "##############################################################################"
echo "#                               nVidia Drivers                               #"
echo "##############################################################################"
tput sgr0
echo
lspci_output="$(lspci | grep -oP '^.*VGA[^:]+:\s*\K.*NVIDIA.*\](?=\s*\(.*)' | sed -E 's/(\[)/\1[0;1;91m/g ; s/(\])/[0m\1/g' | grep -v '^\s*$' || :)"
    if [[ -n "${lspci_output:-}" ]]; then
        printf '%s\n' \
            "Hello ${USER:=$(whoami)}, you have the following nVidia GPUs:" \
            '' \
            "$lspci_output"
    else
        echo "${LF}Hello ${USER:=$(whoami)}, you seem to have no nVidia GPUs."
    fi
echo
echo "###################### Please Select Setup ######################"
echo
echo "1. Pre-Turing Desktop (900/10 Series)."
echo "2. Post-Turing Desktop (16/20/30/40 Series)."
echo "3. Intel/nVidia Pre-Turing (900/10 Series)."
echo "4. Intel/nVidia Post-Turing (16/20/30/40 Series)."
echo
echo "w. Apply Required Wayland Configs."
echo
echo "Type Your Selection. To Exit, just close Window."
echo

while :; do

read CHOICE

case $CHOICE in

    1 )
      echo
      echo "###########################################"
      echo "           Single GPU Pre-Turing           "
      echo "###########################################"
      sleep 3
      sudo pacman -S --needed --noconfirm nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader egl-wayland opencl-nvidia lib32-opencl-nvidia libvdpau-va-gl libvdpau
      sleep 3
      echo "#######################################"
      echo "                 Done !                "
      echo "#######################################"
      clear && sh $0
      ;;

    2 )
      echo
      echo "###########################################"
      echo "          Single GPU Post-Turing.          "
      echo "###########################################"
      sleep 3
      sudo pacman -S --needed --noconfirm nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader egl-wayland opencl-nvidia lib32-opencl-nvidia libvdpau-va-gl libvdpau
      sleep 3
      echo "#######################################"
      echo "                 Done !                "
      echo "#######################################"
      clear && sh $0
      ;;


    3 )
      echo
      echo "###########################################"
      echo "     Dual Intel/nVidia GPUs Pre-Turing     "
      echo "###########################################"
      sleep 3
      sudo pacman -S --needed --noconfirm nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader egl-wayland opencl-nvidia lib32-opencl-nvidia libvdpau-va-gl libvdpau intel-media-driver intel-gmmlib onevpl-intel-gpu nvidia-prime
      sleep 3
      echo "#######################################"
      echo "                 Done !                "
      echo "#######################################"
      clear && sh $0
      ;;


    4 )
      echo
      echo "###########################################"
      echo "     Dual Intel/nVidia GPUs Pre-Turing     "
      echo "###########################################"
      sleep 3
      sudo pacman -S --needed --noconfirm nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader egl-wayland opencl-nvidia lib32-opencl-nvidia libvdpau-va-gl libvdpau intel-media-driver intel-gmmlib onevpl-intel-gpu nvidia-prime
      sleep 3
      echo "#######################################"
      echo "                 Done !                "
      echo "#######################################"
      clear && sh $0
      ;;

    w )
      echo
      echo "##########################################"
      echo "     Applying Wayland Specific Stuff.     "
      echo "##########################################"
      echo
      echo "Step 1: Updating mkinitcpio configuration"
      sleep 3
      sudo sed -i '/^MODULES=/s/()/\(nvidia nvidia_modeset nvidia_uvm nvidia_drm\)/' /etc/mkinitcpio.conf
      echo
      sudo mkinitcpio -P
      echo
      echo "Step 2: Creating a backup of Grub & adding necessary Kernel Flags"
      sudo cp /etc/default/grub /etc/default/grub.xbk
      sudo sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT=/ {/ rd\.driver\.blacklist=nouveau modprobe\.blacklist=nouveau nvidia_drm\.modeset=1/! s/"$/ rd.driver.blacklist=nouveau modprobe.blacklist=nouveau nvidia_drm.modeset=1"/}' /etc/default/grub
      echo
      sudo grub-mkconfig -o /boot/grub/grub.cfg
      echo
      echo "Step 3: Enabling nVidia Power Management"
      echo
      sudo systemctl enable nvidia-{hibernate,resume,suspend}
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
