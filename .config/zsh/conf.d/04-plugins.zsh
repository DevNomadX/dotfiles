# ══════════════════════════════════════════════════════════════
# 🔌 Plugins, Completions, and Integrations
# ══════════════════════════════════════════════════════════════

# 1. Initialize Zinit Plugin Manager (auto-installs if missing)
ZINIT_HOME="${HOME}/.local/share/zinit/zinit.git"
if [[ ! -f ${ZINIT_HOME}/zinit.zsh ]]; then
  echo "📦 Installing Zinit..."
  command mkdir -p "${ZINIT_HOME%/*}" && \
  command git clone --depth=1 https://github.com/zdharma-continuum/zinit "${ZINIT_HOME}"
fi
source "${ZINIT_HOME}/zinit.zsh"

# 2. Fast Compinit (cache refresh every 7 days)
autoload -Uz compinit
zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compdump"
command mkdir -p "${zcompdump:h}"
if [[ -f $zcompdump && $((EPOCHSECONDS - $(stat -c %Y "$zcompdump" 2>/dev/null || echo 0))) -gt 604800 ]]; then
  compinit -i -d "$zcompdump"
  zcompile "$zcompdump"
else
  compinit -C -d "$zcompdump"
fi

# 3. Tool Initializations (FNM, UV)
if (( $+commands[fnm] )); then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi
if (( $+commands[uv] )); then
  eval "$(uv generate-shell-completion zsh)"
fi

# 4. Zinit Annexes & Plugins
zinit light-mode for zdharma-continuum/zinit-annex-bin-gem-node

# 🎯 Load order matters: completions → autosuggestions → fzf-tab → syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit ice wait'0a' lucid atinit'ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)'
zinit light zsh-users/zsh-syntax-highlighting

# OMZ Plugins
zinit ice wait'0b' lucid; zinit snippet OMZP::sudo
zinit ice wait'0c' lucid; zinit snippet OMZP::command-not-found

# 5. External Integrations (FZF, Zoxide)
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init --cmd cd zsh)"
fi

# 6. Completion Styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*:*:*:*:descriptions' format '%F{cyan}-- %d --%f'
zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'

# 7. FZF-Tab Configuration
zstyle ':fzf-tab:*' prefix ''
zstyle ':fzf-tab:*' fzf-flags \
  --height=80% --layout=reverse-list --preview-window=down:50%:wrap \
  --color=fg+:bold,fg:dim,header:italic,preview-border:cyan \
  --bind='ctrl-/:toggle-preview'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'if [[ -d $realpath ]]; then eza --icons --color=always -a --group-directories-first "$realpath"; elif [[ -f $realpath ]]; then bat --color=always --style=plain --line-range=:150 "$realpath"; else echo "Preview not available"; fi'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'if [[ -d $realpath ]]; then eza --icons --color=always -a --group-directories-first "$realpath"; elif [[ -f $realpath ]]; then bat --color=always --style=plain --line-range=:150 "$realpath"; else echo "Preview not available"; fi'
zstyle ':fzf-tab:complete:(cat|bat|less|more|vim|nvim|vi|nano|code|rm|trash|eza):*' fzf-preview 'if [[ -d $realpath ]]; then eza --icons --color=always -a --group-directories-first --oneline "$realpath"; elif [[ -f $realpath ]]; then bat --color=always --style=numbers --theme=Dracula --line-range=:400 "$realpath" 2>/dev/null || cat "$realpath"; else echo "Preview not available"; fi'
zstyle ':fzf-tab:complete:(apt|apt-get):*' fzf-preview 'apt-cache show $word 2>/dev/null'
zstyle ':fzf-tab:complete:yay:*' fzf-preview 'yay -Si $word 2>/dev/null'
