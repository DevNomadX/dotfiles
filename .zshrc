# ──────────────────────────────────────────────
# ⚡ Powerlevel10k Instant Prompt (must be first)
# ──────────────────────────────────────────────
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ──────────────────────────────────────────────
# 🧭 PATH & Environment
# ──────────────────────────────────────────────
typeset -U path PATH
path=(
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
  /opt/nvim-linux-x86_64/bin
  "$HOME/.config/tmux/plugins/tmuxifier/bin"
  /usr/local/go/bin
  "$HOME/bin"
  "$HOME/.bin"
  $path
)

export EDITOR="nvim"
export VISUAL="nvim"
export SUDO_EDITOR="nvim"
export FCEDIT="nvim"
export TERMINAL="ghostty"

# ──────────────────────────────────────────────
# ⚙️ Zinit Plugin Manager (auto-install if missing)
# ──────────────────────────────────────────────
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
  echo "Installing Zinit..."
  mkdir -p "$HOME/.local/share/zinit" &&
  git clone --depth=1 https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git"
fi
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit && _comps[zinit]=_zinit

# ──────────────────────────────────────────────
# 🔌 Zinit Annexes (for async + binary mgmt)
# ──────────────────────────────────────────────
zinit light-mode for zdharma-continuum/zinit-annex-bin-gem-node

# ──────────────────────────────────────────────
# 💎 Powerlevel10k (Minimal Prompt)
# ──────────────────────────────────────────────
zinit ice depth=1
zinit light romkatv/powerlevel10k
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Enable async git info (for large repos)
typeset -g POWERLEVEL9K_VCS_BACKEND=git
typeset -g POWERLEVEL9K_VCS_GIT_HOOKS=(vcs-detect-changes gitstatus)
typeset -g POWERLEVEL9K_VCS_GITSTATUS_DIR="$HOME/.cache/gitstatus"

# ──────────────────────────────────────────────
# 📦 Async Plugins (Turbo Mode)
# ──────────────────────────────────────────────
zinit ice wait'0a' lucid
zinit light zsh-users/zsh-completions

zinit ice wait'0b' lucid
zinit light zsh-users/zsh-autosuggestions

zinit ice wait'1' lucid
zinit light Aloxaf/fzf-tab

zinit ice wait'2' lucid
zinit light zsh-users/zsh-syntax-highlighting  # Must be last

# Minimal OMZ snippets
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# ──────────────────────────────────────────────
# ⚡ Fast Compinit Caching (refreshes every 7 days)
# ──────────────────────────────────────────────
autoload -Uz compinit
zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compdump"
mkdir -p "${zcompdump:h}"
if [[ -f $zcompdump ]]; then
  if (( EPOCHSECONDS - $(stat -c %Y "$zcompdump") > 604800 )); then
    compinit -i -d "$zcompdump"
  else
    compinit -C -U -d "$zcompdump"
  fi
else
  compinit -i -d "$zcompdump"
fi

# ──────────────────────────────────────────────
# ⚙️ Zsh Behavior & History
# ──────────────────────────────────────────────
setopt autocd correct interactivecomments magicequalsubst nonomatch notify numericglobsort promptsubst \
        appendhistory sharehistory hist_ignore_space hist_ignore_all_dups hist_save_no_dups hist_ignore_dups \
        hist_find_no_dups hist_reduce_blanks inc_append_history

HISTSIZE=5000
HISTFILE="$HOME/.zsh_history"
SAVEHIST=$HISTSIZE

bindkey -e
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# ──────────────────────────────────────────────
# 🎨 FZF-TAB Preview with Icons (via eza)
# ──────────────────────────────────────────────
# Case-insensitive matching
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Enable LS_COLORS support
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Menu behavior
zstyle ':completion:*' menu no

# Use eza with icons for directory/file preview in cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview \
  '([[ -d $realpath ]] && eza --icons --color=always -a --group-directories-first "$realpath") || \
   ([[ -f $realpath ]] && bat --color=always --style=plain --line-range=:150 "$realpath")'

# Same for zoxide completion
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview \
  '([[ -d $realpath ]] && eza --icons --color=always -a --group-directories-first "$realpath") || \
   ([[ -f $realpath ]] && bat --color=always --style=plain --line-range=:150 "$realpath")'

# Enable Docker option stacking
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

# Vertical preview layout
zstyle ':fzf-tab:*' fzf-flags --height=80% --layout=reverse-list --preview-window=down:50%:wrap

# Optional: color/border polish
zstyle ':fzf-tab:*' fzf-flags '--color=fg+:bold,fg:dim,header:italic,preview-border:cyan'


# ──────────────────────────────────────────────
# 🧩 Integrations
# ──────────────────────────────────────────────
if command -v fzf &>/dev/null; then
  [[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
fi

# Lazy-load zoxide (fast first use)
function cd() {
  if [[ -z ${_ZO_EXE:-} ]]; then
    eval "$(zoxide init --cmd cd zsh)"
    cd "$@"
  else
    builtin cd "$@"
  fi
}

# ──────────────────────────────────────────────
# 🔧 Aliases (Neovim + Utilities)
# ──────────────────────────────────────────────
alias vi='nvim'
alias svi='sudo -E nvim'
alias ls='eza -al --color=always --group-directories-first --icons'
alias la='eza -a --color=always --group-directories-first --icons'
alias ll='eza -l --color=always --group-directories-first --icons'
alias lt='eza -aT --color=always --group-directories-first --icons'
alias cat='bat --theme=Dracula --style=plain'
alias l.='ls -A | grep "^\."'
alias speedtest='speedtest-cli | awk "/Download:|Upload:/ {print \$1, \$2, \$3, \"(\", \$2/8, \"MBps)\"}"'
