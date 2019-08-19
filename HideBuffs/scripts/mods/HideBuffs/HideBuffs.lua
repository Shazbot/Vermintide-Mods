local mod = get_mod("HideBuffs")

mod.vmf = get_mod("VMF")
mod.simple_ui = get_mod("SimpleUI")

mod.persistent = mod:persistent_table("persistent")

--- Keep track of player ammo and hp from Numeric UI for use in equipment_ui.
mod.numeric_ui_data = {}

mod.change_slot_visibility = mod:get(mod.SETTING_NAMES.HIDE_WEAPON_SLOTS)
mod.reposition_weapon_slots =
	mod.change_slot_visibility
	or mod:get(mod.SETTING_NAMES.REPOSITION_WEAPON_SLOTS) ~= 0

mod.hp_bar_width = 553
mod.ult_bar_width = mod.hp_bar_width*0.88
mod.ult_bar_offset_y = 1
mod.default_hp_bar_width = 553
mod.hp_bar_height = 36
mod.hp_bar_w_scale = mod.hp_bar_width / mod.default_hp_bar_width
mod.team_ammo_bar_length = 92
mod.rect_layout_border_color = { 255, 105, 105, 105 }

--- Store frame_index in a new variable.
mod:hook_safe(UnitFrameUI, "_create_ui_elements", function(self, frame_index)
	self.is_teammate = frame_index ~= nil -- frame_index is nil for player, 2 3 4 for other players
end)

mod:hook(UnitFrameUI, "draw", function(func, self, dt)
	local is_teammate = self.is_teammate

	local team_ui_ammo_bar_enabled = mod:get(mod.SETTING_NAMES.TEAM_UI_AMMO_BAR)
	if is_teammate then
		if self._mod_cached_team_ui_ammo_bar ~= team_ui_ammo_bar_enabled then
			self._dirty = true
			self._mod_cached_team_ui_ammo_bar = team_ui_ammo_bar_enabled
		end
	end

	mod:pcall(function()
		if not self._is_visible then
			return -- just from pcall
		end

		if not self._dirty then
			return -- just from pcall
		end

		if is_teammate then
			mod.teammate_unit_frame_draw(self)
		else
			mod.player_unit_frame_draw(self)
		end

		-- different hero portraits
		local team_ui_portrait_icons = mod:get(mod.SETTING_NAMES.TEAM_UI_PORTRAIT_ICONS)
		local profile_index = self.profile_index
		if profile_index then
			local profile_data = SPProfiles[profile_index]
			local def_static_content = self:_widget_by_feature("default", "static").content
			local character_portrait = def_static_content.character_portrait
			if not def_static_content.portrait_backup then
				def_static_content.portrait_backup = character_portrait
			end
			local default_portrait = def_static_content.portrait_backup

			if team_ui_portrait_icons == mod.PORTRAIT_ICONS.HERO then
				local hero_icon = UISettings.hero_icons.medium[profile_data.display_name]
				if character_portrait ~= hero_icon then
					mod.set_portrait(self, hero_icon)
				end
			elseif team_ui_portrait_icons == mod.PORTRAIT_ICONS.HATS then
				local careers = profile_data.careers
				local career_index = self.career_index
				if career_index then
					local career_name = careers[career_index].display_name
					local hat_icon = mod.career_name_to_hat_icon[career_name]
					if hat_icon and character_portrait ~= hat_icon then
						mod.set_portrait(self, hat_icon)
					end
				end
			elseif character_portrait ~= default_portrait then
				mod.set_portrait(self, default_portrait)
			end
		end
	end)

	-- option to hide the ammo indicator
	-- by making it transparent during the draw call
	local teammate_ammo_indicator_alpha_temp
	if is_teammate and mod:get(mod.SETTING_NAMES.TEAM_UI_AMMO_HIDE_INDICATOR) then
		local def_dynamic_w = self:_widget_by_feature("default", "dynamic")
		teammate_ammo_indicator_alpha_temp = def_dynamic_w.style.ammo_indicator.color[1]
		def_dynamic_w.style.ammo_indicator.color[1] = 0
	end

	func(self, dt)

	-- restore old ammo indicator alpha color value
	if is_teammate and teammate_ammo_indicator_alpha_temp then
		local def_dynamic_w = self:_widget_by_feature("default", "dynamic")
		def_dynamic_w.style.ammo_indicator.color[1] = teammate_ammo_indicator_alpha_temp
	end

	if is_teammate and self._is_visible then
		local network_manager = Managers.state.network
		local game = network_manager:game()
		local widget = self._teammate_custom_widget
		if widget and self.player_unit then
			local go_id = Managers.state.unit_storage:go_id(self.player_unit)
			if self.has_ammo then
				widget.content.ammo_bar.bar_value = GameSession.game_object_field(game, go_id, "ammo_percentage")
			elseif self.has_overcharge then
				local overcharge = GameSession.game_object_field(game, go_id, "overcharge_percentage")
				widget.content.ammo_bar.bar_value = overcharge
			end
		end

		-- adjust teammate ammo bar visibility
		local draw_ammo_bar =
			team_ui_ammo_bar_enabled
			and (
				self.has_ammo
				or self.has_overcharge and mod:get(mod.SETTING_NAMES.TEAM_UI_AMMO_SHOW_HEAT)
				)
		self._teammate_custom_widget.content.ammo_bar.draw_ammo_bar = draw_ammo_bar
		self._teammate_custom_widget.style.hp_bar_fg.color[1] = draw_ammo_bar and 255 or 0

		local ui_renderer = self.ui_renderer
		local ui_scenegraph = self.ui_scenegraph
		local input_service = self.input_manager:get_service("ingame_menu")
		local render_settings = self.render_settings
		UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt, nil, render_settings)
		UIRenderer.draw_widget(ui_renderer, self._teammate_custom_widget)
		UIRenderer.end_pass(ui_renderer)
	end
