set -U fish_greeting ""
  # Commands to run in interactive sessions can go here
if status is-interactive
  # Aliases
  alias lsa="du -sh * | sort -hr"
  alias ls="exa"
  alias ll="exa -alh --group-directories-first"
  alias tree="exa -T --git-ignore"
  alias lsaa="exa --long --header --git -a --group-directories-first"
  alias cat="bat -p"
  alias vim="nvim"
  zoxide init fish | source
  alias cd="z $argv"
  alias zz="z -"
  alias y="pnpm"
  # alias yt="youtube-dl -f 'bestvideo[ext=mp4][height<=1080]+bestaudio[ext=m4a]/best[ext=mp4]/best'"
  alias yt="yt-dlp_linux -f '137+bestaudio[ext=m4a]/136+bestaudio[ext=m4a]/135+bestaudio[ext=m4a]/134+bestaudio[ext=m4a]/133+bestaudio[ext=m4a]/160+bestaudio[ext=m4a]'"

  alias update="paru -Syyu"
  alias install="paru -S"
  alias search="paru -Ss"
  alias remove="paru -Rns"

  #git alias
  alias gita="git add -A"
  alias gits="git status"
  alias gitl="git log"
  alias gitc="git commit -m $argv"
  alias gitr="git reset --hard $argv"

  # custom variables
  set -x BUN_INSTALL $HOME/.bun
  # add custom paths
  fish_add_path $HOME/.local/bin/
  fish_add_path $BUN_INSTALL/bin
end
