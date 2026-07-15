# ═══════════════════════════════════════════════════════════════
# config.fish — Fish shell main configuration
#
# Fish loads config.fish first, then conf.d/*.fish alphabetically.
# This file handles environment variables, PATH, and anything that
# must be set before conf.d/ modules load.
#
# Fish provides syntax highlighting, autosuggestions, and tab
# completions out of the box — no plugin manager required.
# ═══════════════════════════════════════════════════════════════

# ── Early exit for non-interactive shells ─────────────────────
status is-interactive; or exit

# ── Environment variables ────────────────────────────────────
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx SUDO_EDITOR nvim
set -gx TERMINAL alacritty
set -gx COLORTERM truecolor
set -gx JAVA_OPTS "-Xmx512m -Xms256m"
set -gx PATH /home/skmonir/.opencode/bin $PATH

# Only override TERM if unset or linux (preserves tmux/screen values)
if test -z "$TERM" -o "$TERM" = linux
    set -gx TERM xterm-256color
end

# ── PATH ──────────────────────────────────────────────────────
# fish_add_path is idempotent and deduplicates automatically
fish_add_path "$HOME/.local/bin"
fish_add_path "$HOME/.local/sbin"
fish_add_path "$HOME/.cargo/bin"
test -d /usr/local/go/bin && fish_add_path /usr/local/go/bin

# ── Runtime directories ──────────────────────────────────────
# Fish manages its own history file; just ensure the cache dir exists
set -l xdg_cache "$HOME/.cache/fish"
if not test -d "$xdg_cache"
    mkdir -p "$xdg_cache"
end

if status is-interactive
    fastfetch
end

# ── SDKMAN ────────────────────────────────────────────────────
# Fish cannot source bash scripts directly. SDKMAN_DIR is exported
# so that `sdk` can find its home when invoked via `bass` or bash.
# Full SDKMAN integration requires `bass` (omf plugin) or a bash wrapper.
set -gx SDKMAN_DIR "$HOME/.sdkman"
