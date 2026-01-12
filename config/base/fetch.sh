#!/usr/bin/env dash
#
# Description
#   Simple Fetch tool for Artix... can be easily adapted.
#
# BeyondMagic 🄯 2021

# 1. Settings.
{

  # First line to be printed.
  first_line="\033[1m  $(id | sed -r 's/(uid=1000\()|\) gid.*//g')@$(cat /etc/hostname)  |    $(date +'%a %b %d - %H:%M:%S')\033[0m"

  # Colours and icons to be used.
  icons_first="\033[30m----\033[31m----\033[32m----\033[33m----\033[34m----\033[35m----\033[36m----\033[37m----\033[0m"
  icons_second="\033[90m----\033[91m----\033[92m----\033[93m----\033[94m----\033[95m----\033[96m----\033[97m----\033[0m"

  a=" \033[0m\033[90m|\033[0m "

  # Artix logo.
  logo="
        
       ██       \033[38m\033[0m\033[3m  OS       $a $(cat /etc/os-release | grep -m 1 -oP '((?<=NAME=").*(?= Linux"))') - GNU/Linux - x86_64
       ███      \033[33m\033[0m\033[3m  KERNEL   $a Linux $(uname -r)
        █     \033[34m\033[0m\033[3m  UPTIME   $a $(uptime -p | sed 's/^up //')
    █████       \033[35m\033[0m\033[3m  SHELL    $a $(echo "$SHELL" | sed 's_/usr/bin/__')
   █████████    \033[36m\033[0m\033[3m  PACKAGES $a $(pacman -Q | wc -l) packages
  ██████      \033[37m\033[0m\033[3m  INIT     $a $(ls -l /sbin/init | grep -oP '((?<=-> ).*(?=-init))')
 ████     ███ \033[38m\033[0m\033[3m  MEMORY   $a $(free -m | awk '{print $3}' | head -n2 | tail -n1)MiB / $(expr "$(rg MemTotal /proc/meminfo | awk '{print $2}')" \/ 1000)MiB
██          ██
"
}

# 2. Basic definitions.
{

  # Width of the terminal in character count.
  terminal_columns="$(tput cols)"

  # Function.
  #   Center input text based on the terminal's size.
  center() {

    # Find the quantity of characters on the line.
    [ $2 -gt 0 ] && {

      #amount="$(( $(echo "$1" | perl -e 'print sort { length($a) <=> length($b) } <>' | tail -n1 | wc -m) - 1 ))"
      amount=65

    } || {

      amount="$(( $(echo "$1" | sed -r 's/(\\033|)\[(([[:digit:]]+;)+|)[[:digit:]]+m//g' | wc -m) - 1 ))"

    }

    # Spaces on the start of the line.
    spaces_to_add="$(( ($terminal_columns - $amount) / 2 ))"

    # Print lines on stdout.
    echo "$1" | sed -e "s/^/$(printf %${spaces_to_add}s)/"

  }

  #

}

# 3. Main.
{

  # Print name.
  center "$first_line" 0

  # Print logo.
  center "$logo" 1

  # Print pallete.
  center "$icons_first"  0
  center "$icons_second" 0

}
