# ═══════════════════════════════════════════════════════════════
# 010-aliases.fish — Command shortcuts (Fish)
#
# Mirrors the Zsh aliases from conf.d/02-aliases.zsh.
# ═══════════════════════════════════════════════════════════════

# ── Editor ────────────────────────────────────────────────────
alias vi nvim
alias svi "sudo -E nvim"

# ── File listing ──────────────────────────────────────────────
if type -q eza
    alias ls "eza -al --color=always --group-directories-first --icons"
    alias la "eza -a  --color=always --group-directories-first --icons"
    alias ll "eza -l  --color=always --group-directories-first --icons"
    alias lt "eza -aT --color=always --group-directories-first --icons"
else
    alias ls "ls -la --color=auto"
    alias la "ls -a  --color=auto"
    alias ll "ls -l  --color=auto"
    alias lt "ls -laR --color=auto"
end

# ── Pager / viewer ────────────────────────────────────────────
if type -q bat
    alias cat "bat --theme=Dracula -fn"
end

# ── Network tools ─────────────────────────────────────────────
alias myip "curl -sf ifconfig.me"
alias ports "ss -tulanp"

# ── Directory shortcuts ───────────────────────────────────────
alias .. "cd .."
alias ... "cd ../.."
alias .... "cd ../../.."

# ── Safety (interactive confirmation) ─────────────────────────
if type -q trash
    alias rm "trash -v"
else
    alias rm "rm -i"
end
alias cp "cp -i"
alias mv "mv -i"

# ── Shell reload ──────────────────────────────────────────────
alias reload "exec fish"
