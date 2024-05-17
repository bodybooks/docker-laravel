# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
# umask 022

# You may uncomment the following lines if you want `ls' to be colorized:
export LS_OPTIONS='--color=auto'
eval "$(dircolors)"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'

# Some more alias to avoid making mistakes:
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias sb='source ~/.profile'
alias g='git'
alias gi='git'
alias gt='git'
alias gti='git'
alias c='composer'
alias ci='composer install'
alias cu='composer update'
alias cr='composer require'
alias cm='composer remove'
alias cda='composer dump-autoload'
alias d='docker-compose'
alias de='docker-compose exec'
alias dc='docker-compose exec php composer'
alias da='docker-compose exec php php artisan'
alias oadd='php artisan module:make'
alias odel='php artisan module:delete'
alias oset='php artisan suite set'
alias oclear='php artisan suite clear'