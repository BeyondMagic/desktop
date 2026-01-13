#!/usr/bin/env sh
#
# For runit, script to re-execute python-validity after it is thrown off by the system.
#
# João Farias © BeyondMagic <beyondmagic@mail.ru> 2023-2023

SCRIPT=/opt/python-validity/dbus_service/dbus-service

# After resume.
case "$1" in

	'pre')
		exec pkill -f "$SCRIPT"
	;;

	'post')
		exec $SCRIPT
	;;

	*)
		exit 64
	;;

esac
