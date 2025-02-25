#My own rc

#uncomment to profile startup (and see bottom of file)
# zmodload zsh/zprof

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# export FZF_BASE="/home/linuxbrew/.linuxbew/opt/fzf/bin"
# Path to your oh-my-zsh installation.
export ZSH="/home/alexandre/.oh-my-zsh"
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="robbyrussell"
ZSH_THEME="mytheme"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=(" "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# Note : zsh-autosuggestions requires further install see https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md#oh-my-zsh
plugins=(git z zsh-autosuggestions poetry)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
#
# export LANG=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
alias zshconfig="nvim ~/.zshrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"
alias tc="task context"
alias ta="task add"
alias shutdown='sudo shutdown'

setopt hist_ignore_dups # Don't save multiple instances of a command when run in succession

setopt complete_aliases #needed for "config" alias

#work around tmux not using .config dir
export XDG_CONFIG_HOME="$HOME/.config"
alias tmux='tmux -f "$XDG_CONFIG_HOME"/tmux/tmux.conf'

#manage dotfiles with git
alias config='/usr/bin/git --git-dir=/home/alexandre/.cfg/ --work-tree=/home/alexandre'
compdef config='git'

export EDITOR=/usr/bin/nvim




#Functions for brightness control in pure tty on dell 7490
increase_backlight() {
    xbacklight -d :0 -inc 10
}
zle -N increase_backlight_widget increase_backlight
bindkey "^[[24~" increase_backlight_widget

decrease_backlight() {
    xbacklight -d :0 -dec 10
}
zle -N decrease_backlight_widget decrease_backlight
bindkey "^[[23~" decrease_backlight_widget

#Lazy NVM loading : otherwise zsh is slow to start 
declare -a NODE_GLOBALS=(`find ~/.config/nvm/versions/node -maxdepth 3 -type l -wholename '*/bin/*' | xargs -n1 basename | sort | uniq`)

NODE_GLOBALS+=("node")
NODE_GLOBALS+=("nvm")

load_nvm () {
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
}

for cmd in "${NODE_GLOBALS[@]}"; do
    eval "${cmd}(){ unset -f ${NODE_GLOBALS}; load_nvm; ${cmd} \$@ }"
done

#Use the "z" program
[[ -r "/usr/share/z/z.sh" ]] && source /usr/share/z/z.sh

#Python exports
export  PATH="$PATH:/home/alexandre/.local/bin" 

#bat (cat replacement) theme selection
export BAT_THEME="OneHalfDark"

#for tmux
alias ssh='TERM=xterm-256color ssh'

#for adb and co
export PATH=$PATH:/home/alexandre/platform-tools

#Kolibree dev
# source ~/Documents/PROJECTS/KOLIBREE/code/set_kolibree_env
#uncomment for profiling startup time of zsh (and see top of file)
# zprof 

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

usbswitch() {
  poetry run -C /home/alexandre/code/usb-switcher-test/ -P /home/alexandre/code/usb-switcher-test python ~/code/usb-switcher-test/usb_switcher_test/main.py "$@"
}

alias monsoon="poetry run -C /home/alexandre/code/monsoon-control/ -P /home/alexandre/code/monsoon-control python ~/code/monsoon-control/monsoon_control/main.py "
# alias usbswitch="poetry run -C /home/alexandre/code/usb-switcher-test/ -P /home/alexandre/code/usb-switcher-test python ~/code/usb-switcher-test/usb_switcher_test/main.py "
alias logseq="/home/alexandre/Applications/Logseq-linux-x64-0.10.9_dcf8b41b9db5c9fe9f84938688e17f23.AppImage"

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"

#FZF related stuff. Implies that fzf and fd were installed 
source <(fzf --zsh)
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

alias condactivate='source ~/miniconda3/bin/activate'

# bun completions
[ -s "/home/alexandre/.local/share/reflex/bun/_bun" ] && source "/home/alexandre/.local/share/reflex/bun/_bun"

# bun
export BUN_INSTALL="$HOME/.local/share/reflex/bun"
export PATH="$BUN_INSTALL/bin:$PATH"
