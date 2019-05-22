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

mod.get_mod_settings = function()
	local mods_settings = Application.user_setting("mods_settings")
	if mods_settings then
		local mod_settings = mods_settings[mod:get_name()]
		if mod_settings then
			return table.clone(mod_settings)
		end
	end

	return nil
end

mod.get_preset_data = function()
	local screen_resolution = Application.user_setting("screen_resolution")
	local hud_scale = Application.user_setting("hud_scale")
	local use_custom_hud_scale = Application.user_setting("use_custom_hud_scale")
	local hud_clamp_ui_scaling = Application.user_setting("hud_clamp_ui_scaling")

	local cloned_settings = mod.get_mod_settings()
	if cloned_settings then
		return {
			settings = cloned_settings,
			screen_resolution = screen_resolution,
			hud_scale = hud_scale,
			use_custom_hud_scale = use_custom_hud_scale,
			hud_clamp_ui_scaling = hud_clamp_ui_scaling,
			player_name = "Anonymous",
			comment = "",
		}
	end

	return nil
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

		local preset_data = mod.get_preset_data()
		if preset_data then
			preset_data.comment = comment

			local content_json = cjson.encode(preset_data)

			Managers.curl:post(url, content_json, {}, callback(mod, "post_cb"), nil, {})
		end
	end, ...)
end

mod.upload_setting_info =
	"Upload UI Tweaks"
	.."\nUploads your UI Tweaks settings so I can create a preset others can use."
	.."\nWrite your name so I know whom to credit or feel free to stay anonymous."
	.."\nTo add your comment type:"
	.."\n/ut_upload_settings Author is prop joe. This is comment text. Blah blah."
mod:command("ut_upload_settings", mod.upload_setting_info, function(...) mod.upload_settings(...) end)
