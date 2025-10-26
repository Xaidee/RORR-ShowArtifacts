-- ShowArtifacts
-- Xaidee
mods["ReturnsAPI-ReturnsAPI"].auto{ namespace = "show_artifacts", mp = true }

PATH = _ENV["!plugins_mod_folder_path"]

---@class Settings: table
---@field OFFSET_X number
---@field OFFSET_Y number
---@field SPRITE_SCALE number
---@field SPRITE_SPACING number
---@field DRAW_BLACK_SHADOW boolean
---@field COLORS {key: number }
Settings = DefaultSettings

---@type Settings
DefaultSettings = {
	OFFSET_X = 108,
	OFFSET_Y = 44,
	SPRITE_SCALE = 0.6,
	SPRITE_SPACING = 32,
	DRAW_BLACK_SHADOW = true,
	COLORS = {
		SHADOW = Color.from_hsv(345, 11, 29),
		OUTLINE_DARK = Color.from_hsv(225, 16, 10),
		OUTLINE_LIGHT = Color.from_hsv(0, 0, 42),
	},
}

-- Draws artifacts from right-to-left with index being used as an offset
local draw_artifact = function(index, artifact, view)
	local sprite = artifact.loadout_sprite_id
	if not sprite or sprite < 0 then
		return
	end
	local scale = Settings.SPRITE_SCALE
	local x = GM.round(
		view.x
			+ view.width
			- (
				Settings.OFFSET_X
				+ Settings.SPRITE_SPACING * (index - 1) * scale
			)
	)
	local y = GM.round(view.y + Settings.OFFSET_Y)

	-- Draw BLACK shadow
	if Settings.DRAW_BLACK_SHADOW then
		GM.draw_sprite_ext(sprite, 2, x, y + 1, scale, scale, 0, Color.BLACK, 1)
	end

	-- Draw main sprite with layered fog effects
	local fogSettings = {
		{ color = Settings.COLORS.SHADOW, y_offset = 1 },
		{ color = Settings.COLORS.SHADOW, x_offset = 1, y_offset = 1 },
		{ color = Settings.COLORS.SHADOW, x_offset = -1, y_offset = 1 },
		{ color = Settings.COLORS.OUTLINE_DARK, y_offset = 2 },
		{ color = Settings.COLORS.OUTLINE_LIGHT },
	}

	for _, setting in ipairs(fogSettings) do
		GM.gpu_set_fog(true, setting.color, 0, 0)
		GM.draw_sprite_ext(
			sprite,
			0,
			x + (setting.x_offset or 0),
			y + (setting.y_offset or 0),
			scale,
			scale,
			0,
			Color.WHITE,
			1
		)
	end
	GM.gpu_set_fog(false, Settings.COLORS.OUTLINE_LIGHT, 0, 0)
end

local init = function()

	-- HUD draw callback to display active artifacts (same place difficulty HUD is drawn)
	Callback.add(Callback.ON_HUD_DRAW, function()
		if not Global.__run_exists then
			return
		end

		local artifacts = Artifact.find_all(true, Artifact.Property.ACTIVE)

		local view = {
			x = Global.___view_l_x,
			y = Global.___view_l_y,
			width = Global.___view_l_w,
		}
		if not view.x or not view.y or not view.width then
			return
		end
		local artifact_count = 0
		for _, artifact in ipairs(artifacts) do
			artifact_count = artifact_count + 1
			draw_artifact(artifact_count, artifact, view)
		end
	end)

	require("config")
	---Load config if it's there
	if (load_config() ~= nil) then
		Settings = load_config()
	end

	-- once we have loaded everything, enable hot/live reloading.
	-- this variable may be used by content code to make sure it behaves correctly when hotloading
	HOTRELOADING = true
end
Initialize.add(init)

if HOTRELOADING then
	init()
end

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
]]
--
