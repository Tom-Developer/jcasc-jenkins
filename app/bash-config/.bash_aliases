#!/bin/echo "source ~/.bash_aliases"

# ls aliases
alias ls='ls -F --color=never'
alias ll='ls -l'
alias lla='ls -lA'
alias llt='ls -lt'
alias llh='ls -lH'
alias l='ls -C'
alias llr='ls -Rl -F'
alias llta='ls -alt -F'
alias llra='ls -alR -F'
alias llL='ls -lL'
alias lx='ls -lXB'
alias dsdm="ls -FlAh | more"
# show directories only
alias dsdd="ls -FlA | grep :*/"j
# show executables only
alias dsdx="ls -FlA | grep *"
# show non-executables
alias dsdnx="ls -FlA | grep -v *"
# order by date
alias dsdt="ls -FlAtr "
# only file without an extension
alias noext='dsd | egrep -v ".|/"'
# file tree; not working, but it might be good
#alias dirtree="ls -R | grep :*/ | grep ":$" | sed -e 's/:$//' -e 's/[^-][^/]*//--/g' -e 's/^/   /' -e 's/-/|/'"

# cd aliases
alias ..='cd ..'
alias ..2='cd ../../'
alias ..3='cd ../../../'
alias ..4='cd ../../../../'
alias ..5='cd ../../../../..'


