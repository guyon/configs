# .bashrc
# Screen用

# User specific aliases and functions
# Source global definitions
#if [ -f /etc/bashrc ]; then
#	. /etc/bashrc
#fi

#stty -ixon

# unlimit stacksize for large aray in user mode
#ulimit -s unlimited

export PATH=/opt/local/bin:/opt/local/sbin/:$PATH
export MANPATH=/opt/local/man:$MANPATH

# set aliases
alias ls='ls -F --color=auto'
alias ll='ls -la --color=auto'
alias la='ls -a --color=auto'
alias eng='LANG=C LANGUAGE=C LC_ALL=C'

# user file-creation mask
umask 022
if [ "$TERM" = "screen" ]; then
  export PS1='\[\033k\033\\\]'
  export PS1="\u@\h:\w"$PS1'\$ '
  PROMPT_COMMAND='echo -n ""'
fi

#alias screen='screen -U -D -RR'
#export PS1='\[\033k\033\\\]'
#export PS1="\u@\h:\w"$PS1'\$ '