end)

mod:hook(UnitFrameUI, "set_ammo_percentage", function (func, self, ammo_percent)
	if self.is_teammate then
		mod:pcall(function()
			local widget = self._teammate_custom_widget
			if widget then
				self:_on_player_ammo_changed("ammo", widget, ammo_percent)
				self:_set_widget_dirty(widget)
				self:set_dirty()
			end
		end)
	end

	return func(self, ammo_percent)
end)

mod:hook_safe(UnitFrameUI, "set_portrait_frame", function(self)
	mod.adjust_portrait_size_and_position(self)
end)

mod:hook(UnitFrameUI, "update", function(func, self, ...)
	mod:pcall(function()
		if self.unit_frame_index then
			self.is_teammate = self.unit_frame_index > 1 and self.unit_frame_index or nil
		end

		local portrait_static = self._widgets.portrait_static

		-- hide frames: texture_1 is static frame, texture_2 is dynamic frame
		local frame_texture_alpha = mod:get(mod.SETTING_NAMES.HIDE_FRAMES) and 0 or 255
		for _, frame_texture_name in ipairs( mod.frame_texture_names ) do
			if portrait_static.style[frame_texture_name]
			and portrait_static.style[frame_texture_name].color[1] ~= frame_texture_alpha
			then
				portrait_static.style[frame_texture_name].color[1] = frame_texture_alpha
				self:_set_widget_dirty(portrait_static)
			end
		end

		-- force default frame
		if mod:get(mod.SETTING_NAMES.FORCE_DEFAULT_FRAME)
		and portrait_static.content.texture_1 ~= "portrait_frame_0000" then
			self:set_portrait_frame("default", portrait_static.content.level_text)
		end

		-- hide levels
		local level_alpha = mod:get(mod.SETTING_NAMES.HIDE_LEVELS) and 0 or 255
		if portrait_static.style.level.text_color[1] ~= level_alpha then
			portrait_static.style.level.text_color[1] = level_alpha
			self:_set_widget_dirty(portrait_static)
		end

		if self.is_teammate then
			mod.teammate_unit_frame_update(self)
		else
			mod.player_unit_frame_update(self)
		end
	end)
	return func(self, ...)
end)

