local mod = get_mod("HideBuffs")

local pl = require'pl.import_into'()
local tablex = require'pl.tablex'

mod.on_all_mods_loaded = function()
	if get_mod("NumericUI") then
		mod:echo(string.rep("=", 35))
		mod:echo("WARNING: UI Tweaks is not compatible with Numeric UI!")
		mod:echo(string.rep("=", 35))
	end
end

if get_mod("NumericUI") then
	return
end

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

	if setting_name == mod.SETTING_NAMES.SPEEDUP_ANIMATIONS then
		if mod:get(mod.SETTING_NAMES.SPEEDUP_ANIMATIONS) then
			mod.set_anim_ui_settings()
		else
			mod.reset_anim_ui_settings()
		end
	end

	if setting_name == mod.SETTING_NAMES.SECOND_BUFF_BAR_SIZE_ADJUST_X
	or setting_name == mod.SETTING_NAMES.SECOND_BUFF_BAR_SIZE_ADJUST_Y
	then
		mod.need_to_refresh_priority_bar = true
	end
end

--- Store frame_index in a new variable.
mod:hook_safe(UnitFrameUI, "_create_ui_elements", function(self, frame_index)
	self._mod_frame_index = frame_index -- nil for player, 1 2 3 for other players
end)

mod.player_ability_dynamic_content_change_fun = function (content, style)
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
	local bar_length = 515
	uvs[2][2] = ability_progress
	size[1] = bar_length * ability_progress
end

mod.original_health_bar_size = {
	92,
	9
}
mod.health_bar_offset = {
	-(mod.original_health_bar_size[1] / 2),
	-25,
	0
}
mod.team_grimoire_debuff_divider_content_change_fun =  function (content, style)
	local hp_bar_content = content.hp_bar
	local internal_bar_value = hp_bar_content.internal_bar_value
	local actual_active_percentage = content.actual_active_percentage or 1
	local grim_progress = math.max(internal_bar_value, actual_active_percentage)
	local offset = style.offset
	offset[1] = mod.health_bar_offset[1] + mod.hp_bar_size[1] * grim_progress + mod.hp_bar_offset_x
end

mod.team_grimoire_bar_content_change_fun = function (content, style)
	local parent_content = content.parent
	local hp_bar_content = parent_content.hp_bar
	local internal_bar_value = hp_bar_content.internal_bar_value
	local actual_active_percentage = parent_content.actual_active_percentage or 1
	local grim_progress = math.max(internal_bar_value, actual_active_percentage)
	local size = style.size
	local uvs = content.uvs
	local offset = style.offset
	local bar_length = mod.hp_bar_size[1]
	uvs[1][1] = grim_progress
	size[1] = bar_length * (1 - grim_progress)
	offset[1] = 2 + mod.health_bar_offset[1] + bar_length * grim_progress + mod.hp_bar_offset_x
end

mod.team_ability_bar_content_change_fun = function (content, style)
	local ability_progress = content.bar_value
	local size = style.size
	local uvs = content.uvs
	local bar_length = mod.hp_bar_size[1]
	uvs[2][2] = ability_progress
	size[1] = bar_length * ability_progress
end

