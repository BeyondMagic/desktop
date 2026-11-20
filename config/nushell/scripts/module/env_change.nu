# ~/.config/nushell/config.nu (or a sourced module)
#
# João Farias © BeyondMagic <beyondmagic@mail.ru> 2026

# Initialize the PWD hook as an empty list if it doesn't exist.
$env.config.hooks.env_change.PWD = $env.config.hooks.env_change.PWD? | default []

# Hook: record every directory change via the shared dir-history module.
$env.config.hooks.env_change.PWD ++= [{|before, after|
	if ($after | is-empty) {
		return
	}

	use ./dir-history.nu
	dir-history record $after
}]
