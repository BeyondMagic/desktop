return {
	"azratul/live-share.nvim",
	dependencies = {
		"jbyuki/instant.nvim",
	},
	config = function()
		vim.g.instant_username = "magic"
		require("live-share").setup({
			port_internal = 8080,
			max_attempts = 40, -- 10 seconds
			service_url = "/tmp/service.url", -- Path to the file where the URL from serveo.net will be stored
			-- service = "serveo.net"
			service = "nokey@localhost.run", -- Service to use, options are serveo.net or localhost.run
		})
	end
}
