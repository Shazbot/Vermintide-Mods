local mod = get_mod("SpawnTweaks")

local pl = require'pl.import_into'()

mod.simple_ui = get_mod("SimpleUI")

--- List of mutators, a way to have them always sorted.
mod.mutators_list = {
	"true_solo",
	"no_bots",
	"restart_map",
	"disable_spawns",
	"skeet_shot",
	"bomberman",
}

mod.mutators_info = {
	true_solo = {
		name = "True Solo",
		desc = "True Solo is the challenge of finishing a map solo without bot help."
	},
	skeet_shot = {
		name = "Skeet Shot",
		desc = "Disables everything but assassins and ups their numbers."
			.."\nConsider enabling the Infinite Ammo option in the mod options."
			.."\nValues need to be tweaked!"
	},
	disable_spawns = {
		name = "Disable Spawns",
		desc = "Disable all spawns, for Creature Spawner practice or exploring the map."
	},
	no_bots = {
		name = "No Bots",
		desc = "Remove bots from the game."
	},
	restart_map = {
		name = "Restart Map",
		desc = "Restart the map on defeat, instead of going to the inn."
			.."\nTo force a return to inn when with other people you can write /st_win in chat.",
	},
	bomberman = {
		name = "Bomberman",
		desc = "Infinite supply of bombs to kill enemies and teammates!"
			.."\nIdea by dieaready."
	},
}

mod.mutators = {
	true_solo = {
		bosses = 3,
		boss_dmg_multiplier = 200,
		LORD_DMG_MULTIPLIER = 200,
		disable_patrols = true,
		NO_BOTS = true,
		RESTART_ON_DEFEAT = true,
	},
	skeet_shot = {
		skaven_ratling_gunner_toggle = true,
		disable_fixed_spawns = true,
		disable_patrols = true,
		skaven_pack_master_toggle = true,
		specials = 3,
		hordes = 2,
		always_specials = true,
		spawn_cooldown_max = 45,
		spawn_cooldown_min = 25,
		skaven_warpfire_thrower_toggle = true,
		ambients = 2,
		fixed_event_specials = true,
		specials_no_threat_delay = true,
		chaos_corruptor_sorcerer_toggle = true,
		max_specials = 8,
		skaven_poison_wind_globadier_toggle = true,
		max_same_specials = 8,
		chaos_vortex_sorcerer_toggle = true,
		bosses = 2,
		disable_roaming_patrols = true,
	},
	disable_spawns = {
		disable_fixed_spawns = true,
		disable_patrols = true,
		specials = 2,
		hordes = 2,
		ambients = 2,
		fixed_event_specials = true,
		bosses = 2,
		disable_roaming_patrols = true,
	},
	no_bots = {
		NO_BOTS = true,
	},
	restart_map = {
		RESTART_ON_DEFEAT = true,
	},
	bomberman = {
		PLAYER_ITEM_SLOT_MELEE_DMG_MULTIPLIER = 0,
		PLAYER_FF_DMG_MULTIPLIER = 400,
		PLAYER_ITEM_SLOT_BOMB_DMG_MULTIPLIER = 50,
		KEEP_GIVING_BOMBS = true,
		PLAYER_ITEM_SLOT_RANGED_DMG_MULTIPLIER = 0,
		KEEP_GIVING_FIRE_BOMBS = true,
	}
}

mod.mutators_enabled = {}
for mut_name, _ in pairs( mod.mutators ) do
	mod.mutators_enabled[mut_name] = false
end

--- Refresh the UI summary of currently active settings.
mod.refresh_summary = function()
	mod:pcall(function()
		local st = get_mod("SpawnTweaks")
		local diffs = st.get_diffs()
		for _, summary in ipairs( mod.summary_labels ) do
			summary.text = ""
		end
		for i, diff_line in ipairs( pl.stringx.splitlines(diffs) ) do
			local summary = mod.summary_labels[i]
			if summary then
				summary.text = diff_line
			end
		end
	end)
end

