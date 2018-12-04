#!/bin/bash
#
# Start a VNC session at ACCRE.
#
# Rob Siverd
# Created:      2018-12-04
# Last updated: 2018-12-04
#--------------------------------------------------------------------------
#**************************************************************************
#--------------------------------------------------------------------------

## Default options:
debug=0 ; clobber=0 ; force=0 ; timer=0 ; vlevel=0
script_version="0.10"
this_prog="${0##*/}"
#shopt -s nullglob
# Propagate errors through pipelines: set -o pipefail
# Exit if uninitialized variable used (set -u): set -o nounset
# Exit in case of nonzero status (set -e): set -o errexit

## Program options:
#save_file=""
#shuffle=0
#confirmed=0

## Standard scratch files/dirs:
tmp_name="$(date +%Y%m%d.%H%M%S).$$.$(whoami)"
tmp_root="/tmp"
[ -d /dev/shm ] && [ -w /dev/shm ] && tmp_root="/dev/shm"
tmp_dir="$tmp_root"
#tmp_dir="$tmp_root/$tmp_name"
#mkdir -p $tmp_dir
foo="$tmp_dir/foo_$$.txt"
bar="$tmp_dir/bar_$$.txt"
baz="$tmp_dir/baz_$$.fits"
qux="$tmp_dir/qux_$$.fits"
jnk="$foo $bar $baz $qux"  # working copy
def_jnk="$jnk"             # original set
dir_cleanup='(echo -e "\nAutomatic clean up ... " ; cmde "rm -vrf $tmp_dir")'
jnk_cleanup='for X in $jnk ; do [ -f $X ] && cmde "rm -vf $X" ; done'
trap "$jnk_cleanup >&2" EXIT
##trap '[ -d $tmp_dir ] && cmde "rm -vrf $tmp_dir"' EXIT
#trap "[ -d $tmp_dir ] && $dir_cleanup >&2" EXIT
#trap "[ -d $tmp_dir ] && $dir_cleanup >&2; $jnk_cleanup >&2" EXIT
#trap 'oops=$? ; echo ; exit $oops' HUP INT TERM

## Required programs:
declare -a need_exec
need_exec+=( awk cat FuncDef sed tr vncserver Xvnc )
#need_exec+=( shuf shuffle sort ) # for randomization
for need in ${need_exec[*]}; do
   if ! ( /usr/bin/which $need >& /dev/null ); then
      echo "Error:  can't find '$need' in PATH !!" >&2
      exit 1
   fi
done

## Helper function definitions:
fd_args="--argchk --colors --cmde --echo"
#fd_args+=" --Critical"
fd_args+=" --rowwrite"
#fd_args+=" --timers"
fd_args+=" --warnings"
FuncDef $fd_args >/dev/null || exit $?
eval "$(FuncDef $fd_args)"  || exit $?

## Check for arguments:
usage () { 
   Recho "\nSyntax: $this_prog --START\n\n"
}
if [ "$1" != "--START" ]; then
   usage >&2
   exit 1
fi

##**************************************************************************##
##==========================================================================##
##--------------------------------------------------------------------------##

## VNC options for known, valid hosts:
this_hist=$(hostname -s)
case $this_host in
   rsiverd-linux.lco.gtn|krang.vampire|shredder|splinter)
      vnc_opts="-depth 24 -geometry 1680x1050 -autokill -localhost"
      ;;
   *) PauseAbort "Unrecognized host: $this_host"
      ;;
esac

## Look for config file:
disp_conf="src/user_displays.conf"
[ -f $disp_conf ] || PauseAbort "Can't find file: $disp_conf"

## Get list of known users:
my_display=$(awk -v userid=$(whoami) '$1 == userid {print $2}' $disp_conf)
if [ -z "$my_display" ]; then
   PauseAbort "Unrecognized user: `whoami`"
fi
echo "Using DISPLAY: $my_display"
echo "vnc_opts: $vnc_opts"

##--------------------------------------------------------------------------##
## Check in case VNC server already running:
vncserver -list

##--------------------------------------------------------------------------##
## Clean up:
#[ -d $tmp_dir ] && [ -O $tmp_dir ] && rm -rf $tmp_dir
#[ -f $foo ] && rm -f $foo
#[ -f $bar ] && rm -f $bar
#[ -f $baz ] && rm -f $baz
#[ -f $qux ] && rm -f $qux
exit 0

######################################################################
# CHANGELOG (kelt_vnc_session.sh):
#---------------------------------------------------------------------
#
#  2018-12-04:
#     -- Increased script_version to 0.10.
#     -- First created kelt_vnc_session.sh.
#
