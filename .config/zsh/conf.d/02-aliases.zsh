# ══════════════════════════════════════════════════════════════
# 🔧 Aliases (productivity boosters)
# ══════════════════════════════════════════════════════════════

# 📝 Editor shortcuts
alias vi='nvim'
alias svi='sudo -E nvim'
alias svim='sudo -E nvim'

# 📁 Modern ls replacement (eza) or fallback to ls
if command -v eza &>/dev/null; then
  alias ls='eza -al --color=always --group-directories-first --icons'
  alias la='eza -a --color=always --group-directories-first --icons'
  alias ll='eza -l --color=always --group-directories-first --icons'
  alias lt='eza -aT --color=always --group-directories-first --icons'
  alias l.='eza -a | grep -E "^\."'
else
  alias ls='ls -la --color=auto'
  alias la='ls -a --color=auto'
  alias ll='ls -l --color=auto'
  alias lt='ls -laR --color=auto'
fi

# 📖 Better cat (bat) or fallback to cat
if command -v bat &>/dev/null; then
  alias cat='bat -fn --theme=Dracula'
  alias less='bat --paging=always'
else
  alias cat='cat'
fi

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
if command -v trash &>/dev/null; then
  alias rm='trash -v'
else
  alias rm='rm -i'
fi
alias cp='cp -i'
alias mv='mv -i'

# 🔄 Quick reload
alias reload='exec zsh'
