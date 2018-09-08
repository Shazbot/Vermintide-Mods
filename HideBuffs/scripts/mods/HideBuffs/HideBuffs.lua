local mod = get_mod("HideBuffs") -- luacheck: ignore get_mod

-- luacheck: globals BuffUI EquipmentUI AbilityUI UnitFrameUI MissionObjectiveUI TutorialUI
-- luacheck: globals local_require math UnitFramesHandler table UIWidget UIRenderer

local pl = require'pl.import_into'()
local tablex = require'pl.tablex'

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

mod.priority_buffs = pl.List{
	"victor_bountyhunter_passive_crit_buff",
	"traits_melee_attack_speed_on_crit_proc",
	"ranged_power_vs_frenzy",
	"ranged_power_vs_large",
	"ranged_power_vs_armored",
	"ranged_power_vs_unarmored",
	"consecutive_shot_buff",
	"victor_bountyhunter_passive_crit_cooldown",
	-- "grimoire_health_debuff",
}

mod:hook(BuffUI, "_add_buff", function (func, self, buff, ...)
	for buff_name, setting_name in pairs( mod.lookup ) do
		if buff.buff_type == buff_name and mod:get(setting_name) then
			return false
		end
	end

	if mod:get(mod.SETTING_NAMES.SECOND_BUFF_BAR) then
		local is_priority = mod.priority_buffs:contains(buff.buff_type)
		if is_priority and self ~= mod.buff_ui then
			return false
		elseif not is_priority and self == mod.buff_ui then
			return false
		end
	end

	return func(self, buff, ...)
end)

mod.reset_hotkey_alpha = false
mod.reset_portrait_frame_alpha = false
mod.reset_level_alpha = false

mod.change_slot_visibility = mod:get(mod.SETTING_NAMES.HIDE_WEAPON_SLOTS)
mod.reposition_weapon_slots =
	mod.change_slot_visibility
	or mod:get(mod.SETTING_NAMES.REPOSITION_WEAPON_SLOTS) ~= 0

mod.on_setting_changed = function(setting_name)
	mod.reset_hotkey_alpha = not mod:get(mod.SETTING_NAMES.HIDE_HOTKEYS)
	mod.reset_portrait_frame_alpha = not mod:get(mod.SETTING_NAMES.HIDE_FRAMES)
	mod.reset_level_alpha = not mod:get(mod.SETTING_NAMES.HIDE_LEVELS)

	if setting_name == mod.SETTING_NAMES.HIDE_WEAPON_SLOTS then
		mod.change_slot_visibility = true
		mod.reposition_weapon_slots = true
	end
	if setting_name == mod.SETTING_NAMES.REPOSITION_WEAPON_SLOTS then
		mod.reposition_weapon_slots = true
	end

	if pl.List({
			mod.SETTING_NAMES.TEAM_UI_OFFSET_X,
			mod.SETTING_NAMES.TEAM_UI_OFFSET_Y,
			mod.SETTING_NAMES.TEAM_UI_FLOWS_HORIZONTALLY,
			mod.SETTING_NAMES.TEAM_UI_SPACING,
		}):contains(setting_name)
	then
		mod.realign_team_member_frames = true
	end

	if setting_name == mod.SETTING_NAMES.MINI_HUD_PRESET then
		mod.recreate_player_unit_frame = true
	end

	if setting_name == mod.SETTING_NAMES.BUFFS_FLOW_VERTICALLY
	or setting_name == mod.SETTING_NAMES.REVERSE_BUFF_DIRECTION then
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
end

