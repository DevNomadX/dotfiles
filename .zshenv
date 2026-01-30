# ══════════════════════════════════════════════════════════════
# 🌍 Environment Variables (sourced on every shell invocation)
# ══════════════════════════════════════════════════════════════
export EDITOR="nvim"
export VISUAL="nvim"
export SUDO_EDITOR="nvim"
export FCEDIT="nvim"
export TERMINAL="alacritty"
export TERM="xterm-256color"
export COLORTERM=truecolor

# Limit JVM memory for Kotlin LSP / other Java tools
export JAVA_OPTS="-Xmx512m -Xms256m"

# Source local environment file if it exists
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"
