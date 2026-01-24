---@diagnostic disable: undefined-global

local modules = {
	'autocmd.session',
	'autocmd.save_path',
	-- 'autocmd.optimise',
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
