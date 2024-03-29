if status is-interactive
    # Commands to run in interactive sessions can go here
    alias lsa="du -sh * | sort -hr"
    alias ls="exa"
    alias ll="exa -alh --group-directories-first"
    alias tree="exa -T --git-ignore"
    alias lsaa="exa --long --header --git -a --group-directories-first"
    alias vim="nvim"
    zoxide init fish | source
    alias cd="z $argv"

    #git alias
    alias gita="git add -A"
    alias gits="git status"
    alias gitc="git commit -m $argv"
    alias gitr="git reset --hard $argv"
    # add custom paths
    fish_add_path $HOME/.local/bin/
end
