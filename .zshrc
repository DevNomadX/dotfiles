# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ──────────────────────────────────────────────
# 🌟 Terminal Setup
# ──────────────────────────────────────────────
#eval "$(starship init zsh)"


# ──────────────────────────────────────────────
# ⚙️ Zinit Plugin Manager
# ──────────────────────────────────────────────
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33}Installing Zinit Plugin Manager…%f"
    command mkdir -p "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{34}Installation successful.%f" || \
        print -P "%F{160}Zinit installation failed.%f"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load essential annexes only
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-patch-dl

# ──────────────────────────────────────────────
# 📦 Plugins
# ──────────────────────────────────────────────
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# ──────────────────────────────────────────────
# 💎 Powerlevel10k Prompt (via Zinit)
# ──────────────────────────────────────────────
zinit ice depth=1
zinit light romkatv/powerlevel10k


# ──────────────────────────────────────────────
# ⚡ Cached Completion Initialization
# ──────────────────────────────────────────────
autoload -Uz compinit
zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compdump"

# Create cache directory if missing
mkdir -p "${zcompdump:h}"

# Run compinit with caching (-C = trust existing cache)
if [[ -f $zcompdump ]]; then
    compinit -C -d "$zcompdump"
else
    compinit -d "$zcompdump"
fi

# ──────────────────────────────────────────────
# ⚙️ Basic Zsh Options
# ──────────────────────────────────────────────
setopt autocd correct interactivecomments magicequalsubst nonomatch notify numericglobsort promptsubst

# ──────────────────────────────────────────────
# 🧠 Environment
# ──────────────────────────────────────────────
export EDITOR="nvim"
export VISUAL="nvim"
export SUDO_EDITOR="nvim"
export FCEDIT="nvim"
export TERMINAL="ghostty"

bindkey -e

if command -v bat &>/dev/null; then
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    export PAGER="bat"
fi

# ──────────────────────────────────────────────
# 📜 History
# ──────────────────────────────────────────────
HISTSIZE=10000
HISTFILE="$HOME/.zsh_history"
SAVEHIST=$HISTSIZE
setopt appendhistory sharehistory hist_ignore_space hist_ignore_all_dups hist_save_no_dups hist_ignore_dups hist_find_no_dups

# ──────────────────────────────────────────────
# 💡 Completion Styles
# ──────────────────────────────────────────────
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

# ──────────────────────────────────────────────
# 🧭 PATH Setup (minimal, unified)
# ──────────────────────────────────────────────
typeset -U path PATH
path=(
    /opt/nvim-linux-x86_64/bin           # Neovim manual install
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/bin"
    "$HOME/.bin"
    "$HOME/.config/tmux/plugins/tmuxifier/bin"
    /usr/local/go/bin
    $path
)

# ──────────────────────────────────────────────
# 🔧 Aliases
# ──────────────────────────────────────────────
alias vi='nvim'
alias vim='nvim'
alias svi='sudo nvim'
alias vis='nvim "+set si"'
alias speedtest='speedtest-cli | awk "/Download:|Upload:/ {print \$1, \$2, \$3, \"(\", \$2/8, \"MBps)\"}"'

alias ls='eza -al --color=always --group-directories-first --icons'
alias la='eza -a --color=always --group-directories-first --icons'
alias ll='eza -l --color=always --group-directories-first --icons'
alias lt='eza -aT --color=always --group-directories-first --icons'
alias l.='eza -a | grep -e "^\."'
alias cat='batcat --theme=Dracula'

# ──────────────────────────────────────────────
# 🎨 Syntax Highlighting
# ──────────────────────────────────────────────
source ~/.config/zsh/zsh-syntax-highlighting-dracula.sh

# ──────────────────────────────────────────────
# ⌨️ Keybindings
# ──────────────────────────────────────────────
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# ──────────────────────────────────────────────
# 🧩 Integrations
# ──────────────────────────────────────────────
if [[ -n $(command -v fzf) ]]; then
  [[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
fi
#source <(fzf --zsh)
eval "$(zoxide init --cmd cd zsh)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
