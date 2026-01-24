---@diagnostic disable: undefined-global

local modules = {
	'commands.show_non_text_lines',
}

for _, module_name in ipairs(modules) do
	local ok, module = pcall(require, module_name)

	if not ok then
		vim.api.nvim_echo(
			{
				{ ('Failed to load autocmd module: %s').format(module_name) }
			},
			true,
			{
				err = true
			}
		)
	else
		local setup = module and module.setup
		if type(setup) == 'function' then
			setup()
		end
	end
end
