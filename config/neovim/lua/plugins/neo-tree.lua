-- File-tree manager.

-- Unless you are still migrating, remove the deprecated commands from v1.x
vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

-- If you want icons for diagnostic errors, you'll need to define them somewhere:
vim.fn.sign_define("DiagnosticSignError",
	{ text = " ", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn",
	{ text = " ", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo",
	{ text = " ", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint",
	{ text = "", texthl = "DiagnosticSignHint" })
-- NOTE: this is changed from v1.x, which used the old style of highlight groups
-- in the form "LspDiagnosticsSignWarning"

return {
	'nvim-neo-tree/neo-tree.nvim',
	dependencies = {
		"nvim-lua/plenary.nvim",
		"kyazdani42/nvim-web-devicons",    -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
		'saifulapm/neotree-file-nesting-config', -- add plugin as dependency. no need any other config or setup call
	},
	config = {
		close_if_last_window      = true, -- Close Neo-tree if it is the last window left in the tab
		popup_border_style        = "NC", -- "double", "none", "rounded", "shadow", "single" or "solid"
		enable_git_status         = true,
		enable_diagnostics        = true,

		-- popup_border_style is for input and confirmation dialogs.
		-- Configurtaion of floating window is done in the individual source sections.
		-- "NC" is a special style that works well with NormalNC set
		default_source            = "filesystem",
		git_status_async          = true,
		log_level                 = "info", -- "trace", "debug", "info", "warn", "error", "fatal"
		log_to_file               = false, -- true, false, "/path/to/file.log", use :NeoTreeLogs to show the file
		open_files_in_last_window = true, -- false                                                                = open files in top left window
		resize_timer_interval     = 100, -- in ms, needed for containers to redraw right aligned and faded content
		sort_case_insensitive     = true, -- used when sorting files and directories in the tree
		use_popups_for_input      = false, -- If false, inputs will use vim.ui.input() instead of custom floats.

		hide_root_node            = true,
		retain_hidden_root_indent = true,

		event_handlers            = {
			--  {
			--    event = "before_render",
			--    handler = function (state)
			--      -- add something to the state that can be used by custom components
			--    end
			--  },
			--  {
			--    event = "file_opened",
			--    handler = function(file_path)
			--      --auto close
			--      require("neo-tree").close_all()
			--    end
			--  },
			--  {
			--    event = "file_opened",
			--    handler = function(file_path)
			--      --clear search after opening a file
			--      require("neo-tree.sources.filesystem").reset_search()
			--    end
			--  },
			--  {
			--    event = "file_renamed",
			--    handler = function(args)
			--      -- fix references to file
			--      print(args.source, " renamed to ", args.destination)
			--    end
			--  },
			--  {
			--    event = "file_moved",
			--    handler = function(args)
			--      -- fix references to file
			--      print(args.source, " moved to ", args.destination)
			--    end
			--  },
			{
				event = "neo_tree_buffer_enter",
				handler = function()
					vim.cmd("set winbar=")
					vim.cmd("highlight CursorLine gui='bold'")
					vim.cmd("highlight CursorColumn guibg=NONE")
					--vim.cmd("set guicursor+=a:InvisibleCursor")
					--vim.cmd("highlight InvisibleCursor gui=reverse blend=100")
				end
			},
			{
				event = "neo_tree_buffer_leave",
				handler = function()
					--vim.cmd("set guicursor-=a:InvisibleCursor")
					vim.cmd("highlight CursorLine gui=NONE")
					vim.cmd("highlight CursorColumn guibg=" .. COLOUR.bg_2)
				end
			}
		},

		default_component_configs = {
			indent = {
				indent_size        = 2,
				padding            = 0, -- extra padding on left hand side
				-- indent guides
				with_markers       = false,
				indent_marker      = "│",
				last_indent_marker = "└",
				highlight          = "NeoTreeIndentMarker",
				-- expander config, needed for nesting files
				with_expanders     = true, -- if nil and file nesting is enabled, will enable expanders
				expander_collapsed = "",
				expander_expanded  = "",
				expander_highlight = "NeoTreeExpander",
			},
			icon = {
				folder_closed = "",
				folder_open   = "",
				folder_empty  = "-",
				default       = "",
			},
			modified = {
				symbol    = "「+ 」",
				highlight = "NeoTreeModified",
			},
			name = {
				trailing_slash        = true,
				use_git_status_colors = true,
			},
			git_status = {
				symbols = {
					-- Change type
					added     = "˖", -- or "✚", but this is redundant info if you use git_status_colors on the name
					modified  = "±", -- or "", but this is redundant info if you use git_status_colors on the name
					deleted   = "🗙", -- this can only be used in the git_status source
					renamed   = "", -- this can only be used in the git_status source
					-- Status type
					untracked = "",
					ignored   = "🛇",
					unstaged  = "·",
					staged    = "✓",
					conflict  = "",
				}
			},
		},
		renderers                 = {
			directory = {
				{ "indent" },
				{ "icon" },
				{ "current_filter" },
				{
					"container",
					width         = "100%",
					right_padding = 0,
					--max_width   = 60,
					content       = {
						{ "name",        zindex = 10 },
						-- {
						--   "symlink_target",
						--   zindex = 10,
						--   highlight = "NeoTreeSymbolicLinkTarget",
						-- },
						{ "clipboard",   zindex = 10 },
						{ "diagnostics", errors_only = true, zindex = 20, align = "right" },
					},
				},
			},
			file = {
				{ "indent" },
				{ "icon" },
				{
					"container",
					width         = "100%",
					right_padding = 0,
					--max_width   = 60,
					content       = {
						{
							"name",
							use_git_status_colors = true,
							zindex                = 10
						},
						-- {
						--   "symlink_target",
						--   zindex = 10,
						--   highlight = "NeoTreeSymbolicLinkTarget",
						-- },
						{ "clipboard",   zindex = 10 },
						{ "bufnr",       zindex = 10 },
						{ "modified",    zindex = 20, align = "right" },
						{ "diagnostics", zindex = 20, align = "right" },
						{ "git_status",  zindex = 20, align = "right" },
					},
				},
			},
		},
		window                    = { -- see https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/popup for
			-- possible options. These can also be functions that return these options.
			position = "left",  -- left, right, float, current
			width = 34,         -- applies to left and right positions
			popup = {           -- settings that apply to float position only
				size = {
					height = "80%",
					width = "50%",
				},
				position = "50%", -- 50% means center it
				-- you can also specify border here, if you want a different setting from
				-- the global popup_border_style.
			},
			-- Mappings for tree window. See `:h nep-tree-mappings` for a list of built-in commands.
			-- You can also create your own commands by providing a function instead of a string.
			mappings = {
				--["<space>"]       = "toggle_node",
				["<2-LeftMouse>"] = "open",
				["<cr>"]          = "open",
				["S"]             = "open_split",
				["s"]             = "open_vsplit",
				["t"]             = "open_tabnew",
				["C"]             = "close_node",
				["a"]             = "add",
				["A"]             = "add_directory",
				["d"]             = "delete",
				["r"]             = "rename",
				["y"]             = "copy_to_clipboard",
				["x"]             = "cut_to_clipboard",
				["p"]             = "paste_from_clipboard",
				["c"]             = "copy", -- takes text input for destination
				["m"]             = "move", -- takes text input for destination
				["q"]             = "close_window",
				["<Leader>e"]     = "close_window",
				["R"]             = "refresh",
				["?"]             = "show_help",
				["<"]             = "prev_source",
				[">"]             = "next_source",
			}
		},
		nesting_rules             = {},
		filesystem                = {
			filtered_items          = {
				visible         = false, -- when true, they will just be displayed differently than normal items
				hide_dotfiles   = true,
				hide_gitignored = false,
				hide_by_name    = {
					--".DS_Store",
					--"thumbs.db"
					--"node_modules"
				},
				never_show      = { -- remains hidden even if visible is toggled to true
					--".DS_Store",
					--"thumbs.db"
				},
			},
			find_by_full_path_words = true,
			bind_to_cwd             = true, -- true creates a 2-way binding between vim's cwd and neo-tree's root
			search_limit            = 50, -- max number of search results when using filters
			follow_current_file     = {
				enabled = true,    -- This will find and focus the file in the active buffer every
			},
			-- time the current file is changed while the tree is open.
			hijack_netrw_behavior   = "open_default", -- netrw disabled, opening a directory opens neo-tree
			-- in whatever position is specified in window.position
			-- "open_current",  -- netrw disabled, opening a directory opens within the
			-- window like netrw would, regardless of window.position
			-- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
			use_libuv_file_watcher  = false, -- This will use the OS level file watchers to detect changes
			-- instead of relying on nvim autocmd events.
			window                  = {
				mappings = {
					["<bs>"] = "navigate_up",
					["."] = "set_root",
					["H"] = "toggle_hidden",
					["/"] = "fuzzy_finder",
					--["D"] = "fuzzy_finder_directory",
					["f"] = "filter_on_submit",
					["<c-x>"] = "clear_filter",
					["[g"] = "prev_git_modified",
					["]g"] = "next_git_modified",
				}
			}
		},
		buffers                   = {
			show_unloaded = true,
			window = {
				mappings = {
					["bd"]   = "buffer_delete",
					["<bs>"] = "navigate_up",
					["."]    = "set_root",
				}
			},
		},
		git_status                = {
			window = {
				position = "float",
				mappings = {
					["A"]  = "git_add_all",
					["gu"] = "git_unstage_file",
					["ga"] = "git_add_file",
					["gr"] = "git_revert_file",
					["gc"] = "git_commit",
					["gp"] = "git_push",
					["gg"] = "git_commit_and_push",
				}
			}
		}
	},
}
