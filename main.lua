-- ShowArtifacts
-- Xaidee
mods["RoRRModdingToolkit-RoRR_Modding_Toolkit"].auto(true)

PATH = _ENV["!plugins_mod_folder_path"]

DEBUG = true

local offset_x = 108
local offset_y = 44

local artifact_count = 0

function debug_print(...)
	if DEBUG then print(...) end
end

-- Draws artifacts from right-to-left with index being used as an offset
local draw_artifact = function(index, artifact)
	local cx, cy = Global.___view_l_x + Global.___view_l_w, Global.___view_l_y
	local sprite = artifact.loadout_sprite_id
	local scale = 0.6
	local x = gm.round(cx-(offset_x + 32 * (index - 1) * scale))
	local y = gm.round(cy + offset_y)
	debug_print("Attempting to draw sprite for "..artifact.namespace.."-"..artifact.identifier.." ("..sprite..")".." at ", x, y)
	-- (sprite, subimg, x, y, xscale, yscale, rot, colour, alpha)
	gm.draw_sprite_ext(sprite, 2, x, y + 1, scale, scale, 0, Color.BLACK, 1)
	gm.gpu_set_fog(true, Color.from_hsv(345, 11, 29), 0, 0)
	gm.draw_sprite_ext(sprite, 0, x, y + 1, scale, scale, 0, Color.WHITE, 1)
	gm.draw_sprite_ext(sprite, 0, x + 1, y + 1, 0.6, 0.6, 0, Color.WHITE, 1)
	gm.draw_sprite_ext(sprite, 0, x- 1, y + 1, 0.6, 0.6, 0, Color.WHITE, 1)

	gm.gpu_set_fog(true, Color.from_hsv(225, 16, 10), 0, 0)
	gm.draw_sprite_ext(sprite, 0, x, y + 2, 0.6, 0.6, 0, Color.WHITE, 1)

	gm.gpu_set_fog(true, Color.from_hsv(0, 0, 42), 0, 0)
	gm.draw_sprite_ext(sprite, 0, x, y, 0.6, 0.6, 0, Color.WHITE, 1)

	gm.gpu_set_fog(false, Color.from_hsv(0, 0, 42), 0, 0)

end

Callback.add(Callback.TYPE.onHUDDraw, "ShowArtifactHUDDraw", function()
	if gm.variable_global_get("__run_exists") then
		local artifacts, exist = Artifact.find_all()
		if exist then
			artifact_count = 0
			for _,artifact in pairs(artifacts) do
				if artifact.active then
					artifact_count = artifact_count + 1
					draw_artifact(artifact_count, artifact)
				end
			end
		end
	end
end)

--[[ Credits to azzy for helping me with the rendering functions to create the cool display ^-^ below is the complete code they provided me via the RORR Modding Discord that I based the above code off of!
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
