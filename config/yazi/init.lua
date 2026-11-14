-- Shift+Click range selection for Yazi

local anchor_url = nil  -- stored as string for reliable comparison

-- Returns (count, url) for the current selection.
local function selection_info()
    local count, url = 0, nil
    for _, f in pairs(cx.active.selected) do
        count = count + 1
        url = tostring(f.url)
    end
    return count, url
end

function Entity:click(event, up)
    if up or not event.is_left then return end
    if not self._file then return end

    local clicked = self._file
    local mods = event.modifiers or {}

    if mods.shift then
        local count, sel_url = selection_info()
        local hovered = cx.active.current.hovered
        local hovered_url = hovered and tostring(hovered.url) or nil

        -- Anchor priority on shift-click:
        --   1. Exactly one file selected      -> that file is the anchor
        --   2. Nothing selected, hover != anchor -> adopt hover as anchor
        --   3. Everything else                -> keep the existing anchor
        if count == 1 then
            anchor_url = sel_url
        elseif count == 0 and hovered_url and hovered_url ~= anchor_url then
            anchor_url = hovered_url
        elseif not anchor_url then
            anchor_url = hovered_url
        end

        local files = cx.active.current.files
        local anchor_idx, clicked_idx

        for i, f in ipairs(files) do
            local u = tostring(f.url)
            if u == anchor_url then anchor_idx = i end
            if u == tostring(clicked.url) then clicked_idx = i end
        end

        if anchor_idx and clicked_idx then
            -- Put cursor on anchor, enter visual mode there,
            -- then move once to the clicked file to extend the range.
            ya.emit("escape", { select = true })
            ya.emit("reveal", { files[anchor_idx].url })
            ya.emit("visual_mode", {})
            local delta = clicked_idx - anchor_idx
            if delta ~= 0 then
                ya.emit("arrow", { delta })
            end
            ya.emit("escape", { visual = true })  -- commit, keep selection
        end
        return
    end

    -- Plain click: set anchor and reveal
    anchor_url = tostring(clicked.url)
    ya.emit("reveal", { clicked.url })
end

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
