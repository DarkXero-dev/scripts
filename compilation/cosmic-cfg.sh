#!/usr/bin/env bash
clear
set -euo pipefail
echo "==============================================================="
echo "                   XeroCosmic Install Script                   "
echo "       This will install XeroLinux Cosmic Configuration        "
echo "==============================================================="
echo
read -rp "Proceed with installation ? (Might take a while) [y/N]: " proceed
if [[ ! "$proceed" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 1
fi

# Enable multilib if disabled
enable_multilib() {
  if grep -Pq '^\[multilib\]' /etc/pacman.conf; then
    echo "multilib repository already enabled."
  else
    echo "Enabling multilib repository..."
    sudo cp /etc/pacman.conf /etc/pacman.conf.bak-xerocosmic
    sudo sed -i '/#\[multilib\]/,+1s/^#//' /etc/pacman.conf
  fi
}
echo
# Add XeroLinux repo if missing
add_xerolinux_repo() {
  if grep -Pq '^\[xerolinux\]' /etc/pacman.conf; then
    echo "XeroLinux repo already present."
  else
    echo "Adding XeroLinux repository..."
    echo -e "\n[xerolinux]\nSigLevel = Optional TrustAll\nServer = https://repos.xerolinux.xyz/\$repo/\$arch" | sudo tee -a /etc/pacman.conf >/dev/null
  fi
}
echo
# Detect or install AUR helper
setup_aur_helper() {
  if command -v paru >/dev/null; then
    AUR_HELPER="paru"
  elif command -v yay >/dev/null; then
    AUR_HELPER="yay"
  else
    echo "No AUR helper found."
    echo
    echo "Choose AUR helper to install:"
    echo
    select choice in "paru-bin" "yay-bin"; do
      case $choice in
        paru-bin|yay-bin)
          temp_dir=$(mktemp -d)
          git clone "https://aur.archlinux.org/$choice.git" "$temp_dir"
          pushd "$temp_dir"
          makepkg -si --noconfirm
          popd
          rm -rf "$temp_dir"
          AUR_HELPER=${choice%%-bin}
          break
          ;;
        *)
          echo "Invalid choice."
          ;;
      esac
    done
  fi
  echo "Using AUR helper: $AUR_HELPER"
}

# Step 1: Configure pacman
enable_multilib
add_xerolinux_repo
sudo pacman -Syy
echo
# Step 2: Install pacman packages
echo "Installing official packages..."
echo
sudo pacman -S --noconfirm --needed \
  cosmic-desktop-config firefox rust qt6ct kvantum fastfetch gtk-engines adw-gtk-theme \
  gnome-themes-extra gtk-engine-murrine ttf-fira-code nordic-wallpapers \
  otf-libertinus tex-gyre-fonts ttf-hack-nerd xero-fonts-git xero-fix-scripts \
  ttf-ubuntu-font-family awesome-terminal-fonts ttf-jetbrains-mono-nerd \
  adobe-source-sans-pro-fonts bat bat-extras jq figlet bash-completion \
  brightnessctl acpi upower gtk-update-icon-cache cosmic-ext-applet-caffeine-git

# Step 3: Install AUR packages
setup_aur_helper
echo "Installing AUR packages..."
$AUR_HELPER -S --noconfirm --needed \
  oh-my-posh-bin cosmic-applet-arch cosmic-ext-tweaks cosmic-ext-forecast-git \
  system76-power xdg-terminal-exec-git pacseek-bin

# Step 4: Enable services
echo "Enabling services..."
sudo systemctl enable sshd com.system76.PowerDaemon

# Step 5: Copy Wallpaper
sudo mkdir -p /usr/share/xero-gfx
cd /usr/share/xero-gfx && sudo wget https://raw.githubusercontent.com/DarkXero-dev/Storage/refs/heads/main/Archived/CosmicX/airootfs/usr/share/xero-gfx/Xero-Purple.jpg
cd

# Step 6: Copy /etc/skel to home
echo "Copying /etc/skel to user home..."
USER_HOME="/home/$USER"
cp -r /etc/skel/. "$USER_HOME/"

echo
echo "Installation complete."
echo
read -rp "Reboot now? [y/N]: " reboot_confirm
if [[ "$reboot_confirm" =~ ^[Yy]$ ]]; then
  echo "Rebooting..."
  sudo reboot
else
  echo
  echo "Reboot later to apply changes."
fi
