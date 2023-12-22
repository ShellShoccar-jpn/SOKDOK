#!/bin/sh

######################################################################
#
# ABACUS.SH : Abacus Examiner
#
# This program does the abacus examination.
#
#
# Usage(1) : apacus.sh [-b] grade
# Usage(2) : apacus.sh [-b] digits number time
# Arguments: grade
#              * The grade name of the abacus exam
#                - You can choose one from the followings.
#                  "20dan", "19dan", ..., "1dan" (or "shodan"),
#                  "1kyu", "2kyu", ..., "10kyu"
#                - Each grade is relative to three difficulty parameters,
#                  digits, number, and time.
#                - When you choose a grade name, the parameters will be
#                  set by the guidance on the following web page.
#                  https://kentei.soroban-soft.com/about_test.cgi
#            digits, number, time
#              * These arguments are to specify the difficulty manually.
#              * digits : the number of digits in the number on the
#                         question
#              * number : the total number of numbers that should be
#                         calculated
#              * time   : Time taken to display all numbers in the second
# Options  : -b ... Ring the bell when displaying numbers.
#
# Written by @colrichie (Shellshoccar Japan) on 2023-12-22
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
print_usage_and_exit() {
  cat <<-USAGE
	Usage(1) : ${0##*/} [-b] grade
	Usage(2) : ${0##*/} [-b] digits number time
	Arguments: grade
	             * The grade name of the abacus exam
	               - You can choose one from the followings.
	                 "20dan", "19dan", ..., "1dan" (or "shodan"),
	                 "1kyu", "2kyu", ..., "10kyu"
	               - Each grade is relative to three difficulty parameters,
	                 digits, number, and time.
	               - When you choose a grade name, the parameters will be
	                 set by the guidance on the following web page.
	                 https://kentei.soroban-soft.com/about_test.cgi
	           digits, number, time
	             * These arguments are to specify the difficulty manually.
	             * digits : the number of digits in the number on the
	                        question
	             * number : the total number of numbers that should be
	                        calculated
	             * time   : Time taken to display all numbers in the second
	Options  : -b ... Ring the bell when displaying numbers.
	Version  : 2023-12-22 17:03:24 JST
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
LF=$( printf '\n_' ); LF=${LF%_}
BEL=$(printf '\007')


######################################################################
# Argument
######################################################################

# === Default paremeters =============================================
bel=''
dig=3
tim=1.5
num=15

# === Parse arguments ================================================
case $# in    0) print_usage_and_exit;; esac
case $1 in '-b') bel=$BEL; shift     ;; esac
while :; do
  case $# in
    1) case $1 in
         20[Dd]*) dig=3; num=15; tim=1.5;;
         19[Dd]*) dig=3; num=15; tim=1.6;;
         18[Dd]*) dig=3; num=15; tim=1.7;;
         17[Dd]*) dig=3; num=15; tim=1.8;;
         16[Dd]*) dig=3; num=15; tim=1.9;;
         15[Dd]*) dig=3; num=15; tim=2.0;;
         14[Dd]*) dig=3; num=15; tim=2.2;;
         13[Dd]*) dig=3; num=15; tim=2.4;;
         12[Dd]*) dig=3; num=15; tim=2.6;;
         11[Dd]*) dig=3; num=15; tim=2.8;;
         10[Dd]*) dig=3; num=15; tim=3  ;;
          9[Dd]*) dig=3; num=15; tim=4.5;;
          8[Dd]*) dig=3; num=15; tim=6  ;;
          7[Dd]*) dig=3; num=15; tim=8  ;;
          6[Dd]*) dig=3; num=12; tim=8  ;;
          5[Dd]*) dig=3; num=10; tim=7  ;;
          4[Dd]*) dig=3; num=8 ; tim=6  ;;
          3[Dd]*) dig=3; num=6 ; tim=5  ;;
          2[Dd]*) dig=3; num=4 ; tim=4  ;;
          1[Dd]*|[Ss][HhYy][Oo][Dd]*)
                  dig=2; num=15; tim=10 ;;
          1[Kk]*) dig=2; num=15; tim=13 ;;
          2[Kk]*) dig=2; num=12; tim=12 ;;
          3[Kk]*) dig=2; num=10; tim=12 ;;
          4[Kk]*) dig=2; num=8 ; tim=11 ;;
          5[Kk]*) dig=2; num=7 ; tim=10 ;;
          6[Kk]*) dig=2; num=6 ; tim=9  ;;
          7[Kk]*) dig=2; num=5 ; tim=8  ;;
          8[Kk]*) dig=2; num=4 ; tim=7  ;;
          9[Kk]*) dig=2; num=3 ; tim=6  ;;
         10[Kk]*) dig=2; num=2 ; tim=4  ;;
               *) print_usage_and_exit  ;;
       esac
       ;;
    3) printf '%s:%s:%s\n' "$1" "$1" "$1"           |
       grep -Eq '^[0-9]+:[0-9]+:[0-9]+(\.[0-9]+)?$' ||
       print_usage_and_exit
       dig=$1; num=$2; tim=$3
       ;;
    *) print_usage_and_exit;;
  esac
  break
