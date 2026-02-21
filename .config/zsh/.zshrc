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

# Performance profiling (uncomment for debugging startup time)
# zmodload zsh/zprof

# Early exit for non-interactive shells
[[ -o interactive ]] || return

# 0. Startup health check - Ensure required directories exist
for dir in ~/.zfunc ~/.cache/zsh ~/.local/state/zsh; do
  [[ -d $dir ]] || mkdir -p "$dir" 2>/dev/null
done
unset dir

# 1. Source all modular configuration files from conf.d/
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
    zcompile "${f}" 2>/dev/null &
  fi
done
wait
unset f

# Display system information with fastfetch (only in first shell)
if [[ $SHLVL -eq 1 ]] && command -v fastfetch &>/dev/null; then
  (fastfetch &)
fi

# Performance profiling end (uncomment matching zmodload above)
# zprof
