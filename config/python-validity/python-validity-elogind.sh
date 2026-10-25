#!/usr/bin/env sh
#
# For dinit, script to restart python-validity and open-fprintd after resume via elogind.
#
# João Farias © BeyondMagic <beyondmagic@mail.ru> 2023-2026

case "$1" in

	'pre')
		exit 0
	;;

	'post')
		dinitctl --system restart --force --no-wait open-fprintd
		exec dinitctl --system restart --no-wait python-validity
	;;

	*)
		exit 64
	;;

esac

