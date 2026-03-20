swayimg = swayimg or {}

----------------------------------
-- UX
----------------------------------

-- app_id has no Lua API equivalent in swayimg.
swayimg.enable_overlay(false)
swayimg.imagelist.set_order("mtime")

----------------------------------
-- UI
----------------------------------

swayimg.text.set_font("Noto Sans CJK JP")
swayimg.text.set_size(12)
swayimg.gallery.set_window_color(0x00000000)
swayimg.gallery.set_border_color(0x00000000)
swayimg.viewer.set_window_background(0x00000000)
swayimg.viewer.set_image_background(0x00000000)

----------------------------------
-- Helper functions
----------------------------------

local function shell_quote(value)
	return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function with_current_image(fn)
	local image = swayimg.viewer.get_image()
	if not image or not image.path then
		return
	end
	fn(image.path)
end

----------------------------------
-- Hotkeys
----------------------------------

-- q: Closes the viewer.
swayimg.viewer.on_key("q", function()
	swayimg.exit()
end)

-- Delete: Deletes the current image file.
swayimg.viewer.on_key("Delete", function()
	with_current_image(function(path)
		os.remove(path)
	end)
end)

-- Ctrl+p: Copies the file path of the current image to the clipboard.
swayimg.viewer.on_key("Ctrl+p", function()
	with_current_image(function(path)
		os.execute("printf %s " .. shell_quote(path) .. " | wl-copy")
	end)
end)

-- Ctrl+c: Copies the current image file to the clipboard.
swayimg.viewer.on_key("Ctrl+c", function()
	with_current_image(function(path)
		os.execute("cat " .. shell_quote(path) .. " | wl-copy")
	end)
end)

-- Ctrl+k: Adds the current image file to the favorites list in organize-fav.nu.
swayimg.viewer.on_key("Ctrl+k", function()
	with_current_image(function(path)
		os.execute("printf %s " .. shell_quote(path) .. " | organize-fav.nu")
	end)
end)

-- Ctrl+r: Opens the current image file in rnote.
swayimg.viewer.on_key("Ctrl+r", function()
	with_current_image(function(path)
		os.execute("rnote " .. shell_quote(path))
	end)
end)

-- Ctrl+g: Opens the current image file in GIMP.
swayimg.viewer.on_key("Ctrl+g", function()
	with_current_image(function(path)
		os.execute("gimp " .. shell_quote(path))
	end)
end)

-- Ctrl+i: Opens the current image file in Inkscape.
swayimg.viewer.on_key("Ctrl+i", function()
	with_current_image(function(path)
		os.execute("inkscape " .. shell_quote(path))
	end)
end)

-- Ctrl+w: Opens the current image file in aww.
swayimg.viewer.on_key("Ctrl+w", function()
	with_current_image(function(path)
		os.execute("awww img " .. shell_quote(path))
	end)
end)

-- Shift+greater: Flips the current image vertically.
swayimg.viewer.on_key("Shift+greater", function()
	swayimg.viewer.flip_vertical()
end)

-- Shift+less: Flips the current image horizontally.
swayimg.viewer.on_key("Shift+less", function()
	swayimg.viewer.flip_horizontal()
end)
