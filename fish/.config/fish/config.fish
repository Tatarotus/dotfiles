set -U fish_greeting ""
  # Commands to run in interactive sessions can go here
if status is-interactive
  # Aliases
  alias lss "du -sh * | sort -hr"
  alias ls "exa"
  alias ll "exa -alh --group-directories-first"
  alias tree "exa -T --git-ignore"
  alias lsaa "exa --long --header --git -a --group-directories-first"
  alias bat "batcat --theme='OneHalfLight'"  # Fixed this line
  alias vim "nvim"
  zoxide init fish | source
  alias cd "z $argv"
  alias zz "z -"
  alias yt "yt-dlp_linux -f '137+bestaudio[ext=m4a]/136+bestaudio[ext=m4a]/135+bestaudio[ext=m4a]/134+bestaudio[ext=m4a]/133+bestaudio[ext=m4a]/160+bestaudio[ext=m4a]'"
  alias cpu "watch -n 1 'cat /proc/cpuinfo | grep -i mhz'"

  # package manager
  alias update 'sudo nala update'
  alias upgrade 'sudo nala upgrade'
  alias install 'sudo nala install'
  alias remove 'sudo nala remove'
  alias purge 'sudo nala purge'
  alias autoremove 'sudo nala autoremove'
  alias search 'nala search'
  alias show 'nala show'
  alias clean 'sudo nala clean'
  alias fetch 'sudo nala fetch'
  alias history 'nala history'
  alias undo 'sudo nala history undo'
  alias redo 'sudo nala history redo'

  # git aliases
  alias gita "git add -A"
  alias gits "git status"
  alias gitl "git log"
  alias gitc "git commit -m $argv"
  alias gitr "git reset --hard $argv"

  # custom variables
  set -gx BUN_INSTALL "$HOME/.bun"
  set -Ux OPENAI_API_KEY "xai-osMtfopYuZmbaPEyKr6zXDdGhPDbhCrhFh5V4E18fl4mVnXyRhbtsz1jTOj0cmDzvoKgVuRQsSMj6sxK"

  # add custom paths
  fish_add_path "$HOME/.local/bin/"
  fish_add_path "$HOME/.config/composer/vendor/bin/"
  fish_add_path "$HOME/.npm-global/bin/"
  fish_add_path "$BUN_INSTALL/bin"

if status --is-interactive
    and not test -n "$TMUX"  # Only start tmux if no session is active
    # tmux
    set session_name "sam"

    # Check if session exists
    if not tmux has-session -t "$session_name" 2>/dev/null
        tmux new-session -d -s "$session_name" 'dooit'  \; \
             rename-window 'SMRE' \; \
             new-window -n 'Resolve' \; \
             select-window -t 1 \; \
             attach
    else
        tmux attach -t "$session_name"
    fi
    end
end

function d
    cd (find . -type d -print | fzf)
end

end
