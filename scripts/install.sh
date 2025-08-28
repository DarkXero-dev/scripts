#!/usr/bin/env bash
#
# XeroLinux Installer Script — KDE or GNOME
# Bundles all packages in-script, adds repos, installs, and copies /etc/skel.
# Designed for terminal (TTY) use with ANSI flair.

set -euo pipefail

bold=$(tput bold)
normal=$(tput sgr0)
green='\e[32m'
cyan='\e[36m'
yellow='\e[33m'
red='\e[31m'

cat << "EOF"
${cyan}${bold}
  __  __  _____  ____   ___  _  _  ___     _     _      
 |  \/  || ____||  _ \ / _ \| || ||_ _|   / \   | |     
 | |\/| ||  _|  | |_) | | | | || | | |   / _ \  | |     
 | |  | || |___ |  _ <| |_| | || | | |  / ___ \ | |___  
 |_|  |_||_____||_| \_\\___/|_||_||___|/_/   \_\|_____|
${normal}
EOF

echo -e "${yellow}${bold}Select your XeroLinux flavor:${normal}"
echo "1) KDE"
echo "2) GNOME"
read -rp "Enter your choice (1 or 2): " choice

if [[ "$choice" == "1" ]]; then
  flavor="KDE"
elif [[ "$choice" == "2" ]]; then
  flavor="GNOME"
else
  echo -e "${red}Invalid choice, aborting.${normal}"
  exit 1
fi

echo -e "\n${green}Preparing XeroLinux ${flavor} setup...${normal}"

# 1. Add XeroLinux repo if not present
if ! grep -q "^\[xerolinux\]" /etc/pacman.conf; then
  echo -e "${cyan}Adding XeroLinux repository...${normal}"
  sudo tee -a /etc/pacman.conf > /dev/null <<'EOF'

[xerolinux]
SigLevel = Optional TrustAll
Server = https://repos.xerolinux.xyz/$repo/$arch
EOF
else
  echo -e "${yellow}XeroLinux repository already present. Skipping...${normal}"
fi

# 2. Add Chaotic‑AUR repo if not present
if ! grep -q "^\[chaotic-aur\]" /etc/pacman.conf; then
  echo -e "${cyan}Configuring Chaotic‑AUR repository...${normal}"
  sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
  sudo pacman-key --lsign-key 3056513887B78AEB
  sudo pacman -U --noconfirm \
    'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
    'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
  sudo tee -a /etc/pacman.conf > /dev/null <<'EOF'

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF
else
  echo -e "${yellow}Chaotic‑AUR repository already present. Skipping...${normal}"
fi

echo -e "${cyan}Updating package databases...${normal}"
sudo pacman -Syyu --noconfirm

# 3. Define package lists
echo -e "\n${cyan}Compiling package list for ${flavor}...${normal}"

common_packages=(
  archiso b43-fwcutter base base-devel bind bolt brltty clonezilla cloud-init
  darkhttpd ddrescue dhclient dhcpcd diffutils dmidecode dmraid dnsmasq dosfstools
  e2fsprogs edk2-shell efibootmgr espeakup ethtool exfatprogs fatresize foot-terminfo
  fd fsarchiver gpart gpm gptfdisk hdparm hyperv irssi kitty-terminfo ldns less
  lftp libfido2 libusb-compat lsscsi lvm2 lynx man-db man-pages mc mdadm memtest86+
  memtest86+-efi mmc-utils mtools nano nbd ndisc6 nfs-utils nmap ntfs-3g nvme-cli
  open-iscsi openconnect openpgp-card-tools openssh openvpn partclone parted
  partimage pcsclite ppp pptpclient pv reflector rsync screen sdparm sequoia-sq
  sg3_utils smartmontools sof-firmware squashfs-tools sudo tcpdump terminus-font
  testdisk tldr tmux tpm2-tools tpm2-tss udftools usb_modeswitch usbmuxd usbutils
  vpnc wireguard-tools wvdial xdotool xfsprogs xl2tpd xdg-utils linux linux-atm
  linux-headers linux-firmware-intel linux-firmware-amdgpu grub os-prober
  grub-hooks update-grub eza ntp most wget dialog dnsutils logrotate chaotic-keyring
  chaotic-mirrorlist preload xlapit-cli upd72020x-fw calamares-app desktop-config
  xmlto boost ckbcomp kpmcore yaml-cpp boost-libs gtk-update-icon-cache
  xdg-terminal-exec-git mkinitcpio mkinitcpio-fw mkinitcpio-utils mkinitcpio-archiso
  mkinitcpio-openswap mkinitcpio-nfs-utils hblock cryptsetup brightnessctl
  power-profiles-daemon dex bash make libxinerama bash-completion xorg-apps
  xorg-xinit xorg-server xorg-xwayland fwupd amd-ucode intel-ucode mesa autorandr
  mesa-utils lib32-mesa xf86-video-qxl xf86-video-fbdev lib32-mesa-utils
  qemu-hw-display-qxl orca piper onboard fprintd libinput gestures xf86-input-void
  xf86-input-evdev iio-sensor-proxy libinput-gestures game-devices-udev
  xf86-input-vmmouse xf86-input-libinput xf86-input-synaptics libinput-gestures-qt
  xf86-input-elographics hplip print-manager printer-support scanner-support gstreamer
  gst-libav gst-plugins-bad gst-plugins-base gst-plugins-ugly gst-plugins-good
  gst-plugin-pipewire libdvdcss alsa-utils wireplumber alsa-plugins alsa-firmware
  pipewire-jack pavucontrol-qt pipewire-support lib32-pipewire-jack bluez blueberry
  bluez-libs bluez-utils bluez-tools bluez-plugins bluez-hid2hci iw iwd avahi samba
  netctl openldap nss-mdns smbclient net-tools openresolv traceroute modemmanager
  networkmanager nm-cloud-setup wireless-regdb wireless_tools wpa_supplicant
  systemd-resolvconf networkmanager-vpnc networkmanager-pptp networkmanager-l2tp
  network-manager-sstp network-manager-applet networkmanager-openvpn
  networkmanager-strongswan networkmanager-openconnect mobile-broadband-provider-info
  spice-vdagent open-vm-tools qemu-guest-agent virtualbox-guest-utils jq figlet
  ostree lolcat numlockx lm_sensors appstream-glib lib32-lm_sensors bat bat-extras
  ttf-fira-code otf-libertinus tex-gyre-fonts ttf-hack-nerd xero-fonts-git
  ttf-ubuntu-font-family awesome-terminal-fonts ttf-jetbrains-mono-nerd
  adobe-source-sans-pro-fonts bash-language-server typescript-language-server
  vscode-json-languageserver kvantum fastfetch gtk-engines oh-my-posh-bin
  gtk-engine-murrine gnome-themes-extra kde-wallpapers tela-circle-icon-theme-purple
  falkon ffmpeg ffmpegthumbs ffnvcodec-headers paru flatpak topgrade
  appstream-qt pacman-contrib pacman-bintrans gvfs mtpfs udiskie udisks2 ldmtool
  gvfs-afc gvfs-mtp gvfs-nfs gvfs-smb gvfs-gphoto2 libgsf tumbler freetype2
  libopenraw poppler-qt6 poppler-glib ffmpegthumbnailer python-pip python-cffi
  python-numpy python-docopt python-pyaudio python-pyparted python-pygments
  python-websockets sddm xdg-user-dirs ocs-url xmlstarlet yt-dlp wavpack unarchiver
  rate-mirrors gnustep-base parallel xsettingsd polkit-qt6 systemdgenie gnome-keyring
)

