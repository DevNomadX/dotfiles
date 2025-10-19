#!/bin/bash

# Directory where fonts will be installed
FONT_DIR="$HOME/.local/share/fonts"

# Nerd Fonts version to download
VERSION="3.2.1"

# Array of desired fonts
FONTS=("FiraCode" "JetBrainsMono" "Meslo")

# Make sure font directory exists
mkdir -p "$FONT_DIR"

cd /tmp || exit 1

echo "Downloading and installing Nerd Fonts..."

for FONT in "${FONTS[@]}"; do
    echo "Downloading $FONT Nerd Font..."
    FILE="${FONT}.zip"
    URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v${VERSION}/${FILE}"

    # Download
    if curl -L -o "$FILE" "$URL"; then
        echo "Extracting $FONT..."
        unzip -o "$FILE" -d "$FONT_DIR/$FONT"
        rm "$FILE"
    else
        echo "Failed to download $FONT"
    fi
done

# Refresh the font cache
echo "Refreshing font cache..."
fc-cache -fv

echo "Done! Nerd Fonts installed in $FONT_DIR"
