#!/bin/sh

######################################################################
#
# SERIAL.SH : SOKDOK Viewer (Serial Version)
#
# This program shows the text data by every phrase from the top-left
# to the bottom-right on the screen (terminal) at the specified speed.
# You can experience that you can't read the text as fast as the "center.sh"
# viewer. That is because this viewer needs you to move your eyes as
# well as reading ordinary documents, whereas the "center.sh" doesn't
# need you to move your eyes at all. This viewer is made for a control
# experiment.
#
#
# Usage     : serial.sh letters_per_minute [textfile]
# Arguments : letters_per_minute
#               * Speed on the screen in letters per minute
#               * 800 is the moderate speed for ordinary people.
#               * About >=2000 is the speed for speed-readers.
#               * About >=6000 is the speed for well-trained speed-
#                 readers.
#             textfile
#               * Text file you want to print on the screen
#               * The text data in the file should be split into each
#                 phrase that can be read in an instant and put into
#                 line by line.
#               * If you omit this argument, the standard input will be
#                  regarded as the text file to be read.
#
# Written by @colrichie (Shellshoccar Japan) on 2024-01-06
#
######################################################################


######################################################################
# Initialization
######################################################################

# === Initialization =================================================
set -u
umask 0022
PATH="$(command -p getconf PATH)${PATH:+:}${PATH:-}"
export PATH
export LC_ALL='C'

# === Error functions ================================================
print_usage_and_exit () {
  cat <<-USAGE
	Usage   : ${0##*/} letters_per_minute [textfile]
	Version : 2024-01-06 13:37:51 JST
	USAGE
  exit 1
}
error_exit() {
  ${2+:} false && echo "${0##*/}: $2" 1>&2
  exit $1
}

# === Directory definitions ==========================================
Homedir=$(d=${0%/*}/; [ "_$d" = "_$0/" ] && d='./'; cd "$d.."; pwd)
PATH="$Homedir/lib:$PATH"

# === Confirm some required commands =================================
type tscat >/dev/null 2>&1 || {
  error_exit 1 'tscat command is not found. Please run "00setup.sh" in advance.'
}

# === Other value definitions ========================================
case $(awk -W interactive 'BEGIN{print}' 2>&1 >/dev/null) in
  '') alias ubawk='awk -W interactive';;
   *) alias ubawk='awk'               ;;
esac


######################################################################
# Argument
######################################################################

case $# in
  1) lpm=$1; file='-'
     ;;
  2) lpm=$1; file=$2
     case "$file" in /*) :;; ./*) :;; ../*) :;; *) file="./$file";; esac
     ;;
  *) print_usage_and_exit
     ;;
esac
printf '%s\n' "$lpm" | grep -Eq '^[0-9]+$' || {
  error_exit 1 '1st argument "letters_per_minute" is invalid'
}
([ "$file" = '-' ] || [ -f "$file" ] || [ -c "$file" ] || [ -p "$file" ]) || {
  case $# in 2) file=$2;; esac
  error_exit 1 "$file: Not a file"
}


######################################################################
# Main
######################################################################

# === Get center position ============================================
X_max=$(($(tput cols  2>/dev/null)  ))
Y_max=$(($(tput lines 2>/dev/null)-1))
case "$X_max" in '') X_max=80;; esac # Assume the VT100's size (80*24)
case "$Y_max" in '') Y_max=23;; esac # if tput cols/lines doesn't work.

# === Flash ==========================================================
tput clear
cat $file                                                         |
utf8wc -lv                                                        |
# 1:bytes 2:letters 3:length 4:body                               #
awk -v lpm=$lpm '                                                 #
  BEGIN {OFMT="%.14g"; ts=0;}                                     #
  {print ts,$3,substr($0,length($1 $2 $3)+4); ts+=($2)*60/lpm;} ' |
# 1:time 2:length 3:body                                          #
tscat -zZ                                                         |
# 1:length 2:body                                                 #
ubawk -v xm=$X_max -v ym=$Y_max '                                 #
  BEGIN {                                                         #
    OFS=""; l0=0; x0=1; y0=1;                                     #
  }                                                               #
  {                                                               #
    s  = sprintf("%" l0+1 "s","");                                #
    s1 = sprintf("\033[%d;%dH%s",y0,x0,s);                        #
    s  = substr($0,length($1)+2);                                 #
    if ($1>0) {                                                   #
      x=x0+l0; y=y0;                                              #
      if (x>xm) {x=x%xm; y++;}                                    #
      if (y>ym) {        y=1;}                                    #
    } else    {                                                   #
      # If a blank line comes, break the line on the screen.      #
      x=1    ; y++ ;                                              #
      if (y>ym) {        y=1;}                                    #
    }                                                             #
    s2 = sprintf("\033[%d;%dH%s",y,x,s);                          #
    print s1,s2;                                                  #
    l0=$1; x0=x; y0=y;                                            #
  }'


######################################################################
# Finish
######################################################################

exit 0
