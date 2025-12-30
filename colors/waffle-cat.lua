local colors = {
	base00 = "#292025", -- darker bg, gutters/mode text
	base01 = "#3a2d32", -- main bg (Normal/StatusLine)
	base02 = "#4a3a40", -- selection/visual bg
	base03 = "#7a6a60", -- comments/subtle borders
	base04 = "#b6a78f", -- dim fg (tabs/statusline)
	base05 = "#efb159", -- fg accent (operators/menus)
	base06 = "#f7dd9b", -- main fg (Normal)
	base07 = "#fff3cf", -- bright fg (unused)
	base08 = "#834f36", -- errors/identifiers
	base09 = "#ff8c68", -- numbers/command/search
	base0a = "#f6ff40", -- types/labels/search
	base0b = "#a4a900", -- strings/additions
	base0c = "#ffbe55", -- specials/hints/insert
	base0d = "#a4a900", -- functions/info/visual
	base0e = "#e88f37", -- keywords/statements
	base0f = "#e5d0dc", -- extra accent (unused)
}

vim.cmd("highlight clear")
vim.g.colors_name = "waffle-cat"
vim.o.background = "dark"
vim.o.termguicolors = true

local function hi(group, opts)
	vim.api.nvim_set_hl(0, group, opts)
end

local function apply_statusline_highlights()
	hi("StatusLine", { fg = colors.base06, bg = colors.base01 })
	hi("StatusLineNC", { fg = colors.base04, bg = colors.base01 })
	hi("ModeMsg", { fg = colors.base00, bg = colors.base05, bold = true })
	hi("MsgArea", { fg = colors.base06, bg = colors.base01 })
	hi("MsgSeparator", { fg = colors.base02, bg = colors.base01 })
	hi("lualine_a_normal", { fg = colors.base00, bg = colors.base05, bold = true })
	hi("lualine_a_insert", { fg = colors.base00, bg = colors.base0c, bold = true })
	hi("lualine_a_command", { fg = colors.base00, bg = colors.base09, bold = true })
	hi("lualine_a_visual", { fg = colors.base00, bg = colors.base0d, bold = true })
	hi("lualine_a_replace", { fg = colors.base00, bg = colors.base08, bold = true })
	hi("lualine_b_normal", { fg = colors.base06, bg = colors.base02 })
	hi("lualine_b_insert", { fg = colors.base06, bg = colors.base02 })
	hi("lualine_b_command", { fg = colors.base06, bg = colors.base02 })
	hi("lualine_b_visual", { fg = colors.base06, bg = colors.base02 })
	hi("lualine_b_replace", { fg = colors.base06, bg = colors.base02 })
	hi("lualine_c_normal", { fg = colors.base04, bg = colors.base01 })
	hi("lualine_c_insert", { fg = colors.base04, bg = colors.base01 })
	hi("lualine_c_command", { fg = colors.base04, bg = colors.base01 })
	hi("lualine_c_visual", { fg = colors.base04, bg = colors.base01 })
	hi("lualine_c_replace", { fg = colors.base04, bg = colors.base01 })
	hi("MiniStatuslineModeNormal", { fg = colors.base00, bg = colors.base05, bold = true })
	hi("MiniStatuslineModeInsert", { fg = colors.base00, bg = colors.base0c, bold = true })
	hi("MiniStatuslineModeCommand", { fg = colors.base00, bg = colors.base09, bold = true })
	hi("MiniStatuslineModeVisual", { fg = colors.base00, bg = colors.base0d, bold = true })
	hi("MiniStatuslineModeReplace", { fg = colors.base00, bg = colors.base08, bold = true })
	hi("MiniStatuslineInactive", { fg = colors.base04, bg = colors.base01 })
end

local statusline_group = vim.api.nvim_create_augroup("WaffleCatStatusline", { clear = true })
local function apply_statusline_overrides()
	vim.defer_fn(function()
		apply_statusline_highlights()
	end, 20)
end
vim.api.nvim_create_autocmd("ColorScheme", {
	group = statusline_group,
	pattern = "waffle-cat",
	callback = apply_statusline_overrides,
})
vim.api.nvim_create_autocmd("User", {
	group = statusline_group,
	pattern = "VeryLazy",
	callback = apply_statusline_overrides,
})

