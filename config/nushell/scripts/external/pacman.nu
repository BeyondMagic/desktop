export def main []: nothing -> any {
	$env.LANG = 'en_GB.UTF-8' # Ensure consistent output format

	^pacman -Qi
	| str replace --all --regex `\n                  ` ' '
	| split row --regex `\nName`
	| each { "Name" + $in }
	| each {
		$in
		| lines
		| where { ($in | str length) > 0 }
		| split column --regex `\s+:\s+` name value
		| transpose --header-row
	}
	| flatten
	| rename --column {
		NameName: name, # This column comes from the first item in the split, since it doesn't have a preceding newline.
		Name: name,
		Version: version,
		Description: description,
		Architecture: architecture,
		URL: url,
		Licenses: licenses,
		Groups: groups,
		Provides: provides,
		'Depends On': depends_on,
		'Optional Deps': 'optional_deps',
		'Required By': required_by,
		'Optional For': optional_for,
		'Conflicts With': conflicts_with,
		Replaces: replaces,
		'Installed Size': installed_size,
		Packager: packager,
		'Build Date': build_date,
		'Install Date': install_date,
		'Install Reason': install_reason,
		'Install Script': install_script,
		'Validated By': validated_by
	}
	| upsert installed_size { $in | into filesize }
	| upsert build_date { $in | into datetime --format '%Y年%m月%d日 %H時%M分%S秒' }
	| upsert install_date { $in | into datetime --format '%Y年%m月%d日 %H時%M分%S秒' }
}
