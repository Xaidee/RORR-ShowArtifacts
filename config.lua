local modOptions = ModOptions.new()

local draw_shadow = modOptions:add_checkbox("draw_shadow")
---@return boolean
draw_shadow:add_getter(function()
	return Settings.DRAW_BLACK_SHADOW
end)
---@param value boolean
draw_shadow:add_setter(function(value)
	Settings.DRAW_BLACK_SHADOW = value
end)
