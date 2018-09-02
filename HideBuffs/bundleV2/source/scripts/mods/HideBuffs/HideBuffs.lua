local mod = get_mod("HideBuffs") -- luacheck: ignore get_mod

-- luacheck: globals BuffUI EquipmentUI AbilityUI UnitFrameUI MissionObjectiveUI TutorialUI
-- luacheck: globals local_require math UnitFramesHandler

mod.lookup = {
	["victor_bountyhunter_passive_infinite_ammo_buff"] =
		mod.SETTING_NAMES.VICTOR_BOUNTYHUNTER_PASSIVE_INFINITE_AMMO_BUFF,
	["grimoire_health_debuff"] =
		mod.SETTING_NAMES.GRIMOIRE_HEALTH_DEBUFF,
	["markus_huntsman_passive_crit_aura_buff"] =
		mod.SETTING_NAMES.MARKUS_HUNTSMAN_PASSIVE_CRIT_AURA_BUFF,
	["markus_knight_passive_defence_aura"] =
		mod.SETTING_NAMES.MARKUS_KNIGHT_PASSIVE_DEFENCE_AURA,
	["kerillian_waywatcher_passive"] =
		mod.SETTING_NAMES.KERILLIAN_WAYWATCHER_PASSIVE,
	["kerillian_maidenguard_passive_stamina_regen_buff"] =
		mod.SETTING_NAMES.KERILLIAN_MAIDENGUARD_PASSIVE_STAMINA_REGEN_BUFF,
}

mod:hook(BuffUI, "_add_buff", function (func, self, buff, ...)
	for buff_name, setting_name in pairs( mod.lookup ) do
		if buff.buff_type == buff_name and mod:get(setting_name) then
			return false
		end
	end

	return func(self, buff, ...)
end)

mod.reset_hotkey_alpha = false
mod.reset_portrait_frame_alpha = false
mod.reset_level_alpha = false

mod.on_setting_changed = function(setting_name) -- luacheck: ignore setting_name
	mod.reset_hotkey_alpha = not mod:get(mod.SETTING_NAMES.HIDE_HOTKEYS)
	mod.reset_portrait_frame_alpha = not mod:get(mod.SETTING_NAMES.HIDE_FRAMES)
	mod.reset_level_alpha = not mod:get(mod.SETTING_NAMES.HIDE_LEVELS)
end

mod:hook(EquipmentUI, "draw", function(func, self, dt)
	mod:pcall(function()
		if mod.reset_hotkey_alpha then
			for _, widget in ipairs(self._slot_widgets) do
				widget.style.input_text.text_color[1] = 255
				widget.style.input_text_shadow.text_color[1] = 255
				self:_set_widget_dirty(widget)
			end
			mod.reset_hotkey_alpha = false
		end
		if mod:get(mod.SETTING_NAMES.HIDE_HOTKEYS) then
			for _, widget in ipairs(self._slot_widgets) do
				if widget.style.input_text.text_color[1] ~= 0 then
					widget.style.input_text.text_color[1] = 0
					widget.style.input_text_shadow.text_color[1] = 0
					self:_set_widget_dirty(widget)
				end
			end
		end

		-- ammo counter
		for _, widget in ipairs( self._ammo_widgets ) do
			widget.offset[1] = mod:get(mod.SETTING_NAMES.AMMO_COUNTER_OFFSET_X)
			widget.offset[2] = mod:get(mod.SETTING_NAMES.AMMO_COUNTER_OFFSET_Y)
		end
	end)
	return func(self, dt)
end)

local buff_ui_definitions = local_require("scripts/ui/hud_ui/buff_ui_definitions")
local BUFF_SIZE = buff_ui_definitions.BUFF_SIZE
local BUFF_SPACING = buff_ui_definitions.BUFF_SPACING
mod:hook(BuffUI, "_align_widgets", function (func, self, ...)
	if not mod:get(mod.SETTING_NAMES.REVERSE_BUFF_DIRECTION) then
		return func(self, ...)
	end

	local horizontal_spacing = BUFF_SIZE[1] + BUFF_SPACING

	for index, data in ipairs(self._active_buffs) do
		local widget = data.widget
		local widget_offset = widget.offset
		local buffs_direction = mod:get(mod.SETTING_NAMES.REVERSE_BUFF_DIRECTION) and -1 or 1
		local target_position = buffs_direction * (index - 1) * horizontal_spacing
		data.target_position = target_position
		data.target_distance = math.abs(widget_offset[1] - target_position)

		self:_set_widget_dirty(widget)
	end

	self:set_dirty()

	self._alignment_duration = 0
end)

