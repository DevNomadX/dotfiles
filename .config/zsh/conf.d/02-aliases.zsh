# ══════════════════════════════════════════════════════════════
# 🔧 Aliases (productivity boosters)
# ══════════════════════════════════════════════════════════════

# 📝 Editor shortcuts
alias vi='vim'
alias svi='sudo -E vim'
alias svim='sudo -E vim'

# 📁 Modern ls replacement (eza)
alias ls='eza -al --color=always --group-directories-first --icons'
alias la='eza -a --color=always --group-directories-first --icons'
alias ll='eza -l --color=always --group-directories-first --icons'
alias lt='eza -aT --color=always --group-directories-first --icons'
alias l.='eza -a | grep -E "^\."'

# 📖 Better cat (bat)
alias cat='bat -fn --theme=Dracula'
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
alias rm='trash -v'
alias cp='cp -i'
alias mv='mv -i'

# 🔄 Quick reload
alias reload='source ~/.zshrc'