mod:hook(EquipmentUI, "update", function(func, self, ...)
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

		-- hide first 2 item slots
		local weapon_slots_visible = not mod:get(mod.SETTING_NAMES.HIDE_WEAPON_SLOTS)
		if mod.change_slot_visibility
		or self._slot_widgets[1].content.visible ~= weapon_slots_visible
		then
			mod.change_slot_visibility = false
			mod.reposition_weapon_slots = true
			self:_set_widget_visibility(self._slot_widgets[1], weapon_slots_visible)
			self:_set_widget_visibility(self._slot_widgets[2], weapon_slots_visible)
		end

		-- reposition the other item slots
		if mod.reposition_weapon_slots then
			mod.reposition_weapon_slots = false
			local num_slots = mod:get(mod.SETTING_NAMES.REPOSITION_WEAPON_SLOTS)
			if not mod:get(mod.SETTING_NAMES.HIDE_WEAPON_SLOTS) then
				num_slots = 0
			end
			for i = 1, #self._slot_widgets do
				if not self._slot_widgets[i]._hb_mod_offset_cache then
					self._slot_widgets[i]._hb_mod_offset_cache = table.clone(self._slot_widgets[i].offset)
				end
				self._slot_widgets[i].offset = self._slot_widgets[i]._hb_mod_offset_cache
			end
			for i = 3, #self._slot_widgets do
				self._slot_widgets[i].offset = self._slot_widgets[i+num_slots]._hb_mod_offset_cache
				self:_set_widget_dirty(self._slot_widgets[i])
			end
		end
	end)
	return func(self, ...)
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
		if not self._hb_mod_first_frame_done then
			self._hb_mod_first_frame_done = true

			mod.realign_buff_widgets = true
			mod.reset_buff_widgets = true
		end

		if mod.realign_buff_widgets then
			mod.realign_buff_widgets = false
			self:_align_widgets()
		end

		if self.ui_scenegraph.buff_pivot.position[1] ~= mod:get(mod.SETTING_NAMES.BUFFS_OFFSET_X)
		or self.ui_scenegraph.buff_pivot.position[2] ~= mod:get(mod.SETTING_NAMES.BUFFS_OFFSET_Y)
		then
			self.ui_scenegraph.buff_pivot.position[1] = mod:get(mod.SETTING_NAMES.BUFFS_OFFSET_X)
			self.ui_scenegraph.buff_pivot.position[2] = mod:get(mod.SETTING_NAMES.BUFFS_OFFSET_Y)
			mod.reset_buff_widgets = true
		end

		if mod.reset_buff_widgets then
			mod.reset_buff_widgets = false
			self:_on_resolution_modified()
		end
	end)
	return func(self, dt)
end)

--- Store frame_index in a new variable.
mod:hook_safe(UnitFrameUI, "_create_ui_elements", function(self, frame_index)
	self._mod_frame_index = frame_index -- nil for player, 1 2 3 for other players
end)

mod:hook(UnitFrameUI, "draw", function(func, self, dt)
	mod:pcall(function()
		if (not self._mod_frame_index) and mod:get(mod.SETTING_NAMES.MINI_HUD_PRESET) then
			self._ability_widgets.ability_dynamic.element.passes[1].content_change_function = function (content, style)
				if not content.uvs then
					local ability_progress = content.bar_value
					local size = style.texture_size
					local offset = style.offset
					offset[2] = -size[2] + size[2] * ability_progress
					return
				end
				local ability_progress = content.bar_value
				local size = style.size
				local uvs = content.uvs
				local bar_length = 448+20+30+10+7
				uvs[2][2] = ability_progress
				size[1] = bar_length * ability_progress
			end

			local ability_dynamic = self._ability_widgets.ability_dynamic
			if ability_dynamic.style.ability_bar.size then

				local ability_progress = ability_dynamic.content.ability_bar.bar_value
				local bar_length = 448+20+30+10+7
				local size_x = bar_length * ability_progress

				-- ability_dynamic.style.ability_bar.size[2] = 7
				ability_dynamic.style.ability_bar.size[2] = 9
				-- ability_dynamic.offset[1] = -30-2 + bar_length/2 - size_x/2
				ability_dynamic.offset[1] = -30-2 --+ bar_length/2 - size_x/2
				-- ability_dynamic.offset[2] = 20-1-2-1
				ability_dynamic.offset[2] = 20-1-2-2
				ability_dynamic.offset[3] = 50
			end
			self._health_widgets.health_dynamic.style.grimoire_debuff_divider.offset[3] = 200
		end
	end)
	return func(self, dt)
end)

mod.hp_bg_rect_def =
{
	scenegraph_id = "background_panel_bg",
	element = {
		passes = {
			{
				pass_type = "rect",
				style_id = "hp_bar_rect",
			},
		},
	},
	content = {

	},
	style = {
		hp_bar_rect = {
			offset = {0, 0},
			size = {
				500,
				10
			},
			color = {255, 0, 0, 0},
		},
	},
	offset = {
		0,
		0,
		0
	},
}

