local mod = get_mod("HideBuffs")

local pl = require'pl.import_into'()

mod.on_unload = function()
	mod.persistent.was_ingame_entered = mod.was_ingame_entered
end

mod.on_game_state_changed = function(status, state)
	if status == "enter" and state == "StateIngame" then
		mod.was_ingame_entered = true

		-- Load locally saved presets.
		Managers.save:auto_load(mod.local_presets_file_name, callback(mod, "cb_load_local_presets_done"), mod.force_local_save)
	end

	if mod.reset_custom_buff_counters then
		mod.reset_custom_buff_counters()
	end
end

mod.on_all_mods_loaded = function()
	-- NumericUI compatibility.
	-- Disable NumericUI hook that modifies widget definitions.
	-- We'll use hp and ammo values it calculates and stores into widgets content.
	local numeric_ui = get_mod("NumericUI")
	if numeric_ui then
		numeric_ui:hook_disable(UnitFramesHandler, "_create_unit_frame_by_type")
	end

	if mod:get(mod.SETTING_NAMES.SHOW_PRESETS_ADDED_WELCOME_MSG) then
		mod:echo("-------------------------- UI Tweaks --------------------------")
		mod:echo("Presets have been added to UI Tweaks. Open the chat to choose between them.")
		mod:echo("If you have an UI Tweaks configuration you'd like to share with others you can do so with /ut_upload_settings")
		mod:echo("You can stop this message from showing in the mod options.")
		if not get_mod("SimpleUI") then
			mod:echo("IMPORTANT: UI TWEAKS REQUIRES THE SIMPLE UI MOD AS A DEPENDENCY TO MANAGE PRESETS")
		end
	end
end

fassert(not mod.update, "Overwriting existing function!")
mod.update_funcs = {}
mod.update = function()
	for _, update_func in ipairs( mod.update_funcs ) do
		update_func()
	end
end

mod.on_setting_changed = function(setting_name)
	if setting_name == mod.SETTING_NAMES.HIDE_WEAPON_SLOTS then
		mod.change_slot_visibility = true
		mod.reposition_weapon_slots = true
	end

	if pl.List({
			mod.SETTING_NAMES.REPOSITION_WEAPON_SLOTS,
			mod.SETTING_NAMES.PLAYER_ITEM_SLOTS_SPACING,
			mod.SETTING_NAMES.PLAYER_ITEM_SLOTS_OFFSET_X,
			mod.SETTING_NAMES.PLAYER_ITEM_SLOTS_OFFSET_Y,
		}):contains(setting_name)
	then
		mod.reposition_weapon_slots = true
	end

	if pl.List({
			mod.SETTING_NAMES.TEAM_UI_OFFSET_X,
			mod.SETTING_NAMES.TEAM_UI_OFFSET_Y,
			mod.SETTING_NAMES.TEAM_UI_FLOWS_HORIZONTALLY,
			mod.SETTING_NAMES.TEAM_UI_SPACING,
			mod.SETTING_NAMES.TEAM_UI_PORTRAIT_SCALE,
		}):contains(setting_name)
	then
		mod.realign_team_member_frames = true
	end

	if pl.List({
			mod.SETTING_NAMES.PLAYER_UI_CUSTOM_BUFFS_AMMO_DURATION,
			mod.SETTING_NAMES.PLAYER_UI_CUSTOM_BUFFS_DMG_TAKEN_DURATION,
			mod.SETTING_NAMES.PLAYER_UI_CUSTOM_BUFFS_TEMP_HP_DURATION,
			mod.SETTING_NAMES.PLAYER_UI_CUSTOM_BUFFS_DPS_TIMED,
		}):contains(setting_name)
	then
		BuffTemplates.custom_dmg_taken.buffs[1].duration =
			mod:get(mod.SETTING_NAMES.PLAYER_UI_CUSTOM_BUFFS_DMG_TAKEN_DURATION)

		BuffTemplates.custom_temp_hp.buffs[1].duration =
			mod:get(mod.SETTING_NAMES.PLAYER_UI_CUSTOM_BUFFS_TEMP_HP_DURATION)

		BuffTemplates.custom_scavenger.buffs[1].duration =
			mod:get(mod.SETTING_NAMES.PLAYER_UI_CUSTOM_BUFFS_AMMO_DURATION)

		BuffTemplates.custom_dps_timed.buffs[1].duration =
			mod:get(mod.SETTING_NAMES.PLAYER_UI_CUSTOM_BUFFS_DPS_TIMED_DURATION)
	end

	if setting_name == mod.SETTING_NAMES.MINI_HUD_PRESET then
		mod.recreate_player_unit_frame = true
	end

	if setting_name == mod.SETTING_NAMES.BUFFS_FLOW_VERTICALLY
	or setting_name == mod.SETTING_NAMES.REVERSE_BUFF_DIRECTION
	or setting_name == mod.SETTING_NAMES.CENTERED_BUFFS
	or setting_name == mod.SETTING_NAMES.CENTERED_BUFFS_REALIGN then
		mod.realign_buff_widgets = true
		mod.reset_buff_widgets = true
	end

	if setting_name == mod.SETTING_NAMES.BUFFS_OFFSET_X
	or setting_name == mod.SETTING_NAMES.BUFFS_OFFSET_Y then
		mod.reset_buff_widgets = true
	end

	if setting_name == mod.SETTING_NAMES.SECOND_BUFF_BAR then
		if mod.buff_ui then
			mod.buff_ui:set_visible(mod:get(mod.SETTING_NAMES.SECOND_BUFF_BAR))
		end
	end

	if setting_name == mod.SETTING_NAMES.SECOND_BUFF_BAR_SIZE_ADJUST_X
	or setting_name == mod.SETTING_NAMES.SECOND_BUFF_BAR_SIZE_ADJUST_Y
	then
		mod.need_to_refresh_priority_bar = true
	end

	if setting_name == mod.SETTING_NAMES.HIDE_PICKUP_OUTLINES
	or setting_name == mod.SETTING_NAMES.HIDE_OTHER_OUTLINES
	then
		mod.reapply_pickup_ranges()
	end
end
