# ══════════════════════════════════════════════════════════════
# 🎯 Custom Functions
# ══════════════════════════════════════════════════════════════

# 📂 Create and enter directory
mkcd() {
  [[ -z "$1" ]] && { echo "Usage: mkcd <directory>"; return 1; }
  mkdir -p "$1" || return 1
  cd "$1" || { rm -rf "$1"; return 1; }
}

# 🔍 Find and edit file (requires: fzf)
fe() {
  (( $+commands[fzf] )) || { echo "Error: fzf not installed"; return 1; }
  local file
  file=$(fzf --preview 'command -v bat >/dev/null && bat --color=always --style=numbers --line-range=:500 {} || cat {}')
  [[ -n "$file" ]] && "${EDITOR:-nvim}" "$file"
}

# 📊 Show directory size sorted
ducks() {
  command -v du >/dev/null || { echo "Error: du not installed"; return 1; }
  du -sh -- * | sort -h
}

# 🎵 Compile Kotlin source to JAR
kotlincompile() {
  if [ $# -lt 2 ]; then
    echo "Usage: kotlincompile <source-file.kt> <output-jar-name.jar>"
    return 1
  fi
  kotlinc "$1" -include-runtime -d "$2" && echo "✓ Compilation successful: $2"
}

# ══════════════════════════════════════════════════════════════
# ✨ Added Functions
# ══════════════════════════════════════════════════════════════

# Universal archive extractor (requires: tar, unzip, 7z, etc.)
extract() {
  if [ -z "$1" ]; then
    echo "Usage: extract <file>"
    return 1
  fi
  
  local filename="$1"
  
  # Check if required tool exists for file type
  case "$filename" in
    *.zip)
      (( $+commands[unzip] )) || { echo "Error: unzip not installed"; return 1; } ;;
    *.rar)
      (( $+commands[unrar] )) || { echo "Error: unrar not installed"; return 1; } ;;
    *.7z)
      (( $+commands[7z] )) || { echo "Error: 7z not installed"; return 1; } ;;
    *.tar.bz2|*.tbz2)
      (( $+commands[tar] )) || { echo "Error: tar not installed"; return 1; } ;;
    *.tar.gz|*.tgz)
      (( $+commands[tar] )) || { echo "Error: tar not installed"; return 1; } ;;
  esac

  local basename="${filename%.*}"
  
  # Create directory with archive name and extract there
  mkdir -p "$basename" || return 1
  case "$filename" in
    *.tar.bz2) tar xjf "$filename" -C "$basename" && echo "✓ Extracted: $basename" || return 1 ;;
    *.tar.gz)  tar xzf "$filename" -C "$basename" && echo "✓ Extracted: $basename" || return 1 ;;
    *.tar.xz)  tar xf "$filename" -C "$basename" && echo "✓ Extracted: $basename" || return 1 ;;
    *.bz2)     bunzip2 "$filename" && echo "✓ Extracted: $filename" || return 1 ;;
    *.rar)     unrar x "$filename" "$basename" && echo "✓ Extracted: $basename" || return 1 ;;
    *.gz)      gunzip "$filename" && echo "✓ Extracted: $filename" || return 1 ;;
    *.tar)     tar xf "$filename" -C "$basename" && echo "✓ Extracted: $basename" || return 1 ;;
    *.tbz2)    tar xjf "$filename" -C "$basename" && echo "✓ Extracted: $basename" || return 1 ;;
    *.tgz)     tar xzf "$filename" -C "$basename" && echo "✓ Extracted: $basename" || return 1 ;;
    *.zip)     unzip "$filename" -d "$basename" && echo "✓ Extracted: $basename" || return 1 ;;
    *.Z)       uncompress "$filename" && echo "✓ Extracted: $filename" || return 1 ;;
    *.7z)      7z x "$filename" -o"$basename" && echo "✓ Extracted: $basename" || return 1 ;;
    *)         echo "✗ '$filename' cannot be extracted via extract()"; return 1 ;; 
  esac
}

# Create a timestamped backup of a file
bak() {
  if [ -z "$1" ]; then
    echo "Usage: bak <file>"
    return 1
  fi
  if [[ ! -f "$1" ]]; then
    echo "Error: File '$1' does not exist"
    return 1
  fi
  local backup_file="$1.$(date +%Y-%m-%d_%H-%M-%S).bak"
  cp "$1" "$backup_file" && echo "✓ Backup created: $backup_file" || { echo "✗ Backup failed"; return 1; }
}

# Clone a git repository and cd into it (requires: git)
gclone() {
  (( $+commands[git] )) || { echo "Error: git not installed"; return 1; }
  if [ -z "$1" ]; then
    echo "Usage: gclone <repo_url>"
    return 1
  fi
  git clone "$1" && cd "$(basename "$1" .git)" || return 1
}

# ══════════════════════════════════════════════════════════════
# 🧬 Git Functions
# ══════════════════════════════════════════════════════════════

# Show repo status
gstatus() {
  (( $+commands[git] )) || { echo "Error: git not installed"; return 1; }
  git status
}

# ══════════════════════════════════════════════════════════════
# 🎯 Productivity Functions
# ══════════════════════════════════════════════════════════════

# Backup important directories
backup() {
  if [ -z "$1" ]; then
    echo "Usage: backup <directory>"
    echo "Example: backup ~/Projects"
    return 1
  fi
  if [[ ! -d "$1" ]]; then
    echo "Error: Directory '$1' does not exist"
    return 1
  fi
  local source="$1"
  local timestamp=$(date +%Y-%m-%d_%H-%M-%S)
  local backup_dir="$HOME/.backups/${timestamp}_$(basename "$source")"
  mkdir -p "$(dirname "$backup_dir")" || return 1
  cp -r "$source" "$backup_dir" && echo "✓ Backup created: $backup_dir" || { echo "✗ Backup failed"; return 1; }
}


# Show weather in terminal
weather() {
  if ! command -v curl &>/dev/null; then
    echo "Error: curl not installed"
    return 1
  fi
  local location="${1:-}"
  curl -s "wttr.in/${location}" 2>/dev/null || { echo "⚠️  Could not fetch weather (network issue or invalid location?)"; return 1; }
}

# ══════════════════════════════════════════════════════════════
# 🔍 Health Check Function
# ══════════════════════════════════════════════════════════════

# Check system health and required tools
zsh-health() {
  echo "🔍 Checking zsh environment..."
  echo
  echo "Critical Tools:"
  local missing=0
  for tool in git fzf curl nvim; do
    if command -v "$tool" &>/dev/null; then
      echo "  ✓ $tool"
    else
      echo "  ✗ $tool (MISSING)"
      ((missing++))
    fi
  done
  echo
  echo "Optional Tools (for enhanced features):"
  for tool in eza bat zoxide fnm starship fastfetch; do
    if command -v "$tool" &>/dev/null; then
      echo "  ✓ $tool"
    else
      echo "  ○ $tool (optional)"
    fi
  done
  echo
  [[ $missing -eq 0 ]] && echo "✅ All critical tools installed" || echo "⚠️  Missing $missing critical tools"
}