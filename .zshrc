# ══════════════════════════════════════════════════════════════
# ⚡ Powerlevel10k Instant Prompt (MUST stay first for speed)
# ══════════════════════════════════════════════════════════════
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ══════════════════════════════════════════════════════════════
# 🧭 PATH Configuration (deduplicated automatically with typeset -U)
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


# ══════════════════════════════════════════════════════════════
# 🌍 Environment Variables
# ══════════════════════════════════════════════════════════════
export EDITOR="nvim"
export VISUAL="nvim"
export SUDO_EDITOR="nvim"
export FCEDIT="nvim"
export TERMINAL="ghostty"

# ══════════════════════════════════════════════════════════════
# ⚙️ Zinit Plugin Manager (auto-install if missing)
# ══════════════════════════════════════════════════════════════
ZINIT_HOME="${HOME}/.local/share/zinit/zinit.git"
if [[ ! -f ${ZINIT_HOME}/zinit.zsh ]]; then
  echo "📦 Installing Zinit..."
  command mkdir -p "${ZINIT_HOME%/*}" && \
  command git clone --depth=1 https://github.com/zdharma-continuum/zinit "${ZINIT_HOME}"
fi
source "${ZINIT_HOME}/zinit.zsh"

# ══════════════════════════════════════════════════════════════
# 🔌 Zinit Annexes (binary/gem/node management)
# ══════════════════════════════════════════════════════════════
zinit light-mode for zdharma-continuum/zinit-annex-bin-gem-node

# ══════════════════════════════════════════════════════════════
# 💎 Powerlevel10k Theme (fast, async git info)
# ══════════════════════════════════════════════════════════════
zinit ice depth=1
zinit light romkatv/powerlevel10k
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# 🚀 Enable async git status (gitstatus is built into p10k)
typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)

# ══════════════════════════════════════════════════════════════
# ⚡ Fast Compinit (cache refresh every 7 days)
# ══════════════════════════════════════════════════════════════
autoload -Uz compinit
zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compdump"
command mkdir -p "${zcompdump:h}"

# 📊 Check if compdump is older than 7 days (604800 seconds)
if [[ -f $zcompdump && ( ! -s ${zcompdump}.zwc || $zcompdump -nt ${zcompdump}.zwc ) ]]; then
  zcompile "$zcompdump"
fi

if [[ -f $zcompdump && $((EPOCHSECONDS - $(stat -c %Y "$zcompdump" 2>/dev/null || echo 0))) -gt 604800 ]]; then
  compinit -i -d "$zcompdump"
  zcompile "$zcompdump"
else
  compinit -C -d "$zcompdump"
fi

# ══════════════════════════════════════════════════════════════
# 📦 Essential Plugins (loaded immediately for best UX)
# ══════════════════════════════════════════════════════════════
# 🎯 Load order matters: completions → autosuggestions → fzf-tab → syntax-highlighting

zinit light zsh-users/zsh-completions

zinit light zsh-users/zsh-autosuggestions

zinit light Aloxaf/fzf-tab

# ⚠️ Syntax highlighting MUST be last (load with slight delay to avoid blocking)
zinit ice wait'0a' lucid atinit'ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)'
zinit light zsh-users/zsh-syntax-highlighting

# ══════════════════════════════════════════════════════════════
# 🛠️ OMZ Plugins (lightweight, async loaded)
# ══════════════════════════════════════════════════════════════
zinit ice wait'0b' lucid
zinit snippet OMZP::sudo

zinit ice wait'0c' lucid
zinit snippet OMZP::command-not-found

# ══════════════════════════════════════════════════════════════
# ⚙️ Zsh Options (behavior & history)
# ══════════════════════════════════════════════════════════════
setopt autocd                    # 📂 cd by typing directory name
setopt correct                   # ✏️  suggest corrections
setopt interactivecomments       # 💬 allow comments in interactive mode
setopt magicequalsubst           # 🎩 enable filename expansion for foo=~/bar
setopt nonomatch                 # 🎯 pass unmatched globs to command
setopt notify                    # 📢 report job status immediately
setopt numericglobsort           # 🔢 sort filenames numerically
setopt promptsubst               # 🎨 enable prompt substitution

# 📜 History settings
setopt appendhistory             # ➕ append to history file
setopt sharehistory              # 🔄 share history between sessions
setopt hist_ignore_space         # 🙈 ignore commands starting with space
setopt hist_ignore_all_dups      # 🚫 remove all duplicate entries
setopt hist_save_no_dups         # 💾 don't save duplicates
setopt hist_ignore_dups          # 🔇 ignore consecutive duplicates
setopt hist_find_no_dups         # 🔍 don't show duplicates in search
setopt hist_reduce_blanks        # 🧹 remove extra blanks
setopt inc_append_history        # ⚡ write to history immediately

HISTSIZE=10000                   # 📊 increased from 5000 for better history
HISTFILE="${HOME}/.zsh_history"
SAVEHIST=$HISTSIZE

