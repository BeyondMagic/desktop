--- Shift+Click range selection for Yazi
local M = {
	anchor_url = nil,
}

-- Returns (count, url) for the current selection.
local function selection_info()
	local count, url = 0, nil
	for _, f in pairs(cx.active.selected) do
		count = count + 1
		url = tostring(f.url)
	end
	return count, url
end

function M.set_anchor(url)
	M.anchor_url = tostring(url)
end

function M.handle(file)
	local clicked = file
	local count, sel_url = selection_info()
	local hovered = cx.active.current.hovered
	local hovered_url = hovered and tostring(hovered.url) or nil

	-- Anchor priority on shift-click:
	--   1. Exactly one file selected      -> that file is the anchor
	--   2. Nothing selected, hover != anchor -> adopt hover as anchor
	--   3. Everything else                -> keep the existing anchor
	if count == 1 then
		M.anchor_url = sel_url
	elseif count == 0 and hovered_url and hovered_url ~= M.anchor_url then
		M.anchor_url = hovered_url
	elseif not M.anchor_url then
		M.anchor_url = hovered_url
	end

	local files = cx.active.current.files
	local anchor_idx, clicked_idx

	for i, f in ipairs(files) do
		local u = tostring(f.url)
		if u == M.anchor_url then anchor_idx = i end
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
end

return M