mod:hook(UnitFrameUI, "draw", function(func, self, dt)
	if self._mod_frame_index then
		local team_ui_ammo_bar = mod:get(mod.SETTING_NAMES.TEAM_UI_AMMO_BAR)
		if self._mod_cached_team_ui_ammo_bar ~= team_ui_ammo_bar then
			self._dirty = true
			self._mod_cached_team_ui_ammo_bar = team_ui_ammo_bar
		end
	end

	mod:pcall(function()
		if not self._is_visible then
			return -- just from pcall
		end

		if not self._dirty then
			return -- just from pcall
		end

		if not self._mod_frame_index then -- PLAYER UI
			self.ui_scenegraph.pivot.position[1] = mod:get(mod.SETTING_NAMES.PLAYER_UI_OFFSET_X)
			self.ui_scenegraph.pivot.position[2] = mod:get(mod.SETTING_NAMES.PLAYER_UI_OFFSET_Y)

			if mod:get(mod.SETTING_NAMES.MINI_HUD_PRESET) then
				local ability_dynamic = self._ability_widgets.ability_dynamic

				ability_dynamic.element.passes[1].content_change_function = mod.player_ability_dynamic_content_change_fun

				local ability_bar_height = mod:get(mod.SETTING_NAMES.PLAYER_ULT_BAR_HEIGHT)

				if ability_dynamic.style.ability_bar.size then
					ability_dynamic.style.ability_bar.size[2] = ability_bar_height
					ability_dynamic.offset[1] = -30-2
					ability_dynamic.offset[2] = 16 + 3 - ability_bar_height + ability_bar_height/2
					ability_dynamic.offset[3] = 50
				end
				self._health_widgets.health_dynamic.style.grimoire_debuff_divider.offset[3] = 200
			end
		else -- TEAMMATE UI
			-- adjust loadout dynamic offset(item slots)
			local loadout_dynamic = self._equipment_widgets.loadout_dynamic
			loadout_dynamic.offset[1] = -15 + mod:get(mod.SETTING_NAMES.TEAM_UI_ITEM_SLOTS_OFFSET_X)
			loadout_dynamic.offset[2] = -121 + mod:get(mod.SETTING_NAMES.TEAM_UI_ITEM_SLOTS_OFFSET_Y)

			local hp_bar_scale_x = mod:get(mod.SETTING_NAMES.TEAM_UI_HP_BAR_SCALE_WIDTH) / 100
			local hp_bar_scale_y = mod:get(mod.SETTING_NAMES.TEAM_UI_HP_BAR_SCALE_HEIGHT) / 100
			mod.hp_bar_size = { 92*hp_bar_scale_x, 9*hp_bar_scale_y }
			local hp_bar_size = mod.hp_bar_size

			local static_w_style = self:_widget_by_feature("default", "static").style
			static_w_style.ability_bar_bg.size = { hp_bar_size[1], 5*hp_bar_scale_y }

			local ability_bar_delta_y = 5*hp_bar_scale_y - 5
			local delta_x = hp_bar_size[1] - 92
			local delta_y = hp_bar_size[2] - 9
			static_w_style.hp_bar_bg.size = {
				100 + delta_x,
				17 + delta_y + ability_bar_delta_y
			}
			static_w_style.hp_bar_fg.size = {
				100 + delta_x,
				24 + delta_y + ability_bar_delta_y
			}
			static_w_style.ability_bar_bg.size = {
				92 + delta_x,
				5*hp_bar_scale_y
			}

			local hp_bar_offset_x = mod:get(mod.SETTING_NAMES.TEAM_UI_HP_BAR_OFFSET_X)
			local hp_bar_offset_y = mod:get(mod.SETTING_NAMES.TEAM_UI_HP_BAR_OFFSET_Y)
			mod.hp_bar_offset_x = hp_bar_offset_x

			local def_dynamic_w = self:_widget_by_feature("default", "dynamic")
			def_dynamic_w.style.ammo_indicator.offset[1] = 60 + delta_x + hp_bar_offset_x
			def_dynamic_w.style.ammo_indicator.offset[2] = -40 + delta_y/2 + hp_bar_offset_y

			static_w_style.ability_bar_bg.offset[1] = -46 + hp_bar_offset_x
			static_w_style.ability_bar_bg.offset[2] = -34 + hp_bar_offset_y

			static_w_style.hp_bar_fg.offset[1] = -50 + hp_bar_offset_x
			static_w_style.hp_bar_fg.offset[2] = -36 + hp_bar_offset_y

			static_w_style.hp_bar_bg.offset[1] = -50 + hp_bar_offset_x
			static_w_style.hp_bar_bg.offset[2] = -29 + hp_bar_offset_y

			local hp_dynamic = self:_widget_by_name("health_dynamic")
			local hp_dynamic_style = hp_dynamic.style

			hp_dynamic_style.hp_bar.offset[1] = -46 + hp_bar_offset_x
			hp_dynamic_style.hp_bar.offset[2] = -25 + delta_y/2 + hp_bar_offset_y

			hp_dynamic_style.total_health_bar.offset[1] = -46 + hp_bar_offset_x
			hp_dynamic_style.total_health_bar.offset[2] = -25 + delta_y/2 + hp_bar_offset_y

			local hp_bar_size_to_clone = {
				hp_bar_size[1],
				hp_bar_size[2]
			}
			hp_dynamic_style.total_health_bar.size = table.clone(hp_bar_size_to_clone)
			hp_dynamic_style.hp_bar.size = table.clone(hp_bar_size_to_clone)
			hp_dynamic_style.grimoire_bar.size = table.clone(hp_bar_size_to_clone)

			hp_dynamic_style.grimoire_debuff_divider.size = { 3, 28 + delta_y }

			for _, pass in ipairs( hp_dynamic.element.passes ) do
				if pass.style_id == "grimoire_debuff_divider" then
					pass.content_change_function = mod.team_grimoire_debuff_divider_content_change_fun
				end
				if pass.style_id == "grimoire_bar" then
					pass.content_change_function = mod.team_grimoire_bar_content_change_fun
				end
			end

			local ability_dynamic = self:_widget_by_feature("ability", "dynamic")
			ability_dynamic.style.ability_bar.size[2] = 5*hp_bar_scale_y
			ability_dynamic.style.ability_bar.offset[1] = -46 + hp_bar_offset_x
			ability_dynamic.style.ability_bar.offset[2] = -34 + hp_bar_offset_y

			for _, pass in ipairs( ability_dynamic.element.passes ) do
				if pass.style_id == "ability_bar" then
					pass.content_change_function = mod.team_ability_bar_content_change_fun
				end
			end

			if not self._teammate_custom_widget then
				self._teammate_custom_widget = UIWidget.init(mod.teammate_ui_custom_def)
			end

			self._teammate_custom_widget.style.hp_bar_fg.size = {
				100 + delta_x,
				24 + delta_y + ability_bar_delta_y
			}

			self._teammate_custom_widget.style.hp_bar_fg.offset[1] = -62 + hp_bar_offset_x
			self._teammate_custom_widget.style.hp_bar_fg.offset[2] = -37 + hp_bar_offset_y - delta_y + ability_bar_delta_y

			mod.team_ammo_bar_length = 92 + delta_x
			self._teammate_custom_widget.style.ammo_bar.size = {
				92 + delta_x,
				5*hp_bar_scale_y
			}
			self._teammate_custom_widget.style.ammo_bar.offset[1] = -59 + hp_bar_offset_x
			self._teammate_custom_widget.style.ammo_bar.offset[2] = -35 + hp_bar_offset_y - delta_y + ability_bar_delta_y

			local important_icons_offset_x = mod:get(mod.SETTING_NAMES.TEAM_UI_ICONS_OFFSET_X)
			local important_icons_offset_y = mod:get(mod.SETTING_NAMES.TEAM_UI_ICONS_OFFSET_Y)
			local icons_start_offset_x = 44
			local icons_start_offset_y = -31
			local custom_widget_style = self._teammate_custom_widget.style
			custom_widget_style.icon_natural_bond.offset = {
				icons_start_offset_x + delta_x + hp_bar_offset_x + important_icons_offset_x,
				icons_start_offset_y + hp_bar_offset_y + delta_y/2 + important_icons_offset_y
			}
			custom_widget_style.frame_natural_bond.offset = {
				custom_widget_style.icon_natural_bond.offset[1] - 2,
				custom_widget_style.icon_natural_bond.offset[2] - 2
			}

			custom_widget_style.icon_is_wounded.offset = {
				icons_start_offset_x + (self.has_natural_bond and 30 or 0) + delta_x + hp_bar_offset_x + important_icons_offset_x,
				icons_start_offset_y + hp_bar_offset_y + delta_y/2 + important_icons_offset_y
			}
			custom_widget_style.frame_is_wounded.offset = {
				custom_widget_style.icon_is_wounded.offset[1] - 2,
				custom_widget_style.icon_is_wounded.offset[2] - 2
			}

			if self.important_icons_enabled then
				def_dynamic_w.style.ammo_indicator.offset[1] = def_dynamic_w.style.ammo_indicator.offset[1]
					+ (self.is_wounded and 30 or 0)
					+ (self.has_natural_bond and 30 or 0)
			end
		end
	end)

	-- option to hide the ammo indicator
	-- by making it transparent during the draw call
	local teammate_ammo_indicator_alpha_temp
	if self._mod_frame_index and mod:get(mod.SETTING_NAMES.TEAM_UI_AMMO_HIDE_INDICATOR) then
		local def_dynamic_w = self:_widget_by_feature("default", "dynamic")
		teammate_ammo_indicator_alpha_temp = def_dynamic_w.style.ammo_indicator.color[1]
		def_dynamic_w.style.ammo_indicator.color[1] = 0
	end

	func(self, dt)

	-- restore old ammo indicator alpha color value
	if self._mod_frame_index and teammate_ammo_indicator_alpha_temp then
		local def_dynamic_w = self:_widget_by_feature("default", "dynamic")
		def_dynamic_w.style.ammo_indicator.color[1] = teammate_ammo_indicator_alpha_temp
	end

	if self._mod_frame_index
	and self._is_visible then
		if not self.has_ammo and self.has_overcharge then
			local widget = self._teammate_custom_widget
			if widget and self.player_unit then
				pcall(function()
					local network_manager = Managers.state.network
					local game = network_manager:game()
					local go_id = Managers.state.unit_storage:go_id(self.player_unit)
					local overcharge = GameSession.game_object_field(game, go_id, "overcharge_percentage")
					widget.content.ammo_bar.bar_value = overcharge
				end)
			end
		end

		if (self.has_ammo or self.has_overcharge)
		and mod:get(mod.SETTING_NAMES.TEAM_UI_AMMO_BAR) then
			local ui_renderer = self.ui_renderer
			local ui_scenegraph = self.ui_scenegraph
			local input_service = self.input_manager:get_service("ingame_menu")
			local render_settings = self.render_settings
			UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt, nil, render_settings)
			UIRenderer.draw_widget(ui_renderer, self._teammate_custom_widget)
			UIRenderer.end_pass(ui_renderer)
		end
	end
