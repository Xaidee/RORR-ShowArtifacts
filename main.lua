-- ShowArtifacts
-- Xaidee
mods["RoRRModdingToolkit-RoRR_Modding_Toolkit"].auto(true)

PATH = _ENV["!plugins_mod_folder_path"]

-- Useful for live debugging, i.e. use of debug_print over print
-- Set to false automatically by ./create_package.sh when zipping
DEBUG = true

local CONFIG = {
	OFFSET_X = 108,
	OFFSET_Y = 44,
	SPRITE_SCALE = 0.6,
	SPRITE_SPACING = 32
}

local COLORS = {
	SHADOW = Color.from_hsv(345, 11, 29),
	OUTLINE_DARK = Color.from_hsv(225, 16, 10),
	OUTLINE_LIGHT = Color.from_hsv(0, 0, 42),
	WHITE = Color.WHITE,
	BLACK = Color.Black
}

local offset_x = 108
local offset_y = 44

-- Debug print utility
function debug_print(...)
	if DEBUG then print(...) end
end

-- Draws artifacts from right-to-left with index being used as an offset
local draw_artifact = function(index, artifact, view)
	local sprite = artifact.loadout_sprite_id
	if not sprite or sprite < 0 then
		debug_print(string.format("Invalid sprite for %s-%s", artifact.namespace, artifact.identifier))
		return
	end
	local scale = CONFIG.SPRITE_SCALE
	local x = gm.round(view.x + view.width - (CONFIG.OFFSET_X + CONFIG.SPRITE_SPACING * (index - 1) * scale))
	local y = gm.round(view.y + CONFIG.OFFSET_Y)

	debug_print(string.format("Drawing %s-%s (sprite %d) at (%d, %d)", artifact.namespace, artifact.identifier, sprite, x, y))

	-- Draw shadow
	gm.draw_sprite_ext(sprite, 2, x, y + 1, scale, scale, 0, COLORS.BLACK, 1)

	-- Draw main sprite with layered fog effects
	local fog_settings = {
		{ color = COLORS.SHADOW,                       y_offset = 1 },
		{ color = COLORS.OUTLINE_DARK,  x_offset = 1,  y_offset = 1 },
		{ color = COLORS.OUTLINE_DARK,  x_offset = -1, y_offset = 1 },
		{ color = COLORS.OUTLINE_DARK,                 y_offset = 2 },
		{ color = COLORS.OUTLINE_LIGHT,                             },
	}

	for _, setting in ipairs(fog_settings) do
		gm.gpu_set_fog(true, setting.color, 0, 0)
		gm.draw_sprite_ext(sprite, 0, x + (setting.x_offset or 0), y + (setting.y_offset or 0), scale, scale, 0, COLORS.WHIE, 1)
	end
	gm.gpu_set_fog(false, COLORS.OUTLINE_LIGHT, 0, 0)
end

-- HUD draw callback to display active artifacts (same place difficulty HUD is drawn)
Callback.add(Callback.TYPE.onHUDDraw, "ShowArtifactHUDDraw", function()
	if gm.variable_global_get("__run_exists") then return end

	local artifacts, exist = Artifact.find_all()
	if not exist then return end

	local view = {
		x = Global.___view_l_x,
		y = Global.___view_l_y,
		width = Global.___view_l_w
	}
	local artifact_count = 0
	for _,artifact in pairs(artifacts) do
		if artifact.active then
			artifact_count = artifact_count + 1
			draw_artifact(artifact_count, artifact, view)
		end
	end
end)

--[[
--Credits to azzy for helping me with the rendering functions to create the cool display ^-^
--below is the complete code they provided me via the RORR Modding Discord that I based the above code off of!
Callback.add(Callback.TYPE.onPlayerHUDDraw, "ArtifactDisplay", function(actor, x, y)
	local arr = GM.variable_global_get("class_artifact")
	local scale = GM.variable_global_get("current_hud_scale")
	local artifact_num = 1
	local xx = 445 * 2 / scale
	local yy = 413 * 2 / scale
	if scale <= 1 then
		xx = xx + 35
		yy = yy + 127
	end

	for i = 1, #arr do
		local class = arr[i]
		if type(class) == "table" then
			local artifact = class[1].."-"..class[2]
			local sprite = Artifact.find(artifact).loadout_sprite_id
			if Artifact.find(artifact).active then
				gm.gpu_set_fog(true, Color.from_hsv(345, 11, 29), 0, 0)
				gm.draw_sprite_ext(sprite, 0, x + xx - 16 * artifact_num, y - yy + 1, 0.6, 0.6, 0, Color.WHITE, 1)
				gm.draw_sprite_ext(sprite, 0, x + xx - 16 * artifact_num + 1, y - yy + 1, 0.6, 0.6, 0, Color.WHITE, 1)
				gm.draw_sprite_ext(sprite, 0, x + xx - 16 * artifact_num - 1, y - yy + 1, 0.6, 0.6, 0, Color.WHITE, 1)

				gm.gpu_set_fog(true, Color.from_hsv(225, 16, 10), 0, 0)
				gm.draw_sprite_ext(sprite, 0, x + xx - 16 * artifact_num, y - yy + 2, 0.6, 0.6, 0, Color.WHITE, 1)

				gm.gpu_set_fog(true, Color.from_hsv(0, 0, 42), 0, 0)
				gm.draw_sprite_ext(sprite, 0, x + xx - 16 * artifact_num, y - yy, 0.6, 0.6, 0, Color.WHITE, 1)

				gm.gpu_set_fog(false, Color.from_hsv(0, 0, 42), 0, 0)

				artifact_num = artifact_num + 1
			end
		end
	end
end)
]]--
