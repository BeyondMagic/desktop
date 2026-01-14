# João Farias © BeyondMagic 2024 <beyondmagic@mail.ru>

# Initialization modules.
use ./scripts/init.nu *

# The default config record. This is where much of your global configuration is setup.
$env.config = {
	show_banner: false # true or false to enable or disable the welcome banner at startup

	ls: {
		use_ls_colors: true # use the LS_COLORS environment variable to colorize output
		clickable_links: true # enable or disable clickable links. Your terminal has to support links.
	}

	rm: {
		always_trash: true # always act as if -t was given. Can be overridden with -p
	}

	table: {
		mode: basic # basic, compact, compact_double, light, thin, with_love, rounded, reinforced, heavy, none, other
		index_mode: always # "always" show indexes, "never" show indexes, "auto" = show indexes when a table has "index" column
		show_empty: true # show 'empty list' and 'empty record' placeholders for command output
		padding: { left: 1, right: 1 } # a left right padding of each column in a table
		trim: {
			methodology: wrapping # wrapping or truncating
			wrapping_try_keep_words: true # A strategy used by the 'wrapping' methodology
			truncating_suffix: "..." # A suffix used by the 'truncating' methodology
		}
		header_on_separator: false # show header text on separator/border line
		# abbreviated_row_count: 10 # limit data rows from top and bottom after reaching a set point
	}

	error_style: "fancy" # "fancy" or "plain" for screen reader-friendly error messages

	# datetime_format determines what a datetime rendered in the shell would look like.
	# Behavior without this configuration point will be to "humanize" the datetime display,
	# showing something like "a day ago."
	datetime_format: {
		# normal: '%a, %d %b %Y %H:%M:%S %z'	# shows up in displays of variables or other datetime's outside of tables
		# table: '%m/%d/%y %I:%M:%S%p'		  # generally shows up in tabular outputs such as ls. commenting this out will change it to the default human readable datetime format
	}

	explore: {
		status_bar_background: {fg: "#1D1F21", bg: "#C4C9C6"},
		command_bar_text: {fg: "#C4C9C6"},
		highlight: {fg: "black", bg: "yellow"},
		status: {
			error: {fg: "white", bg: "red"},
			warn: {}
			info: {}
		},
		table: {
			split_line: {fg: "#404040"},
			selected_cell: {bg: light_blue},
			selected_row: {},
			selected_column: {},
		},
	}

	history: {
		max_size: 100_000 # Session has to be reloaded for this to take effect
		sync_on_enter: true # Enable to share history between multiple sessions, else you have to close the session to write history to file
		file_format: "plaintext" # "sqlite" or "plaintext"
		isolation: false # only available with sqlite file_format. true enables history isolation, false disables it. true will allow the history to be isolated to the current session using up/down arrows. false will allow the history to be shared across all sessions.
	}

	completions: {
		case_sensitive: false # set to true to enable case-sensitive completions
		quick: true	# set this to false to prevent auto-selecting completions when only one remains
		partial: true	# set this to false to prevent partial filling of the prompt
		algorithm: "fuzzy"	# prefix or fuzzy
		external: {
			enable: true # set to false to prevent nushell looking into $env.PATH to find more suggestions, `false` recommended for WSL users as this look up may be very slow
			max_results: 100 # setting it lower can improve completion performance at the cost of omitting some options
			completer: null # check 'carapace_completer' above as an example
		}
	}

	#filesize: {
	#	metric: false # true => KB, MB, GB (ISO standard), false => KiB, MiB, GiB (Windows standard)
	#	format: "auto" # b, kb, kib, mb, mib, gb, gib, tb, tib, pb, pib, eb, eib, auto
	#}

	cursor_shape: {
		emacs: line # block, underscore, line, blink_block, blink_underscore, blink_line, inherit to skip setting cursor shape (line is the default)
		vi_insert: block # block, underscore, line, blink_block, blink_underscore, blink_line, inherit to skip setting cursor shape (block is the default)
		vi_normal: underscore # block, underscore, line, blink_block, blink_underscore, blink_line, inherit to skip setting cursor shape (underscore is the default)
	}

	# color_config: $dark_theme # if you want a more interesting theme, you can replace the empty record with `$dark_theme`, `$light_theme` or another custom record
	color_config: (tokyo-night)
	#use_grid_icons: true
	footer_mode: 25 # always, never, number_of_rows, auto
	float_precision: 2 # the precision for displaying floats in tables
	buffer_editor: "" # command that will be used to edit the current line buffer with ctrl+o, if unset fallback to $env.EDITOR and $env.VISUAL
	use_ansi_coloring: true
	bracketed_paste: true # enable bracketed paste, currently useless on windows
	edit_mode: vi # emacs, vi
	shell_integration: {
		# osc2 abbreviates the path if in the home_dir, sets the tab/window title, shows the running command in the tab/window title
		osc2: true
		# osc7 is a way to communicate the path to the terminal, this is helpful for spawning new tabs in the same directory
		osc7: true
		# osc8 is also implemented as the deprecated setting ls.show_clickable_links, it shows clickable links in ls output if your terminal supports it. show_clickable_links is deprecated in favor of osc8
		osc8: true
		# osc9_9 is from ConEmu and is starting to get wider support. It's similar to osc7 in that it communicates the path to the terminal
		osc9_9: false
		# osc133 is several escapes invented by Final Term which include the supported ones below.
		# 133;A - Mark prompt start
		# 133;B - Mark prompt end
		# 133;C - Mark pre-execution
		# 133;D;exit - Mark execution finished with exit code
		# This is used to enable terminals to know where the prompt is, the command is, where the command finishes, and where the output of the command is
		osc133: true
		# osc633 is closely related to osc133 but only exists in visual studio code (vscode) and supports their shell integration features
		# 633;A - Mark prompt start
		# 633;B - Mark prompt end
		# 633;C - Mark pre-execution
		# 633;D;exit - Mark execution finished with exit code
		# 633;E - NOT IMPLEMENTED - Explicitly set the command line with an optional nonce
		# 633;P;Cwd=<path> - Mark the current working directory and communicate it to the terminal
		# and also helps with the run recent menu in vscode
		osc633: true
		# reset_application_mode is escape \x1b[?1l and was added to help ssh work better
		reset_application_mode: true
	}
	render_right_prompt_on_last_line: false # true or false to enable or disable right prompt to be rendered on last line of the prompt.
	use_kitty_protocol: false # enables keyboard enhancement protocol implemented by kitty console, only if your terminal support this

	hooks: {
		pre_prompt: [{ null }] # run before the prompt is shown
		env_change: {
			PWD: [{|before, after| null }] # run if the PWD environment is different since the last repl input
		}
		# run before the repl input is run
		#pre_execution: [{
		#	print "\b\b\b\b\b\b\b\bHH:MM:SS" --raw
		#}]
		# run to display the output of a pipeline
		display_output: {
			# Save last output and put in $env.LAST.
			$env.LAST = $in

			let out = $in
				| if (term size).columns >= 80 {
					table --expand
				} else {
					table
				}

			$out
		}
		command_not_found: {( null )}

	}

	menus: [
		# Configuration for default nushell menus
		# Note the lack of source parameter
		{
			name: completion_menu
			only_buffer_difference: false
			marker: "| "
			type: {
				layout: columnar
				columns: 4
				col_width: 20	 # Optional value. If missing all the screen width is used to calculate column width
				col_padding: 2
			}
			style: {
				text: green
				selected_text: {attr: r}
				description_text: yellow
			}
		}
		{
			name: ide_completion_menu
			only_buffer_difference: false
			marker: "| "
			type: {
				layout: ide
				min_completion_width: 0,
				max_completion_width: 50,
				# max_completion_height: 10, # will be limited by the available lines in the terminal
				padding: 0,
				border: true,
				cursor_offset: 0,
				description_mode: "prefer_right"
				min_description_width: 0
				max_description_width: 50
				max_description_height: 10
				description_offset: 1
				# If true, the cursor pos will be corrected, so the suggestions match up with the typed text
				#
				# C:\> str
				#	  str join
				#	  str trim
				#	  str split
				correct_cursor_pos: false
			}
			style: {
				text: green
				selected_text: {attr: r}
				description_text: yellow
				match_text: {attr: u}
				selected_match_text: {attr: ur}
			}
		}
		{
			name: history_menu
			only_buffer_difference: true
			marker: "? "
			type: {
				layout: list
				page_size: 10
			}
			style: {
				text: green
				selected_text: green_reverse
				description_text: yellow
			}
		}
		{
			name: help_menu
			only_buffer_difference: true
			marker: "? "
			type: {
				layout: description
				columns: 4
				col_width: 20	 # Optional value. If missing all the screen width is used to calculate column width
				col_padding: 2
				selection_rows: 4
				description_rows: 10
			}
			style: {
				text: green
				selected_text: green_reverse
				description_text: yellow
			}
		}
	]

	keybindings: [
		{
			name: completion_menu
			modifier: none
			keycode: tab
			mode: [emacs vi_normal vi_insert]
			event: {
				until: [
					{ send: menu name: completion_menu }
					{ send: menunext }
					{ edit: complete }
				]
			}
		}
		{
			name: ide_completion_menu
			modifier: control
			keycode: char_n
			mode: [emacs vi_normal vi_insert]
			event: {
				until: [
					{ send: menu name: ide_completion_menu }
					{ send: menunext }
					{ edit: complete }
				]
			}
		}
		{
			name: history_menu
			modifier: control
			keycode: char_r
			mode: [emacs, vi_insert, vi_normal]
			event: { send: menu name: history_menu }
		}
		{
			name: help_menu
			modifier: none
			keycode: f1
			mode: [emacs, vi_insert, vi_normal]
			event: { send: menu name: help_menu }
		}
		{
			name: completion_previous_menu
			modifier: shift
			keycode: backtab
			mode: [emacs, vi_normal, vi_insert]
			event: { send: menuprevious }
		}
		{
			name: next_page_menu
			modifier: control
			keycode: char_x
			mode: emacs
			event: { send: menupagenext }
		}
		{
			name: undo_or_previous_page_menu
			modifier: control
			keycode: char_z
			mode: emacs
			event: {
				until: [
					{ send: menupageprevious }
					{ edit: undo }
				]
			}
		}
		{
			name: escape
			modifier: none
			keycode: escape
			mode: [emacs, vi_normal, vi_insert]
			event: { send: esc }	# NOTE: does not appear to work
		}
		{
			name: cancel_command
			modifier: control
			keycode: char_c
			mode: [emacs, vi_normal, vi_insert]
			event: { send: ctrlc }
		}
		{
			name: quit_shell
			modifier: control
			keycode: char_d
			mode: [emacs, vi_normal, vi_insert]
			event: { send: ctrld }
		}
		{
			name: clear_screen
			modifier: control
			keycode: char_l
			mode: [emacs, vi_normal, vi_insert]
			event: { send: clearscreen }
		}
		{
			name: search_history
			modifier: control
			keycode: char_q
			mode: [emacs, vi_normal, vi_insert]
			event: { send: searchhistory }
		}
		{
			name: open_command_editor
			modifier: control
			keycode: char_o
			mode: [emacs, vi_normal, vi_insert]
			event: { send: openeditor }
		}
		{
			name: move_up
			modifier: none
			keycode: up
			mode: [emacs, vi_normal, vi_insert]
			event: {
				until: [
					{send: menuup}
					{send: up}
				]
			}
		}
		{
			name: move_down
			modifier: none
			keycode: down
			mode: [emacs, vi_normal, vi_insert]
			event: {
				until: [
					{send: menudown}
					{send: down}
				]
			}
		}
		{
			name: move_left
			modifier: none
			keycode: left
			mode: [emacs, vi_normal, vi_insert]
			event: {
				until: [
					{send: menuleft}
					{send: left}
				]
			}
		}
		{
			name: move_right_or_take_history_hint
			modifier: none
			keycode: right
			mode: [emacs, vi_normal, vi_insert]
			event: {
				until: [
					{send: historyhintcomplete}
					{send: menuright}
					{send: right}
				]
			}
		}
		{
			name: move_one_word_left
			modifier: control
			keycode: left
			mode: [emacs, vi_normal, vi_insert]
			event: {edit: movewordleft}
		}
		{
			name: move_one_word_right_or_take_history_hint
			modifier: control
			keycode: right
			mode: [emacs, vi_normal, vi_insert]
			event: {
				until: [
					{send: historyhintwordcomplete}
					{edit: movewordright}
				]
			}
		}
		{
			name: move_to_line_start
			modifier: none
			keycode: home
			mode: [emacs, vi_normal, vi_insert]
			event: {edit: movetolinestart}
		}
		{
			name: move_to_line_start
			modifier: control
			keycode: char_a
			mode: [emacs, vi_normal, vi_insert]
			event: {edit: movetolinestart}
		}
		{
			name: move_to_line_end_or_take_history_hint
			modifier: none
			keycode: end
			mode: [emacs, vi_normal, vi_insert]
			event: {
				until: [
					{send: historyhintcomplete}
					{edit: movetolineend}
				]
			}
		}
		{
			name: move_to_line_end_or_take_history_hint
			modifier: control
			keycode: char_e
			mode: [emacs, vi_normal, vi_insert]
			event: {
				until: [
					{send: historyhintcomplete}
					{edit: movetolineend}
				]
			}
		}
		{
			name: move_to_line_start
			modifier: control
			keycode: home
			mode: [emacs, vi_normal, vi_insert]
			event: {edit: movetolinestart}
		}
		{
			name: move_to_line_end
			modifier: control
			keycode: end
			mode: [emacs, vi_normal, vi_insert]
			event: {edit: movetolineend}
		}
		{
			name: move_up
			modifier: control
			keycode: char_p
			mode: [emacs, vi_normal, vi_insert]
			event: {
				until: [
					{send: menuup}
					{send: up}
				]
			}
		}
		{
			name: move_down
			modifier: control
			keycode: char_t
			mode: [emacs, vi_normal, vi_insert]
			event: {
				until: [
					{send: menudown}
					{send: down}
				]
			}
		}
		{
			name: delete_one_character_backward
			modifier: none
			keycode: backspace
			mode: [emacs, vi_insert]
			event: {edit: backspace}
		}
		{
			name: delete_one_word_backward
			modifier: control
			keycode: backspace
			mode: [emacs, vi_insert]
			event: {edit: backspaceword}
		}
		{
			name: delete_one_character_forward
			modifier: none
			keycode: delete
			mode: [emacs, vi_insert]
			event: {edit: delete}
		}
		{
			name: delete_one_character_forward
			modifier: control
			keycode: delete
			mode: [emacs, vi_insert]
			event: {edit: delete}
		}
		{
			name: delete_one_character_forward
			modifier: control
			keycode: char_h
			mode: [emacs, vi_insert]
			event: {edit: backspace}
		}
		{
			name: delete_one_word_backward
			modifier: control
			keycode: char_w
			mode: [emacs, vi_insert]
			event: {edit: backspaceword}
		}
		{
			name: move_left
			modifier: none
			keycode: backspace
			mode: vi_normal
			event: {edit: moveleft}
		}
		{
			name: newline_or_run_command
			modifier: none
			keycode: enter
			mode: emacs
			event: {send: enter}
		}
		{
			name: move_left
			modifier: control
			keycode: char_b
			mode: emacs
			event: {
				until: [
					{send: menuleft}
					{send: left}
				]
			}
		}
		{
			name: move_right_or_take_history_hint
			modifier: control
			keycode: char_f
			mode: emacs
			event: {
				until: [
					{send: historyhintcomplete}
					{send: menuright}
					{send: right}
				]
			}
		}
		{
			name: redo_change
			modifier: control
			keycode: char_g
			mode: emacs
			event: {edit: redo}
		}
		{
			name: undo_change
			modifier: control
			keycode: char_z
			mode: emacs
			event: {edit: undo}
		}
		{
			name: paste_before
			modifier: control
			keycode: char_y
			mode: emacs
			event: {edit: pastecutbufferbefore}
		}
		{
			name: cut_word_left
			modifier: control
			keycode: char_w
			mode: emacs
			event: {edit: cutwordleft}
		}
		{
			name: cut_line_to_end
			modifier: control
			keycode: char_k
			mode: emacs
			event: {edit: cuttoend}
		}
		{
			name: cut_line_from_start
			modifier: control
			keycode: char_u
			mode: emacs
			event: {edit: cutfromstart}
		}
		{
			name: swap_graphemes
			modifier: control
			keycode: char_t
			mode: emacs
			event: {edit: swapgraphemes}
		}
		{
			name: move_one_word_left
			modifier: alt
			keycode: left
			mode: emacs
			event: {edit: movewordleft}
		}
		{
			name: move_one_word_right_or_take_history_hint
			modifier: alt
			keycode: right
			mode: emacs
			event: {
				until: [
					{send: historyhintwordcomplete}
					{edit: movewordright}
				]
			}
		}
		{
			name: move_one_word_left
			modifier: alt
			keycode: char_b
			mode: emacs
			event: {edit: movewordleft}
		}
		{
			name: move_one_word_right_or_take_history_hint
			modifier: alt
			keycode: char_f
			mode: emacs
			event: {
				until: [
					{send: historyhintwordcomplete}
					{edit: movewordright}
				]
			}
		}
		{
			name: delete_one_word_forward
			modifier: alt
			keycode: delete
			mode: emacs
			event: {edit: deleteword}
		}
		{
			name: delete_one_word_backward
			modifier: alt
			keycode: backspace
			mode: emacs
			event: {edit: backspaceword}
		}
		{
			name: delete_one_word_backward
			modifier: alt
			keycode: char_m
			mode: emacs
			event: {edit: backspaceword}
		}
		{
			name: cut_word_to_right
			modifier: alt
			keycode: char_d
			mode: emacs
			event: {edit: cutwordright}
		}
		{
			name: upper_case_word
			modifier: alt
			keycode: char_u
			mode: emacs
			event: {edit: uppercaseword}
		}
		{
			name: lower_case_word
			modifier: alt
			keycode: char_l
			mode: emacs
			event: {edit: lowercaseword}
		}
		{
			name: capitalize_char
			modifier: alt
			keycode: char_c
			mode: emacs
			event: {edit: capitalizechar}
		}
		{
			name: copy_selection
			modifier: control_shift
			keycode: char_c
			mode: emacs
			event: { edit: copyselection }
		}
		{
			name: cut_selection
			modifier: control_shift
			keycode: char_x
			mode: emacs
			event: { edit: cutselection }
		}
		{
			name: select_all
			modifier: control_shift
			keycode: char_a
			mode: emacs
			event: { edit: selectall }
		}
		{
			name: paste
			modifier: control_shift
			keycode: char_v
			mode: emacs
			event: { edit: pastecutbufferbefore }
		}
	]
}

# use ~/projetos/pessoal/nincat/nincat.nu
# nincat random (glob '~/projetos/pessoal/nincat/data.json').0