done

# === Validate parameters ============================================
([ $dig -gt 0 ] && [ $dig -le 10 ])      || {
  error_exit 1 "$dig: \"dig\" parameter is out of range (1-10)"
}
[ $num -gt 0 ]                           || {
  error_exit 1 "$num: \"num\" parameter must be above 0."
}
awk -v tim=$tim 'BEGIN{exit tim>0?0:1;}' || {
  error_exit 1 "$tim: \"tim\" parameter must be above 0."
}


######################################################################
# Main
######################################################################

# === Make the question ==============================================
s=$(dd if=/dev/urandom bs=4 count=$num 2>/dev/null                 |
    od -v -A n -t u4                                               |
    tr '[[:blank:]]' '\n'                                          |
    grep -E '^[0-9]+$'                                             |
    awk -v dig=$dig '                                              #
      BEGIN{OFMT="%.14g"; u4max=4294967296; max=10^dig; acm=0;   } #
           {n=int($1*max/u4max); acm+=n; printf("%" dig "d\n",n);} #
      END  {print acm;                                           }')
q=${s%$LF*}
a=${s##*$LF}

# === Get center position ============================================
X_mid=$(($(tput cols  2>/dev/null)/2))
Y_mid=$(($(tput lines 2>/dev/null)/2))
case "$X_mid" in '') X_mid=40;; esac # Assume the VT100's size (80*24)
case "$Y_mid" in '') Y_mid=12;; esac # if tput cols/lines doesn't work.

# === Questioning ====================================================
clear
echo "$q"                                              |
awk -v num=$num -v tim=$tim '                          #
  BEGIN{t0=0; blink=0.2;                               #
        print 0, "[3]"; t0++;                          #
        print 1, "[2]"; t0++;                          #
        print 2, "[1]"; t0++;                     }    #
       {printf("%.6g %s\n",t0+(NR-1)*tim/num, $0);     #
        printf("%.6g \n"  ,t0+(NR-blink)*tim/num);}    #
  END  {printf("%.6g \n"  ,t0+(NR-1)*tim/num    );}'   |
# 1:timestamp 2:message                                #
tscat -zZ                                              |
# 1: message                                           #
awk -v bel=$bel -v xm=$X_mid -v ym=$Y_mid '            #
  BEGIN {                                              #
    OFS=""; l0=0;                                      #
  }                                                    #
  {                                                    #
    if (l0==0) {                                       #
      s1 = "";                                         #
    }                                                  #
    else       {                                       #
      s  = sprintf("%" l0 "s","");                     #
      s1 = sprintf("\033[%d;%dH%s",ym,int(xm-l0/2),s); #
    }                                                  #
    l  = length($0);                                   #
    s  = ((l>0)?bel:"") $0;                            #
    s2 = sprintf("\033[%d;%dH%s",ym,int(xm-l/2),s);    #
    print s1,s2;                                       #
    l0 = l;                                            #
  }'

# === Asking =========================================================
printf '\033[%d;1HType the answer: ' $Y_mid; read n;
case "$n" in
  "$a") echo "Correct."             ;;
     *) echo "Not correct! (ans=$a)";;
esac


######################################################################
# Finish
######################################################################

exit 0