mod:hook(UnitFrameUI, "_update_portrait_opacity", function(func, self, is_dead, is_knocked_down, needs_help, assisted_respawn)
	local widget = self:_widget_by_feature("default", "static")
	local color = widget.style.character_portrait.color

	local normal_state = not is_dead
			and not is_knocked_down
			and not needs_help
			and not assisted_respawn

	local alpha_temp = color[1]
	if normal_state then
		color[1] = 255 -- skip an if check that dirties the widget
	end

	-- if using hero or hat portrait icons colorize them red
	if self.is_teammate
	and mod:get(mod.SETTING_NAMES.TEAM_UI_PORTRAIT_ICONS) ~= mod.PORTRAIT_ICONS.DEFAULT
	then
		if is_knocked_down or needs_help then
			-- firebrick color
			color[2] = 178
			color[3] = 34
			color[4] = 34
		else
			color[2] = 255
			color[3] = 255
			color[4] = 255
		end
	end

	local is_dirtied = func(self, is_dead, is_knocked_down, needs_help, assisted_respawn)

	local portrait_alpha = mod:get(mod.SETTING_NAMES.TEAM_UI_PORTRAIT_ALPHA)
	if not is_dirtied and normal_state then
		color[1] = portrait_alpha
		if alpha_temp ~= portrait_alpha then
			self:_set_widget_dirty(widget)
			return true
		end
	end

	return is_dirtied
end)

--- Catch unit_frame_ui:set_portrait calls to cache the real portrait.
mod:hook_safe(UnitFrameUI, "set_portrait", function(self)
	local widget = self:_widget_by_feature("default", "static")
	local widget_content = widget.content
	widget_content.portrait_backup = widget_content.character_portrait
end)

--- Catch Material.set_vector2 crash on changed portrait textures.
mod:hook(UnitFrameUI, "set_portrait_status", function(func, ...)
	mod:hook_enable(Material, "set_vector2")

	func(...)

	mod:hook_disable(Material, "set_vector2")
end)

mod:hook(Material, "set_vector2", function(func, gui_material, ...)
	if not gui_material then
		return
	end

	return func(gui_material, ...)
end)
mod:hook_disable(Material, "set_vector2")

mod:hook(UnitFramesHandler, "_create_unit_frame_by_type", function(func, self, frame_type, frame_index)
	local unit_frame = func(self, frame_type, frame_index)
	if frame_type == "player" and mod:get(mod.SETTING_NAMES.MINI_HUD_PRESET) then
		local new_definitions = local_require("scripts/ui/hud_ui/player_console_unit_frame_ui_definitions")
		unit_frame.definitions.widget_definitions.health_dynamic = new_definitions.widget_definitions.health_dynamic
		unit_frame.widget = UnitFrameUI:new(self.ingame_ui_context, unit_frame.definitions, unit_frame.data, frame_index, unit_frame.player_data)
	end
	return unit_frame
end)

