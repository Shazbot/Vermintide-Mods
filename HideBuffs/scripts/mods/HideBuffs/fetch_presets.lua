local mod = get_mod("HideBuffs")

local pl = require'pl.import_into'()

mod.presets_page = 1

mod.fetch_presets_cb = function (self, success, code, headers, data, userdata) -- luacheck: no unused
	if not success then
		return
	end

	if code ~= 200 then
		return
	end

	mod:echo("Presets fetched!")

	mod.fetched_snippets = pl.List(cjson.decode(data)):map(function(snippet_data) return snippet_data.blob end)

	--- Make all the hotkey options nil so they use the default i.e. {}.
	local hotkey_setting_names = pl.List{
		"HIDE_HUD_HOTKEY",
		"PLAYER_UI_CUSTOM_BUFFS_DPS_HOTKEY",
		"PLAYER_UI_CUSTOM_BUFFS_DPS_TIMED_HOTKEY",
	}
	for _, preset in ipairs( mod.fetched_snippets ) do
		for _, hotkey_setting_name in ipairs( hotkey_setting_names ) do
			preset.settings[hotkey_setting_name] = nil
		end
		preset.settings["SHOW_PRESETS_UI"] = true
	end

	-- number the Anonymous players
	local anon_index = 1
	for _, preset in ipairs( mod.fetched_snippets ) do
		if preset.player_name == "Anonymous" then
			preset.player_name = "Anonymous "..anon_index
			anon_index = anon_index + 1
		end
	end

	local resolutions = pl.Map(pl.Set(mod.presets:map(
		function(preset)
			local res = preset.screen_resolution
			return mod.get_string_resolution(res)
		end)
		:append(mod.get_current_resolution())
	)):keys()

	local split_resolutions = resolutions:map(function(res) return pl.stringx.split(res, 'x') end)
	table.sort(split_resolutions, function(res1, res2)
		return res1[1]*res1[2] >= res2[1]*res2[2]
	end)
	mod.resolutions = split_resolutions:map(function(res)
			return mod.get_string_resolution(res)
		end)

	mod.set_presets_page(mod.presets_page)
end

mod.fetch_presets = function()
	mod:pcall(function()
		local url = "https://raw.githubusercontent.com/Shazbot/ui-tweaks-presets/master/presets.json"
		Managers.curl:get(url, {}, callback(mod, "fetch_presets_cb"), {}, {})
	end)
end

mod.set_presets_page = function(page_index)
	mod:pcall(function()
		if not page_index then
			mod:echo("Page number missing, for example:")
			mod:echo("/ut_preset_page 1")
			return
		end

		if not mod.fetched_snippets then
			mod:echo("Fetching presets...")
			mod.fetch_presets()
			mod.presets_page = page_index
			return
		end

		mod.presets = mod.fetched_snippets:slice((page_index-1)*40, (page_index)*40)
		for _, preset in ipairs( mod.presets ) do
			if preset.comment and preset.comment ~= "" then
				preset.player_name = preset.comment:sub(0, 20)
			end
		end

		mod:echo(string.format("Now showing presets page %s with %s presets!", page_index, #mod.presets))
	end)
end

mod:command("ut_preset_page", "Show presets at the page specified, e.g. /up_presets_page 1", function(...) mod.set_presets_page(...) end)
mod:command("ut_fetch_presets", "Fetch the presets.", function(...) mod.fetch_presets(...) end)
