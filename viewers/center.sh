#!/bin/sh

######################################################################
#
# CENTER.SH : SOKDOK Viewer (Center Version)
#
# This program shows the text data by every phrase on the center of
# the screen (terminal) at the specified speed.
# You can experience the feeling of speed-readers because you don't
# have to move your eyes when you read them. It's said that eye-moving
# costs pretty heavily for text reading.
#
#
# Usage     : center.sh letters_per_minute [textfile]
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
# Written by @colrichie (Shellshoccar Japan) on 2023-12-24
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
	Version : 2023-12-24 02:25:43 JST
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
X_mid=$(($(tput cols  2>/dev/null)/2))
Y_mid=$(($(tput lines 2>/dev/null)/2))
case "$X_mid" in '') X_mid=40;; esac # Assume the VT100's size (80*24)
case "$Y_mid" in '') Y_mid=12;; esac # if tput cols/lines doesn't work.

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
awk -v xm=$X_mid -v ym=$Y_mid '                                   #
  BEGIN {                                                         #
    OFS=""; l0=0;                                                 #
  }                                                               #
  {                                                               #
    if (l0==0) {                                                  #
      s1 = "";                                                    #
    }                                                             #
    else       {                                                  #
      s  = sprintf("%" l0 "s","");                                #
      s1 = sprintf("\033[%d;%dH%s",ym,int(xm-l0/2),s);            #
    }                                                             #
    s  = substr($0,length($1)+2);                                 #
    s2 = sprintf("\033[%d;%dH%s",ym,int(xm-$1/2),s);              #
    print s1,s2;                                                  #
    l0 = $1;                                                      #
  }'


######################################################################
# Finish
######################################################################

exit 0
