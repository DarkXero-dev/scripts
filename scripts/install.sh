#!/usr/bin/env bash
# File: xerolinux-setup-embedded-final.sh
# Purpose: Post-install for Arch-based systems to set up XeroLinux KDE/GNOME with embedded package lists only.
# WHY: Adds Xero + Chaotic-AUR repos, installs embedded package sets, then copies /etc/skel to the user's home.

set -Eeuo pipefail

#====================[ Visual Flair ]====================#
if [[ -t 1 ]]; then
  CSI=$'\033['
  RESET="${CSI}0m"; BOLD="${CSI}1m"; DIM="${CSI}2m"; ITALIC="${CSI}3m";
  RED="${CSI}31m"; GREEN="${CSI}32m"; YELLOW="${CSI}33m"; BLUE="${CSI}34m"; MAGENTA="${CSI}35m"; CYAN="${CSI}36m"; GRAY="${CSI}90m"
else
  RESET=""; BOLD=""; DIM=""; ITALIC=""; RED=""; GREEN=""; YELLOW=""; BLUE=""; MAGENTA=""; CYAN=""; GRAY=""
fi

banner() {
  cat <<'EOF'
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃   __  __            _      _ _             _            ┃
┃  |  \/  | ___  _ _ (_)__ _| (_)_ _  __ _  | |  _  _     ┃
┃  | |\/| |/ _ \| ' \| / _` | | | ' \/ _` | | |_| || |    ┃
┃  |_|  |_|\___/|_||_|_\__,_|_|_|_||_\__, | |____\_,_|    ┃
┃                                   |___/                 ┃
┃              X e r o L i n u x   S e t u p             ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
EOF
}

hr() { printf "${GRAY}%*s${RESET}\n" "$(tput cols 2>/dev/null || echo 60)" | tr ' ' '─'; }
msg() { printf "${BOLD}==>${RESET} %s\n" "$*"; }
ok()  { printf "${GREEN}✔${RESET} %s\n" "$*"; }
warn(){ printf "${YELLOW}⚠${RESET} %s\n" "$*"; }
err() { printf "${RED}✖${RESET} %s\n" "$*" >&2; }

with_spinner() {
  # WHY: Adds flair while a quiet command runs; logs output on failure
  local descr="$1"; shift
  local log="/var/log/xerolinux-setup.log"
  printf "  ${CYAN}…${RESET} %s" "$descr"
  { ("$@") &> >(sed 's/^/  /'); } &>"$log" &
  local pid=$!
  local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  local i=0
  while kill -0 "$pid" 2>/dev/null; do
    printf "\r  ${CYAN}%s${RESET} %s" "${spin:i++%${#spin}:1}" "$descr"
    sleep 0.1
  done
  if wait "$pid"; then
    printf "\r  ${GREEN}✔${RESET} %s\n" "$descr"
  else
    printf "\r  ${RED}✖${RESET} %s (see %s)\n" "$descr" "$log"; return 1
  fi
}

#====================[ Config ]====================#
PACMAN_CONF="/etc/pacman.conf"
CHAOTIC_KEY="3056513887B78AEB"

#====================[ Embedded Package Sets ]====================#
# KDE packages (Don't add anything else)
read -r -d '' KDE_PACKAGES_RAW <<'KDE_EOF'
#######################################################
###                   Archiso                       ###
#######################################################

### Base stuff

archiso
b43-fwcutter
base
base-devel

### More Stuff

bind
bolt
brltty
#btrfs-progs
clonezilla
cloud-init
darkhttpd
ddrescue
dhclient
dhcpcd
diffutils
dmidecode
dmraid
dnsmasq
dosfstools
e2fsprogs
edk2-shell
efibootmgr
espeakup
ethtool
exfatprogs
#f2fs-tools
fatresize
foot-terminfo
fd
fsarchiver
gpart
gpm
gptfdisk
hdparm
hyperv
irssi
#jfsutils
kitty-terminfo
ldns
less
lftp
libfido2
libusb-compat
lsscsi
lvm2
lynx
man-db
man-pages
mc
mdadm
memtest86+
memtest86+-efi
mmc-utils
mtools
nano
nbd
ndisc6
nfs-utils
#nilfs-utils
nmap
ntfs-3g
nvme-cli
open-iscsi
openconnect
openpgp-card-tools
openssh
openvpn
partclone
parted
partimage
pcsclite
ppp
pptpclient
pv
reflector
rsync
screen
sdparm
sequoia-sq
sg3_utils
smartmontools
sof-firmware
squashfs-tools
sudo
#syslinux
tcpdump
terminus-font
testdisk
tldr
tmux
tpm2-tools
tpm2-tss
udftools
usb_modeswitch
usbmuxd
usbutils
vpnc
wireguard-tools
wvdial
xdotool
xfsprogs
xl2tpd
xdg-utils

### Kernel/Firmware

linux
linux-atm
linux-headers
linux-firmware-intel
linux-firmware-amdgpu

### Grub Stuff

grub
os-prober
grub-hooks
update-grub

### archiso-extra

eza
ntp
most
wget
dialog
dnsutils
logrotate

#######################################################
###                  Required                       ###
#######################################################

### Chaotic-AUR

chaotic-keyring
chaotic-mirrorlist

### XeroLinux Build


preload
xlapit-cli
upd72020x-fw
calamares-app
calamares-cfg
desktop-config

### Build Stuff

xmlto
boost
ckbcomp
kpmcore
yaml-cpp
boost-libs
gtk-update-icon-cache
xdg-terminal-exec-git

### mkinitcpio stuff

mkinitcpio
mkinitcpio-fw
mkinitcpio-utils
mkinitcpio-archiso
mkinitcpio-openswap
mkinitcpio-nfs-utils

### Tools

hblock
cryptsetup
brightnessctl
power-profiles-daemon

### Bash & Other

dex
bash
make
libxinerama
bash-completion

### Xorg Applications
### https://archlinux.org/groups/x86_64/xorg-apps/

xorg-apps
xorg-xinit
xorg-server
xorg-xwayland

#######################################################
###                  Hardware                       ###
#######################################################

### CPU ucode

fwupd
amd-ucode
intel-ucode

### Video

mesa
autorandr
mesa-utils
lib32-mesa
xf86-video-qxl
xf86-video-fbdev
lib32-mesa-utils
qemu-hw-display-qxl

### Input

orca
piper
onboard
fprintd
libinput
gestures
xf86-input-void
xf86-input-evdev
iio-sensor-proxy
libinput-gestures
game-devices-udev
xf86-input-vmmouse
xf86-input-libinput
xf86-input-synaptics
libinput-gestures-qt
xf86-input-elographics

### Printers & Scanner support

hplip
print-manager
printer-support
scanner-support

### G-Streamer

gstreamer
gst-libav
gst-plugins-bad
gst-plugins-base
gst-plugins-ugly
gst-plugins-good
gst-plugin-pipewire

## Pipewire Audio

libdvdcss
alsa-utils
wireplumber
alsa-plugins
alsa-firmware
pipewire-jack
pavucontrol-qt
pipewire-support
lib32-pipewire-jack

### Bluetooth

bluez
blueberry
bluez-libs
bluez-utils
bluez-tools
bluez-plugins
bluez-hid2hci

### Networking tools

iw
iwd
avahi
samba
netctl
openldap
nss-mdns
smbclient
net-tools
openresolv
traceroute
b43-fwcutter
modemmanager
networkmanager
nm-cloud-setup
wireless-regdb
wireless_tools
wpa_supplicant
systemd-resolvconf
networkmanager-vpnc
networkmanager-pptp
networkmanager-l2tp
network-manager-sstp
network-manager-applet
networkmanager-openvpn
networkmanager-strongswan
networkmanager-openconnect
mobile-broadband-provider-info

### Virtual Machine

spice-vdagent
open-vm-tools
qemu-guest-agent
virtualbox-guest-utils

#######################################################
###                Applications                     ###
#######################################################

### Applications

jq
figlet
ostree
lolcat
numlockx
lm_sensors
appstream-glib
lib32-lm_sensors

### Bat to replace cat

bat
bat-extras

### Fonts

ttf-fira-code
otf-libertinus
tex-gyre-fonts
ttf-hack-nerd
xero-fonts-git
ttf-ubuntu-font-family
awesome-terminal-fonts
ttf-jetbrains-mono-nerd
adobe-source-sans-pro-fonts

### Kate Plugins

bash-language-server
typescript-language-server
vscode-json-languageserver

### Theme Tools

kvantum
fastfetch
gtk-engines
oh-my-posh-bin
gtk-engine-murrine
gnome-themes-extra

### Rice/Config Related

kde-wallpapers
tela-circle-icon-theme-purple

### Browser

falkon

### Multimedia

ffmpeg
ffmpegthumbs
ffnvcodec-headers

### PKG Management

paru
flatpak
topgrade
appstream-qt
pacman-contrib
pacman-bintrans

#######################################################
###                  Libraries                      ###
#######################################################

### File management

gvfs
mtpfs
udiskie
udisks2
ldmtool
gvfs-afc
gvfs-mtp
gvfs-nfs
gvfs-smb
gvfs-gphoto2

### Tumbler

libgsf
tumbler
freetype2
libopenraw
poppler-qt6
poppler-glib
ffmpegthumbnailer

### Python & Libs

python-pip
python-cffi
python-numpy
python-docopt
python-pyaudio
python-pyparted
python-pygments
python-websockets

#######################################################
###                The System Tools                 ###
#######################################################

### Essentials

sddm
xdg-user-dirs

### Others

ocs-url
xmlstarlet

## Utilities

yt-dlp
wavpack
unarchiver
rate-mirrors
gnustep-base

## Complements

amarok
pacseek
parallel
xsettingsd
polkit-qt6
systemdgenie
gnome-keyring

#######################################################
###                  KDE Desktop                    ###
#######################################################

### https://archlinux.org/groups/x86_64/kf6/

#######################################################
###                   The Groups                    ###
#######################################################

### https://archlinux.org/groups/x86_64/kf6/
### https://archlinux.org/groups/x86_64/qt6/
### https://archlinux.org/groups/x86_64/kde-system/

kf6
qt6
kde-system

#######################################################
###                 The Selections                  ###
#######################################################

### Plasma Selection
### https://archlinux.org/groups/x86_64/plasma/

kwin
krdp
milou
breeze
oxygen
aurorae
drkonqi
kwrited
kgamma
kscreen
sddm-kcm
#kwin-x11
kmenuedit
bluedevil
kpipewire
plasma-nm
plasma-pa
plasma-sdk
libkscreen
breeze-gtk
powerdevil
kinfocenter
flatpak-kcm
kdecoration
ksshaskpass
kwallet-pam
libksysguard
plasma-vault
ksystemstats
kde-cli-tools
oxygen-sounds
kscreenlocker
kglobalacceld
systemsettings
kde-gtk-config
layer-shell-qt
plasma-desktop
polkit-kde-agent
plasma-workspace
kdeplasma-addons
ocean-sound-theme
qqc2-breeze-style
kactivitymanagerd
#plasma-x11-session
plasma-integration
plasma-thunderbolt
plasma5-integration
plasma-systemmonitor
xdg-desktop-portal-kde
plasma-browser-integration

### KDE Network Selection
### https://archlinux.org/groups/x86_64/kde-network/

krdc
krfb
smb4k
alligator
kdeconnect
kio-admin
kio-extras
kio-gdrive
konversation
kio-zeroconf
kdenetwork-filesharing
signon-kwallet-extension

### KDE Graphics Selection
### https://archlinux.org/groups/x86_64/kde-graphics/

okular
kamera
svgpart
skanlite
gwenview
spectacle
colord-kde
kcolorchooser
kimagemapeditor
kdegraphics-thumbnailers

### KDE Utilities Selection
### https://archlinux.org/groups/x86_64/kde-utilities/

ark
kate
kgpg
kfind
sweeper
konsole
kdialog
yakuake
kweather
skanpage
filelight
kmousetool
kcharselect
markdownpart
qalculate-qt
keditbookmarks
kdebugsettings
kwalletmanager
dolphin-plugins

### KDE Multimedia Selection
### https://archlinux.org/groups/x86_64/kde-multimedia/

k3b
kamoso
audiotube
plasmatube
audiocd-kio

### KDE Applications Selection
### https://archlinux.org/groups/x86_64/kde-applications/

akregator

### KDE Wayland

waypipe
dwayland
egl-wayland
qt6-wayland
lib32-wayland
wayland-protocols
kwayland-integration
plasma-wayland-protocols

#######################################################
###                XeroLinux Extras                 ###
#######################################################

vi
duf
gcc
git
npm
yad
zip
xdo
gum
inxi
meld
lzop
nmon
tree
vala
btop
glfw
htop
lshw
cblas
expac
fuse3
lhasa
meson
unace
unrar
unzip
p7zip
iftop
nvtop
rhash
sshfs
vnstat
nodejs
cronie
hwinfo
arandr
assimp
netpbm
wmctrl
grsync
libmtp
polkit
sysprof
semver
zenity
gparted
hddtemp
mlocate
jsoncpp
fuseiso
gettext
node-gyp
intltool
graphviz
pkgstats
inetutils
downgrade
s3fs-fuse
playerctl
asciinema
oniguruma
ventoy-bin
cifs-utils
lsb-release
dbus-python
laptop-detect
perl-xml-parser
gnome-disk-utility
appmenu-gtk-module
KDE_EOF

# Gnome Packages (Don't add anything else)
read -r -d '' GNOME_PACKAGES_RAW <<'GNOME_EOF'
#######################################################
###                   Archiso                       ###
#######################################################

### Base stuff

archiso
b43-fwcutter
base
base-devel

### More Stuff

bind
bolt
brltty
#btrfs-progs
clonezilla
cloud-init
darkhttpd
ddrescue
dhclient
dhcpcd
diffutils
dmidecode
dmraid
dnsmasq
dosfstools
e2fsprogs
edk2-shell
efibootmgr
espeakup
ethtool
exfatprogs
#f2fs-tools
fatresize
foot-terminfo
fd
fsarchiver
gpart
gpm
gptfdisk
hdparm
hyperv
irssi
#jfsutils
kitty-terminfo
ldns
less
lftp
libfido2
libusb-compat
lsscsi
lvm2
lynx
man-db
man-pages
mc
mdadm
memtest86+
memtest86+-efi
mtools
mmc-utils
nano
nbd
ndisc6
nfs-utils
#nilfs-utils
nmap
ntfs-3g
nvme-cli
open-iscsi
openconnect
openpgp-card-tools
openssh
openvpn
partclone
parted
partimage
pcsclite
ppp
pptpclient
pv
reflector
rsync
screen
sdparm
sequoia-sq
sg3_utils
smartmontools
sof-firmware
squashfs-tools
sudo
#syslinux
tcpdump
terminus-font
testdisk
tldr
tmux
tpm2-tools
tpm2-tss
udftools
usb_modeswitch
usbmuxd
usbutils
vpnc
wireguard-tools
wvdial
xdotool
xfsprogs
xl2tpd
xdg-utils

### Kernel/Firmware

linux
linux-atm
linux-headers
linux-firmware-intel
linux-firmware-amdgpu

### Grub Stuff

grub
os-prober
grub-hooks
update-grub

### archiso-extra

eza
ntp
most
wget
dialog
dnsutils
logrotate

### Wayland Stuff

wayland
kwayland5
qt6-wayland
egl-wayland
xorg-xwayland
lib32-wayland
wayland-utils
wayland-protocols

#######################################################
###                  Required                       ###
#######################################################

### Chaotic-AUR

chaotic-keyring
chaotic-mirrorlist

### XeroLinux Build

gsound
preload
libgdata
xlapit-cli
upd72020x-fw
calamares-app
calamares-g-cfg
desktop-config-gnome
evolution-data-server
xdg-terminal-exec-git

### Build Stuff

xmlto
boost
ckbcomp
kpmcore
yaml-cpp
boost-libs
gtk-update-icon-cache

### mkinitcpio stuff

mkinitcpio
mkinitcpio-fw
mkinitcpio-utils
mkinitcpio-archiso
mkinitcpio-openswap
mkinitcpio-nfs-utils

### Tools

mpv
hblock
cryptsetup
brightnessctl
power-profiles-daemon

### Bash & Other

dex
bash
make
libxinerama
bash-completion

### Xorg Applications
### https://archlinux.org/groups/x86_64/xorg-apps/

xorg-apps
xorg-xinit
xorg-server
xorg-xwayland

### Essentials

xmlto
ckbcomp
kpmcore
yaml-cpp
kirigami
boost-libs
polkit-gnome
gtk-update-icon-cache

#######################################################
###                  Hardware                       ###
#######################################################

### CPU ucode

fwupd
amd-ucode
intel-ucode

### Video

mesa
autorandr
mesa-utils
lib32-mesa
xf86-video-qxl
xf86-video-fbdev
lib32-mesa-utils
qemu-hw-display-qxl

### Input

orca
piper
fprintd
libinput
gestures
xf86-input-void
xf86-input-evdev
iio-sensor-proxy
libinput-gestures
game-devices-udev
xf86-input-vmmouse
xf86-input-libinput
xf86-input-synaptics
xf86-input-elographics

### Printers

hplip
printer-support

### G-Streamer

gstreamer
gst-libav
gst-plugins-bad
gst-plugins-base
gst-plugins-ugly
gst-plugins-good
gst-plugin-pipewire

## Pipewire Audio

libdvdcss
alsa-utils
pavucontrol
wireplumber
alsa-plugins
alsa-firmware
pipewire-jack
pipewire-support
lib32-pipewire-jack

### Bluetooth

bluez
blueberry
bluez-libs
bluez-tools
bluez-utils
bluez-plugins
bluez-hid2hci

### Networking tools

iw
iwd
avahi
samba
netctl
openldap
nss-mdns
smbclient
net-tools
openresolv
traceroute
b43-fwcutter
modemmanager
networkmanager
nm-cloud-setup
wireless-regdb
wireless_tools
wpa_supplicant
systemd-resolvconf
networkmanager-vpnc
network-manager-applet
networkmanager-openvpn

### Virtual Machine

spice-vdagent
open-vm-tools
qemu-guest-agent
virtualbox-guest-utils

#######################################################
###                Applications                     ###
#######################################################

### Applications

jq
chafa
figlet
ostree
lolcat
flatseal
numlockx
lm_sensors
gdm-settings
appstream-glib

### Bat to replace cat

bat
bat-extras

### Fonts

ttf-fira-code
otf-libertinus
tex-gyre-fonts
ttf-hack-nerd
xero-fonts-git
ttf-ubuntu-font-family
awesome-terminal-fonts
ttf-jetbrains-mono-nerd
adobe-source-sans-pro-fonts

### Theme Tools

qt5ct
qt6ct
kvantum
fastfetch
gtk-engines
adw-gtk-theme
oh-my-posh-bin
gnome-themes-extra
gtk-engine-murrine

### Rice/Config Related

tela-circle-icon-theme-purple
kvantum-theme-libadwaita-git

### Browser

epiphany

### Multimedia

ffmpeg
ffnvcodec-headers

### PKG Management

paru
flatpak
topgrade
appstream
pacman-contrib
pacman-bintrans

#######################################################
###                  Libraries                      ###
#######################################################

### File management

gvfs
mtpfs
udiskie
udisks2
ldmtool
gvfs-afc
gvfs-mtp
gvfs-nfs
gvfs-smb
gvfs-google
gvfs-gphoto2

### Tumbler

libgsf
tumbler
poppler
freetype2
libopenraw
poppler-glib
ffmpegthumbnailer

### Python & Libs

python-pip
python-cffi
python-numpy
python-docopt
python-pyaudio
python-pyparted
python-pygments
python-websockets

#######################################################
###                 GNOME Desktop                   ###
#######################################################


## GNOME Stuff
## https://archlinux.org/groups/x86_64/gnome/

gnac
gmtk
tecla
loupe
rygel
sushi
baobab
cheese
evince
snapshot
gnome-logs
gnome-maps
gnome-usage
gnome-menus
gnome-music
gnome-shell
simple-scan
gnome-clocks
gnome-autoar
gnome-weather
gnome-photos
grilo-plugins
gnome-session
gnome-keyring
gnome-calendar
gnome-contacts
tracker3-miners
gnome-user-share
gnome-characters
gnome-connections
gnome-font-viewer
xdg-user-dirs-gtk
gnome-disk-utility
gnome-color-manager
gnome-control-center
gnome-remote-desktop
gnome-system-monitor
xdg-terminal-exec-git
gnome-settings-daemon
gnome-network-displays
xdg-desktop-portal-gnome

## Other Gnome Apps
## https://archlinux.org/groups/x86_64/gnome-extra/

gitg
d-spy
geary
gedit
glade
mousai
sysprof
ptyxis
commit
showtime
shortwave
evolution
endeavour
impression
file-roller
gnome-tweaks
dconf-editor
gnome-desktop
gnome-builder
gnome-nettool
gnome-applets
gnome-firmware
gnome-podcasts
gnome-subtitles
gnome-dictionary
gnome-multi-writer
gnome-bluetooth-3.0
gnome-power-manager
gnome-sound-recorder
gnome-desktop-common
gnome-online-accounts
gnome-epub-thumbnailer
gnome-browser-connector
gnome-appfolders-manager

#######################################################
###              GNOME Desktop Extras               ###
#######################################################

## Adwaita stuff

libadwaita
adwaita-fonts
adwaita-cursors
adwaita-icon-theme
adwaita-icon-theme-legacy

## GDM

gdm

## Gnome File Management

nautilus-share
nautilus-compare
nautilus-admin-gtk4
nautilus-open-in-ptyxis
nautilus-image-converter

## GNOME Shell Extensions

extension-manager
gnome-shell-extensions
gnome-shell-extension-arc-menu
gnome-shell-extension-caffeine
gnome-shell-extension-gsconnect
gnome-shell-extension-arch-update
gnome-shell-extension-blur-my-shell
gnome-shell-extension-appindicator
gnome-shell-extension-dash-to-dock
gnome-shell-extension-weather-oclock
gnome-shell-extension-desktop-icons-ng

### Useful shit

pacseek
waypipe
pika-backup
rate-mirrors
qalculate-gtk
libappindicator-gtk3

#######################################################
###                XeroLinux Extras                 ###
#######################################################

vi
duf
gcc
git
npm
yad
zip
xdo
gum
inxi
meld
lzop
nmon
tree
vala
btop
glfw
htop
lshw
cblas
expac
fuse3
lhasa
meson
unace
unrar
unzip
7zip
rhash
iftop
nvtop
sshfs
vnstat
nodejs
cronie
hwinfo
arandr
assimp
netpbm
wmctrl
grsync
libmtp
polkit
sysprof
semver
zenity
gparted
hddtemp
mlocate
jsoncpp
fuseiso
gettext
node-gyp
intltool
graphviz
pkgstats
inetutils
downgrade
s3fs-fuse
playerctl
asciinema
oniguruma
ventoy-bin
cifs-utils
file-roller
lsb-release
dbus-python
laptop-detect
perl-xml-parser
appmenu-gtk-module
GNOME_EOF

#====================[ Helpers ]====================#
require_root() { if [[ ${EUID:-$(id -u)} -ne 0 ]]; then err "Run as root (sudo)."; exit 1; fi }
backup_once() { local f="$1"; [[ -f $f ]] || return 0; local b="$f.bak.$(date +%Y%m%d-%H%M%S)"; cp -a -- "$f" "$b"; ok "Backup: $(basename "$f") → $(basename "$b")"; }
has_block() { grep -qE "^\s*$(printf '%s' "$2" | sed 's/\[/\\[/;s/\]/\\]/')\s*$" "$1"; }
append_if_missing() { local f="$1" hdr="$2" body="$3"; if has_block "$f" "$hdr"; then ok "$hdr already present"; else printf "\n%s\n" "$body" >>"$f"; ok "Added $hdr"; fi }

read_packages_from_raw() {
  # WHY: Only accept explicit package names; ignore comments/blank lines
  printf '%s' "$1" | awk '
    /^\s*#/ {next}
    /^\s*$/ {next}
    { gsub(/\r/, ""); }
    /^[a-z0-9@._+-]+$/ { print $0 }
  '
}

install_in_chunks() {
  local -a pkgs=("$@")
  local total=${#pkgs[@]} chunk=120 i=0
  (( total )) || { warn "No packages to install"; return 0; }
  while (( i < total )); do
    local slice=("${pkgs[@]:i:chunk}")
    msg "Installing $(( i + 1 ))..$(( i + ${#slice[@]} )) of $total"
    pacman -S --needed --noconfirm --noprogressbar "${slice[@]}"
    (( i += chunk ))
  done
}

choose_target_user() {
  if [[ -n ${SUDO_USER:-} && $SUDO_USER != root ]]; then printf '%s\n' "$SUDO_USER"; return; fi
  command -v logname >/dev/null 2>&1 && { ln=$(logname 2>/dev/null || true); [[ -n $ln && $ln != root ]] && { printf '%s\n' "$ln"; return; }; }
  local uid_min; uid_min=$(awk '/^UID_MIN/{print $2}' /etc/login.defs 2>/dev/null || echo 1000)
  getent passwd | awk -F: -v umin="$uid_min" '$3>=umin && $1!="nobody"{print $1; exit}' || echo root
}

copy_skel_to_home() {
  local user="$1" home; home=$(eval echo ~"$user")
  [[ -d $home ]] || { err "Home not found: $home"; return 1; }
  msg "Applying /etc/skel to $home"; shopt -s dotglob nullglob
  cp -an /etc/skel/* "$home" 2>/dev/null || true
  cp -an /etc/skel/.[!.]* "$home" 2>/dev/null || true
  chown -R "$user":"$user" "$home"; ok "Skel applied"
}

#====================[ Repo Setup ]====================#
ensure_xerolinux_repo() {
  msg "Configuring XeroLinux repo"
  backup_once "$PACMAN_CONF"
  local block='[xerolinux]\nSigLevel = Optional TrustAll\nServer = https://repos.xerolinux.xyz/$repo/$arch'
  append_if_missing "$PACMAN_CONF" "[xerolinux]" "$block"
}
ensure_chaotic_repo() {
  msg "Configuring Chaotic-AUR"
  with_spinner "Importing Chaotic key $CHAOTIC_KEY" pacman-key --recv-key "$CHAOTIC_KEY" --keyserver keyserver.ubuntu.com || true
  with_spinner "Locally signing key" pacman-key --lsign-key "$CHAOTIC_KEY" || true
  with_spinner "Installing chaotic keyring + mirrorlist" pacman -U --noconfirm \
    'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
    'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' || true
  backup_once "$PACMAN_CONF"
  local block='[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist'
  append_if_missing "$PACMAN_CONF" "[chaotic-aur]" "$block"
}

#====================[ Menu / Flow ]====================#
print_menu() { cat <<EOF
${BOLD}Choose your XeroLinux edition:${RESET}
  ${CYAN}1)${RESET} XeroLinux ${BOLD}KDE${RESET}
  ${CYAN}2)${RESET} XeroLinux ${BOLD}GNOME${RESET}
EOF
}
resolve_choice() {
  local arg="${1:-}" choice=""
  case "${arg,,}" in
    1|kde) choice="kde" ;;
    2|gnome|gnome-shell) choice="gnome" ;;
    *) print_menu; read -rp "Enter 1 or 2: " ans; case "${ans,,}" in 1|kde) choice="kde" ;; 2|gnome) choice="gnome" ;; *) err "Invalid choice"; exit 1 ;; esac ;;
  esac
  printf '%s\n' "$choice"
}
install_profile() {
  local profile="$1"; local raw
  case "$profile" in
    kde) raw="$KDE_PACKAGES_RAW" ;;
    gnome) raw="$GNOME_PACKAGES_RAW" ;;
    *) err "Unknown profile: $profile"; exit 1 ;;
  esac
  if [[ -z $(printf '%s' "$raw" | grep -vE '^\s*(#|$)') ]]; then err "The embedded $profile package list is empty."; exit 1; fi
  msg "Parsing $profile package list"
  mapfile -t pkgs < <(read_packages_from_raw "$raw")
  (( ${#pkgs[@]} )) || { err "No valid packages found for $profile"; exit 1; }
  msg "Refreshing pacman databases"; pacman -Syy --noconfirm
  msg "Installing ${#pkgs[@]} packages for ${BOLD}$profile${RESET}"; install_in_chunks "${pkgs[@]}"
}

main() {
  banner; hr; require_root
  local profile; profile=$(resolve_choice "${1:-}")
  hr; ensure_xerolinux_repo; ensure_chaotic_repo; msg "Syncing databases"; pacman -Syy --noconfirm
  hr; install_profile "$profile"
  hr; local tgt_user; tgt_user=$(choose_target_user); copy_skel_to_home "$tgt_user"
  hr; ok "All done! Reboot when ready."
}

main "$@"