--- Reset all Spawn Tweaks settings to default values.
mod.reset_settings = function()
	for setting_name, value in pairs( mod.setting_defaults ) do
		mod:set(setting_name, value, true)
	end
end

--- Return newline-delimited string of Spawn Tweaks settings
--- that differ from default value.
mod.get_diffs = function()
	local diffs = ""
	for setting_name, default in pairs( mod.setting_defaults ) do
		local current_value = mod:get(setting_name)
		if current_value ~= nil and current_value ~= default then
			diffs = diffs
				..mod.setting_names_localized[setting_name]
				..": "
				..(type(current_value) == "number" and current_value or tostring(current_value))
				.."   ("
				..tostring(default)
				..")"
				.."\n"
		end
	end

	return diffs
end

--- Enable mutators that have all their settings enabled.
mod.enabled_eligible_mutators = function()
	for mutator_name, mutator_settings in pairs( mod.mutators ) do
		local all_settings_enabled = true
		for setting_name, value in pairs( mutator_settings ) do
			local current_value = mod:get(setting_name)
			if current_value ~= value then
				all_settings_enabled = false
				break
			end
		end
		if all_settings_enabled then
			mod.mutators_enabled[mutator_name] = true
			mod.mutator_chks[mutator_name].value = true
		end
	end
end

--- Enable or disable a mutator.
mod.set_mutator = function(mutator_name, enabled, dont_recurse)
	for setting_name, value in pairs( mod.mutators[mutator_name] ) do
		local new_value = value

		if not enabled then
			-- if the setting is manually changed in the mod options don't reset it
			local current_value = mod:get(setting_name)
			if current_value == value then
				new_value = mod.setting_defaults[setting_name]
			end
		end
		mod:set(setting_name, new_value, true)
	end

	mod.mutators_enabled[mutator_name] = enabled

	-- reapply other enabled mutators, but don't cause recursion
	if not dont_recurse then
		for mut_name, is_enabled in pairs( mod.mutators_enabled ) do
			if mut_name ~= mutator_name and is_enabled then
				mod.set_mutator(mut_name, is_enabled, true)
			end
		end
	end
end

mod.create_window = function()
	mod.mutator_chks = {}
	mod.summary_labels = {}

	local screen_width, screen_height = UIResolution()
	local window_size = {514, 310}
	local window_position = {screen_width/2 - window_size[1]/2, screen_height/2 - window_size[2]/2}

	mod.main_window = mod.simple_ui:create_window("spawn_tweaks", window_position, window_size)

	mod.main_window.position = {screen_width/2 - window_size[1]/2-1, screen_height/2+108-10}

	local pos_x = -10

	for i, mutator_name in ipairs( mod.mutators_list ) do
		if i == 4 then
			pos_x = 170
		end
		local row = i/3 > 1 and i%4 + 1 or i
		local mutator_chk = mod.main_window:create_checkbox(mutator_name.."_ckh", {pos_x+30, window_size[2]-35-20-10-(row*50)}, {40, 40})
		mutator_chk.on_value_changed = function()
			local mut_enabled = mutator_chk.value
			mod.set_mutator(mutator_name, mut_enabled)

			mod.refresh_summary()
		end
		mod.mutator_chks[mutator_name] = mutator_chk
		mutator_chk.value = mod.mutators_enabled[mutator_name]

		local mutator_localized_name = mod.mutators_info[mutator_name].name
		mutator_chk.text = mutator_localized_name
		mutator_chk.tooltip = mutator_localized_name.."\n"..mod.mutators_info[mutator_name].desc
	end

	local reset_button = mod.main_window:create_button("reset_button", {235+135, window_size[2]-35-10-40}, {80, 30}, nil, "Reset All")
	reset_button.on_click = function()
		for _, mutator_ckh in pairs( mod.mutator_chks ) do
			mutator_ckh.value = false
			mutator_ckh:on_value_changed()
		end
		mod.reset_settings()
		mod.refresh_summary()
	end
	reset_button.tooltip =
		"Reset All"
		.."\nReset all Spawn Tweaks setting to defaults, meaning vanilla game difficulty."

	local title_label = mod.main_window:create_label("title_label", {230-40, window_size[2]-35-10}, {120, 40}, nil, "Spawn Tweaks")
	title_label.tooltip =
		"Spawn Tweaks"
		.."\nMenu to enable mutators that work via Spawn Tweaks settings."
		-- .."\nPost a comment on mod workshop page or message me on discord if you have any other mutator ideas."

	local summary_title = mod.main_window:create_label("summary_title", {5+30+40+155-20, window_size[2]-35-35-35-10-50-70-10-5}, {80, 40}, nil, "Summary")
	summary_title.tooltip =
		"Summary"
		.."\nList of all the changes Spawn Tweaks is currently doing. Default value is in brackets."
		.."\nThis summary will always correctly show the currently enabled values."
		.."\nClick Reset All if you don't want anything active."

	for i = 1, 30 do
		local summary = mod.main_window:create_label("summary_"..i, {5+30+10+10+155, window_size[2]-30-35-20-35-10-50-70-5+2-(28*i)}, {100, 40}, nil, "")
		table.insert(mod.summary_labels, summary)
	end

	mod.main_window.on_hover_enter = function(window)
		window:focus()
	end

	mod.main_window:init()

	mod.main_window.transparent = true

	mod.refresh_summary()

	mod.enabled_eligible_mutators()
