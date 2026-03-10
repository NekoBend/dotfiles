# ===== Oh My Zsh =====
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh

# User configuration

# ===== zsh基本設定 =====
bindkey -e

HISTFILE=~/.zsh_history
HISTSIZE=8192
SAVEHIST=8192

# ===== PATH =====
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

# ===== Env sources =====
# cargo → Rust toolchain environment
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
# uv → Python toolchain environment
[ -f "$HOME/.local/bin/env" ] && source "$HOME/.local/bin/env"

# ===== CLI Tools =====

# cat → bat (syntax-highlighted cat, falls back to native cat)
cat() {
    if command -v bat &>/dev/null; then
        bat --style=plain --paging=never "$@"
    else
        command cat "$@"
    fi
}

# find → fd (falls back to native find)
find() {
    if command -v fd &>/dev/null; then
        fd "$@"
    else
        command find "$@"
    fi
}

# grep → ripgrep (falls back to native grep)
grep() {
    if command -v rg &>/dev/null; then
        rg "$@"
    else
        command grep --color=auto "$@"
    fi
}

# la → lsd -a (show all including hidden, falls back to ls -A)
la() {
    if command -v lsd &>/dev/null; then
        lsd -a "$@"
    else
        command ls -A --color=auto "$@"
    fi
}

# ll → lsd -l (long format, falls back to ls -lF)
ll() {
    if command -v lsd &>/dev/null; then
        lsd -l "$@"
    else
        command ls -lF --color=auto "$@"
    fi
}

# lla → lsd -la (long format + hidden, falls back to ls -laF)
lla() {
    if command -v lsd &>/dev/null; then
        lsd -la "$@"
    else
        command ls -laF --color=auto "$@"
    fi
}

# llt → lsd -l --tree (long format tree view)
llt() {
    if command -v lsd &>/dev/null; then
        lsd -l --tree "$@"
    else
        echo "lsd is not installed. Install: cargo install lsd" >&2
    fi
}

# ls → lsd (modern ls replacement, falls back to native ls)
ls() {
    if command -v lsd &>/dev/null; then
        lsd "$@"
    else
        command ls --color=auto "$@"
    fi
}

# lt → lsd --tree (tree view)
lt() {
    if command -v lsd &>/dev/null; then
        lsd --tree "$@"
    else
        echo "lsd is not installed. Install: cargo install lsd" >&2
    fi
}

# md5 → file MD5 hash
md5() {
    if [ -z "$1" ]; then
        echo "usage: md5 <file>" >&2
        return 1
    fi
    md5sum "$1" | awk '{ print $1 }'
}

# mkfile → create a dummy file of specified size (e.g. mkfile 10M test.bin)
mkfile() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "usage: mkfile <size> <path>  (e.g. mkfile 10M test.bin)" >&2
        return 1
    fi
    truncate -s "$1" "$2" && echo "Created $2 ($1)"
}

# path → display PATH entries one per line
path() {
    echo "$PATH" | tr ':' '\n'
}

# ports → show listening TCP ports with process info
ports() {
    if command -v ss &>/dev/null; then
        ss -tlnp
    elif command -v netstat &>/dev/null; then
        netstat -tlnp
    else
        echo "Neither ss nor netstat found" >&2
    fi
}

# ripgrep → explicit alias for rg
ripgrep() {
    if command -v rg &>/dev/null; then
        rg "$@"
    else
        echo "ripgrep is not installed." >&2
    fi
}

# sha256 → file SHA256 hash
sha256() {
    if [ -z "$1" ]; then
        echo "usage: sha256 <file>" >&2
        return 1
    fi
    sha256sum "$1" | awk '{ print $1 }'
}

# ===== Navigation =====

# .. → go up one directory
alias ..="cd .."

# c → clear screen
alias c="clear"

# cdf → fuzzy find and cd into a subdirectory (requires fd + fzf)
cdf() {
    if ! command -v fzf &>/dev/null; then
        echo "fzf is not installed." >&2
        return 1
    fi
    local dir
    dir="$(fd -t d . 2>/dev/null | fzf)" && [ -n "$dir" ] && builtin cd -- "$dir"
}

# mkcd → mkdir + cd in one step
mkcd() {
    if [ -z "$1" ]; then
        echo "usage: mkcd <dir>" >&2
        return 1
    fi
    mkdir -p -- "$1" && builtin cd -- "$1"
}

# reload → re-source .zshrc
reload() {
    source ~/.zshrc
}