--- Realign teammate portraits and pass additional data to unit frames.
mod:hook(UnitFramesHandler, "update", function(func, self, ...)
	if not self._hb_mod_first_frame_done then
		self._hb_mod_first_frame_done = true

		mod.realign_team_member_frames = true
		mod.recreate_player_unit_frame = true
	end

	if mod.realign_team_member_frames then
		mod.realign_team_member_frames = false

		self:_align_party_member_frames()

		-- dirtify the portrait widget
		for _, unit_frame in ipairs(self._unit_frames) do
			local unit_frame_widget = unit_frame.widget
			unit_frame_widget:_set_widget_dirty(unit_frame_widget._widgets.portrait_static)
		end
	end

	if mod.recreate_player_unit_frame then
		mod.recreate_player_unit_frame = false

		local my_unit_frame = self._unit_frames[1]
		my_unit_frame.widget:destroy()

		local new_unit_frame = self:_create_unit_frame_by_type("player")
		new_unit_frame.player_data = my_unit_frame.player_data
		new_unit_frame.sync = true
		self._unit_frames[1] = new_unit_frame

		self:set_visible(self._is_visible)
	end

	for _, unit_frame in ipairs(self._unit_frames) do
		local has_ammo
		local has_overcharge
		local player_data = unit_frame.player_data
		local player_unit = player_data.player_unit
		local player_ui_id = player_data.player_ui_id

		local inventory_extension = ScriptUnit.has_extension(player_unit, "inventory_system")
		if inventory_extension then
			local equipment = inventory_extension:equipment()
			if equipment then
				local slot_data = equipment.slots["slot_ranged"]
				local item_data = slot_data and slot_data.item_data

				if item_data then
					local item_template = BackendUtils.get_item_template(item_data)
					has_overcharge = not not item_template.overcharge_data
					has_ammo = not not item_template.ammo_data
				end
			end
		end

		local unit_frame_w = unit_frame.widget
		unit_frame_w.unit_frame_index = self._unit_frame_index_by_ui_id[player_ui_id]

		local buff_extension = ScriptUnit.has_extension(player_unit, "buff_system")
		if buff_extension then
			unit_frame_w.has_natural_bond = false
			if mod:get(mod.SETTING_NAMES.TEAM_UI_ICONS_NATURAL_BOND) then
				unit_frame_w.has_natural_bond = buff_extension:has_buff_type("trait_necklace_no_healing_health_regen")
			end
			unit_frame_w.has_hand_of_shallya = false
			if mod:get(mod.SETTING_NAMES.TEAM_UI_ICONS_HAND_OF_SHALLYA) then
				unit_frame_w.has_hand_of_shallya = buff_extension:has_buff_type("trait_necklace_heal_self_on_heal_other")
			end

			unit_frame_w.has_healshare_talent = false
			if mod:get(mod.SETTING_NAMES.TEAM_UI_ICONS_HEALSHARE) then
				for _, hs_buff_name in ipairs( mod.healshare_buff_names ) do
					if buff_extension:has_buff_type(hs_buff_name) then
						unit_frame_w.has_healshare_talent = true
						break
					end
				end
			end
		end

		local is_wounded = unit_frame.data.is_wounded
		unit_frame_w.is_wounded = is_wounded

		-- wounded buff handling for local player
		if player_unit then
			local buff_ext = ScriptUnit.extension(player_unit, "buff_system")
			if buff_ext then
				if unit_frame_w.unit_frame_index == 1
				and is_wounded
				and mod:get(mod.SETTING_NAMES.PLAYER_UI_CUSTOM_BUFFS_WOUNDED)
				then
					buff_ext:add_buff("custom_wounded")
				else
					local wounded_buff = buff_ext:get_non_stacking_buff("custom_wounded")
					if wounded_buff then
						buff_ext:remove_buff(wounded_buff.id)
					end
				end
			end
		end

		-- for debugging
		-- unit_frame_w.is_wounded = true
		-- unit_frame_w.has_natural_bond = true
		-- unit_frame_w.has_hand_of_shallya = true
		-- unit_frame_w.has_healshare_talent = true

		unit_frame_w.has_ammo = has_ammo
		unit_frame_w.has_overcharge = has_overcharge
		unit_frame_w.player_unit = player_unit
		unit_frame_w.profile_index = self.profile_synchronizer:profile_by_peer(player_data.peer_id, player_data.local_player_id)

		local extensions = player_data.extensions
		if extensions and extensions.career then
			unit_frame_w.career_index = extensions.career:career_index()
		end
	end

	func(self, ...)
end)

--- Teammate UI.
mod:hook_origin(UnitFramesHandler, "_align_party_member_frames", function(self)
	local start_offset_x = 80 + mod:get(mod.SETTING_NAMES.TEAM_UI_OFFSET_X)
	local start_offset_y = -100 + mod:get(mod.SETTING_NAMES.TEAM_UI_OFFSET_Y)
	local spacing = mod:get(mod.SETTING_NAMES.TEAM_UI_SPACING)
	local is_visible = self._is_visible
	local count = 0

	for index, unit_frame in ipairs(self._unit_frames) do
		if index > 1 then
			local widget = unit_frame.widget
			local player_data = unit_frame.player_data
			local peer_id = player_data.peer_id
			local connecting_peer_id = player_data.connecting_peer_id

			if (peer_id or connecting_peer_id) and is_visible then
				local position_x = start_offset_x
				local position_y = start_offset_y - count * spacing

				if mod:get(mod.SETTING_NAMES.TEAM_UI_FLOWS_HORIZONTALLY) then
					position_x = start_offset_x + count * spacing
					position_y = start_offset_y
				end

				widget:set_position(position_x, position_y)

				count = count + 1

				widget:set_visible(true)
			else
				widget:set_visible(false)
			end
		end
	end
end)

--- Chat position and background transparency.
mod:hook("ChatGui", "update", function(func, self, ...)
	mod:pcall(function()
		local position = self.ui_scenegraph.chat_window_root.local_position
		position[1] = mod:get(mod.SETTING_NAMES.CHAT_OFFSET_X)
		position[2] = 200 + mod:get(mod.SETTING_NAMES.CHAT_OFFSET_Y)
		UISettings.chat.window_background_alpha = mod:get(mod.SETTING_NAMES.CHAT_BG_ALPHA)

		mod.on_chat_gui_update(self)
		mod.bm_on_chat_gui_update(self)
	end)

	return func(self, ...)
end)