end

mod.reload_windows = function()
	mod.destroy_windows()
	mod.create_window()
end

mod.destroy_windows = function()
	if mod.main_window then
		mod.main_window:destroy()
		mod.main_window = nil
	end
end

mod:hook(StartGameWindowAdventure, "draw", function(func, self, ...)
	mod:pcall(function()
		self._widgets_by_name.adventure_texture.style.texture_id.color[1] = 0
		self._widgets_by_name.adventure_title_divider.style.texture_id.color[1] = 0
		self._widgets_by_name.description_text.style.text.text_color[1] = 0
		self._widgets_by_name.description_text.style.text_shadow.text_color[1] = 0
		self._widgets_by_name.adventure_title.offset[2] = -420
	end)
	return func(self, ...)
end)

mod:hook(StartGameWindowMutator, "draw", function(func, self, ...)
	mod:pcall(function()
		self._widgets_by_name.mutator_texture.style.texture_id.color[1] = 0
		self._widgets_by_name.mutator_title_divider.style.texture_id.color[1] = 0
		self._widgets_by_name.description_text.style.text.text_color[1] = 0
		self._widgets_by_name.description_text.style.text_shadow.text_color[1] = 0
		self._widgets_by_name.mutator_title.offset[2] = -420
	end)
	return func(self, ...)
end)

mod:hook(StartGameWindowMission, "draw", function(func, self, ...)
	mod:pcall(function()
		self._widgets_by_name.map_texture.style.texture_id.color[1] = 0
		self._widgets_by_name.mission_title_divider.style.texture_id.color[1] = 0
		self._widgets_by_name.description_text.style.text.text_color[1] = 0
		self._widgets_by_name.description_text.style.text_shadow.text_color[1] = 0
		self._widgets_by_name.mission_title.offset[2] = -420
	end)
	return func(self, ...)
end)

mod:hook(StartGameWindowTwitchLogin, "draw", function(func, self, ...)
	mod:pcall(function()
		self._widgets_by_name.twitch_title_divider.style.texture_id.color[1] = 255
		self._widgets_by_name.description_text.content.text = "Spawn Tweaks menu not shown here\nbut it's still active."
	end)
	return func(self, ...)
end)

for _, obj in ipairs( { StartGameWindowAdventure, StartGameWindowMutator, StartGameWindowMission } ) do
	mod:hook_safe(obj, "on_enter", function()
		mod:reload_windows()
	end)
	mod:hook(obj, "on_exit", function(func, self)
		func(self)
		mod:destroy_windows()
	end)
end
