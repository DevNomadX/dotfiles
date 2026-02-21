# ══════════════════════════════════════════════════════════════
# 🧭 PATH Configuration & Login Items (sourced on login)
# ══════════════════════════════════════════════════════════════

# Synchronize 'path' array and 'PATH' string, removing duplicates.
typeset -U path PATH

# Iterate through common binary directories.
for dir in "$HOME/.local/sbin" "$HOME/.local/bin" "$HOME/.cargo/bin" "/usr/local/go/bin"; do
  # Only add the directory if it actually exists.
  [[ -d $dir ]] && path+=$dir
done

# Export the final PATH to all sub-shells.
export PATH

# SDKMAN Initialization (must be at the end)
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