# y → yazi file manager (tracks cwd on exit)
y() {
    if ! command -v yazi &>/dev/null; then
        echo "yazi is not installed." >&2
        return 1
    fi
    local tmp cwd
    tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# ===== Git =====

# g → git
alias g="git"
# ga → git add
alias ga="git add"
# gaa → git add --all
alias gaa="git add --all"
# gb → git branch
alias gb="git branch"
# gc → git commit
alias gc="git commit"
# gcm → git commit -m
alias gcm="git commit -m"
# gco → git checkout
alias gco="git checkout"
# gd → git diff
alias gd="git diff"
# gds → git diff --staged
alias gds="git diff --staged"
# gf → git fetch --all --prune
alias gf="git fetch --all --prune"
# gl → git log --oneline --graph
alias gl="git log --oneline --graph"
# gpl → git pull
alias gpl="git pull"
# gps → git push
alias gps="git push"
# gst → git status (short)
alias gst="git status -sb"
# gsw → git switch
alias gsw="git switch"

# ===== Docker =====

# d → docker
alias d="docker"
# dc → docker compose
alias dc="docker compose"
# dcb → docker compose build
alias dcb="docker compose build"
# dcd → docker compose down
alias dcd="docker compose down"
# dce → docker compose exec
alias dce="docker compose exec"
# dcl → docker compose logs
alias dcl="docker compose logs"
# dcu → docker compose up
alias dcu="docker compose up"
# di → docker images
alias di="docker images"
# dps → docker ps
alias dps="docker ps"
# dri → docker run -it (interactive)
alias dri="docker run -it"
# drir → docker run -it --rm (interactive, auto-remove)
alias drir="docker run -it --rm"

# ===== Editor =====

# code → code-insiders (falls back to stable code)
if command -v code-insiders &>/dev/null; then
    alias code="code-insiders"
elif ! command -v code &>/dev/null; then
    alias code='echo "VS Code is not installed." >&2 && false'
fi

# gu → gitui (terminal git UI)
if command -v gitui &>/dev/null; then
    alias gu="gitui"
else
    alias gu='echo "gitui is not installed." >&2 && false'
fi

# ===== Python / uv =====

# _show_uv_only_message → display warning that direct python/pip is disabled
_show_uv_only_message() {
    echo "Direct use of '$1' is disabled. Please use uv instead." >&2
}

# pip → uv pip (falls back to system pip)
pip() {
    if command -v uv &>/dev/null; then
        _show_uv_only_message 'pip'
        uv pip "$@"
    else
        command pip "$@"
    fi
}

# pip3 → uv pip (falls back to system pip3)
pip3() {
    if command -v uv &>/dev/null; then
        _show_uv_only_message 'pip3'
        uv pip "$@"
    else
        command pip3 "$@"
    fi
}

# py → uv run python (falls back to system python3)
py() {
    if command -v uv &>/dev/null; then
        _show_uv_only_message 'py'
        uv run python "$@"
    else
        command python3 "$@"
    fi
}

# python → uv run python (falls back to system python)
python() {
    if command -v uv &>/dev/null; then
        _show_uv_only_message 'python'
        uv run python "$@"
    else
        command python "$@"
    fi
}

# python3 → uv run python (falls back to system python3)
python3() {
    if command -v uv &>/dev/null; then
        _show_uv_only_message 'python3'
        uv run python "$@"
    else
        command python3 "$@"
    fi
}

# va → activate Python venv (default: .venv)
va() {
    local name="${1:-.venv}"
    if [ ! -f "$name/bin/activate" ]; then
        echo "activate script not found: $name/bin/activate" >&2
        return 1
    fi
    source "$name/bin/activate"
}

# ===== Hardware info (for starship) =====
if [ -f /proc/cpuinfo ]; then
    _cpu_name=$(grep -m1 'model name' /proc/cpuinfo | sed 's/.*: //')
    case "$_cpu_name" in
        *Intel*|*intel*) export STARSHIP_CPU_INTEL="$_cpu_name" ;;
        *AMD*|*amd*)     export STARSHIP_CPU_AMD="$_cpu_name" ;;
    esac
    unset _cpu_name
fi
if command -v lspci &>/dev/null; then
    _gpu_name=$(lspci | grep -i 'vga\|3d\|display' | head -1 | sed 's/.*: //')
    case "$_gpu_name" in
        *NVIDIA*|*nvidia*) export STARSHIP_GPU_NVIDIA="$_gpu_name" ;;
        *AMD*|*amd*|*Radeon*|*radeon*) export STARSHIP_GPU_AMD="$_gpu_name" ;;
        *Intel*|*intel*) export STARSHIP_GPU_INTEL="$_gpu_name" ;;
    esac
    unset _gpu_name
fi

# ===== Init tools =====
command -v zoxide &>/dev/null && eval "$(zoxide init zsh --cmd cd)"
command -v starship &>/dev/null && eval "$(starship init zsh)"

# ===== nvm =====
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
