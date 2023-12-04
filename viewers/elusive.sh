#!/bin/sh

######################################################################
#
# ELUSIVE.SH : SOKDOK Viewer (Elusive Version)
#
# This program shows the text data by every phrase somewhere on the
# screen (terminal.) at the specified speed.
# You can experience the feeling when you see a terrablly unreadable
# program having a lot of loops, branches, and subroutines.
# It is said that eye-moving costs pretty heavily for text reading.
#
#
# Usage     : elusive.sh letters_per_minute [textfile]
# Arguments : letters_per_minute
#               * Speed on the screen in letters per minute
#               * 800 is the moderate speed for ordinal people.
#               * About >=2000 is the speed for speed-readers.
#               * About >=6000 is the speed for well-trained speed-
#                 readers.
#             textfile
#               * Text file you want to print on the screen
#               * The textdata in the file should be split into each
#                 phrase that can be read in an instant and put into
#                 line by line.
#               * If you omit this argument, the standard input will be
#                  regarded as the text file to be read.
#
# Written by @colrichie (Shellshoccar Japan) on 2023-12-05
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
	Version : 2023-12-05 01:18:57 JST
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
type ptw   >/dev/null 2>&1 || {
  error_exit 1 'ptw command is not found. Please run "00setup.sh" in advance.'
}
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
X_max=$(($(tput cols  2>/dev/null)  ))
Y_max=$(($(tput lines 2>/dev/null)-2))
case "$X_max" in '') X_max=80;; esac
case "$Y_max" in '') Y_max=23;; esac

# === Flash ==========================================================
clear
cat /dev/urandom |
od -A n -t u4    |
awk -v xm=$X_max -v ym=$Y_max '                                   #
  {                                                               #
    print int($1/4294967296*xm)+1,int($2/4294967296*ym)+1;        #
  }'                                                              |
# 1:random-x-position 2:random-y-position                         #
awk -v file="$file" '                                             #
  {                                                               #
    if (! getline line < file) {exit 0;}                          #
    print $1,$2,line;                                             #
  }'                                                              |
# 1:random-x-position 2:random-y-position 3:body                  #
utf8wc -lv                                                        |
# 1:bytes(includes fld.4-5) 2:leters(includes fld.4-5)            #
# 3:length(includes fld.4-5) 4:rx 5:ry 6:body                     #
awk '                                                             #
  NF>=6{                                                          #
    match($0,/^[^ ]+ [^ ]+ [^ ]+ /            ); l1=RLENGTH;      #
    match($0,/^[^ ]+ [^ ]+ [^ ]+ [^ ]+ [^ ]+ /); l2=RLENGTH;      #
    l=l2-l1;                                                      #
    print $1-l,$2-l,$3-l,substr($0,l1+1)                          #
  }'                                                              |
# 1:bytes(fld.6) 2:leters(fld.6) 3:length(fld.6) 4:rx 5:ry 6:body #
awk -v lpm=$lpm '                                                 #
  BEGIN {OFMT="%.14g"; ts=0;}                                     #
  {print ts,$3,substr($0,length($1 $2 $3)+4); ts+=($2)*60/lpm;} ' |
# 1:time 2:length 3:rx 4:ry 5:body                                #
tscat -zZ                                                         |
# 1:length 2:rx 3:ry 4:body                                       #
ptw awk '                                                         #
  BEGIN {                                                         #
    OFS=""; l0=0; x0=1; y0=1;                                     #
  }                                                               #
  {                                                               #
    s  = sprintf("%" l0+1 "s","");                                #
    s1 = sprintf("\033[%d;%dH%s",y0,x0,s);                        #
    s  = substr($0,length($1 $2 $3)+4);                           #
    s2 = sprintf("\033[%d;%dH%s",$3,$2,s);                        #
    print s1,s2;                                                  #
    l0=$1; x0=$2; y0=$3;                                          #
  }'


######################################################################
# Finish
######################################################################

exit 0
