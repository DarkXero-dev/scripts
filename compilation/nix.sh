  GNU nano 8.6                                     nix.sh
#!/usr/bin/env bash

set -e

# Install basic dependencies
sudo pacman -Sy --noconfirm curl xz

# Remove any previous single-user installation remnants
rm -rf ~/.nix-profile ~/.nix-defexpr ~/.nix-channels ~/.config/nix

# Run Nix installer in daemon (multi-user) mode
sh <(curl -L https://nixos.org/nix/install) --daemon

# Reload systemd in case nix-daemon.service is not yet recognized
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

# Enable and start nix-daemon.service
sudo systemctl enable --now nix-daemon.service

# Ensure /etc/nix exists
sudo mkdir -p /etc/nix

# Add flakes and nix-command support
echo "experimental-features = nix-command" | sudo tee /etc/nix/nix.conf

# Ensure shell setup (for Bash)
if ! grep -qF '. /etc/profile.d/nix.sh' /etc/profile; then
  echo '. /etc/profile.d/nix.sh' | sudo tee -a /etc/profile
fi

# Add aliases

for rc in ~/.bashrc ~/.zshrc; do
  if [ -f "$rc" ]; then
    {
      echo ""
      echo "# Nix aliases"
      echo "nstall() { nix-env -iA \"nixpkgs.\$1\"; }"
      echo "nsearch() { nix-env -qaP \"\$@\" 2>&1 | grep -vE '^(evaluation warning:|warning: name collision)'; }"
    } >> "$rc"
  fi
done

echo "System-wide Nix installed with flakes and nix-command enabled."
echo "You may need to log out and back in (or reboot) for shell integration to take effect."
sleep 3
