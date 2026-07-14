# ═══════════════════════════════════════════════════════════════
# 030-integrations.fish — External tool integration
#
# Starship prompt, zoxide, fzf, and lazy tool initialisation.
# ═══════════════════════════════════════════════════════════════

# ── Starship prompt ──────────────────────────────────────────
if type -q starship
    starship init fish | source
end

# ── zoxide (smart cd) ───────────────────────────────────────
if type -q zoxide
    zoxide init fish | source
end

# ── fzf ──────────────────────────────────────────────────────
if test -f ~/.fzf.fish
    source ~/.fzf.fish
end

# ── fnm (Node version manager) — lazy PATH addition ──────────
if not type -q fnm
    set -l fnm_path "$HOME/.local/share/fnm"
    if test -d $fnm_path
        fish_add_path $fnm_path
    end
end

# ── Tool completions (one-shot generation) ───────────────────
# uv
if type -q uv
    uv generate-shell-completion fish | source
end
