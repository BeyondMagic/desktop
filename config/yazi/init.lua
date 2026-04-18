require("projects"):setup({
	event = {
		save = {
			enable = true,
			name = "project-saved",
		},
		load = {
			enable = true,
			name = "project-loaded",
		},
		delete = {
			enable = true,
			name = "project-deleted",
		},
		delete_all = {
			enable = true,
			name = "project-deleted-all",
		},
		merge = {
			enable = true,
			name = "project-merged",
		},
	},
	save = {
		method = "yazi",              -- yazi | lua
		yazi_load_event = "@projects-load", -- event name when loading projects in `yazi` method
		lua_save_path = "",           -- path of saved file in `lua` method, comment out or assign explicitly
		-- default value:
		-- windows: "%APPDATA%/yazi/state/projects.json"
		-- unix: "~/.local/state/yazi/projects.json"
	},
	last = {
		update_after_save = true,
		update_after_load = true,
		update_before_quit = false,
		load_after_start = false,
	},
	merge = {
		event = "projects-merge",
		quit_after_merge = false,
	},
	notify = {
		enable = true,
		title = "Projects",
		timeout = 3,
		level = "info",
	},
})