--- Hide or make less obtrusive the floating mission marker.
--- Used for "Set Free" on respawned player.
mod:hook(TutorialUI, "update_mission_tooltip", function(func, self, ...)
	if mod:get(mod.SETTING_NAMES.NO_TUTORIAL_UI) then
		return
	end

	func(self, ...)

	if mod:get(mod.SETTING_NAMES.UNOBTRUSIVE_MISSION_TOOLTIP) then
		mod:pcall(function()
			local widget_style = self.tooltip_mission_widget.style
			widget_style.texture_id.size = nil
			widget_style.texture_id.offset = { 0, 0 }
			if widget_style.text.text_color[1] ~= 0 then
				widget_style.texture_id.color[1] = 100
				widget_style.text.text_color[1] = 100
				widget_style.text_shadow.text_color[1] = 100
			else
				widget_style.texture_id.size = { 32, 32 }
				widget_style.texture_id.offset = { 16+16, 16 }
			end
		end)
	end
end)

mod:hook(TutorialUI, "update", function(func, self, ...)
	if mod:get(mod.SETTING_NAMES.NO_TUTORIAL_UI) then
		mod:pcall(function()
			self.active_tooltip_widget = nil
			for _, obj_tooltip in ipairs( self.objective_tooltip_widget_holders ) do
				obj_tooltip.updated = false
			end
		end)
	end
	return func(self, ...)
end)

--- Change size and transparency of floating objective icon.
mod:hook(TutorialUI, "update_objective_tooltip_widget", function(func, self, widget_holder, player_unit, dt)
	func(self, widget_holder, player_unit, dt)

	if mod:get(mod.SETTING_NAMES.UNOBTRUSIVE_FLOATING_OBJECTIVE) then
		local widget = self.objective_tooltip_widget_holders[1].widget
		local icon_style = widget.style.texture_id
		icon_style.size = { 32, 32 }
		icon_style.offset = { 16, 16 }
		icon_style.color[1] = 75

		if widget.style.text.text_color[1] ~= 0 then
			widget.style.text.text_color[1] = 100
			widget.style.text_shadow.text_color[1] = 100
		end
	end
end)

mod:hook(MissionObjectiveUI, "draw", function(func, self, dt)
	if mod:get(mod.SETTING_NAMES.NO_MISSION_OBJECTIVE) then
		return
	end

	return func(self, dt)
end)

--- Hide or reposition boss hp bar.
mod:hook(BossHealthUI, "_draw", function(func, self, dt, t)
	if mod:get(mod.SETTING_NAMES.HIDE_BOSS_HP_BAR) then
		return
	end

	-- boss hp bar position
	local local_position = self.ui_scenegraph.pivot.local_position
	if not mod.boss_health_ui_default_position then
		mod.boss_health_ui_default_position = table.clone(local_position)
	end

	local_position[1] = mod.boss_health_ui_default_position[1]
		+ mod:get(mod.SETTING_NAMES.OTHER_ELEMENTS_BOSS_HP_BAR_OFFSET_X)
	local_position[2] = mod.boss_health_ui_default_position[2]
		+ mod:get(mod.SETTING_NAMES.OTHER_ELEMENTS_BOSS_HP_BAR_OFFSET_Y)

	return func(self, dt, t)
end)

-- not making this mod.disable_outlines to attempt some optimization
-- since OutlineSystem.always gets called a crazy amount of times per frame
local disable_outlines = false

--- Hide HUD when inspecting or when "Hide HUD" toggled with hotkey.
mod:hook(GameModeManager, "has_activated_mutator", function(func, self, name, ...)
	if name == "realism" then
		if mod:get(mod.SETTING_NAMES.HIDE_HUD_WHEN_INSPECTING) then
			local just_return
			pcall(function()
				local player_unit = Managers.player:local_player().player_unit
				local character_state_machine_ext = ScriptUnit.extension(player_unit, "character_state_machine_system")
				just_return = character_state_machine_ext:current_state() == "inspecting"
			end)

			local is_inpecting = not not just_return
			disable_outlines = is_inpecting
			if is_inpecting then
				return true
			end
		end

		if mod.keep_hud_hidden then
			return true
		end
	end

	return func(self, name, ...)
end)

--- Patch realism visibility_group to show LevelCountdownUI.
mod:hook(IngameHud, "_update_component_visibility", function(func, self)
	if self._definitions then
		for _, visibility_group in ipairs( self._definitions.visibility_groups ) do
			if visibility_group.name == "realism" then
				visibility_group.visible_components["LevelCountdownUI"] = true
			end
		end
	end

	return func(self)
end)

