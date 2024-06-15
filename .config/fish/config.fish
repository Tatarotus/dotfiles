if status is-interactive
    # Commands to run in interactive sessions can go here
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
    alias spotify="ncspot"
    alias stf="ncspot"
    alias nm="pnpm"
    # alias rsync = "rsync -avzh --progress --stats \"$src\" \"$dst\""
    # alias rsync = "rsync -r --info=progress2 --info=name0"

    #git alias
    alias gita="git add -A"
    alias gits="git status"
    alias gitl="git log"
    alias gitc="git commit -m $argv"
    alias gitr="git reset --hard $argv"
    # add custom paths
    fish_add_path $HOME/.local/bin/
end