local ALIGNMENT_DURATION_TIME = 0.3
mod:hook_origin(BuffUI, "_update_pivot_alignment", function(self, dt)
	local alignment_duration = self._alignment_duration

	if not alignment_duration then
		return
	end

	alignment_duration = math.min(alignment_duration + dt, ALIGNMENT_DURATION_TIME)
	local progress = alignment_duration / ALIGNMENT_DURATION_TIME
	if mod:get(mod.SETTING_NAMES.BUFFS_DISABLE_ALIGN_ANIMATION) then
		progress = 1
	end
	local anim_progress = math.easeOutCubic(progress, 0, 1)

	if progress == 1 then
		self._alignment_duration = nil
	else
		self._alignment_duration = alignment_duration
	end

	for _, data in ipairs(self._active_buffs) do
		local widget = data.widget
		local widget_offset = widget.offset
		local widget_target_position = data.target_position
		local widget_target_distance = data.target_distance

		local start_offset_x = self._active_buffs[1] and self._active_buffs[1].widget.offset[1]
		local start_offset_y = self._active_buffs[1] and self._active_buffs[1].widget.offset[2]

		if widget_target_distance then
			if mod:get(mod.SETTING_NAMES.BUFFS_FLOW_VERTICALLY) then
				widget_offset[2] = widget_target_position + widget_target_distance * (1 - anim_progress)
				if start_offset_x then
					widget_offset[1] = start_offset_x
				end
			else
				widget_offset[1] = widget_target_position + widget_target_distance * (1 - anim_progress)
				if start_offset_y then
					widget_offset[2] = start_offset_y
				end
			end
		end

		self:_set_widget_dirty(widget)
	end

	self:set_dirty()
end)

mod:hook(BuffUI, "draw", function(func, self, dt)
	mod:pcall(function()
		local are_buffs_reversed = mod:get(mod.SETTING_NAMES.REVERSE_BUFF_DIRECTION)
		if self._hb_mod_cached_are_buffs_reversed ~= are_buffs_reversed then
			self._hb_mod_cached_are_buffs_reversed = are_buffs_reversed
			self:_align_widgets()
			self:_on_resolution_modified()
		end
		local are_buffs_vertical = mod:get(mod.SETTING_NAMES.BUFFS_FLOW_VERTICALLY)
		if self._hb_mod_cached_are_buffs_vertical ~= are_buffs_vertical then
			self._hb_mod_cached_are_buffs_vertical = are_buffs_vertical
			self:_align_widgets()
			self:_on_resolution_modified()
		end
		local buffs_offset_x = mod:get(mod.SETTING_NAMES.BUFFS_OFFSET_X)
		if self._hb_mod_cached_buffs_offset_x ~= buffs_offset_x then
			self._hb_mod_cached_buffs_offset_x = buffs_offset_x
			self.ui_scenegraph.buff_pivot.position[1] = buffs_offset_x
			self:_on_resolution_modified()
		end
		local buffs_offset_y = mod:get(mod.SETTING_NAMES.BUFFS_OFFSET_Y)
		if self._hb_mod_cached_buffs_offset_y ~= buffs_offset_y then
			self._hb_mod_cached_buffs_offset_y = buffs_offset_y
			self.ui_scenegraph.buff_pivot.position[2] = buffs_offset_y
			self:_on_resolution_modified()
		end
	end)
	return func(self, dt)
end)

--- Hide ult hotkey.
mod:hook(AbilityUI, "draw", function(func, self, dt)
	mod:pcall(function()
		if mod.reset_hotkey_alpha then
			local widget = self._widgets_by_name.ability
			widget.style.input_text.text_color[1] = 255
			widget.style.input_text_shadow.text_color[1] = 255
			self:_set_widget_dirty(widget)
			mod.reset_hotkey_alpha = false
		end
		if mod:get(mod.SETTING_NAMES.HIDE_HOTKEYS) then
			local widget = self._widgets_by_name.ability
			if widget.style.input_text.text_color[1] ~= 0 then
				widget.style.input_text.text_color[1] = 0
				widget.style.input_text_shadow.text_color[1] = 0
				self:_set_widget_dirty(widget)
			end
		end
	end)
	return func(self, dt)
end)

--- Store frame_index in a new variable.
mod:hook_safe(UnitFrameUI, "_create_ui_elements", function(self, frame_index)
	self._mod_frame_index = frame_index
end)