--- Disable hero outlines.
mod:hook(OutlineSystem, "always", function(func, self, ...)
	if disable_outlines then
		return false
	end

	return func(self, ...)
end)

--- Mute Olesya in the Ubersreik levels.
mod:hook(DialogueSystem, "trigger_sound_event_with_subtitles", function(func, self, sound_event, subtitle_event, speaker_name)
	local level_key = Managers.state.game_mode and Managers.state.game_mode:level_key()

	if speaker_name == "ferry_lady"
	and level_key
	and mod.ubersreik_lvls:contains(level_key)
	and mod:get(mod.SETTING_NAMES.DISABLE_OLESYA_UBERSREIK_AUDIO)
	then
		return
	end

	return func(self, sound_event, subtitle_event, speaker_name)
end)

--- Hide name of new location text.
mod:hook(PlayerHud, "set_current_location", function(func, self, ...)
	if mod:get(mod.SETTING_NAMES.HIDE_NEW_AREA_TEXT) then
		return
	end

	return func(self, ...)
end)

--- Reposition the subtitles.
mod:hook_safe(SubtitleGui, "update", function(self)
	local subtitle_widget = self._subtitle_widget
	if not subtitle_widget.offset then
		subtitle_widget.offset = { 0, 0, 0 }
	end
	subtitle_widget.offset[1] = mod:get(mod.SETTING_NAMES.OTHER_ELEMENTS_SUBTITLES_OFFSET_X)
	subtitle_widget.offset[2] = mod:get(mod.SETTING_NAMES.OTHER_ELEMENTS_SUBTITLES_OFFSET_Y)
end)

--- Reposition the Twitch voting UI.
mod:hook(TwitchVoteUI, "_draw", function(func, self, dt, t)
	local offset_x = mod:get(mod.SETTING_NAMES.OTHER_ELEMENTS_TWITCH_VOTE_OFFSET_X)
	local offset_y = mod:get(mod.SETTING_NAMES.OTHER_ELEMENTS_TWITCH_VOTE_OFFSET_Y)

	local local_position = self._ui_scenegraph.base_area.local_position
	local_position[1] = 0 + offset_x
	local_position[2] = 120 + offset_y

	local results_local_position = self._ui_scenegraph.result_area.local_position
	results_local_position[1] = 0 + offset_x
	results_local_position[2] = 200 + offset_y

	return func(self, dt, t)
end)

--- Hide the "Waiting for rescue" message.
mod:hook(WaitForRescueUI, "update", function(func, ...)
	if mod:get(mod.SETTING_NAMES.HIDE_WAITING_FOR_RESCUE) then
		return
	end

	return func(...)
end)

--- Hide the Twitch mode icons in lower right.
mod:hook(TwitchIconView, "_draw", function(func, self, ...)
	if mod:get(mod.SETTING_NAMES.HIDE_TWITCH_MODE_ON_ICON) then
		return
	end

	return func(self, ...)
end)

--- Disable White HP flashing.
mod:hook(UnitFrameUI, "_update_bar_flash", function(func, self, widget, style, time, dt)
	if mod:get(mod.SETTING_NAMES.STOP_WHITE_HP_FLASHING) then
		return
	end

	return func(self, widget, style, time, dt)
end)

-- execute this in an external file
-- mod:hook_safe(StateInGameRunning, "post_update", function(self, dt, t)
-- 	mod.was_reloaded = false
-- end)

mod:dofile("scripts/mods/HideBuffs/mod_data")
mod:dofile("scripts/mods/HideBuffs/mod_events")
mod:dofile("scripts/mods/HideBuffs/content_change_functions")
mod:dofile("scripts/mods/HideBuffs/teammate_widget_definitions")
mod:dofile("scripts/mods/HideBuffs/player_widget_definitions")
mod:dofile("scripts/mods/HideBuffs/player_unit_frame_ui")
mod:dofile("scripts/mods/HideBuffs/teammate_unit_frame_ui")
mod:dofile("scripts/mods/HideBuffs/buff_ui")
mod:dofile("scripts/mods/HideBuffs/ability_ui")
mod:dofile("scripts/mods/HideBuffs/equipment_ui")
mod:dofile("scripts/mods/HideBuffs/second_buff_bar")
mod:dofile("scripts/mods/HideBuffs/level_loading_screen")
mod:dofile("scripts/mods/HideBuffs/persistent_ammo_counter")
mod:dofile("scripts/mods/HideBuffs/locked_and_loaded_compat")
mod:dofile("scripts/mods/HideBuffs/faster_chest_opening")
mod:dofile("scripts/mods/HideBuffs/custom_buffs")
mod:dofile("scripts/mods/HideBuffs/stamina_shields")
mod:dofile("scripts/mods/HideBuffs/upload_settings")
mod:dofile("scripts/mods/HideBuffs/presets_data")
mod:dofile("scripts/mods/HideBuffs/presets")
mod:dofile("scripts/mods/HideBuffs/overcharge_bar")
mod:dofile("scripts/mods/HideBuffs/local_presets")
mod:dofile("scripts/mods/HideBuffs/buffs_manager")

