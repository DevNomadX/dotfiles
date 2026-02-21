# ══════════════════════════════════════════════════════════════
# ⚙️ Zsh Options (behavior & history)
# ══════════════════════════════════════════════════════════════
umask 0027                       # 🔒 restrictive file permissions

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
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
SAVEHIST=$HISTSIZE

# Ensure history directory exists with proper permissions
mkdir -p "$(dirname "$HISTFILE")"
touch "$HISTFILE" 2>/dev/null
chmod 600 "$HISTFILE" 2>/dev/null

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
