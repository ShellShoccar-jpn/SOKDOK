#!/bin/sh

######################################################################
#
# 00SETUP.SH : "SOKDOK" Set-up Script
#
# To try this application "SOKDOK," run this script onece before running
# other commands. This script will compile and build some commands
# this application requires.
#
# Usage : 00setup.sh
#
# Written by @colrichie (Shellshoccar Japan) on 2023-11-12
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
	Usage   : ${0##*/}
	Version : 2023-11-12 20:02:12 JST
	USAGE
  exit 1
}
error_exit() {
  ${2+:} false && echo "${0##*/}: $2" 1>&2
  exit $1
}

# === Directory definitions ==========================================
Homedir=$(d=${0%/*}/; [ "_$d" = "_$0/" ] && d='./'; cd "$d."; pwd)
PATH="$Homedir/lib:$PATH"


######################################################################
# Argument Parsing
######################################################################

case "$#" in 0) :;; *) print_usage_and_exit;; esac


######################################################################
# Main
######################################################################

"$Homedir/lib/c_src/MAKE.sh" -u || error_exit 1 'Failed to setup'


######################################################################
# Finish
######################################################################

echo
echo '*** Setup has done successfully. Enjoy SOKDOK! ***' 1>&2
exit 0
