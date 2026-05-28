# ==============================================================================
# ZSH CONFIGURATION
# ==============================================================================

# ----- Core Variables & Paths -----
export BUN_INSTALL="$HOME/.bun"
export GOPATH=$HOME/go/bin
export PATH="$HOME/.local/bin:$HOME/.config/composer/vendor/bin:$BUN_INSTALL/bin:$WASMTIME_HOME/bin:$GOPATH:$PATH"

export EDITOR='nvim'
export VISUAL='nvim'

# Force software rendering for stability on older Intel chips/Wayland
export LIBGL_ALWAYS_SOFTWARE=1
export WINIT_UNIX_BACKEND=wayland

# ----- API Keys & Secrets -----
if [ -f "$HOME/.secrets" ]; then
    source "$HOME/.secrets"
fi

# ----- NNN Configuration -----
export NNN_OPTS="e"                 # 'e' uses text editor, 'H' shows hidden files
export NNN_COLORS="2136"             # Define colors for folders and files
export NNN_FSTR='^i'                 # Shortcut for search (case-insensitive)
export NNN_SEL='/tmp/.nnn_cp'        # Define a fixed selection file
export NNN_FIFO='/tmp/nnn.fifo'      
export NNN_PREVIEW_IMGPROG='ueberzug'
export NNN_PLUG='p:preview-tui;o:nuke;'


# ----- Commentary -----
setopt interactivecomments

# ----- History Settings -----
# Crucial for Autosuggestions functionality
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory sharehistory

# ----- FZF Configuration (GitHub Light Theme) -----
# Custom fzf look to match 'projekt0n/github-nvim-theme' light
export FZF_DEFAULT_OPTS="
  --color=bg:-1,bg+:#f6f8fa
  --color=fg:#24292f,fg+:#24292f
  --color=hl:#0969da,hl+:#0969da
  --color=info:#57606a,prompt:#1a7f37,pointer:#0969da
  --color=marker:#1a7f37,spinner:#8250df,header:#0969da
  --height 40% --layout=reverse --border
"

# FZF History Search (Ctrl+R) - fuzzy find through command history
fzf-history-search() {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2>/dev/null
  selected=( $(fc -rl 1 | awk '{ cmd=$0; sub(/^[ \t]*[0-9]+\*[?\t ]+/, "", cmd); if (!seen[cmd]++) print $0 }' |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} ${FZF_DEFAULT_OPTS-} -n2..,.. --scheme=history --bind=ctrl-r:toggle-sort,ctrl-z:ignore ${FZF_CTRL_R_OPTS-} --query=${(qqq)LBUFFER} +m" fzf) )
  local ret=$?
  if [ -n "$selected" ]; then
    num=$selected[1]
    if [ -n "$num" ]; then
      zle vi-fetch-history -n $num
    fi
  fi
  zle reset-prompt
  return $ret
}
zle -N fzf-history-search
bindkey '^R' fzf-history-search

# ----- Plugins & Prompt -----
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

source ${ZSH_CUSTOM:-$HOME/.local/share}/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh 2>/dev/null

# ----- Keybindings -----
# Enable "Bracketed Paste Magic" to prevent auto-execution of pasted text
autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic

# Ensure pasted URLs are not incorrectly escaped
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

# Up/Down history search based on typed prefix
bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search

# Skip words (Ctrl+Right / Ctrl+Left)
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# ----- Aliases -----
alias grep='grep --color=auto'
alias nala="sudo nala"
alias vim="nvim"
alias vi="nvim"
alias yt="yt-dlp_linux -f '137+bestaudio[ext=m4a]/136+bestaudio[ext=m4a]/135+bestaudio[ext=m4a]/134+bestaudio[ext=m4a]/133+bestaudio[ext=m4a]/160+bestaudio[ext=m4a]'"


# edit root files
alias snvim='sudo XDG_CONFIG_HOME=$HOME/.config nvim'
alias se='SUDO_EDITOR=nvim sudoedit'

# Eza (better ls)
alias ls='eza --icons --group-directories-first'
alias ll='eza -alh --icons --group-directories-first'
alias la='eza -a --icons'
alias tree='eza -T --icons --git-ignore'

# File management wrappers
alias cp='cpg -g'
alias mv='mvg -g'

# Git Aliases
alias gita="git add -A"
alias gits="git status"
alias gitl="git log"
alias gitc="git commit -m"   
alias gitr="git ressetopt interactivecommentset --hard"

# Zoxide Navigation
alias cd="z"
alias zz="z -"

# Hardware Info
alias cpu="watch -n 1 'cat /proc/cpuinfo | grep -i mhz'"
# ----- Functions -----

# System Maintenance: Cleans package caches, app caches, trash, and logs
cleanup() {
    echo "--- Cleaning Nala/Apt Cache ---"
    sudo nala clean
    sudo apt-get autoremove -y
    
    echo "--- Cleaning User Cache ---"
    rm -rf ~/.cache/pip ~/.cache/pypoetry ~/.cache/yarn
    
    echo "--- Emptying Trash ---"
    rm -rf ~/.local/share/Trash/*
    
    echo "--- Vacuuming System Logs (Keeping last 100MB) ---"
    sudo journalctl --vacuum-size=100M
    
    echo "--- Current Disk Usage ---"
    df -h /
}

# NNN Wrapper: Persists the last visited directory upon exit
n() {
    if [ -n "$NNNLVL" ] && [ "${NNNLVL:-0}" -ge 1 ]; then
        echo "nnn is already running"
        return
    fi

    export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

    command nnn -e "$@"

    if [ -f "$NNN_TMPFILE" ]; then
        . "$NNN_TMPFILE"
        rm -f "$NNN_TMPFILE" > /dev/null
    fi
}

# NNN Shortcut: Defaults to the PARA directory
nnn() {
    if [ $# -eq 0 ]; then
        # If no arguments are passed, open PARA
        command nnn -e ~/PARA
    else
        # If an argument is passed (like a specific folder), open that instead
        command nnn -e "$@"
    fi
}

function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	cwd=""
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# ==============================================================================
# NVM / Bun Intercept Logic
# ==============================================================================
# By default, Node/NPM/NPX commands are routed to Bun for faster execution.
# If 'nvm' is explicitly called (e.g., 'nvm use 18'), it removes the Bun wrappers,
# loads the real NVM, and restores standard Node functionality for the session.

export NVM_DIR="$HOME/.nvm"

_load_nvm() {
    # 1. Remove Bun wrappers to allow the real Node binaries to take over
    unset -f nvm node npm npx
    
    # 2. Source the official NVM scripts
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    
    # 3. Execute the NVM command the user just typed
    nvm "$@"
}

# Route JavaScript commands to Bun by default
node() { bun "$@" }
npm()  { bun "$@" }
npx()  { bunx "$@" }

# Intercept 'nvm' to trigger the real environment load
nvm() { _load_nvm "$@" }
alias lt='eza --tree --icons'
alias y='yazi'
alias v='nvim'
alias l='eza -CF --icons'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gs='git status'

# opencode
export PATH=/home/sam/.opencode/bin:$PATH


# Added by Antigravity CLI installer
export PATH="/home/sam/.local/bin:$PATH"
