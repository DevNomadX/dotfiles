#!/usr/bin/env bash
set -e

notify () {
  echo -e "\n🔔 $1\n"
}

# -------------------------------------------------
# Sudo keep-alive (Fixed)
# -------------------------------------------------
sudo -v
(
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done
) 2>/dev/null &
keep_alive_pid=$!

notify "Starting Pop!_OS 24.04 post-install setup"

# -------------------------------------------------
# Add External Repositories (eza, VS Code, GH CLI)
# -------------------------------------------------
notify "Configuring external repositories"

sudo mkdir -p -m 755 /etc/apt/keyrings

# eza repo
if [ ! -f /etc/apt/sources.list.d/gierens.list ]; then
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
fi

# VS Code repo (Modern deb822 format)
if [ ! -f /etc/apt/sources.list.d/vscode.sources ]; then
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft.gpg > /dev/null
    sudo tee /etc/apt/sources.list.d/vscode.sources > /dev/null << EOF
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64,arm64,armhf
Signed-By: /usr/share/keyrings/microsoft.gpg
EOF
fi

# GitHub CLI repo
if [ ! -f /etc/apt/sources.list.d/github-cli.list ]; then
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
fi

# -------------------------------------------------
# System update & Core Packages
# -------------------------------------------------
notify "Updating system and installing packages"
sudo apt update
sudo apt full-upgrade -y

sudo apt install -y \
  curl wget git zsh neovim ripgrep fd-find batcat \
  alacritty htop trash-cli unzip p7zip-full exfatprogs \
  fuse3 python3 python3-pip pipx clang build-essential \
  ca-certificates stow eza gh code

# Fix naming quirks
mkdir -p ~/.local/bin
ln -sf /usr/bin/batcat ~/.local/bin/bat
ln -sf /usr/bin/fdfind ~/.local/bin/fd

# -------------------------------------------------
# Flatpak
# -------------------------------------------------
notify "Setting up Flatpaks"
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak install -y flathub \
  it.mijorus.gearlever \
  com.valvesoftware.ProtonVPN \
  fr.handbrake.ghb

# -------------------------------------------------
# Starship, SDKMAN, and Proton Pass (Latest)
# -------------------------------------------------
# Starship
if ! command -v starship &> /dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# SDKMAN!
if [ ! -d "$HOME/.sdkman" ]; then
    curl -s "https://get.sdkman.io" | bash
fi

# Proton Pass (Using the 'latest' redirect URL)
if ! dpkg -l | grep -q proton-pass; then
    notify "Installing latest Proton Pass"
    wget -q "https://proton.me/download/pass/linux/ProtonPass.deb" -O /tmp/proton-pass.deb
    sudo apt install -y /tmp/proton-pass.deb
    rm /tmp/proton-pass.deb
fi

# -------------------------------------------------
# Modern Runtimes (uv & fnm)
# -------------------------------------------------
# UV
if ! command -v uv &> /dev/null; then
    notify "Installing uv"
    curl -LsSf https://astral.sh/uv/install.sh | sh
    source "$HOME/.local/bin/env"
fi

# FNM
if ! command -v fnm &> /dev/null; then
    notify "Installing fnm"
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env --shell bash)"
    
    notify "Installing Node.js 24"
    fnm install 24
    fnm default 24
fi
# -------------------------------------------------
# Shell & Dotfiles
# -------------------------------------------------
# Fonts
if [ -f ./fonts_install.sh ]; then
  chmod +x ./fonts_install.sh
  ./fonts_install.sh
fi

# Zsh default
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s "$(which zsh)"
fi

# Stow
if [ -d "$HOME/dotfile" ]; then
    cd "$HOME/dotfile"
    stow -t "$HOME" . -v
fi

# -------------------------------------------------
# Cleanup
# -------------------------------------------------
notify "Cleaning up"
sudo apt autoremove -y
kill "$keep_alive_pid" 2>/dev/null || true

notify "Pop!_OS 24.04 setup complete 🚀"
echo "➡️ Reboot recommended"