end)

mod.team_ammo_bar_length = 92
mod:hook(UnitFrameUI, "set_ammo_percentage", function (func, self, ammo_percent)
	if self._mod_frame_index then
		mod:pcall(function()
			local widget = self._teammate_custom_widget
			self:_on_player_ammo_changed("ammo", widget, ammo_percent)
			self:_set_widget_dirty(widget)
			self:set_dirty()
		end)
	end

	return func(self, ammo_percent)
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
			local status_icon_widget = self:_widget_by_feature("status_icon", "dynamic")
			local status_icon_widget_content = status_icon_widget.content
			if (hide_player_portrait and status_icon_widget_content.visible)
			or (hide_player_portrait and status_icon_widget_content.visible == nil)
			or (not hide_player_portrait and not status_icon_widget_content.visible)
			then
				status_icon_widget_content.visible = not hide_player_portrait
				self:_set_widget_dirty(status_icon_widget)
			end

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
			-- has_natural_bond and is_wounded updates
			if self._teammate_custom_widget then
				local important_icons_enabled = mod:get(mod.SETTING_NAMES.TEAM_UI_ICONS_GROUP)
				self.important_icons_enabled = important_icons_enabled
				if self._teammate_custom_widget.content.important_icons_enabled ~= important_icons_enabled then
					self._teammate_custom_widget.content.important_icons_enabled = important_icons_enabled
					self:_set_widget_dirty(self._teammate_custom_widget)
					self:set_dirty()
				end
				if self._teammate_custom_widget.content.has_natural_bond ~= self.has_natural_bond
				or self._teammate_custom_widget.content.is_wounded ~= self.is_wounded
				then
					self._teammate_custom_widget.content.has_natural_bond = self.has_natural_bond
					self._teammate_custom_widget.content.is_wounded = self.is_wounded
					self:_set_widget_dirty(self._teammate_custom_widget)
					self:set_dirty()
				end
			end

			if not self._hb_mod_cached_character_portrait_size then
				self._hb_mod_cached_character_portrait_size = table.clone(self._default_widgets.default_static.style.character_portrait.size)
			end
			local portrait_scale = mod:get(mod.SETTING_NAMES.TEAM_UI_PORTRAIT_SCALE)/100
			self._default_widgets.default_static.style.character_portrait.size = tablex.map("*", self._hb_mod_cached_character_portrait_size, portrait_scale)

			local widget = self:_widget_by_feature("status_icon", "dynamic")
			widget.style.portrait_icon.size = tablex.map("*", self._hb_mod_cached_character_portrait_size, portrait_scale)

			local team_ui_portrait_offset_x = mod:get(mod.SETTING_NAMES.TEAM_UI_PORTRAIT_OFFSET_X)
			local team_ui_portrait_offset_y = mod:get(mod.SETTING_NAMES.TEAM_UI_PORTRAIT_OFFSET_Y)

			local portrait_size = widget.style.portrait_icon.size
			widget.style.portrait_icon.offset[1] = -portrait_size[1]/2 + team_ui_portrait_offset_x
			local delta_y = self._hb_mod_cached_character_portrait_size[2] -
				self._default_widgets.default_static.style.character_portrait.size[2]
			widget.style.portrait_icon.offset[2] = delta_y/2 + team_ui_portrait_offset_y

			local def_dynamic_w = self:_widget_by_feature("default", "dynamic")

			local adjust_offsets_of = {
				def_dynamic_w.style.talk_indicator,
				def_dynamic_w.style.talk_indicator_highlight,
				def_dynamic_w.style.talk_indicator_highlight_glow,
			}
			for _, talk_widget in ipairs( adjust_offsets_of ) do
				talk_widget.offset[1] = 60 + team_ui_portrait_offset_x
				talk_widget.offset[2] = 30 + team_ui_portrait_offset_y
			end

			def_dynamic_w.style.connecting_icon.offset[1] = -25 + team_ui_portrait_offset_x
			def_dynamic_w.style.connecting_icon.offset[2] = 34 + team_ui_portrait_offset_y

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

			local def_static_widget = self:_widget_by_feature("player_name", "static")
			if def_static_widget then
				def_static_widget.style.player_name.offset[1] = 0 + mod:get(mod.SETTING_NAMES.TEAM_UI_NAME_OFFSET_X)
				def_static_widget.style.player_name.offset[2] = 110 + mod:get(mod.SETTING_NAMES.TEAM_UI_NAME_OFFSET_Y)
				def_static_widget.style.player_name_shadow.offset[1] = 2 + mod:get(mod.SETTING_NAMES.TEAM_UI_NAME_OFFSET_X)
				def_static_widget.style.player_name_shadow.offset[2] = 110 - 2 + mod:get(mod.SETTING_NAMES.TEAM_UI_NAME_OFFSET_Y)
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

	for _, unit_frame in ipairs(self._unit_frames) do
		local has_ammo
		local has_overcharge
		local player_unit = unit_frame.player_data.player_unit
		pcall(function()
			local inventory_extension = ScriptUnit.has_extension(player_unit, "inventory_system")
			has_ammo = inventory_extension and inventory_extension:has_ammo_consuming_weapon_equipped()

			local equipment = inventory_extension:equipment()
			if equipment then
				local slot_data = equipment.slots["slot_ranged"]
				local item_data = slot_data and slot_data.item_data

				if item_data then
					local item_template = BackendUtils.get_item_template(item_data)
					has_overcharge = not not item_template.overcharge_data
				end
			end
		end)

		local buff_extension = ScriptUnit.has_extension(player_unit, "buff_system")
		unit_frame.widget.has_natural_bond = buff_extension and buff_extension:has_buff_type("trait_necklace_no_healing_health_regen")

		unit_frame.widget.is_wounded = unit_frame.data.is_wounded

		unit_frame.widget.has_ammo = has_ammo
		unit_frame.widget.has_overcharge = has_overcharge
		unit_frame.widget.has_overcharge = has_overcharge
		unit_frame.widget.player_unit = unit_frame.player_data.player_unit
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

--- Hide boss hp bar.
mod:hook(BossHealthUI, "_draw", function(func, self, dt, t)
	if mod:get(mod.SETTING_NAMES.HIDE_BOSS_HP_BAR) then
		return
	end

	return func(self, dt, t)
end)

-- not making this mod.disable_outlines to attempt some optimization
-- since OutlineSystem.always gets called a crazy amount of times per frame
local disable_outlines = false

--- Hide HUD when inspecting.
mod:hook(IngameUI, "update", function(func, self, dt, t, ...)
	script_data.disable_ui = mod.keep_hud_hidden

	if mod:get(mod.SETTING_NAMES.HIDE_HUD_WHEN_INSPECTING) then
		local just_return
		pcall(function()
			local player_unit = Managers.player:local_player().player_unit
			local character_state_machine_ext = ScriptUnit.extension(player_unit, "character_state_machine_system")
			just_return = character_state_machine_ext:current_state() == "inspecting"
		end)

		disable_outlines = not not just_return
		script_data.disable_ui = not not just_return
		if mod.keep_hud_hidden then
			script_data.disable_ui = true
		end
	end

	return func(self, dt, t, ...)
end)

mod:hook(OutlineSystem, "always", function(func, self, ...)
	if disable_outlines then
		return false
	end

	return func(self, ...)
end)

mod.hide_hud = function()
	mod.keep_hud_hidden = not mod.keep_hud_hidden
end

mod:dofile("scripts/mods/HideBuffs/teammate_widget_definitions")
mod:dofile("scripts/mods/HideBuffs/buff_ui")
mod:dofile("scripts/mods/HideBuffs/ability_ui")
mod:dofile("scripts/mods/HideBuffs/equipment_ui")
mod:dofile("scripts/mods/HideBuffs/anim_speedup")
mod:dofile("scripts/mods/HideBuffs/second_buff_bar")
mod:dofile("scripts/mods/HideBuffs/persistent_ammo_counter")
mod:dofile("scripts/mods/HideBuffs/locked_and_loaded_compat")

fassert(not mod.update, "Overwriting existing function!")
mod.update = function()
	mod.locked_and_loaded_update()
end
