export dotfiles_path=$HOME/.dotfiles


HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
HOSTNAME="`hostname`"
REPORTTIME=120 # print elapsed time when more than 10 seconds

if [[ `uname` == "Darwin" ]]; then
  export CLICOLOR=1
  export LSCOLORS=gxfxcxdxbxegedabagacad
else
  alias ls='ls --color'
  export LS_COLORS="di=36;40:ln=35;40:so=32;40:pi=33;40:ex=31;40:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=:ow=:"
fi

source $dotfiles_path/.aliases
source $dotfiles_path/.exports
source $dotfiles_path/.functions
source $dotfiles_path/.prompt

# for vim inside tmux to not have background mismatch
export TERM='screen-256color'


# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# ZSH_THEME="solarized-powerline"
eval "$(fasd --init auto)"
eval "$(scmpuff init -s)"
if [ -z "$SSH_AUTH_SOCK" ] ; then
    eval `ssh-agent -s`
    ssh-add
fi
