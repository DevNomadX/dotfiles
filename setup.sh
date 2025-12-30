#!/usr/bin/env bash
set -e

notify() {
  echo -e "\n🔔 $1\n"
}

notify "Starting Fedora post-install setup"

# -------------------------------------------------
# System update
# -------------------------------------------------
notify "Updating system"
sudo dnf upgrade -y

# -------------------------------------------------
# Enable RPM Fusion (SAFE)
# -------------------------------------------------
notify "Enabling RPM Fusion repositories"

sudo dnf install -y \
  "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

sudo dnf install -y --skip-unavailable \
  rpmfusion-free-release-tainted \
  rpmfusion-nonfree-release-tainted \
  dnf-plugins-core

sudo dnf update -y @core
sudo dnf install -y rpmfusion-\*-appstream-data

# -------------------------------------------------
# Multimedia (Intel Broadwell SAFE)
# -------------------------------------------------
notify "Installing multimedia codecs (Intel Broadwell)"

# Replace Fedora ffmpeg safely
sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing

# Update multimedia group (no weak deps = safer)
sudo dnf update -y @multimedia \
  --setopt="install_weak_deps=False" \
  --exclude=PackageKit-gstreamer-plugin

# VAAPI + ffmpeg libs (NO intel-media-driver!)
sudo dnf install -y --skip-unavailable \
  ffmpeg-libs \
  libva \
  libva-utils \
  libva-intel-driver

# -------------------------------------------------
# Core packages
# -------------------------------------------------
notify "Installing core applications"

sudo dnf install -y --skip-unavailable \
  fzf \
  zoxide \
  kitty \
  vlc \
  neovim \
  wget \
  tar \
  git \
  zsh \
  trash-cli \
  htop \
  fastfetch \
  bat \
  fd-find \
  gnome-tweaks \
  stow \
  curl \
  clang \
  java-25-openjdk \
  java-25-openjdk-devel \
  nodejs \
  npm \
  python3 \
  python3-pip \
  fuse-libs \
  exfat-utils \
  exfatprogs \
  peazip \
  unzip \
  p7zip \
  flatseal \
  nautilus-python \
  gnome-shell-extension-gsconnect \
  gnome-shell-extension-dash-to-dock \
  gnome-shell-extension-user-themes \
  gnome-shell-extension-blur-my-shell \
  gnome-shell-extension-caffeine \
  pipx \
  ripgrep \
  speedtest-cli \
  firewall-config

# -------------------------------------------------
# VS Code (official repo)
# -------------------------------------------------
notify "Installing Visual Studio Code"

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

sudo tee /etc/yum.repos.d/vscode.repo >/dev/null <<EOF
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

sudo dnf install -y --skip-unavailable code

# -------------------------------------------------
# eza (binary install, SAFE)
# -------------------------------------------------
notify "Installing eza"

TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

wget -qO- https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz | tar xz
sudo install -m 755 eza /usr/local/bin/eza

cd -
rm -rf "$TMP_DIR"

# -------------------------------------------------
# Development tools
# -------------------------------------------------
notify "Installing Development Tools group"

sudo dnf group install -y "Development Tools" --skip-unavailable

# -------------------------------------------------
# Install Starship prompt
# -------------------------------------------------
notify "Installing Starship shell prompt"

# Install Starship
curl -sS https://starship.rs/install.sh | sh -s -- -y

# -------------------------------------------------
# gext and GNOME extensions
# -------------------------------------------------
notify "gext and gnome extensions setup"
# Install gext if not installed
pipx install gnome-extensions-cli

# Install some GNOME extensions via gext
gext install \
  tactile@lundal.io \
  appindicatorsupport@rgcjonas.gmail.com \
  clipboard-indicator@tudmotu.com \
  logomenu@aryan_k \
  network-stats@gnome.noroadsleft.xyz \
  window-title-is-back@fthx

# -------------------------------------------------
# Setup LazyVim (Neovim config)
# -------------------------------------------------
notify "Setting up LazyVim for Neovim"

