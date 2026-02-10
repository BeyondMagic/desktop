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

# List available calendars
export def list []: nothing -> table<access: string, title: string> {
	run-external ...[
		gcalcli
		list
	]
	| ansi strip
	| lines
	| str trim
	| parse "{access} {title}"
	| skip 2
}