#!/bin/sh

# Quadhelion Engineering
# elias@quadhelion.engineering
#
# Workaround Origin: https://lock.cmpxchg8b.com/zenbleed.html

# PROVIDE: Zenbleed
# AFTER: kldxref

. /etc/rc.subr

name="zenbleed"
desc="Zenbleed Workaround"
rcvar="${name}_enable"
start_cmd="msr_set"


: "${zenbleed_enable:=NO}"

msr_set() {
    cores=$(ls -l /dev | grep "cpuctl" | wc -l)
    a=0; while [ $a -lt $cores ]; do cpucontrol -m '0xc0011029|=0x200' /dev/cpuctl$a; a=$((a + 1)); done
}

load_rc_config "${name}"
run_rc_command "$1" 