# Remove old config if exists
rm -rf ~/.config/nvim

# Clone LazyVim starter config
git clone https://github.com/LazyVim/starter ~/.config/nvim

# Remove the .git folder to prevent accidental git operations
rm -rf ~/.config/nvim/.git

# -------------------------------------------------
# Install SDKMAN! (Java & other SDK manager)
# -------------------------------------------------
notify "Installing SDKMAN!"

# Install SDKMAN! non-interactively
curl -s "https://get.sdkman.io" | bash

# Initialize SDKMAN! in bashrc if not already present
if ! grep -q 'sdkman-init.sh' ~/.bashrc; then
  echo 'export SDKMAN_DIR="$HOME/.sdkman"' >>~/.bashrc
  echo '[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"' >>~/.bashrc
fi

# -------------------------------------------------
# Install Brave Browser
# -------------------------------------------------
notify "Installing Brave Browser"

# Fetch and run the official Brave install script
curl -fsS https://dl.brave.com/install.sh | sudo bash

# -------------------------------------------------
# Flatpak apps
# -------------------------------------------------
notify "Setting up Flatpak and installing apps"

# Install Flatpak itself if not installed
sudo dnf install -y --skip-unavailable flatpak

# Enable Flathub repository if not already enabled
if ! flatpak remote-list | grep -q flathub; then
  sudo flatpak remote-add --if-not-exists flathub \
    https://flathub.org/repo/flathub.flatpakrepo
fi

# Install Flatpak applications
flatpak install -y flathub \
  it.mijorus.gearlever \
  com.protonvpn.www \
  fr.handbrake.ghb \
  com.mattjakeman.ExtensionManager \
  com.github.unrud.VideoDownloader

# -------------------------------------------------
# Install GitHub CLI
# -------------------------------------------------
notify "Installing GitHub CLI"

# Install DNF plugin to manage repositories
sudo dnf install -y dnf-plugins-core --skip-unavailable
sudo dnf4 config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo

# Install gh from the official repo
sudo dnf install -y gh --repo gh-cli --skip-unavailable

# -------------------------------------------------
# Font setup
# -------------------------------------------------
notify "Installing fonts"

sudo dnf install -y --skip-unavailable \
  fontconfig \
  freetype \
  liberation-fonts \
  google-noto-fonts \
  google-noto-emoji-fonts \
  google-noto-cjk-fonts \
  fira-code-fonts \
  cascadia-code-fonts

# Install Fira Mono Nerd Font (manual install)
# Make sure the script is executable
chmod +x ./fonts_install.sh
./fonts_install.sh

chmod +x ./gnome/shortcut/restor_shortcut.sh
./gnome/shortcut/restor_shortcut.sh

# -------------------------------------------------
# Install Proton Pass (official RPM)
# -------------------------------------------------
notify "Installing Proton Pass (password manager)"

TMP_PP=$(mktemp -d)
cd "$TMP_PP"

# Download the specified Proton Pass RPM
wget -qO proton-pass.rpm "https://proton.me/download/pass/linux/proton-pass-1.33.3-1.x86_64.rpm"

# Install with dnf so dependencies are handled
sudo dnf install -y --skip-unavailable ./proton-pass.rpm

cd -
rm -rf "$TMP_PP"

# -------------------------------------------------
# Change default shell to Zsh
# -------------------------------------------------
notify "Changing default shell to Zsh"

# Change the shell for the current user
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s "$(which zsh)"
fi

# -------------------------------------------------
# Deploy dotfiles with GNU Stow
# -------------------------------------------------
notify "Deploying dotfiles from ~/dotfile with GNU Stow"

# Go to the dotfile folder
cd ~/dotfiles

# Deploy all subdirectories into $HOME
stow -t "$HOME" . -v

# -------------------------------------------------
# Done
# -------------------------------------------------
notify "Setup complete 🎉"
echo "➡️ Reboot recommended for multimedia & VAAPI"
