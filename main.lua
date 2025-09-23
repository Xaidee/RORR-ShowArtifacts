-- ShowArtifacts
-- Xaidee
mods["RoRRModdingToolkit-RoRR_Modding_Toolkit"].auto(true)

PATH = _ENV["!plugins_mod_folder_path"]

local Settings = {
	DEBUG = true,
	OFFSET_X = 108,
	OFFSET_Y = 44,
	SPRITE_SCALE = 0.6,
	SPRITE_SPACING = 32,
	DRAW_BLACK_SHADOW = true,
	COLORS = {
		SHADOW = Color.from_hsv(345, 11, 29),
		OUTLINE_DARK = Color.from_hsv(225, 16, 10),
		OUTLINE_LIGHT = Color.from_hsv(0, 0, 42),
		WHITE = Color.WHITE,
		BLACK = Color.BLACK
	}
}

local LogLevel = {
	INFO = 1,
	DEBUG = 2,
	WARN = 3,
	ERROR = 4
}

-- Custom log utility for printing
function log(level, message, ...)
	-- Only log if DEBUG is enabled or level is ERROR/WARN
	if not Settings.DEBUG and level ~= LogLevel.ERROR and level ~= LogLevel.WARN then return end

	-- Prefix based on log level
	local prefix = ""
	if level == LogLevel.INFO then
		prefix = "[INFO] "
	elseif level == LogLevel.DEBUG then
		prefix = "[DEBUG] "
	elseif level == LogLevel.WARN then
		prefix = "[WARN] "
	elseif level == LogLevel.ERROR then
		prefix = "[ERROR] "
	end

	-- Handle formatted vs. non-formatted messages
	local final_message
	if select("#", ...) > 0 then
		-- Format the message if additional argument are not provided
		final_message = prefix .. string.format(message, ...)
	else
		-- Use message as-is
		final_message = prefix .. tostring(message)
	end

	print(final_message)
end

-- Draws artifacts from right-to-left with index being used as an offset
local draw_artifact = function(index, artifact, view)
	local sprite = artifact.loadout_sprite_id
	if not sprite or sprite < 0 then
		log(LogLevel.WARN, string.format("Invalid sprite for %s-%s", artifact.namespace, artifact.identifier))
		return
	end
	local scale = Settings.SPRITE_SCALE
	local x = gm.round(view.x + view.width - (Settings.OFFSET_X + Settings.SPRITE_SPACING * (index - 1) * scale))
	local y = gm.round(view.y + Settings.OFFSET_Y)

	log(LogLevel.INFO, "Drawing %s-%s (sprite %d) at (%d, %d)", artifact.namespace, artifact.identifier, sprite, x, y)

	-- Draw BLACK shadow
	if Settings.DRAW_BLACK_SHADOW then gm.draw_sprite_ext(sprite, 2, x, y + 1, scale, scale, 0, Settings.COLORS.BLACK, 1) end

	-- Draw main sprite with layered fog effects
	local fog_Settings = {
		{ color = Settings.COLORS.SHADOW,                       y_offset = 1 },
		{ color = Settings.COLORS.OUTLINE_DARK,  x_offset = 1,  y_offset = 1 },
		{ color = Settings.COLORS.OUTLINE_DARK,  x_offset = -1, y_offset = 1 },
		{ color = Settings.COLORS.OUTLINE_DARK,                 y_offset = 2 },
		{ color = Settings.COLORS.OUTLINE_LIGHT,                             },
	}

	for _, setting in ipairs(fog_Settings) do
		gm.gpu_set_fog(true, setting.color, 0, 0)
		gm.draw_sprite_ext(sprite, 0, x + (setting.x_offset or 0), y + (setting.y_offset or 0), scale, scale, 0, Color.WHITE, 1)
	end
	gm.gpu_set_fog(false, Settings.COLORS.OUTLINE_LIGHT, 0, 0)
end

-- HUD draw callback to display active artifacts (same place difficulty HUD is drawn)
log(LogLevel.INFO, "Registering callback ShowArtifactHUDDraw")
Callback.add(Callback.TYPE.onHUDDraw, "ShowArtifactHUDDraw", function()
	log(LogLevel.INFO, "Running ShowArtifactHUDDraw")
	if gm.variable_global_get("__run_exists") then
		log(LogLevel.ERROR, "Run doesn't seem to exist!!")
		--return
	end

	local artifacts, exist = Artifact.find_all()
	if not exist then
		log(LogLevel.ERROR, "Artifact.find_all() returned an empty table!")
		return
	end

	local view = {
		x = Global.___view_l_x,
		y = Global.___view_l_y,
		width = Global.___view_l_w
	}
	local artifact_count = 0
	for _,artifact in pairs(artifacts) do
		log(LogLevel.INFO, "Checking if %s is active", artifact.identifier)
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
