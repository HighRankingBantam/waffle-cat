-- Deliberate Base16 reduction of palette/waffle-cat-base24.yaml.
local colors = {
	base00 = "#292025", -- cocoa background
	base01 = "#362d30", -- lighter background
	base02 = "#6b5650", -- selection background
	base03 = "#a58c82", -- comments and muted text
	base04 = "#a58c82", -- dark foreground
	base05 = "#fff4d8", -- default foreground
	base06 = "#fff4d8", -- light foreground
	base07 = "#fffaf0", -- bright foreground
	base08 = "#cf7358", -- errors and deletions
	base09 = "#c8964b", -- constants and warnings
	base0a = "#c8964b", -- types and search
	base0b = "#9fad68", -- strings and additions
	base0c = "#9eb8b2", -- specials and hints
	base0d = "#c87d2a", -- functions and information
	base0e = "#c98c97", -- keywords and statements
	base0f = "#644b26", -- embedded and deprecated syntax
}

vim.cmd("highlight clear")
vim.g.colors_name = "waffle-cat"
vim.o.background = "dark"
vim.o.termguicolors = true

local function hi(group, opts)
	vim.api.nvim_set_hl(0, group, opts)
end

hi("Normal", { fg = colors.base05, bg = colors.base00 })
hi("NormalFloat", { fg = colors.base05, bg = colors.base01 })
hi("FloatBorder", { fg = colors.base03, bg = colors.base01 })
hi("Cursor", { fg = colors.base00, bg = colors.base07 })
hi("CursorLine", { bg = colors.base01 })
hi("CursorColumn", { bg = colors.base01 })
hi("CursorLineNr", { fg = colors.base0d, bg = colors.base00, bold = true })
hi("LineNr", { fg = colors.base03, bg = colors.base00 })
hi("SignColumn", { fg = colors.base04, bg = colors.base00 })
hi("ColorColumn", { bg = colors.base01 })
hi("VertSplit", { fg = colors.base02 })
hi("WinSeparator", { fg = colors.base02 })
hi("StatusLine", { fg = colors.base00, bg = colors.base05 })
hi("StatusLineNC", { fg = colors.base03, bg = colors.base01 })
hi("ModeMsg", { fg = colors.base0d, bold = true })
hi("MsgArea", { fg = colors.base05, bg = colors.base00 })
hi("MsgSeparator", { fg = colors.base02, bg = colors.base01 })
hi("TabLine", { fg = colors.base03, bg = colors.base01 })
hi("TabLineSel", { fg = colors.base05, bg = colors.base02 })
hi("TabLineFill", { fg = colors.base03, bg = colors.base01 })
hi("Visual", { bg = colors.base02 })
hi("Search", { fg = colors.base00, bg = colors.base0a })
hi("IncSearch", { fg = colors.base00, bg = colors.base09 })
hi("MatchParen", { fg = colors.base0a, bg = colors.base02 })
hi("Pmenu", { fg = colors.base05, bg = colors.base01 })
hi("PmenuSel", { fg = colors.base05, bg = colors.base02 })
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
hi("Todo", { fg = colors.base00, bg = colors.base0a, bold = true })
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
