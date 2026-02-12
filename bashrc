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

# coloured ls output
if [[ "$(ls --version 2>/dev/null)" == *'coreutils'* ]]; then
  alias ls='ls --color'
else
  export CLICOLOR=1
  export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd
fi
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
alias drun='docker run --rm -it'

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
 kubectl config view --minify -ojson 2>/dev/null | jq '. | "\(.clusters[0].cluster.server) \(.contexts[0].context.namespace)"' -r | sed 's|https://[^\.]*\.\([^\.]*\)\.\S*|\1|'
}

get_return_code_error() {
  code=$?
  if [ ${code} -gt 0 ]; then
    echo -e "${FG_BLACK}${BG_RED} Command exited with code ${code} ${RESET}"
    echo $'\a'
  fi
}

get_sysload() {
  colourGood="${FG_GREEN_DARK}${POINTY_TRIANGLE_BG}${BG_GREEN_DARK}${FG_BLACK}"
  colourOk="${FG_YELLOW_DARK}${POINTY_TRIANGLE_BG}${BG_YELLOW_DARK}${FG_BLACK}"
  colourBad="${FG_RED_DARK}${POINTY_TRIANGLE_BG}${BG_RED_DARK}${FG_BLACK}"
  if command -v pmset >/dev/null; then
    output=$(pmset -g sysload)
    for string in user battery thermal; do
      case "$(awk '/'"${string}"'/ {print $5}' <<< "${output}")" in
        Bad)
          echo -en "${colourBad}";;
        OK)
          echo -en "${colourOk}";;
        Great)
          echo -en "${colourGood}";;
      esac
      case "${string}" in
        user)
          echo -n "U ";;
        battery)
          echo -n "B ";;
        thermal)
          echo -n "T ";;
      esac
    done
  else
    # Processes
    load=$(awk '{printf $1}' < /proc/loadavg)
    if [ "${load%.*}" -lt 1 ]; then
      echo -en "${colourGood}"
    elif [ "${load%.*}" -lt 2 ]; then
      echo -en "${colourOk}"
    else
      echo -en "${colourBad}"
    fi
    echo -n "${load} "
    # Memory
    memory=$(free 2>/dev/null)
    if [ -n "${memory}" ]; then
      totalMemory=$(awk '/Mem:/ {print $2}' <<< "${memory}")
      availableMemory=$(awk '/Mem:/ {print $7}' <<< "${memory}")
      availablePercent=$((100*availableMemory/totalMemory))
      if [ "${availablePercent}" -lt 10 ]; then
        echo -en "${colourBad}"
      elif [ "${availablePercent}" -lt 50 ]; then
        echo -en "${colourOk}"
      else
        echo -en "${colourGood}"
      fi
      echo -n "$(free -h | awk '/Mem:/ {print $7}') "
    fi
    # Battery
    battery=$(upower --enumerate 2>/dev/null | grep 'BAT')
    if [ -n "${battery}" ]; then
      batteryPercent=$(upower -i "${battery}" | awk '/percentage:/ {print $2}')
      if [ "${batteryPercent%%%}" = 100 ]; then
        echo -en "${colourGood}"
      elif [ "${batteryPercent%%%}" -gt 20 ]; then
        echo -en "${colourOk}"
      else
        echo -en "${colourBad}"
      fi
      echo -n "${batteryPercent} "
    fi
    # Temperature
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
      maxTemp=$(cat /sys/class/thermal/thermal_zone*/temp | sort --numeric-sort | tail -1)
      if [ "${maxTemp}" -lt 40000 ]; then
        echo -en "${colourGood}"
      elif [ "${maxTemp}" -lt 80000 ]; then
        echo -en "${colourOk}"
      else
        echo -en "${colourBad}"
      fi
      echo -n "$((maxTemp/1000))°"
    fi
  fi
}