--- MOD FUNCTIONS ---
mod.reapply_pickup_ranges = function()
	OutlineSettings.ranges = table.clone(mod.persistent.outline_ranges_backup)
	if mod:get(mod.SETTING_NAMES.HIDE_PICKUP_OUTLINES) then
		OutlineSettings.ranges.pickup = 0
	end
	if mod:get(mod.SETTING_NAMES.HIDE_OTHER_OUTLINES) then
		OutlineSettings.ranges.doors = 0
		OutlineSettings.ranges.objective = 0
		OutlineSettings.ranges.objective_light = 0
		OutlineSettings.ranges.interactable = 0
		OutlineSettings.ranges.revive = 0
		OutlineSettings.ranges.player_husk = 0
		OutlineSettings.ranges.elevators = 0
	end
end

mod.adjust_portrait_size_and_position = function(unit_frame_ui)
	local self = unit_frame_ui
	if self.is_teammate then
		local widgets = self._widgets
		local team_ui_portrait_offset_x = mod:get(mod.SETTING_NAMES.TEAM_UI_PORTRAIT_OFFSET_X)
		local team_ui_portrait_offset_y = mod:get(mod.SETTING_NAMES.TEAM_UI_PORTRAIT_OFFSET_Y)

		local default_static_widget = self._default_widgets.default_static
		local default_static_style = default_static_widget.style
		local portrait_size = default_static_style.character_portrait.size
		default_static_style.character_portrait.offset[1] = -portrait_size[1]/2 + team_ui_portrait_offset_x

		local delta_y = self._hb_mod_cached_character_portrait_size[2] -
			default_static_style.character_portrait.size[2]
		if mod:get(mod.SETTING_NAMES.TEAM_UI_PORTRAIT_ICONS) ~= mod.PORTRAIT_ICONS.DEFAULT then
			delta_y = 86 - default_static_style.character_portrait.size[2] + 10+15
		end
		default_static_style.character_portrait.offset[2] = 1 + delta_y/2 + team_ui_portrait_offset_y

		local portrait_static_w = widgets.portrait_static
		portrait_static_w.offset[1] = team_ui_portrait_offset_x
		portrait_static_w.offset[2] = team_ui_portrait_offset_y

		default_static_style.host_icon.offset[1] = -50 + team_ui_portrait_offset_x
		default_static_style.host_icon.offset[2] = 10 + team_ui_portrait_offset_y

		self:_set_widget_dirty(default_static_widget)
		self:_set_widget_dirty(portrait_static_w)
		self:set_dirty()
	end
end

--- Same as UnitFrameUI.set_portrait, but we avoid using that so we can instead hook
--- UnitFrameUI set_portrait calls and cache results.
mod.set_portrait = function(unit_frame_ui, portrait_texture)
	local self = unit_frame_ui
	local widget = self:_widget_by_feature("default", "static")
	local widget_content = widget.content
	widget_content.character_portrait = portrait_texture

	self:_set_widget_dirty(widget)
	self._hb_mod_adjusted_portraits = false
end

--- Hide HUD hotkey callback.
mod.hide_hud = function()
	mod.keep_hud_hidden = not mod.keep_hud_hidden
end

--- EXECUTE ---
mod.was_ingame_entered = mod.persistent.was_ingame_entered
if mod.was_ingame_entered then
	mod.was_reloaded = true -- was_ingame_entered will only be true after a reload
end

if not mod.persistent.outline_ranges_backup then
	mod.persistent.outline_ranges_backup = table.clone(OutlineSettings.ranges)
end

mod.reapply_pickup_ranges()
