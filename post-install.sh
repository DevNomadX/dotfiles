#!/usr/bin/env bash
set -e

notify () {
  echo -e "\n🔔 $1\n"
}

# Avoid apt hanging on EULA/config prompts (e.g. ttf-mscorefonts-installer)
export DEBIAN_FRONTEND=noninteractive

# -------------------------------------------------
# Sudo keep-alive (Fixed: trap ensures it dies even on early exit)
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
trap 'kill "$keep_alive_pid" 2>/dev/null || true' EXIT

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="/tmp/post-install-$(date +%Y%m%d-%H%M%S).log"

# Redirect all output to both terminal and log file
exec > >(tee -a "$LOG_FILE") 2>&1

notify "Starting Pop!_OS 24.04 post-install setup"
echo "Log: $LOG_FILE"

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

# Fish shell PPA (Fixed: [ ] doesn't glob-expand, use compgen instead)
if ! compgen -G "/etc/apt/sources.list.d/fish-shell-ubuntu-release-4-*.sources" > /dev/null; then
    sudo add-apt-repository -y ppa:fish-shell/release-4
fi

# -------------------------------------------------
# System update & Core Packages
# -------------------------------------------------
notify "Updating system and installing packages"
sudo apt update
sudo apt full-upgrade -y

# Fixed: batcat -> bat (the apt package is "bat"; "batcat" is just the
# binary name after Debian's rename-due-to-collision, not the package name)
sudo apt install -y \
  curl wget git zsh neovim ripgrep fd-find bat \
  alacritty htop trash-cli unzip p7zip-full exfatprogs \
  fuse3 python3 python3-pip pipx clang build-essential \
  ca-certificates eza gh code ubuntu-restricted-extras ufw fish

# Fix naming quirks
mkdir -p ~/.local/bin
ln -sf /usr/bin/batcat ~/.local/bin/bat
ln -sf /usr/bin/fdfind ~/.local/bin/fd

# Ensure ~/.local/bin is in PATH for future sessions
if ! grep -q '\.local/bin' "$HOME/.zshrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
fi

# -------------------------------------------------
# Stow (Build from source for latest)
# -------------------------------------------------
if ! command -v stow &> /dev/null; then
    notify "Installing Stow from source"
    wget -q https://ftp.gnu.org/gnu/stow/stow-latest.tar.gz -O /tmp/stow.tar.gz
    cd /tmp
    tar xzf stow.tar.gz
    cd stow-*
    ./configure --prefix=/usr/local
    make
    sudo make install
    cd "$SCRIPT_DIR"
    rm -rf /tmp/stow.tar.gz /tmp/stow-*
fi

# -------------------------------------------------
# Ghostty Terminal
# -------------------------------------------------
if ! command -v ghostty &> /dev/null; then
    notify "Installing Ghostty Terminal"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"
fi

# -------------------------------------------------
# Fastfetch (Modern Neofetch replacement)
# -------------------------------------------------
if ! command -v fastfetch &> /dev/null; then
    notify "Installing Fastfetch"
    sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
    sudo apt update
    sudo apt install -y fastfetch
fi

# -------------------------------------------------
# Flatpak
# -------------------------------------------------
notify "Setting up Flatpaks"
if command -v flatpak &> /dev/null; then
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    sudo flatpak install -y flathub \
      it.mijorus.gearlever \
      com.valvesoftware.ProtonVPN \
      fr.handbrake.ghb
else
    echo "⚠️ flatpak not found, skipping Flatpak setup"
fi

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
fi

# FNM (Fixed: --skip-shell means fnm never gets on PATH permanently unless
# we add it to .zshrc ourselves, same as we do for ~/.local/bin above)
if ! command -v fnm &> /dev/null; then
    notify "Installing fnm"
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env --shell bash)"

    if ! grep -q 'fnm env' "$HOME/.zshrc" 2>/dev/null; then
        {
            echo 'export PATH="$HOME/.local/share/fnm:$PATH"'
            echo 'eval "$(fnm env --shell zsh)"'
        } >> "$HOME/.zshrc"
    fi

    notify "Installing Node.js 24"
    fnm install 24
    fnm default 24
fi

# -------------------------------------------------
# Shell & Dotfiles
# -------------------------------------------------
# Fonts
if [ -f "$SCRIPT_DIR/fonts_install.sh" ]; then
  chmod +x "$SCRIPT_DIR/fonts_install.sh"
  "$SCRIPT_DIR/fonts_install.sh"
fi

# Stow
if [ -d "$HOME/dotfile" ]; then
    ( cd "$HOME/dotfile" && stow -t "$HOME" . -v )
fi

# -------------------------------------------------
# Cleanup
# -------------------------------------------------
notify "Cleaning up"
sudo apt autoremove -y

# Enable firewall if ufw is installed
# Fixed: default ufw policy is deny-incoming. Allowing SSH first prevents
# locking yourself out over a remote session. KDE Connect uses TCP+UDP
# 1714-1764, opened here so pairing/sync still works after enable.
if command -v ufw &> /dev/null; then
    notify "Configuring firewall (allowing SSH + KDE Connect before enabling)"
    sudo ufw allow ssh
    sudo ufw allow 1714:1764/tcp
    sudo ufw allow 1714:1764/udp
    sudo ufw --force enable
fi

notify "Pop!_OS 24.04 setup complete 🚀"
echo "➡️ Reboot recommended"
