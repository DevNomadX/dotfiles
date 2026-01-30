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

#  for compileing Kotlin
kotlincompile() {
    # Check if both arguments are provided
    if [ $# -lt 2 ]; then
        echo " Usage: kotlincompile <source-file.kt> <output-jar-name.jar>"
        return 1
    fi

    # Compile the Kotlin file into the specified JAR
    kotlinc "$1" -include-runtime -d "$2" && echo "  ⟶  Compilation successful: $2"
}

# ══════════════════════════════════════════════════════════════
# ✨ Added Functions
# ══════════════════════════════════════════════════════════════

# Universal archive extractor
extract() {
  if [ -z "$1" ]; then
    echo "Usage: extract <file>"
    return 1
  fi

  local filename="$1"
  local basename="${filename%.*}"
  
  # Create directory with archive name and extract there
  mkdir -p "$basename" && \
  case "$filename" in
    *.tar.bz2) tar xjf "$filename" -C "$basename" ;;
    *.tar.gz)  tar xzf "$filename" -C "$basename" ;;
    *.tar.xz)  tar xf "$filename" -C "$basename"  ;;
    *.bz2)     bunzip2 "$filename"              ;;
    *.rar)     unrar x "$filename" "$basename"  ;;
    *.gz)      gunzip "$filename"               ;;
    *.tar)     tar xf "$filename" -C "$basename"  ;;
    *.tbz2)    tar xjf "$filename" -C "$basename" ;;
    *.tgz)     tar xzf "$filename" -C "$basename" ;;
    *.zip)     unzip "$filename" -d "$basename" ;;
    *.Z)       uncompress "$filename"           ;;
    *.7z)      7z x "$filename" -o"$basename"   ;;
    *)         echo "'$filename' cannot be extracted via extract()" ;; 
  esac
}

# Create a timestamped backup of a file
bak() {
  if [ -z "$1" ]; then
    echo "Usage: bak <file>"
    return 1
  fi
  cp "$1" "$1.$(date +%Y-%m-%d_%H-%M-%S).bak"
}

# Clone a git repository and cd into it
gclone() {
  if [ -z "$1" ]; then
    echo "Usage: gclone <repo_url>"
    return 1
  fi
  git clone "$1" && cd "$(basename "$1" .git)"
}