hi("Normal", { fg = colors.base06, bg = colors.base01 })
hi("Command", { fg = colors.base00, bg = colors.base09 })
hi("Insert", { fg = colors.base00, bg = colors.base0c })
hi("NormalFloat", { fg = colors.base05, bg = colors.base01 })
hi("FloatBorder", { fg = colors.base03, bg = colors.base01 })
hi("Cursor", { fg = colors.base00, bg = colors.base05 })
hi("CursorLine", { bg = colors.base01 })
hi("CursorColumn", { bg = colors.base01 })
hi("CursorLineNr", { fg = colors.base06, bg = colors.base01 })
hi("LineNr", { fg = colors.base03, bg = colors.base00 })
hi("SignColumn", { fg = colors.base04, bg = colors.base00 })
hi("ColorColumn", { bg = colors.base01 })
hi("VertSplit", { fg = colors.base02 })
hi("WinSeparator", { fg = colors.base02 })
apply_statusline_highlights()
hi("TabLine", { fg = colors.base04, bg = colors.base01 })
hi("TabLineSel", { fg = colors.base06, bg = colors.base02 })
hi("TabLineFill", { fg = colors.base03, bg = colors.base01 })
hi("Visual", { bg = colors.base02 })
hi("Search", { fg = colors.base00, bg = colors.base0a })
hi("IncSearch", { fg = colors.base00, bg = colors.base09 })
hi("MatchParen", { fg = colors.base0a, bg = colors.base02 })
hi("Pmenu", { fg = colors.base05, bg = colors.base01 })
hi("PmenuSel", { fg = colors.base06, bg = colors.base02 })
hi("PmenuSbar", { bg = colors.base01 })
hi("PmenuThumb", { bg = colors.base03 })
hi("Folded", { fg = colors.base04, bg = colors.base01 })
hi("FoldColumn", { fg = colors.base03, bg = colors.base00 })
hi("DiffAdd", { fg = colors.base0b, bg = colors.base01 })
hi("DiffChange", { fg = colors.base0d, bg = colors.base01 })
hi("DiffDelete", { fg = colors.base08, bg = colors.base01 })
hi("DiffText", { fg = colors.base0a, bg = colors.base02 })

hi("Comment", { fg = colors.base03, italic = true })
hi("Constant", { fg = colors.base09 })
hi("String", { fg = colors.base0b })
hi("Character", { fg = colors.base0b })
hi("Number", { fg = colors.base09 })
hi("Boolean", { fg = colors.base09 })
hi("Float", { fg = colors.base09 })
hi("Identifier", { fg = colors.base08 })
hi("Function", { fg = colors.base0d })
hi("Statement", { fg = colors.base0e })
hi("Conditional", { fg = colors.base0e })
hi("Repeat", { fg = colors.base0e })
hi("Label", { fg = colors.base0a })
hi("Operator", { fg = colors.base05 })
hi("Keyword", { fg = colors.base0e })
hi("Exception", { fg = colors.base08 })
hi("PreProc", { fg = colors.base0a })
hi("Include", { fg = colors.base0d })
hi("Define", { fg = colors.base0e })
hi("Macro", { fg = colors.base0e })
hi("Type", { fg = colors.base0a })
hi("StorageClass", { fg = colors.base0a })
hi("Structure", { fg = colors.base0a })
hi("Typedef", { fg = colors.base0a })
hi("Special", { fg = colors.base0c })
hi("SpecialChar", { fg = colors.base0c })
hi("Tag", { fg = colors.base0a })
hi("Delimiter", { fg = colors.base05 })
hi("SpecialComment", { fg = colors.base03, italic = true })
hi("Underlined", { fg = colors.base0d, underline = true })
hi("Todo", { fg = colors.base0a, bg = colors.base01, bold = true })
hi("Error", { fg = colors.base08, bold = true })

hi("DiagnosticError", { fg = colors.base08 })
hi("DiagnosticWarn", { fg = colors.base09 })
hi("DiagnosticInfo", { fg = colors.base0d })
hi("DiagnosticHint", { fg = colors.base0c })
hi("DiagnosticOk", { fg = colors.base0b })
hi("DiagnosticUnderlineError", { underline = true, sp = colors.base08 })
hi("DiagnosticUnderlineWarn", { underline = true, sp = colors.base09 })
hi("DiagnosticUnderlineInfo", { underline = true, sp = colors.base0d })
hi("DiagnosticUnderlineHint", { underline = true, sp = colors.base0c })

hi("SpellBad", { underline = true, sp = colors.base08 })
hi("SpellCap", { underline = true, sp = colors.base0d })
hi("SpellLocal", { underline = true, sp = colors.base0c })
hi("SpellRare", { underline = true, sp = colors.base0a })
