--- @since 25.5.31
--- @sync entry

local function setup(self, opts) self.open_multi = opts.open_multi end

local function entry(self)
	local h = cx.active.current.hovered
	if not h then return end

	if h.cha.is_dir then
		-- Safely navigate into the directory
		ya.emit("enter", {})
	else
		-- Open files while preserving multi-selection (hovered = false)
		ya.emit("open", { hovered = false })
	end
end

return { entry = entry, setup = setup }
