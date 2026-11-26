--- @since 25.5.31
--- Mouse interactions plugin for Yazi

--- @class YaziMouseModifiers
--- @field shift? boolean
--- @field ctrl? boolean
--- @field alt? boolean

--- @class YaziMouseEvent
--- @field is_left boolean
--- @field modifiers? YaziMouseModifiers

--- @class YaziEntity
--- @field _file? fs__File
--- @field click fun(self: YaziEntity, event: YaziMouseEvent, up: boolean)
--- @global Entity
Entity = Entity

local M = {
	options = {
		double_click = {
			enable = true,
			delay = 300,
		},
		shift_click = {
			enable = true,
		},
	},
}

function M:setup(opts)
	opts = opts or {}
	if opts.double_click ~= nil then
		if type(opts.double_click) == "table" then
			if opts.double_click.enable ~= nil then
				self.options.double_click.enable = opts.double_click.enable
			end
			if opts.double_click.delay ~= nil then
				self.options.double_click.delay = opts.double_click.delay
			end
		elseif type(opts.double_click) == "boolean" then
			self.options.double_click.enable = opts.double_click
		end
	end

	if opts.shift_click ~= nil then
		if type(opts.shift_click) == "table" then
			if opts.shift_click.enable ~= nil then
				self.options.shift_click.enable = opts.shift_click.enable
			end
		elseif type(opts.shift_click) == "boolean" then
			self.options.shift_click.enable = opts.shift_click
		end
	end

	local shift_click = require("mouse.shift-click")
	local double_click = require("mouse.double-click")

	double_click.setup(self.options.double_click)

	--- @param event YaziMouseEvent
	--- @param up boolean
	function Entity:click(event, up)
		if up or not event.is_left then return end
		local clicked = self._file
		if not clicked then return end

		local mods = event.modifiers or {}

		if mods.shift and M.options.shift_click.enable then
			double_click.reset()
			shift_click.handle(clicked)
			return
		end

		if M.options.double_click.enable and double_click.handle(clicked) then
			return
		end

		shift_click.set_anchor(clicked.url)
		ya.emit("reveal", { clicked.url })
	end
end

return M
