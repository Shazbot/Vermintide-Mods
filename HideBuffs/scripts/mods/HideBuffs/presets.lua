local mod = get_mod("HideBuffs")

local pl = require'pl.import_into'()

mod.simple_ui = get_mod("SimpleUI")

--- Get current game resolution.
mod.get_current_resolution = function()
	return mod.get_string_resolution({ UIResolution() })
end

--- Get resolution in format 0000x0000 from a table {res_x, res_y}.
mod.get_string_resolution = function(table_res)
	return string.format("%sx%s", tostring(table_res[1]), tostring(table_res[2]))
end

--- Get all presets for a resolution.
mod.get_presets_for_resolution = function(resolution)
	return mod.presets:filter(
			function(preset)
				return mod.get_string_resolution(preset.screen_resolution) == resolution
			end)
end

--- Get player name from a preset.
mod.get_name_from_preset = function(preset)
	return preset.player_name
end

--- Activate a preset.
mod.apply_preset = function(preset)
	Application.set_user_setting("use_custom_hud_scale", preset.use_custom_hud_scale)
	Application.set_user_setting("hud_clamp_ui_scaling", preset.hud_clamp_ui_scaling)

	local hud_scale = preset.hud_scale
	if UISettings.hud_scale ~= hud_scale then
		Application.set_user_setting("hud_scale", hud_scale)
		UISettings.hud_scale = hud_scale
	end

	for setting_name, value in pairs( preset.settings ) do
		mod:set(setting_name, value, true)
	end

	-- settings names missing from the preset
	local missing_settings = pl.tablex.pairmap(function(k,_)
		if preset.settings[k] ~= nil then
			return nil,nil
		end
		return k
	end, mod.setting_defaults)

	for _, setting_name_missing in ipairs( missing_settings ) do
		mod:set(setting_name_missing, mod.setting_defaults[setting_name_missing], true)
	end

	-- refresh UI
	UPDATE_RESOLUTION_LOOKUP(true, UISettings.hud_scale * 0.01)

	mod:pcall(function()
		local ingame_ui = Managers.matchmaking._ingame_ui
		local ingame_hud = ingame_ui.ingame_hud

		local components_array = ingame_hud._components_array
		local currently_visible_components = ingame_hud._currently_visible_components
		for i = 1, #components_array, 1 do
			local component = components_array[i]
			local component_name = component.name

			if component.set_dirty and currently_visible_components[component_name] then
				component:set_dirty(true)
			end
		end
	end)
end

mod.presets_window_size = {350, 250}
mod.presets_window_position = { 0, 0 }

mod.create_presets_window = function()
	mod.presets_window = mod.simple_ui:create_window("presets", mod.presets_window_position, mod.presets_window_size)

	mod.presets_window.position = mod.presets_window_position

	mod.presets_window:create_title("presets_title", "UI Tweaks Presets", 40)

	local presets_close_button = mod.presets_window:create_close_button("presets_close_button")
	presets_close_button.anchor = "top_right"

	local revert_button = mod.presets_window:create_button("revert_button",
		{0, 30},
		{100, 45},
		"middle_bottom",
		"Revert")
	revert_button.on_click = function()
		mod.apply_preset(mod.user_preset)

		mod.reload_presets_window()
	end
	revert_button.tooltip = "Revert"
		.."\nRevert to state when the chat/presets window was first opened."
		.."\nTo revert to state when the game was started choose that from the presets."
		.."\nIf using 1440p try out 1080p presets and play with turning Limit UI Scaling on/off in game options."
		.."\nIf you notice any UI artifacts after applying a preset they are likely to resolve upon new level load."
		.."\nOpening and closing the game menu with ESC also forces a UI redraw."
		.."\nYou can stop this window from showing in the mod options."

	mod.valid_presets = mod.get_presets_for_resolution(mod.preset_resolution)
	mod.valid_presets:insert(1, mod.empty_preset)
	mod.valid_presets:insert(2, mod.local_preset)
	mod.valid_presets:insert(3, mod.defaults_preset)
	mod.valid_presets:splice(4, mod.local_presets:values())

	local indexed_preset_names = pl.tablex.index_map(mod.valid_presets:map(mod.get_name_from_preset))
	local presets_dropdown = mod.presets_window:create_dropdown(
		"presets_dropdown",
		{0, 50+50},
		{220, 25},
		"middle_top",
		indexed_preset_names,
		nil,
		1
	)
	presets_dropdown.on_index_changed = function(dropdown)
		local preset_to_apply = mod.valid_presets[dropdown.index]

		if preset_to_apply == mod.empty_preset then
			return
		end

		mod.apply_preset(preset_to_apply)
	end

	local indexed_resolutions = pl.tablex.index_map(mod.resolutions)
	local resolution_index = pl.tablex.find(mod.resolutions, mod.preset_resolution)
	local resolutions_dropdown = mod.presets_window:create_dropdown(
		"resolutions_dropdown",
		{0, 50},
		{150, 35},
		"middle_top",
		indexed_resolutions,
		nil,
		resolution_index
	)

	mod.presets_window.on_hover_enter = function(window)
		window:focus()
	end

	mod.reset_presets_window_position()

	mod.presets_window:init()

	-- on_index_changed go after init or we get into a stack overflow loop
	resolutions_dropdown.on_index_changed = function(dropdown)
		mod.preset_resolution = mod.resolutions[dropdown.index]
		mod.reload_presets_window()
	end

	mod.presets_window.transparent = false
	mod.presets_window.theme.color[1] = 100

	mod.reset_presets_window_position()
