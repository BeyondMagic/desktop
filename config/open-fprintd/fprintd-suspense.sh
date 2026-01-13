#!/usr/bin/env sh
#
# For runit, script to re-execute python-validity after it is thrown off by the system.
# 
# João Farias © BeyondMagic <beyondmagic@mail.ru> 2023-2023

SCRIPT=/opt/python-validity/dbus_service/dbus-service

# After resume.
[ "$1" == "post"] && {
	touch /home/dream/dawdwadawd.resume
	
# Before suspend.
} || {
	touch /home/dream/lol.kakkk
	#pkill -f "$SCRIPT"
}

