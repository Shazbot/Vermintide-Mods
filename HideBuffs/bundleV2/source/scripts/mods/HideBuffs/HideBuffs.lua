local mod = get_mod("HideBuffs") -- luacheck: ignore get_mod

-- luacheck: globals BuffUI EquipmentUI AbilityUI UnitFrameUI MissionObjectiveUI TutorialUI
-- luacheck: globals local_require math UnitFramesHandler table UIWidget UIRenderer
-- luacheck: globals CrosshairUI Managers ScriptUnit BossHealthUI Colors UIWidgets
-- luacheck: globals RETAINED_MODE_ENABLED BackendUtils OutlineSystem

local pl = require'pl.import_into'()
local tablex = require'pl.tablex'

mod.buff_name_to_setting_name_lookup = {
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
	for buff_name, setting_name in pairs( mod.buff_name_to_setting_name_lookup ) do
		if buff.buff_type == buff_name and mod:get(setting_name) then
			return false
		end
	end

	if mod:get(mod.SETTING_NAMES.SECOND_BUFF_BAR) then
		for setting_name, buff_names in pairs( mod.priority_buff_setting_name_to_buff_name ) do
			for _, buff_name in ipairs( buff_names ) do
				if buff_name == buff.buff_type then
					if mod:get(setting_name) then
						return false
					end
				end
			end
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

	if setting_name == mod.SETTING_NAMES.SPEEDUP_ANIMATIONS then
		if mod:get(mod.SETTING_NAMES.SPEEDUP_ANIMATIONS) then
			mod.set_anim_ui_settings()
		else
			mod.reset_anim_ui_settings()
		end
	end
end

mod:hook(EquipmentUI, "update", function(func, self, ...)
	mod:pcall(function()
		local inventory_extension = ScriptUnit.extension(Managers.player:local_player().player_unit, "inventory_system")
		local equipment = inventory_extension:equipment()
		local slot_data = equipment.slots["slot_ranged"]
		if slot_data then
			local item_data = slot_data.item_data
			self:_mod_update_ammo(slot_data.left_unit_1p, slot_data.right_unit_1p, BackendUtils.get_item_template(item_data))
		end

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

		local buffs_offset_x = mod:get(mod.SETTING_NAMES.BUFFS_OFFSET_X)
		local buffs_offset_y = mod:get(mod.SETTING_NAMES.BUFFS_OFFSET_Y)

		if self.ui_scenegraph.buff_pivot.position[1] ~= buffs_offset_x
		or self.ui_scenegraph.buff_pivot.position[2] ~= buffs_offset_y
		then
			self.ui_scenegraph.buff_pivot.position[1] = buffs_offset_x
			self.ui_scenegraph.buff_pivot.position[2] = buffs_offset_y
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
	local bar_length = 448+20+30+10+7
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

				if ability_dynamic.style.ability_bar.size then
					local ability_progress = ability_dynamic.content.ability_bar.bar_value
					local bar_length = 515
					local size_x = bar_length * ability_progress

					ability_dynamic.style.ability_bar.size[2] = 9
					ability_dynamic.offset[1] = -30-2 --+ bar_length/2 - size_x/2
					ability_dynamic.offset[2] = 16
					ability_dynamic.offset[3] = 50
				end
				self._health_widgets.health_dynamic.style.grimoire_debuff_divider.offset[3] = 200
			end
		else -- TEAMMATE UI
			-- loadout dynamic offset(item slots)
			local loadout_dynamic = self._equipment_widgets.loadout_dynamic
			loadout_dynamic.offset[1] = -15 + mod:get(mod.SETTING_NAMES.TEAM_UI_ITEM_SLOTS_OFFSET_X)
			loadout_dynamic.offset[2] = -121 + mod:get(mod.SETTING_NAMES.TEAM_UI_ITEM_SLOTS_OFFSET_Y)

			local hp_bar_scale = mod:get(mod.SETTING_NAMES.TEAM_UI_HP_BAR_SCALE) / 100
			mod.hp_bar_size = { 92*hp_bar_scale, 9*hp_bar_scale }
			local hp_bar_size = mod.hp_bar_size

			local static_w_style = self:_widget_by_feature("default", "static").style
			static_w_style.ability_bar_bg.size = { hp_bar_size[1], 5*hp_bar_scale }

			local ability_bar_delta_y = 5*hp_bar_scale - 5
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
				5*hp_bar_scale
			}

			local hp_bar_offset_x = mod:get(mod.SETTING_NAMES.TEAM_UI_HP_BAR_OFFSET_X)
			local hp_bar_offset_y = mod:get(mod.SETTING_NAMES.TEAM_UI_HP_BAR_OFFSET_Y)
			mod.hp_bar_offset_x = hp_bar_offset_x

			local def_dynamic_w = self:_widget_by_feature("default", "dynamic")
			def_dynamic_w.style.ammo_indicator.offset[1] = 60 + delta_x + hp_bar_offset_x
			def_dynamic_w.style.ammo_indicator.offset[2] = -40 + delta_y + hp_bar_offset_y

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

			hp_dynamic_style.total_health_bar.size = {
				hp_bar_size[1],
				hp_bar_size[2]
			}
			hp_dynamic_style.hp_bar.size = {
				hp_bar_size[1],
				hp_bar_size[2]
			}
			hp_dynamic_style.grimoire_bar.size = {
				hp_bar_size[1],
				hp_bar_size[2]
			}
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
			ability_dynamic.style.ability_bar.size[2] = 5*hp_bar_scale
			ability_dynamic.style.ability_bar.offset[1] = -46 + hp_bar_offset_x
			ability_dynamic.style.ability_bar.offset[2] = -34 + hp_bar_offset_y

			for _, pass in ipairs( ability_dynamic.element.passes ) do
				if pass.style_id == "ability_bar" then
					pass.content_change_function = mod.team_ability_bar_content_change_fun
				end
			end
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
			offset = {0, 0, 0},
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

mod.ammo_bar_width = 531

mod.ammo_widget_def =
{
	scenegraph_id = "background_panel_bg",
	element = {
		passes = {
			{
				style_id = "ammo_bar",
				pass_type = "texture_uv",
				content_id = "ammo_bar",
				content_change_function = function (content, style)
					local ammo_progress = content.bar_value
					local size = style.size
					local uvs = content.uvs
					local bar_length = mod.ammo_bar_width
					uvs[2][2] = ammo_progress
					size[1] = bar_length*ammo_progress
				end
			},
		},
	},
	content = {
		ammo_bar = {
			bar_value = 1,
			texture_id = "hud_teammate_ammo_bar_fill",
			uvs = {
				{
					0,
					0
				},
				{
					1,
					1
				}
			}
		},
	},
	style = {
		ammo_bar = {
			size = {
				mod.ammo_bar_width,
				15
			},
			offset = {
				0,
				0,
				0
			},
			color = {
				255,
				255,
				255,
				255
			},
		},
	},
	offset = {
		0,
		0,
		0
	},
}

UIWidgets._mod_create_border = function (scenegraph_id, retained, thickness, color, layer)
	local definition = {
		element = {
			passes = {
				{
					style_id = "border",
					pass_type = "border",
					retained_mode = retained,
				},
			}
		},
		content = {
		},
		style = {
			border = {
				thickness = thickness or 1,
				color = color or {255,255,255,255},
				offset = {
					0,
					0,
					0
				},
				size = {
					500,
					50
				}
			},
		},
		offset = {
			0,
			0,
			layer or 0
		},
		scenegraph_id = scenegraph_id
	}

	return definition
end

EquipmentUI._mod_update_ammo = function (self, left_hand_wielded_unit, right_hand_wielded_unit, item_template)
	local ammo_extension

	if not item_template.ammo_data then
		return
	end

	local ammo_unit_hand = item_template.ammo_data.ammo_hand

	if ammo_unit_hand == "right" then
		ammo_extension = ScriptUnit.extension(right_hand_wielded_unit, "ammo_system")
	elseif ammo_unit_hand == "left" then
		ammo_extension = ScriptUnit.extension(left_hand_wielded_unit, "ammo_system")
	else
		return
	end

	local max_ammo = ammo_extension:get_max_ammo()
	local remaining_ammo = ammo_extension:total_remaining_ammo()

	if max_ammo and remaining_ammo then
		if self._hb_mod_ammo_widget then
		    self._hb_mod_ammo_widget.content.ammo_bar.bar_value = remaining_ammo / max_ammo
		end
	end
end

mod:hook(EquipmentUI, "draw", function(func, self, dt)
	if mod:get(mod.SETTING_NAMES.MINI_HUD_PRESET)
	and self._is_visible
	then
		mod:pcall(function()
			local player_ui_offset_x = mod:get(mod.SETTING_NAMES.PLAYER_UI_OFFSET_X)
			local player_ui_offset_y = mod:get(mod.SETTING_NAMES.PLAYER_UI_OFFSET_Y)
			self._static_widgets[1].content.texture_id = "console_hp_bar_frame"
			self._static_widgets[1].style.texture_id.size = { 576+10, 36 }
			self._static_widgets[1].offset[1] = 20 + player_ui_offset_x
			self._static_widgets[1].offset[2] = 20 + player_ui_offset_y
			self._static_widgets[1].offset[3] = 0

			self._static_widgets[2].style.texture_id.size = { 576-10, 36 }
			self._static_widgets[2].offset[1] = -50 + player_ui_offset_x
			self._static_widgets[2].offset[2] = 20 + player_ui_offset_y

			if not self._hb_mod_widget then
				self._hb_mod_widget = UIWidget.init(mod.hp_bg_rect_def)
			end
			self._hb_mod_widget.style.hp_bar_rect.size = { 576-10, 21 }
			self._hb_mod_widget.offset[1] = -50 + player_ui_offset_x
			self._hb_mod_widget.offset[2] = 23 + player_ui_offset_y

			self.ui_scenegraph.slot.position[1] = 149 + player_ui_offset_x
			self.ui_scenegraph.slot.position[2] = 44 + 15 + player_ui_offset_y

			if not self._hb_mod_ammo_widget then
				self._hb_mod_ammo_widget = UIWidget.init(mod.ammo_widget_def)
			end

			if not self._mod_ammo_border then
				self._mod_ammo_border = UIWidget.init(UIWidgets._mod_create_border("background_panel_bg", RETAINED_MODE_ENABLED))
			end

			local player_ammo_bar_height = mod:get(mod.SETTING_NAMES.PLAYER_AMMO_BAR_HEIGHT)
			self._mod_ammo_border.offset[1] = -33 + player_ui_offset_x
			self._mod_ammo_border.offset[2] = 18 - player_ammo_bar_height + player_ui_offset_y
			self._mod_ammo_border.offset[3] = -20
			self._mod_ammo_border.style.border.size = { mod.ammo_bar_width + 2-10, player_ammo_bar_height + 2 }
			self._mod_ammo_border.style.border.color = { 255, 0,0,0 }
			-- self._mod_ammo_border.style.border.color = { 255, 0,255,0 }

			self._hb_mod_ammo_widget.offset[1] = player_ui_offset_x - 25
			self._hb_mod_ammo_widget.offset[2] = player_ui_offset_y + 43
			self._hb_mod_ammo_widget.style.ammo_bar.color[1] = mod:get(mod.SETTING_NAMES.PLAYER_AMMO_BAR_ALPHA)
			self._hb_mod_ammo_widget.style.ammo_bar.size[2] = player_ammo_bar_height
			self._hb_mod_ammo_widget.style.ammo_bar.offset[1] = -7
			self._hb_mod_ammo_widget.style.ammo_bar.offset[2] = -24 - player_ammo_bar_height
			self._hb_mod_ammo_widget.style.ammo_bar.offset[3] = 50
		end)

		if mod:get(mod.SETTING_NAMES.SHOW_RELOAD_REMINDER) then
			local need_to_reload, any_ammo_in_clip, can_reload = mod.player_requires_reload()
			if need_to_reload then
				local ammo_clip_widget = self._ammo_widgets_by_name.ammo_text_clip
				local ammo_clip_widget_style = ammo_clip_widget.style.text
				ammo_clip_widget_style.text_color = Colors.get_color_table_with_alpha("red", 255)
				if any_ammo_in_clip then
					ammo_clip_widget_style.text_color = Colors.get_color_table_with_alpha("khaki", 255)
				end
				if any_ammo_in_clip and not can_reload then
					ammo_clip_widget_style.text_color = Colors.get_color_table_with_alpha("orange", 255)
				end
				self:_set_widget_dirty(ammo_clip_widget)
			end
		end

		local ui_renderer = self.ui_renderer
		local ui_scenegraph = self.ui_scenegraph
		local input_service = self.input_manager:get_service("ingame_menu")
		local render_settings = self.render_settings
		UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt, nil, render_settings)
		UIRenderer.draw_widget(ui_renderer, self._hb_mod_widget)
		if mod:get(mod.SETTING_NAMES.PLAYER_AMMO_BAR) then
			if self._hb_mod_ammo_widget then
				UIRenderer.draw_widget(ui_renderer, self._hb_mod_ammo_widget)
			end
			if self._mod_ammo_border then
				UIRenderer.draw_widget(ui_renderer, self._mod_ammo_border)
			end
		end
		UIRenderer.end_pass(ui_renderer)

		self._static_widgets[2].content.visible = false
	end

	return func(self, dt)
end)

mod.player_ability_ability_effect_left_content_check_fun = function()
	return false
end

mod.player_ability_input_text_content_check_fun = function()
	return not mod:get(mod.SETTING_NAMES.HIDE_HOTKEYS)
end

mod:hook(AbilityUI, "draw", function (func, self, dt)
	if mod:get(mod.SETTING_NAMES.MINI_HUD_PRESET) then
		for _, pass in ipairs( self._widgets[1].element.passes ) do
			if pass.style_id == "ability_effect_left"
				or pass.style_id == "ability_effect_top_left" then
					pass.content_check_function = mod.player_ability_ability_effect_left_content_check_fun
			end
		end

		for _, pass in ipairs( self._widgets[1].element.passes ) do
			if pass.style_id == "input_text"
			or pass.style_id == "input_text_shadow"
			then
				pass.content_check_function = mod.player_ability_input_text_content_check_fun
			end
		end

		mod:pcall(function()
			self.ui_scenegraph.ability_root.position[1] = mod:get(mod.SETTING_NAMES.PLAYER_UI_OFFSET_X)
			self.ui_scenegraph.ability_root.position[2] = mod:get(mod.SETTING_NAMES.PLAYER_UI_OFFSET_Y)

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
			self._widgets[1].offset[2]= 17
			self._widgets[1].offset[3]= 60
			self._widgets[1].style.ability_bar_highlight.texture_size[1] = 576-20
			self._widgets[1].style.ability_bar_highlight.texture_size[2] = 54
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
			local status_icon_widget = self:_widget_by_feature("status_icon", "dynamic")
			local status_icon_widget_content = status_icon_widget.content
			if (hide_player_portrait and status_icon_widget_content.visible)
			or (hide_player_portrait and status_icon_widget_content.visible == nil)
			or (not hide_player_portrait and not status_icon_widget_content.visible)
			then
				status_icon_widget_content.visible = not hide_player_portrait
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

--- Hide crosshair when inspecting.
mod:hook(CrosshairUI, "draw", function(func, self, ...)
	if mod:get(mod.SETTING_NAMES.HIDE_CROSSHAIR_WHEN_INSPECTING) then
		local just_return
		pcall(function()
			local player_unit = Managers.player:local_player().player_unit
			local character_state_machine_ext = ScriptUnit.extension(player_unit, "character_state_machine_system")
			just_return = character_state_machine_ext:current_state() == "inspecting"
		end)

		disable_outlines = just_return
		if just_return then
			return
		end
	end

	return func(self, ...)
end)

mod:hook(OutlineSystem, "always", function(func, self, ...)
	if disable_outlines then
		return false
	end

	return func(self, ...)
end)

--- Return if the player need to reload ranged weapon,
--- if player has any ammo in clip but not a full clip,
--- and if the player has enough ammo to reload.
mod.player_requires_reload = function()
	local player_unit = Managers.player:local_player().player_unit
	if player_unit then
		local inventory_extension = ScriptUnit.extension(player_unit, "inventory_system")
		local slot_data = inventory_extension:equipment().slots["slot_ranged"]
		if slot_data then
			local right_unit = slot_data.right_unit_1p
			local left_unit = slot_data.left_unit_1p
			local ammo_extn = (right_unit and ScriptUnit.has_extension(right_unit, "ammo_system")) or
				(left_unit and ScriptUnit.has_extension(left_unit, "ammo_system"))
			if ammo_extn and (not ammo_extn:ammo_available_immediately()) and (ammo_extn.reload_time > 0.5) and
					(ammo_extn:ammo_count() < ammo_extn:clip_size()) then
				return true,
					ammo_extn:ammo_count() > 0 and ammo_extn:ammo_count() ~= ammo_extn:clip_size(),
					ammo_extn:can_reload()
			end
		end
	end
	return false
end

mod:dofile("scripts/mods/HideBuffs/anim_speedup")
mod:dofile("scripts/mods/HideBuffs/second_buff_bar")
mod:dofile("scripts/mods/HideBuffs/persistent_ammo_counter")
