#!/bin/bash
#set -e
##################################################################################################################
# Written to be used on 64 bits computers
# Author 	: 	DarkXero
# Website 	: 	http://xerolinux.xyz
##################################################################################################################
tput setaf 5
echo "###################################################################################"
echo "#                             Essential Pkg Installer                             #"
echo "###################################################################################"
tput sgr0
echo
echo "Hello $USER, this will install missing packages not included with ArchInstall."
echo
echo "a. VIM Including Plugins."
echo "b. PipeWire/Codec Packages."
echo "c. Extra Input and Trackpad Tools."
echo "d. Extra Networking/WiFi & VPN Tools."
echo "e. Extra Useful System Tools (Recommended)."
echo "f. Recommended tools from the AUR (Helper Required)."
echo
echo "Type Your Selection. To Exit, just close Window."
echo

while :; do

read CHOICE

case $CHOICE in

    a )
      echo
      echo "###########################################"
      echo "      Installing Vim + Essentials       "
      echo "###########################################"
      echo
      echo "Please wait while packages install... "
      sudo pacman -S --needed --noconfirm vim vim-align vim-csound vim-pastie vim-runtime vim-nerdtree vim-supertab vim-syntastic vim-gitgutter vim-bufexplorer vim-editorconfig vim-nerdcommenter vim-coverage-highlight > /dev/null 2>&1
      sleep 3
      echo
      echo "#######################################"
      echo "                 Done !                "
      echo "#######################################"
            clear && sh $0
      ;;

    b )
      echo
      echo "###########################################"
      echo "      Installing Audio Codecs       "
      echo "###########################################"
      echo
      echo "Please wait while packages install... "
      sudo pacman -S --needed --noconfirm gstreamer gst-libav gst-plugins-bad gst-plugins-base gst-plugins-ugly gst-plugins-good gst-plugin-pipewire libdvdcss alsa-utils wireplumber alsa-firmware  pipewire-jack pavucontrol lib32-pipewire-jack pipewire libpipewire  pipewire-alsa pipewire-pulse pipewire-v4l2 pipewire-x11-bell pipewire-zeroconf  realtime-privileges sof-firmware ffmpeg ffmpegthumbs ffnvcodec-headers mesa-utils > /dev/null 2>&1
      sleep 3
      echo
      echo "#######################################"
      echo "                 Done !                "
      echo "#######################################"
            clear && sh $0
      ;;

    c )
      echo
      echo "###########################################"
      echo "      Installing Input Essentials       "
      echo "###########################################"
      echo
      echo "Please wait while packages install... "
      sudo pacman -S --needed --noconfirm piper xf86-input-void xf86-input-evdev iio-sensor-proxy xf86-input-libinput xf86-input-synaptics xf86-input-elographics > /dev/null 2>&1
      sleep 3
      echo
      echo "#######################################"
      echo "                 Done !                "
      echo "#######################################"
            clear && sh $0
      ;;

    d )
      echo
      echo "###########################################"
      echo "      Installing Networking Essentials       "
      echo "###########################################"
      echo
      echo "Please wait while packages install... "
      sudo pacman -S --needed --noconfirm broadcom-wl avahi netctl openldap smbclient net-tools openresolv traceroute nm-cloud-setup wireless-regdb wireless_tools wpa_supplicant networkmanager-vpnc networkmanager-pptp networkmanager-l2tp network-manager-sstp network-manager-applet networkmanager-openvpn networkmanager-strongswan networkmanager-openconnect mobile-broadband-provider-info > /dev/null 2>&1
      sleep 3
      echo
      echo "#######################################"
      echo "                 Done !                "
      echo "#######################################"
            clear && sh $0
      ;;
    
    e )
      echo
      echo "###########################################"
      echo "      Installing Useful System Tools       "
      echo "###########################################"
      echo
      echo "Please wait while packages install... "
      sudo pacman -S --needed --noconfirm linux-firmware-marvell eza git numlockx lm_sensors appstream-glib bat bat-extras neofetch fastfetch pacman-contrib pacman-bintrans pacman-mirrorlist yt-dlp gnustep-base parallel dex bash make libxinerama logrotate bash-completion gtk-update-icon-cache gnome-disk-utility appmenu-gtk-module dconf-editor dbus-python lsb-release asciinema playerctl s3fs-fuse vi duf gcc git yad zip xdo inxi meld lzop nmon mkinitcpio-archiso mkinitcpio-nfs-utils tree vala btop lshw expac fuse3 meson unace unrar unzip p7zip rhash sshfs vnstat nodejs cronie hwinfo arandr assimp netpbm wmctrl grsync libmtp polkit sysprof gparted hddtemp mlocate fuseiso gettext node-gyp graphviz inetutils appstream cifs-utils ntfs-3g nvme-cli exfatprogs f2fs-tools man-db man-pages tldr wget python-pip python-cffi python-numpy python-docopt python-pyaudio > /dev/null 2>&1
      sleep 3
      echo
      echo "#######################################"
      echo "                 Done !                "
      echo "#######################################"
            clear && sh $0
      ;;
    
    f )
      echo
      echo "###########################################"
      echo "      Installing Recommended tools from the AUR       "
      echo "###########################################"
      echo
      echo "Please wait while packages install... "
      echo
      yay -S --noconfirm downgrade yt-dlg libadwaita-without-adwaita-git mkinitcpio-firmware hw-probe pkgstats alsi gestures libinput-gestures update-grub rate-mirrors-bin ocs-url
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
