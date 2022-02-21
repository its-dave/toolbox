# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth
# append to the history file, don't overwrite it
shopt -s histappend
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Enable history expansion with space
# E.g. typing !!<space> will replace the !! with your last command
bind Space:magic-space

# enable color support of ls
export CLICOLOR=1
export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd
# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
function cdls() {
  cd "$@" && ls
}
alias grep='grep --color'
alias hgrep='history | grep -i'
alias envgrep='env | grep -i'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

parse_git_branch() {
 git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

parse_kubectl_target() {
 kubectl config view --minify -ojson | jq '. | "\(.clusters[0].cluster.server) \(.contexts[0].context.namespace)"' -r | gsed 's|https://[^\.]*\.\([^\.]*\)\.\S*|\1|'
}

get_return_code() {
  code=$?
  if [ $code -gt 0 ]; then
    echo -en "\033[91m"
  fi
  echo $code
}

get_sysload() {
  echo -en "\033[30m"
  output=$(pmset -g sysload)
  for string in user battery thermal; do
    case "$(awk '/'"${string}"'/ {print $5}' <<< "${output}")" in
      Bad)
        echo -en "\033[101m";;
      OK)
        echo -en "\033[103m";;
      Great)
        echo -en "\033[102m";;
    esac
    case "${string}" in
      user)
        echo -n " U ";;
      battery)
        echo -n " B ";;
      thermal)
        echo -n " T ";;
    esac
  done
}

# multi-line prompts require ansi codes to be wrapped in square brackets
FG_DEFAULT="\[\033[39m\]"
BG_DEFAULT="\[\033[49m\]"
FG_GREY="\[\033[90m\]"
BG_GREY="\[\033[100m\]"
FG_BLACK="\[\033[30m\]"
BG_BLACK="\[\033[40m\]"
FG_RED="\[\033[91m\]"
BG_RED="\[\033[101m\]"
FG_RED_DARK="\[\033[31m\]"
BG_RED_DARK="\[\033[41m\]"
FG_GREEN="\[\033[92m\]"
BG_GREEN="\[\033[102m\]"
FG_GREEN_DARK="\[\033[32m\]"
BG_GREEN_DARK="\[\033[42m\]"
FG_YELLOW="\[\033[93m\]"
BG_YELLOW="\[\033[103m\]"
FG_YELLOW_DARK="\[\033[33m\]"
BG_YELLOW_DARK="\[\033[43m\]"
FG_BLUE="\[\033[94m\]"
BG_BLUE="\[\033[104m\]"
FG_BLUE_DARK="\[\033[34m\]"
BG_BLUE_DARK="\[\033[44m\]"
FG_MAGENTA="\[\033[95m\]"
BG_MAGENTA="\[\033[105m\]"
FG_MAGENTA_DARK="\[\033[35m\]"
BG_MAGENTA_DARK="\[\033[45m\]"
FG_CYAN="\[\033[96m\]"
BG_CYAN="\[\033[106m\]"
FG_CYAN_DARK="\[\033[36m\]"
BG_CYAN_DARK="\[\033[46m\]"
TEXT_BOLD="\[\033[1m\]"
TEXT_FAINT="\[\033[2m\]"
TEXT_NORMAL="\[\033[22m\]"
REV_ON="\[\033[7m\]"
REV_OFF="\[\033[27m\]"
RESET="\[\033[0m\]"

FG=("${FG_RED}" "${FG_GREEN}" "${FG_YELLOW}" "${FG_BLUE}" "${FG_MAGENTA}" "${FG_CYAN}")
BG=("${BG_RED}" "${BG_GREEN}" "${BG_YELLOW}" "${BG_BLUE}" "${BG_MAGENTA}" "${BG_CYAN}")

rando=$((RANDOM%${#FG[*]}))
FG1=${FG[rando]}
BG1=${BG[rando]}
rando=$((RANDOM%${#FG[*]}))
FG2=${FG[rando]}
BG2=${BG[rando]}
rando=$((RANDOM%${#FG[*]}))
FG3=${FG[rando]}
BG3=${BG[rando]}

export PS1="${TEXT_FAINT}Command exited with code \$(get_return_code)\n\
${TEXT_NORMAL}\$(get_sysload)${RESET} ${FG3}\$(parse_kubectl_target)${RESET}\n\
${FG_BLACK}${BG1}[\A]${BG_DEFAULT}${FG1} \u@\h ${FG_BLACK}${BG2}\w${BG_DEFAULT}${FG3} \$(parse_git_branch)${FG1}${BG_DEFAULT}\n\
\$${FG2} "
trap 'tput sgr0' DEBUG

export PATH=~/bin:$PATH
