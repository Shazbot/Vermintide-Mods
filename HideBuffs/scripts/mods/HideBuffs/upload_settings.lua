local mod = get_mod("HideBuffs")

local pl = require'pl.import_into'()

mod.post_cb = function (self, success, code, headers, data) -- luacheck: no unused
	if not success then
		mod:echo("Failed to upload. Server possibly offline.")
		return
	end
	
	if code ~= 201 then
		mod:echo("Upload failed!")
		return
	end
	
	mod:echo("Upload successful! I greatly appreciate you doing this!")
end

mod.upload_settings = function(...)
	mod:pcall(function(...)
		mod:echo("Uploading...")
		
		local comment = ""
		local args={...}
		if #args ~= 0 then
			comment = pl.stringx.join(' ', pl.List(args):map(pl.stringx.strip))
		end
		
		local url = "http://188.226.166.223/ui_tweaks/upload"
		
		local screen_resolution = Application.user_setting("screen_resolution")
		local hud_scale = Application.user_setting("hud_scale")
		local use_custom_hud_scale = Application.user_setting("use_custom_hud_scale")
		local hud_clamp_ui_scaling = Application.user_setting("hud_clamp_ui_scaling")
		
		local local_player = Managers.player:local_player()
		local player_name = local_player._cached_name or local_player:name()
		
		local mods_settings = Application.user_setting("mods_settings")
		if mods_settings then
			local mod_settings = mods_settings[mod:get_name()]
			if mod_settings then
				local cloned_settings = table.clone(mod_settings)
				
				local body = {
					comment = comment,
					settings = cloned_settings,
					screen_resolution = screen_resolution,
					hud_scale = hud_scale,
					use_custom_hud_scale = use_custom_hud_scale,
					hud_clamp_ui_scaling = hud_clamp_ui_scaling,
					player_name = player_name,
				}
				local content_json = cjson.encode(body)
				
				Managers.curl:post(url, content_json, {}, callback(mod, "post_cb"), nil, {})
			end
		end
	end, ...)
end

mod:command("ut_upload_settings", "Upload settings", function(...) mod.upload_settings(...) end)