mod:hook(EquipmentUI, "draw", function(func, self, dt)
	if mod:get(mod.SETTING_NAMES.MINI_HUD_PRESET) then
		mod:pcall(function()
			self._static_widgets[1].content.texture_id = "console_hp_bar_frame"
			self._static_widgets[1].style.texture_id.size = { 576+10, 36 }
			self._static_widgets[1].offset = { 20, 20, 0 }

			self._static_widgets[2].style.texture_id.size = { 576-10, 36 }
			self._static_widgets[2].offset[1] = -50
			self._static_widgets[2].offset[2] = 20

			self.ui_scenegraph.slot.local_position[2] = 44+15
		end)

		if not self._hb_mod_widget then
			self._hb_mod_widget = UIWidget.init(mod.hp_bg_rect_def)
		end
		mod:pcall(function()
			self._hb_mod_widget.style.hp_bar_rect.size = { 576-10, 20 }
			self._hb_mod_widget.offset[1] = -50
			self._hb_mod_widget.offset[2] = 20
		end)

		local ui_renderer = self.ui_renderer
		local ui_scenegraph = self.ui_scenegraph
		local input_service = self.input_manager:get_service("ingame_menu")
		local render_settings = self.render_settings
		UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt, nil, render_settings)
		UIRenderer.draw_widget(ui_renderer, self._hb_mod_widget)
		UIRenderer.end_pass(ui_renderer)

		self._static_widgets[2].content.visible = false
	end

	return func(self, dt)
end)

mod:hook(AbilityUI, "draw", function (func, self, dt)
	if mod:get(mod.SETTING_NAMES.MINI_HUD_PRESET) then
		for _, pass in ipairs( self._widgets[1].element.passes ) do
			if pass.style_id == "ability_effect_left"
				or pass.style_id == "ability_effect_top_left" then
					pass.content_check_function = function() return false end
			end
		end

		for _, pass in ipairs( self._widgets[1].element.passes ) do
			if pass.style_id == "input_text"
			or pass.style_id == "input_text_shadow"
			then
				pass.content_check_function = function() return not mod:get(mod.SETTING_NAMES.HIDE_HOTKEYS) end
			end
		end

		mod:pcall(function()
			local skull_offsets = { 0, -15 }
			self._widgets[1].style.ability_effect_left.offset[1] = -(576+10)/2 - 50
			self._widgets[1].style.ability_effect_left.horizontal_alignment = "center"
			self._widgets[1].style.ability_effect_left.offset[2] = skull_offsets[2]
			self._widgets[1].style.ability_effect_top_left.horizontal_alignment = "center"
			self._widgets[1].style.ability_effect_top_left.offset[1] = -(576+10)/2 - 50
			self._widgets[1].style.ability_effect_top_left.offset[2] = skull_offsets[2]

			self._widgets[1].style.ability_effect_right.offset[1] = (576+10)/2 + 30
			self._widgets[1].style.ability_effect_right.horizontal_alignment = "center"
			self._widgets[1].style.ability_effect_right.offset[2] = skull_offsets[2]
			self._widgets[1].style.ability_effect_top_right.horizontal_alignment = "center"
			self._widgets[1].style.ability_effect_top_right.offset[1] = (576+10)/2 + 30
			self._widgets[1].style.ability_effect_top_right.offset[2] = skull_offsets[2]

			self._widgets[1].offset[1]= -1+3
			self._widgets[1].offset[2]= 56-30-5-3
			self._widgets[1].offset[3]= 60
			self._widgets[1].style.ability_bar_highlight.texture_size[1] = 576-20
			self._widgets[1].style.ability_bar_highlight.texture_size[2] = 50
			self._widgets[1].style.ability_bar_highlight.offset[2] = 22 + 4
		end)
	end

	return func(self, dt)
end)