kde_extras=(
  kf6 qt6 kde-system kwin krdp milou breeze oxygen aurorae drkonqi kwrited kgamma
  kscreen sddm-kcm kmenuedit bluedevil kpipewire plasma-nm plasma-pa plasma-sdk
  libkscreen breeze-gtk powerdevil kinfocenter flatpak-kcm kdecoration ksshaskpass
  kwallet-pam libksysguard plasma-vault ksystemstats kde-cli-tools oxygen-sounds
  kscreenlocker kglobalacceld systemsettings kde-gtk-config layer-shell-qt plasma-desktop
  polkit-kde-agent plasma-workspace kdeplasma-addons ocean-sound-theme qqc2-breeze-style
  kactivitymanagerd plasma-integration plasma-thunderbolt plasma5-integration
  plasma-systemmonitor xdg-desktop-portal-kde plasma-browser-integration krdc krfb smb4k
  alligator kdeconnect kio-admin kio-extras kio-gdrive konversation kio-zeroconf
  kdenetwork-filesharing signon-kwallet-extension okular kamera svgpart skanlite
  gwenview spectacle colord-kde kcolorchooser kimagemapeditor kdegraphics-thumbnailers ark
  kate kgpg kfind sweeper konsole kdialog yakuake kweather skanpage filelight kcharselect
  markdownpart qalculate-qt keditbookmarks kdebugsettings kwalletmanager akregator
  waypipe dwayland egl-wayland qt6-wayland lib32-wayland wayland-protocols
  kwayland-integration plasma-wayland-protocols
)

gnome_extras=(
  wayland kwayland5 egl-wayland xorg-xwayland lib32-wayland wayland-utils
  wayland-protocols gsound libgdata evolution-data-server dconf-editor mpv
  gdm-settings flatseal gdm polkit-gnome kirigami gtk-update-icon-cache
  gnome-shell-extensions gnome-tweaks file-roller gnome-control-center nautilus
)

if [[ "$flavor" == "KDE" ]]; then
  all_packages=("${common_packages[@]}" "${kde_extras[@]}")
else
  all_packages=("${common_packages[@]}" "${gnome_extras[@]}")
fi

echo -e "${cyan}Installing ${#all_packages[@]} packages...${normal}"
sudo pacman -S --noconfirm --needed "${all_packages[@]}"

# Enable services based on DE
echo -e "${cyan}Enabling system services...${normal}"
if [[ "$flavor" == "KDE" ]]; then
  sudo systemctl enable sddm power-profiles-daemon
else
  sudo systemctl enable gdm power-profiles-daemon
fi

echo -e "${cyan}Copying /etc/skel to your home directory...${normal}"
cp -a /etc/skel/. "$HOME/"

echo -e "\n${bold}${green}XeroLinux ${flavor} setup complete — enjoy!${normal}"