mod:hook(UnitFrameUI, "update", function(func, self, ...)
	mod:pcall(function()
		local portrait_static = self._widgets.portrait_static

		-- portrait frame
		if mod.reset_portrait_frame_alpha then
			portrait_static.style.texture_1.color[1] = 255
			self:_set_widget_dirty(portrait_static)
			mod.reset_portrait_frame_alpha = false
		end
		if mod:get(mod.SETTING_NAMES.HIDE_FRAMES)
		and portrait_static.style.texture_1.color[1] ~= 0 then
			portrait_static.style.texture_1.color[1] = 0
			self:_set_widget_dirty(portrait_static)
		end

		if mod:get(mod.SETTING_NAMES.FORCE_DEFAULT_FRAME)
		and portrait_static.content.texture_1 ~= "portrait_frame_0000" then
			self:set_portrait_frame("default", portrait_static.content.level_text)
		end

		-- level
		if mod.reset_level_alpha then
			portrait_static.style.level.text_color[1] = 255
			self:_set_widget_dirty(portrait_static)
			mod.reset_level_alpha = false
		end
		if mod:get(mod.SETTING_NAMES.HIDE_LEVELS)
		and portrait_static.style.level.text_color[1] ~= 0 then
			portrait_static.style.level.text_color[1] = 0
			self:_set_widget_dirty(portrait_static)
		end

		local hide_player_portrait = mod:get(mod.SETTING_NAMES.HIDE_PLAYER_PORTRAIT)
		if not self._mod_frame_index then
			local def_static_widget = self:_widget_by_feature("default", "static")
			local def_static_widget_content = def_static_widget.content
			if (hide_player_portrait and def_static_widget_content.visible)
			or (hide_player_portrait and def_static_widget_content.visible == nil)
			or (not hide_player_portrait and not def_static_widget_content.visible)
			then
				def_static_widget_content.visible = not hide_player_portrait
				self:_set_widget_dirty(def_static_widget)
			end

			local portrait_widget_content = self._portrait_widgets.portrait_static.content
			if (hide_player_portrait and portrait_widget_content.visible)
			or (hide_player_portrait and portrait_widget_content.visible == nil)
			or (not hide_player_portrait and not portrait_widget_content.visible)
			then
				portrait_widget_content.visible = not hide_player_portrait
				self:_set_widget_dirty(self._portrait_widgets.portrait_static)

			end
		end
	end)
	return func(self, ...)
end)

--- Teammate UI update hook to catch when we need to realign teammate portraits.
mod:hook(UnitFramesHandler, "update", function(func, self, ...)
	-- keep everything cached to catch mod option changes between frames
	local team_ui_offset_x = mod:get(mod.SETTING_NAMES.TEAM_UI_OFFSET_X)
	local team_ui_offset_y = mod:get(mod.SETTING_NAMES.TEAM_UI_OFFSET_Y)
	local team_ui_flows_horizontally = mod:get(mod.SETTING_NAMES.TEAM_UI_FLOWS_HORIZONTALLY)
	local team_ui_spacing = mod:get(mod.SETTING_NAMES.TEAM_UI_SPACING)

	if self._hb_mod_cached_team_ui_offset_x ~= team_ui_offset_x
	or self._hb_mod_cached_team_ui_offset_y ~= team_ui_offset_y
	or self._hb_mod_cached_team_ui_flows_horizontally ~= team_ui_flows_horizontally
	or self._hb_mod_cached_team_ui_spacing ~= team_ui_spacing
	then
		self._hb_mod_cached_team_ui_offset_x = team_ui_offset_x
		self._hb_mod_cached_team_ui_offset_y = team_ui_offset_y
		self._hb_mod_cached_team_ui_flows_horizontally = team_ui_flows_horizontally
		self._hb_mod_cached_team_ui_spacing = team_ui_spacing
		self:_align_team_member_frames()
	end

	return func(self, ...)
end)

--- Teammate UI.
mod:hook_origin(UnitFramesHandler, "_align_team_member_frames", function(self)
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

mod:hook(TutorialUI, "update_mission_tooltip", function(func, self, ...)
	if mod:get(mod.SETTING_NAMES.NO_TUTORIAL_UI) then
		return
	end
	return func(self, ...)
end)

mod:hook(TutorialUI, "pre_render_update", function(func, self, ...)
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

mod:hook(MissionObjectiveUI, "draw", function(func, self, dt)
	if mod:get(mod.SETTING_NAMES.NO_MISSION_OBJECTIVE) then
		return
	end
	return func(self, dt)
end)

mod:dofile("scripts/mods/HideBuffs/anim_speedup")