mod:hook_safe(UnitFrameUI, "set_portrait_frame", function(self)
	if self._mod_frame_index then
		local widgets = self._widgets
		local team_ui_portrait_offset_x = mod:get(mod.SETTING_NAMES.TEAM_UI_PORTRAIT_OFFSET_X)
		local team_ui_portrait_offset_y = mod:get(mod.SETTING_NAMES.TEAM_UI_PORTRAIT_OFFSET_Y)

		local default_static_widget = self._default_widgets.default_static
		local portrait_size = self._default_widgets.default_static.style.character_portrait.size
		default_static_widget.style.character_portrait.offset[1] = -portrait_size[1]/2 + team_ui_portrait_offset_x

		local delta_y = self._hb_mod_cached_character_portrait_size[2] -
			self._default_widgets.default_static.style.character_portrait.size[2]
		default_static_widget.style.character_portrait.offset[2] = 1 + delta_y/2 + team_ui_portrait_offset_y

		widgets.portrait_static.offset[1] = team_ui_portrait_offset_x
		widgets.portrait_static.offset[2] = team_ui_portrait_offset_y
		self:_set_widget_dirty(widgets.portrait_static)
	end
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

		-- hide player portrait
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

		-- changes to the non-player portraits UI
		if self._mod_frame_index then
			if not self._hb_mod_cached_character_portrait_size then
				self._hb_mod_cached_character_portrait_size = table.clone(self._default_widgets.default_static.style.character_portrait.size)
			end
			local portrait_scale = mod:get(mod.SETTING_NAMES.TEAM_UI_PORTRAIT_SCALE)/100
			self._default_widgets.default_static.style.character_portrait.size = tablex.map("*", self._hb_mod_cached_character_portrait_size, portrait_scale)

			local team_ui_portrait_offset_x = mod:get(mod.SETTING_NAMES.TEAM_UI_PORTRAIT_OFFSET_X)
			local team_ui_portrait_offset_y = mod:get(mod.SETTING_NAMES.TEAM_UI_PORTRAIT_OFFSET_Y)

			local widgets = self._widgets
			local previous_widget = widgets.portrait_static
			if (
					self._hb_mod_portrait_scale_lf ~= portrait_scale
					or self._hb_mod_portrait_offset_x_lf ~= team_ui_portrait_offset_x
					or self._hb_mod_portrait_offset_y_lf ~= team_ui_portrait_offset_y
				)
				and previous_widget.content.level_text
			then
				self._hb_mod_portrait_offset_x_lf = team_ui_portrait_offset_x
				self._hb_mod_portrait_offset_y_lf = team_ui_portrait_offset_y
				self._hb_mod_portrait_scale_lf = portrait_scale

				local current_frame_settings_name = previous_widget.content.frame_settings_name
				previous_widget.content.scale = portrait_scale
				previous_widget.content.frame_settings_name = nil
				self:set_portrait_frame(current_frame_settings_name, previous_widget.content.level_text)
			end

			local widget = self:_widget_by_feature("player_name", "static")
			if widget then
				widget.style.player_name.offset[1] = 0 + mod:get(mod.SETTING_NAMES.TEAM_UI_NAME_OFFSET_X)
				widget.style.player_name.offset[2] = 110 + mod:get(mod.SETTING_NAMES.TEAM_UI_NAME_OFFSET_Y)
				widget.style.player_name_shadow.offset[1] = 2 + mod:get(mod.SETTING_NAMES.TEAM_UI_NAME_OFFSET_X)
				widget.style.player_name_shadow.offset[2] = 110 - 2 + mod:get(mod.SETTING_NAMES.TEAM_UI_NAME_OFFSET_Y)
			end
		end
	end)
	return func(self, ...)
end)

mod:hook(UnitFramesHandler, "_create_unit_frame_by_type", function(func, self, frame_type, frame_index)
	local unit_frame = func(self, frame_type, frame_index)
	if frame_type == "player" and mod:get(mod.SETTING_NAMES.MINI_HUD_PRESET) then
		local new_definitions = local_require("scripts/ui/hud_ui/player_console_unit_frame_ui_definitions")
		unit_frame.definitions.widget_definitions.health_dynamic = new_definitions.widget_definitions.health_dynamic
		unit_frame.widget = UnitFrameUI:new(self.ingame_ui_context, unit_frame.definitions, unit_frame.data, frame_index, unit_frame.player_data)
	end
	return unit_frame
end)

--- Teammate UI update hook to catch when we need to realign teammate portraits.
mod:hook(UnitFramesHandler, "update", function(func, self, ...)
	if not self._hb_mod_first_frame_done then
		self._hb_mod_first_frame_done = true

		mod.realign_team_member_frames = true
		mod.recreate_player_unit_frame = true
	end

	if mod.realign_team_member_frames then
		mod.realign_team_member_frames = false

		self:_align_team_member_frames()
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

--- Chat.
mod:hook("ChatGui", "update", function(func, self, ...)
	mod:pcall(function()
		local position = self.ui_scenegraph.chat_window_root.local_position
		position[1] = mod:get(mod.SETTING_NAMES.CHAT_OFFSET_X)
		position[2] = 200 + mod:get(mod.SETTING_NAMES.CHAT_OFFSET_Y)
	end)

	return func(self, ...)
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
mod:dofile("scripts/mods/HideBuffs/second_buff_bar")
