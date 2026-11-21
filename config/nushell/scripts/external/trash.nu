#!/usr/bin/env -S nu --stdin
#
# João Farias © BeyondMagic <beyondmagic@mail.ru> 2026

const LOCAL_FS_TYPES = [
	ext4
	btrfs
	xfs
	f2fs
	vfat
	exfat
	ntfs
	ntfs3
	tmpfs
	zfs
	fuseblk
]

# Discover existing FreeDesktop XDG trash directories (home + local mounts).
def trash-dirs []: nothing -> table<dir: path, mount: string> {
	let xdg_data = ($env.XDG_DATA_HOME? | default ($env.HOME | path join ".local/share"))
	let home_trash = {
		dir: ($xdg_data | path join "Trash")
		mount: "/"
	}

	let uid = (^id -u | str trim)
	let volume_trashes = (
		open --raw /proc/mounts
		| lines
		| each {|line|
			let cols = ($line | split row " ")
			let fs_type = ($cols | get --optional 2 | default "")
			if $fs_type in $LOCAL_FS_TYPES {
				$cols | get --optional 1 | default "" | str replace --all '\040' ' '
			}
		}
		| compact
		| uniq
		| each {|mount|
			[
				{ dir: ($mount | path join $".Trash-($uid)"), mount: $mount }
				{ dir: ($mount | path join ".Trash" $uid), mount: $mount }
			]
		}
		| flatten
	)

	[ $home_trash ...$volume_trashes ]
	| uniq-by dir
	| where { ($in.dir | path type) == "dir" }
}

# Parse a single .trashinfo file into { datetime, original, path }, or null if missing.
def parse-trashinfo [
	info_file: path
	trash_dir: path
	mount: string
]: nothing -> any {
	let name = ($info_file | path basename | str replace --regex '\.trashinfo$' '')
	let trashed = ($trash_dir | path join "files" $name)

	# Use `path type` instead of `path exists` so trashed broken symlinks are included.
	if ($trashed | path type | is-empty) {
		return null
	}

	let content = (try { open --raw $info_file | lines } catch { [] })

	let raw_path = (
		$content
		| where { $in starts-with "Path=" }
		| get --optional 0
		| default ""
		| str replace --regex '^Path=' ''
	)
	let decoded = (try { $raw_path | url decode } catch { $raw_path })
	let original = if ($decoded | is-empty) {
		""
	} else if ($decoded starts-with "/") {
		$decoded
	} else {
		$mount | path join $decoded
	}

	let raw_date = (
		$content
		| where { $in starts-with "DeletionDate=" }
		| get --optional 0
		| default ""
		| str replace --regex '^DeletionDate=' ''
	)
	let deleted_at = (try { $raw_date | into datetime } catch { null })

	{
		datetime: $deleted_at
		original: $original
		path: $trashed
	}
}

# List trashed files with deletion time, original path, and current path in trash.
export def list [
	--sizes # Show the disk usage sizes of all items.
]: nothing -> any {
	let data = (
		trash-dirs
		| each {|entry|
			let info_dir = ($entry.dir | path join "info")
			if ($info_dir | path type) != "dir" {
				return []
			}

			let info_files = (
				try {
					ls --all $info_dir
					| where name ends-with ".trashinfo"
					| get name
				} catch {
					[]
				}
			)

			$info_files | par-each {|info_file|
				parse-trashinfo $info_file $entry.dir $entry.mount
			}
		}
		| flatten
		| compact
	)

	if ($data | is-empty) {
		return []
	}

	if not $sizes {
		return ($data | sort-by datetime --reverse)
	}

	$data
	| par-each {|row|
		let sz = (try { du $row.path | select apparent physical | first } catch { { apparent: 0B, physical: 0B } })
		$row | merge $sz
	}
	| sort-by physical apparent
}

# Permanently delete trashed files (all, older than a duration, or piped from `list`).
export def clear [
	--force (-f)           # Delete without asking for confirmation.
	--older-than: duration # Only delete items deleted at least this long ago.
	--dry-run (-n)         # Return matching items without deleting them.
]: any -> any {
	let piped = $in
	let from_pipe = (($piped | describe) != "nothing")

	mut targets = if $from_pipe {
		$piped
	} else {
		list
	}

	if ($older_than | is-not-empty) {
		let cutoff = ((date now) - $older_than)
		$targets = ($targets | where {|row|
			($row.datetime? | is-not-empty) and ($row.datetime <= $cutoff)
		})
	}

	let full_clear = (not $from_pipe) and ($older_than | is-empty)
	let has_orphans = if $full_clear and ($targets | is-empty) {
		(trash-dirs | any {|entry|
			let has_sub = ([ "files" "info" ] | any {|sub|
				let dir = ($entry.dir | path join $sub)
				($dir | path type) == "dir" and (try { ls --all $dir | is-not-empty } catch { false })
			})
			let has_ds = (($entry.dir | path join "directorysizes" | path type) == "file")
			$has_sub or $has_ds
		})
	} else {
		false
	}

	if ($targets | is-empty) and not $has_orphans {
		if $dry_run {
			return []
		}
		return
	}

	if $dry_run {
		return $targets
	}

	if not $force {
		let count = ($targets | length)
		let prompt = if $has_orphans {
			"Permanently clear orphaned trash entries? [y/N]: "
		} else {
			$"Permanently delete ($count) trashed item\(s\)? [y/N]: "
		}
		let answer = (input $prompt | str trim | str lowercase)
		if $answer not-in [ "y" "yes" ] {
			print "Aborted."
			return
		}
	}

	if $full_clear {
		for entry in (trash-dirs) {
			for sub in [ "files" "info" ] {
				let dir = ($entry.dir | path join $sub)
				if ($dir | path type) == "dir" {
					let leftover = (try { ls --all $dir | get name } catch { [] })
					if ($leftover | is-not-empty) {
						$leftover | chunks 200 | each {|batch| ^rm -rf ...$batch } | ignore
					}
				}
			}

			let dirsizes = ($entry.dir | path join "directorysizes")
			if ($dirsizes | path type) == "file" {
				^rm -f $dirsizes
			}
		}
	} else {
		$targets
		| each {|row|
			let trashed = $row.path
			let info_file = ($trashed | path dirname | path dirname | path join "info" $"($trashed | path basename).trashinfo")
			[ $trashed $info_file ]
		}
		| flatten
		| chunks 200
		| each {|batch| ^rm -rf ...$batch }
		| ignore
	}
}