FG_WHITE="$(tput setaf 15)"
BG_WHITE="$(tput setab 15)"
FG_GREY="$(tput setaf 7)"
BG_GREY="$(tput setab 7)"
FG_GREY_DARK="$(tput setaf 8)"
BG_GREY_DARK="$(tput setab 8)"
FG_BLACK="$(tput setaf 0)"
BG_BLACK="$(tput setab 0)"
FG_RED="$(tput setaf 9)"
BG_RED="$(tput setab 9)"
FG_RED_DARK="$(tput setaf 1)"
BG_RED_DARK="$(tput setab 1)"
FG_GREEN="$(tput setaf 10)"
BG_GREEN="$(tput setab 10)"
FG_GREEN_DARK="$(tput setaf 2)"
BG_GREEN_DARK="$(tput setab 2)"
FG_YELLOW="$(tput setaf 11)"
BG_YELLOW="$(tput setab 11)"
FG_YELLOW_DARK="$(tput setaf 3)"
BG_YELLOW_DARK="$(tput setab 3)"
FG_BLUE="$(tput setaf 12)"
BG_BLUE="$(tput setab 12)"
FG_BLUE_DARK="$(tput setaf 4)"
BG_BLUE_DARK="$(tput setab 4)"
FG_MAGENTA="$(tput setaf 13)"
BG_MAGENTA="$(tput setab 13)"
FG_MAGENTA_DARK="$(tput setaf 5)"
BG_MAGENTA_DARK="$(tput setab 5)"
FG_CYAN="$(tput setaf 14)"
BG_CYAN="$(tput setab 14)"
FG_CYAN_DARK="$(tput setaf 6)"
BG_CYAN_DARK="$(tput setab 6)"
REVERSE="$(tput rev)"
RESET="$(tput sgr0)"

rando=$((RANDOM%6+9))
FG1=$(tput setaf ${rando})
BG1=$(tput setab ${rando})
rando=$((RANDOM%6+9))
FG2=$(tput setaf ${rando})
BG2=$(tput setab ${rando})
rando=$((RANDOM%6+9))
FG3=$(tput setaf ${rando})
BG3=$(tput setab ${rando})

if [ -z "${POINTY_TRIANGLE_FG}" ]; then
  echo "Symbols for Legacy Computing are not included in all fonts, export POINTY_TRIANGLE_FG='🭬' in .bashrc (or wherever this file is sourced) if this terminal is displaying the '🭬' character correctly"
  POINTY_TRIANGLE_FG='▍'
fi
POINTY_TRIANGLE_BG="${REVERSE}${POINTY_TRIANGLE_FG}${RESET}"

# Ensure zero-length characters are wrapped in \[ \] in prompt to avoid redraw issues
PS1="\$(get_return_code_error)"
PS1+="\[${BG_GREY_DARK}${FG_WHITE}\] \A " # Time
PS1+="\$(get_sysload)"
PS1+="\[${FG_GREY_DARK}\]${POINTY_TRIANGLE_BG}" # Colour transition
PS1+="\[${BG_GREY_DARK}${FG_WHITE}\]\u\[${FG_GREY}\]@\[${FG_WHITE}\]\h " # User
PS1+="\[${FG_GREY_DARK}${BG1}\]${POINTY_TRIANGLE_FG}" # Colour transition
PS1+="\[${FG_BLACK}\]\w " # Dir
PS1+="\[${RESET}${FG1}\]${POINTY_TRIANGLE_FG}" # Colour transition
PS1+="\[${FG3}\]\$(parse_git_branch)\n"
PS1+="\[${BG1}${FG_BLACK}\] \$ " # Prompt
PS1+="\[${RESET}${FG1}\]${POINTY_TRIANGLE_FG}\[${FG2}\]" # Colour transition
export PS1
trap 'tput sgr0' DEBUG

echo -e "${BG_CYAN}${FG_BLACK} Running $0 on $(hostname) ${RESET}"
dfOutput=$(df -P -h 2>/dev/null | grep -v '^map' | grep 'home') || dfOutput=$(df -P -h 2>/dev/null | grep '/$')
echo -e "$(awk '{print $6}' <<< "${dfOutput}") filesystem is $(awk '{print $5}' <<< "${dfOutput}") full, $(awk '{print $4}' <<< "${dfOutput}") remaining"
