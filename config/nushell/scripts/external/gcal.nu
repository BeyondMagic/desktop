# Thank you @kurokirasama for developing initially this wrapper.

# gcalcli wrapper for accesing google calendar
export def "gcal help" [] {
	print ([
		"gcalcli wrapper:"
		"METHODS"
		"- gcal add"
		"- gcal agenda"
		"- gcal semana"
		"- gcal mes"
		"- gcal list"
	] | str join "\n"
		| nu-highlight
	) 
}

#add event to google calendar, also usable without arguments
export def "gcal add" [
	calendar?   #to which calendar add event
	title?      #event title
	when?       #date: yyyy.MM.dd hh:mm
	where?      #location
	duration?   #duration in minutes
] {
	let calendar = if ($calendar | is-empty) {
		gcal list -r | sort | input list -f (echo-g "Select calendar: ")
	} else {
		$calendar
	}

	let title = if ($title | is-empty) {input (echo-g "title: ")} else {$title}
	let when = if ($when | is-empty) {input (echo-g "when: ")} else {$when}
	let where = if ($where | is-empty) {input (echo-g "where: ")} else {$where}
	let duration = if ($duration | is-empty) {input (echo-g "duration: ")} else {$duration}

	gcalcli --calendar $"($calendar)" add --title $"($title)" --when $"($when)" --where $"($where)" --duration $"($duration)" --default-reminders
}

#show gcal agenda in selected calendars
#
# Examples
# agenda 
# agenda --full
# agenda "--details=all"
# agenda --full "--details=all"
export def --wrapped "gcal agenda" [
	--full(-f)  #show all calendars
	...rest     #extra flags for gcalcli between quotes (specified full needed)
] {
	let calendars = gcal list -R (not $full) -f $full| str join "|"

	gcalcli --calendar $"($calendars)" agenda --military ...$rest
}

#show gcal week in selected calendards
#
# Examples
# semana 
# semana --full
# semana "--details=all"
# semana --full "--details=all"
export def --wrapped "gcal semana" [
	--full(-f) #show all calendars (export default: 0)
	...rest    #extra flags for gcalcli between quotes (specified full needed)
] {
	let calendars = gcal list -R (not $full) -f $full | str join "|"

	gcalcli --calendar $"($calendars)" calw ...$rest --military --monday
}

#show gcal month in selected calendards
#
# Examples
# mes 
# mes --full
# mes "--details=all"
# mes --full "--details=all"
export def --wrapped "gcal mes" [
	--full(-f)  #show all calendars (export default: 0)
	...rest     #extra flags for gcalcli between quotes (specified full needed)
] {
	let calendars = gcal list -R (not $full) -f $full | str join "|"

	gcalcli --calendar $"($calendars)" calm ...$rest --military --monday
}

#list available calendars
export def "gcal list" [
	--readers(-r) #exclude read-only calendars
	--readers_bool(-R) = false #same as -r, but bool flag
	--full(-f) = true  #if false, filter not wanted calendars
] {
	gcalcli list
	| ansi strip
	| lines
	| skip 2 
	| if $readers or $readers_bool {find -v reader} else {find ""}
	| if $full {find ""} else {find -v Cuentas}
	| drop 
	| str replace -a "owner" "" 
	| str replace "writer" "" 
	| str replace "reader" "" 
	| str replace "    " "" 
	| str replace "   " "" 
	| str trim
}

#re-authenticate gcalcli
export def "gcal reauth" [] {
	rm ~/.gcalcli* -f
	gcalcli --client-id $env.MY_ENV_VARS.api_keys.google.calendar.client_id --client-secret $env.MY_ENV_VARS.api_keys.google.calendar.client_secret --noauth_local_webserver list
}
