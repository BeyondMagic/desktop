#!/usr/bin/env sh
#
# For dinit, script to suspend and resume open-fprintd devices via elogind.
#
# João Farias © BeyondMagic <beyondmagic@mail.ru> 2023-2026

case "$1" in

	'pre')
		exec /usr/lib/open-fprintd/suspend.py
	;;

	'post')
		exec /usr/lib/open-fprintd/resume.py
	;;

	*)
		exit 64
	;;

esac

