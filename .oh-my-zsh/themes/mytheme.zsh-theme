PROMPT="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"

if [[ -z "$SSH_CLIENT" ]]; then
        PROMPT+='%{$fg[cyan]%}%d%{$reset_color%} $(git_prompt_info)'
else
        #add %n before the @ if you want the username in ssh prompt
        PROMPT+='@%m %{$fg[yellow]%}%d%{$reset_color%} $(git_prompt_info)'
fi

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
