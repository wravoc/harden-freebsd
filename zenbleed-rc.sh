#!/bin/sh

# Quadhelion Engineering
# elias@quadhelion.engineering
#
# Workaround Origin: https://lock.cmpxchg8b.com/zenbleed.html


. /etc/rc.subr

name="zenbleed"
desc="Zenbleed MSR chicken-bit Workaround"
rcvar="${name}_enable"

start_cmd="zenbleed_workaround"
stop_cmd="zenbleed_restore"

load_rc_config "${name}"

: "${zenbleed_enable:=NO}"

zenbleed_workaround() {
    for core in /dev/cpuctl*
    do
        echo "Applying zenbleed_workaround for $core"
        /usr/sbin/cpucontrol -m "0xc0011029|=0x200" "$core"
    done
}

zenbleed_restore() {
    for core in /dev/cpuctl*
    do
        echo "Removing zenbleed_workaround for $core"
        /usr/sbin/cpucontrol -m "0xc0011029&=~0x200" "$core"
    done
}

run_rc_command "$1" 