# ══════════════════════════════════════════════════════════════
# ⌨️  Key Bindings (Emacs mode)
# ══════════════════════════════════════════════════════════════
bindkey -e                                    # 🔤 emacs key bindings
bindkey '^[[1;5C' forward-word                # ➡️  Ctrl+Right
bindkey '^[[1;5D' backward-word               # ⬅️  Ctrl+Left
bindkey '^[[H' beginning-of-line              # 🏠 Home key
bindkey '^[[F' end-of-line                    # 🔚 End key
bindkey '^[[3~' delete-char                   # 🗑️  Delete key
bindkey '^[[A' history-search-backward        # ⬆️  Up arrow (history search)
bindkey '^[[B' history-search-forward         # ⬇️  Down arrow (history search)

# ══════════════════════════════════════════════════════════════
# 🎨 Completion Styling (modern, case-insensitive)
# ══════════════════════════════════════════════════════════════
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'           # 🔠 case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"          # 🌈 colorful completions
zstyle ':completion:*' menu no                                   # 🚫 disable default menu
zstyle ':completion:*' squeeze-slashes true                      # 🗜️  remove duplicate slashes
zstyle ':completion:*:*:*:*:descriptions' format '%F{cyan}-- %d --%f'
zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}-- %d (errors: %e) --%f'
zstyle ':completion:*:messages' format '%F{purple}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'

# 🐳 Docker completion optimization
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

# ══════════════════════════════════════════════════════════════
# 🔍 FZF-Tab Configuration (preview with eza + bat)
# ══════════════════════════════════════════════════════════════
# 🎨 Visual layout (80% height, reverse list, bottom preview)
zstyle ':fzf-tab:*' fzf-flags \
  --height=80% \
  --layout=reverse-list \
  --preview-window=down:50%:wrap \
  --color=fg+:bold,fg:dim,header:italic,preview-border:cyan \
  --bind='ctrl-/:toggle-preview'

# 📂 Directory/file preview for cd command
zstyle ':fzf-tab:complete:cd:*' fzf-preview \
  'if [[ -d $realpath ]]; then
     eza --icons --color=always -a --group-directories-first "$realpath"
   elif [[ -f $realpath ]]; then
     bat --color=always --style=plain --line-range=:150 "$realpath"
   else
     echo "Preview not available"
   fi'

# 🧭 Zoxide preview (same as cd)
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview \
  'if [[ -d $realpath ]]; then
     eza --icons --color=always -a --group-directories-first "$realpath"
   elif [[ -f $realpath ]]; then
     bat --color=always --style=plain --line-range=:150 "$realpath"
   else
     echo "Preview not available"
   fi'

# 📦 Preview for package managers
zstyle ':fzf-tab:complete:(apt|apt-get):*' fzf-preview 'apt-cache show $word 2>/dev/null'
zstyle ':fzf-tab:complete:yay:*' fzf-preview 'yay -Si $word 2>/dev/null'

# ══════════════════════════════════════════════════════════════
# 🧩 External Integrations (lazy-loaded for speed)
# ══════════════════════════════════════════════════════════════

# 🔍 FZF integration
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh


# 🧭 Zoxide integration (properly lazy-loaded)
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init --cmd cd zsh)"
fi

# ══════════════════════════════════════════════════════════════
# 🔧 Aliases (productivity boosters)
# ══════════════════════════════════════════════════════════════

# 📝 Editor shortcuts
alias vi='nvim'
alias vim='nvim'
alias svi='sudo -E nvim'
alias svim='sudo -E nvim'

# 📁 Modern ls replacement (eza)
alias ls='eza -al --color=always --group-directories-first --icons'
alias la='eza -a --color=always --group-directories-first --icons'
alias ll='eza -l --color=always --group-directories-first --icons'
alias lt='eza -aT --color=always --group-directories-first --icons'
alias l.='eza -a | grep -E "^\."'

# 📖 Better cat (bat)
alias cat='bat --theme=Dracula'
alias less='bat --paging=always'

# 🌐 Network utilities
alias speedtest='speedtest-cli --simple | awk "{print \$1, \$2, \"(\", \$2/8, \"MB/s)\"}"'
alias myip='curl -s ifconfig.me'
alias ports='netstat -tulanp'

# 🛠️ System shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# 🧹 Safety nets
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# 🔄 Quick reload
alias reload='source ~/.zshrc'

# ══════════════════════════════════════════════════════════════
# 🎯 Custom Functions
# ══════════════════════════════════════════════════════════════

# 📂 Create and enter directory
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# 🔍 Find and edit file
fe() {
  local file
  file=$(fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}')
  [[ -n $file ]] && ${EDITOR:-nvim} "$file"
}

# 📊 Show directory size sorted
ducks() {
  du -sh -- * | sort -h
}

# ══════════════════════════════════════════════════════════════
# ✨ Final Touches
# ══════════════════════════════════════════════════════════════

# 🎨 Enable LS_COLORS if not set
[[ -z $LS_COLORS ]] && command -v dircolors &>/dev/null && eval "$(dircolors -b)"

# 🚀 Compile zshrc for faster loading (run in background)
if [[ ! -f ~/.zshrc.zwc || ~/.zshrc -nt ~/.zshrc.zwc ]]; then
  zcompile ~/.zshrc &!
fi