end

mod.reset_presets_window_position = function()
	local screen_width, screen_height = UIResolution()
	local presets_window_width = mod.presets_window.size[1]
	local presets_window_height = mod.presets_window.size[2]
	mod.presets_window_position[2] = screen_height - presets_window_height
	mod.presets_window_position[1] = screen_width/2 - presets_window_width/2
end

mod.reload_presets_window = function()
	mod.destroy_presets_window()
	mod.create_presets_window()
end

mod.destroy_presets_window = function()
	if mod.presets_window then
		mod.presets_window:destroy()
		mod.presets_window = nil
	end
end

--- Open UI on chat open.
mod.on_chat_gui_update = function(chat_gui)
	if not Managers.state.game_mode
	or not mod:get(mod.SETTING_NAMES.SHOW_PRESETS_UI)
	or not mod.simple_ui
	then
		mod.destroy_presets_window()
		return
	end

	if Managers.state.game_mode:level_key() ~= "inn_level"
	and not mod:get(mod.SETTING_NAMES.SHOW_PRESETS_UI_OUTSIDE_KEEP)
	then
		mod.destroy_presets_window()
		return
	end

	if not chat_gui.chat_focused then
		mod.destroy_presets_window()
	elseif mod.was_ingame_entered and not mod.presets_window then
		mod.user_preset = mod.get_preset_data()
		mod.reload_presets_window()
	end
end

--- Populate some variables once Ingame.
table.insert(mod.update_funcs, function() mod.presets_update_func() end)
mod.presets_update_func = function()
	if not mod.was_ingame_entered then
		return
	end

	--- Create a table of resolutions from all the resolutions in presets + game resolution.
	if not mod.resolutions then
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
	end

	--- Current resolution in the resolution dropdown.
	mod.preset_resolution = mod.preset_resolution or mod.get_current_resolution()

	--- Preset with settings as they were at the start of the game.
	if not mod.local_preset then
		mod.local_preset = mod.get_preset_data()
		mod.local_preset.player_name = "At game start"
	end

	--- Preset with UI Tweaks defaults.
	if not mod.defaults_preset then
		mod.defaults_preset = table.clone(mod.local_preset)
		mod.defaults_preset.settings = table.clone(mod.setting_defaults)
		mod.defaults_preset.player_name = "Default"
		mod.defaults_preset.hud_scale = 100
		mod.defaults_preset.hud_clamp_ui_scaling = true
		mod.defaults_preset.use_custom_hud_scale = false
	end

	--- Empty preset to serve as a default dropdown option.
	if not mod.empty_preset then
		mod.empty_preset = table.clone(mod.local_preset)
		mod.empty_preset.settings = {}
		mod.empty_preset.player_name = "Current"
	end
end

