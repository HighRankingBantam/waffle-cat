-- Waffle Cat editor QA: Lua
local Palette = {}
Palette.__index = Palette

function Palette:new(name, colors)
  assert(type(name) == "string", "palette name must be text")
  return setmetatable({ name = name, colors = colors or {} }, self)
end

function Palette:describe()
  local accent = self.colors.accent or "#c87d2a"
  return string.format("%s uses honey amber %s", self.name, accent)
end

local waffle_cat = Palette:new("Waffle Cat", {
  background = "#292025",
  foreground = "#fff4d8",
  accent = "#c87d2a",
})

print(waffle_cat:describe())
