return {
	{
		"bjarneo/aether.nvim",
		name = "aether",
		priority = 1000,
		opts = {
			disable_italics = false,
			colors = {
				-- Monotone shades (base00-base07)
				base00 = "#292025", -- Default background
				base01 = "#7a6a60", -- Lighter background (status bars)
				base02 = "#b6a78f", -- Selection background
				base03 = "#7a6a60", -- Comments, invisibles
				base04 = "#efb159", -- Dark foreground
				base05 = "#f7dd9b", -- Default foreground
				base06 = "#fff3cf", -- Light foreground
				base07 = "#b6a78f", -- Light background

				-- Accent colors (base08-base0F)
				base08 = "#d66556", -- Variables, errors, red
				base09 = "#ff8c68", -- Integers, constants, orange
				base0A = "#f6ff40", -- Classes, types, yellow
				base0B = "#a4a900", -- Strings, green
				base0C = "#ffbe55", -- Support, regex, cyan
				base0D = "#c5a0b6", -- Functions, keywords, blue
				base0E = "#e5d0dc", -- Keywords, storage, magenta
				base0F = "#e88f37", -- Deprecated, brown/yellow
			},
		},
		config = function(_, opts)
			require("aether").setup(opts)
			vim.cmd.colorscheme("aether")

			-- Enable hot reload
			require("aether.hotreload").setup()
		end,
	},
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "aether",
		},
	},
}
