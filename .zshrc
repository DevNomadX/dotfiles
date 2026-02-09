# ══════════════════════════════════════════════════════════════
# ZSH CONFIGURATION - MAIN
# ----------------------------------------------------------------------
# This file is for interactive shells. It sources modular config
# files and runs commands that should only execute when you're
# at a prompt.
#
# -> .zshenv is for environment variables (loaded by all shells)
# -> .zprofile is for login shells (PATH, etc.)
# ══════════════════════════════════════════════════════════════
export PATH="$HOME/.local/share/fnm:$PATH"
# 1. Source all modular configuration files from conf.d/
ZDOTDIR=${ZDOTDIR:-~/dotfiles/.config/zsh}
for file in "$ZDOTDIR"/conf.d/*.zsh; do
  if [ -r "$file" ]; then
    source "$file"
  fi
done
unset file

# 2. Enable LS_COLORS if not set
[[ -z $LS_COLORS ]] && command -v dircolors &>/dev/null && eval "$(dircolors -b)"

# 3. Compile config files for speed
# Zcompiles each file in conf.d if the source is newer than the compiled version.
for f in "$ZDOTDIR"/conf.d/*.zsh; do
  if [[ ! -f ${f}.zwc || ${f} -nt ${f}.zwc ]]; then
    zcompile ${f} &!
  fi
done
unset f

# Display system information with fastfetch
if command -v fastfetch &> /dev/null; then
  fastfetch
fi
