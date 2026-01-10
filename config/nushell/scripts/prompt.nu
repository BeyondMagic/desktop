export-env {

	let symbol = open ~/.config/nushell/symbols.txt
		| lines
		| random item

	let indicator = ' ' + $symbol + ' '

	# The prompt indicators are environmental variables that represent
	# the state of the prompt.
	$env.PROMPT_INDICATOR = {|| $indicator }
	$env.PROMPT_INDICATOR_VI_INSERT = {|| $indicator }
	$env.PROMPT_INDICATOR_VI_NORMAL = {|| $symbol + ' ' }
	$env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }
}
