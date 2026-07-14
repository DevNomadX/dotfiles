# ═══════════════════════════════════════════════════════════════
# 020-functions.fish — Custom shell functions (Fish)
#
# Mirrors the useful subset of Zsh functions from conf.d/03-functions.zsh.
# Only functions that solve a recurring problem are included.
# ═══════════════════════════════════════════════════════════════

# ── mkcd — Create and enter a directory ──────────────────────
function mkcd -d "Create directory and cd into it"
    if test -z "$argv[1]"
        echo "Usage: mkcd <directory>" >&2
        return 1
    end
    mkdir -p $argv[1]; and cd $argv[1]
end

# ── fe — Fuzzy-find a file and open in $EDITOR ───────────────
function fe -d "Fuzzy-find file and open in editor"
    if not type -q fzf
        echo "fe: requires fzf" >&2
        return 1
    end
    set -l file (fzf --preview '
        if type -q bat >/dev/null 2>&1; then
            bat --color=always --style=numbers --line-range=:500 {}
        else
            cat {}
        fi
    ')
    if test -n "$file"
        $EDITOR $file
    end
end

# ── extract — Universal archive extractor ────────────────────
function extract -d "Extract archives into a named subdirectory"
    if test -z "$argv[1]"
        echo "Usage: extract <archive>" >&2
        return 1
    end
    if not test -f "$argv[1]"
        echo "extract: '$argv[1]' is not a regular file" >&2
        return 1
    end

    set -l bname (string replace -r '\.[^.]*$' '' "$argv[1]")
    mkdir -p $bname; or return 1

    switch "$argv[1]"
        case '*.tar.bz2' '*.tbz2'
            tar xjf "$argv[1]" -C $bname
        case '*.tar.gz' '*.tgz'
            tar xzf "$argv[1]" -C $bname
        case '*.tar.xz'
            tar xf "$argv[1]" -C $bname
        case '*.tar'
            tar xf "$argv[1]" -C $bname
        case '*.bz2'
            bunzip2 "$argv[1]"
        case '*.gz'
            gunzip "$argv[1]"
        case '*.Z'
            uncompress "$argv[1]"
        case '*.zip'
            unzip "$argv[1]" -d $bname
        case '*.rar'
            unrar x "$argv[1]" $bname
        case '*.7z'
            7z x "$argv[1]" -o$bname
        case '*'
            echo "extract: no handler for '$argv[1]'" >&2
            return 1
    end
    and echo "✓ Extracted to $argv[1]"
end

# ── bak — Timestamped file backup ────────────────────────────
function bak -d "Create a timestamped backup of a file"
    if test -z "$argv[1]"
        echo "Usage: bak <file>" >&2
        return 1
    end
    if not test -f "$argv[1]"
        echo "bak: '$argv[1]' not found" >&2
        return 1
    end
    set -l dst "$argv[1].bak."(date +%Y-%m-%d_%H-%M-%S)
    cp $argv[1] $dst; and echo "✓ Backup: $dst"
end

# ── gclone — Clone a repo and cd into it ─────────────────────
function gclone -d "Clone a git repository and enter it"
    if not type -q git
        echo "gclone: requires git" >&2
        return 1
    end
    if test -z "$argv[1]"
        echo "Usage: gclone <repo-url>" >&2
        return 1
    end
    git clone $argv[1]; and cd (basename $argv[1] .git)
end

# ── weather — Quick weather via wttr.in ──────────────────────
function weather -d "Show weather forecast"
    if not type -q curl
        echo "weather: requires curl" >&2
        return 1
    end
    curl -sf "wttr.in/$argv[1]"; or echo "weather: could not fetch" >&2
end

# ── ducks — Directory sizes sorted ───────────────────────────
function ducks -d "Show directory sizes sorted"
    du -sh */ 2>/dev/null | sort -h
end

# ── zsh-health — Check tool availability ─────────────────────
function zsh-health -d "Check that expected tools are installed"
    set -l missing 0
    echo "Checking shell environment..."
    echo
    echo "Critical:"
    for tool in git fzf curl nvim
        if type -q $tool
            echo "  ✓ $tool"
        else
            echo "  ✗ $tool (MISSING)"
            set missing (math $missing + 1)
        end
    end
    echo
    echo "Optional:"
    for tool in eza bat fnm starship fastfetch trash
        if type -q $tool
            echo "  ✓ $tool"
        else
            echo "  ∘ $tool"
        end
    end
    echo
    if test $missing -eq 0
        echo "✅ All critical tools present"
    else
        echo "⚠️  $missing critical tool(s) missing"
    end
end
