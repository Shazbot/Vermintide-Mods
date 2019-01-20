local mod = get_mod("HideBuffs")

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

		for i = 1, #self._slot_widgets do
			-- keep original offsets cached
			if not self._slot_widgets[i]._hb_mod_offset_cache then
				self._slot_widgets[i]._hb_mod_offset_cache = table.clone(self._slot_widgets[i].offset)
			end

			-- change size
			local item_slot_size = mod:get(mod.SETTING_NAMES.PLAYER_ITEM_SLOTS_SIZE)
			self._slot_widgets[i].style.texture_icon.texture_size[1] = item_slot_size
			self._slot_widgets[i].style.texture_icon.texture_size[2] = item_slot_size

			self._slot_widgets[i].style.texture_background.texture_size[1] = item_slot_size
			self._slot_widgets[i].style.texture_background.texture_size[2] = item_slot_size

			self._slot_widgets[i].style.texture_highlight.texture_size[1] = item_slot_size-4
			self._slot_widgets[i].style.texture_highlight.texture_size[2] = item_slot_size+6

			self._slot_widgets[i].style.texture_selected.texture_size[1] = item_slot_size-2
			self._slot_widgets[i].style.texture_selected.texture_size[2] = item_slot_size-18

			self._slot_widgets[i].style.texture_frame.size[1] = item_slot_size+6
			self._slot_widgets[i].style.texture_frame.size[2] = item_slot_size+6

			local resize_offset = -(item_slot_size - 40)/2
			self._slot_widgets[i].style.texture_frame.offset[1] = resize_offset
			self._slot_widgets[i].style.texture_frame.offset[2] = resize_offset
		end

		-- reposition the other item slots
		if mod.reposition_weapon_slots then
			mod.reposition_weapon_slots = false

			local num_slots = mod:get(mod.SETTING_NAMES.REPOSITION_WEAPON_SLOTS)
			if not mod:get(mod.SETTING_NAMES.HIDE_WEAPON_SLOTS) then
				num_slots = 0
			end
			for i = 1, #self._slot_widgets do
				local slot_index = i > 2 and i+num_slots or i
				self._slot_widgets[i].offset = table.clone(self._slot_widgets[slot_index]._hb_mod_offset_cache)

				self._slot_widgets[i].offset[1] = self._slot_widgets[i].offset[1] + mod:get(mod.SETTING_NAMES.PLAYER_ITEM_SLOTS_OFFSET_X)
				self._slot_widgets[i].offset[2] = self._slot_widgets[i].offset[2] + mod:get(mod.SETTING_NAMES.PLAYER_ITEM_SLOTS_OFFSET_Y)

				self._slot_widgets[i].offset[1] = self._slot_widgets[i].offset[1] + i*mod:get(mod.SETTING_NAMES.PLAYER_ITEM_SLOTS_SPACING)

				self:_set_widget_dirty(self._slot_widgets[i])
			end
		end
	end)
	return func(self, ...)
end)

mod:hook(EquipmentUI, "draw", function(func, self, dt)
	if mod:get(mod.SETTING_NAMES.SHOW_RELOAD_REMINDER)
	and self._is_visible
	then
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

	if mod:get(mod.SETTING_NAMES.MINI_HUD_PRESET)
	and self._is_visible
	then
		mod:pcall(function()
			local player_ui_offset_x = mod:get(mod.SETTING_NAMES.PLAYER_UI_OFFSET_X)
			local player_ui_offset_y = mod:get(mod.SETTING_NAMES.PLAYER_UI_OFFSET_Y)
			local static_widget_1 = self._static_widgets[1]
			static_widget_1.content.texture_id = "console_hp_bar_frame"
			if not static_widget_1.style.texture_id.size then
				static_widget_1.style.texture_id.size = {}
			end
			static_widget_1.style.texture_id.size[1] = mod.hp_bar_width
			static_widget_1.style.texture_id.size[2] = mod.hp_bar_height
			static_widget_1.offset[1] = -static_widget_1.style.texture_id.size[1]/2 + player_ui_offset_x
			static_widget_1.offset[2] = -49 + player_ui_offset_y
			static_widget_1.offset[3] = 0
			static_widget_1.scenegraph_id = "pivot"

			local static_widget_2 = self._static_widgets[2]
			if not static_widget_2.style.texture_id.size then
				static_widget_2.style.texture_id.size = {}
			end
			static_widget_2.style.texture_id.size[1] = mod.hp_bar_width
			static_widget_2.style.texture_id.size[2] = 36
			static_widget_2.offset[1] = -50 + player_ui_offset_x
			static_widget_2.offset[2] = 20 + player_ui_offset_y

			if not self._hb_mod_widget then
				self._hb_mod_widget = UIWidget.init(mod.hp_bg_rect_def)
			end
			local hp_bar_rect_w = mod.hp_bar_width - 20 * mod.hp_bar_w_scale
			self._hb_mod_widget.style.hp_bar_rect.size[1] = hp_bar_rect_w
			self._hb_mod_widget.style.hp_bar_rect.size[2] = 21
			self._hb_mod_widget.scenegraph_id = "pivot"
			self._hb_mod_widget.offset[1] = player_ui_offset_x - hp_bar_rect_w/2
			self._hb_mod_widget.offset[2] = player_ui_offset_y - 37
			self._hb_mod_widget.offset[2] = player_ui_offset_y - 37
			self._hb_mod_widget.offset[3] = -10

			self.ui_scenegraph.slot.position[1] = 149 + player_ui_offset_x
			self.ui_scenegraph.slot.position[2] = 44 + 15 + player_ui_offset_y

			if not self._hb_mod_ammo_widget then
				self._hb_mod_ammo_widget = UIWidget.init(mod.ammo_widget_def)
			end

			if not self._mod_ammo_border then
				self._mod_ammo_border = UIWidget.init(UIWidgets._mod_create_border("background_panel_bg", false))
				self._mod_ammo_border.style.border.color = { 255, 0, 0, 0 }
			end

			mod.ammo_bar_width = mod.default_ammo_bar_width * mod.hp_bar_w_scale
			local ammo_bar_w_delta = mod.default_ammo_bar_width - mod.ammo_bar_width

			local mod_ammo_border = self._mod_ammo_border
			local player_ammo_bar_height = mod:get(mod.SETTING_NAMES.PLAYER_AMMO_BAR_HEIGHT)
			mod_ammo_border.offset[1] = -19 + player_ui_offset_x + ammo_bar_w_delta/2
			mod_ammo_border.offset[2] = 18 - player_ammo_bar_height + player_ui_offset_y
			mod_ammo_border.offset[3] = -20
			mod_ammo_border.style.border.size[1] = mod.ammo_bar_width + 2
			mod_ammo_border.style.border.size[2] = player_ammo_bar_height + 2
			-- mod_ammo_border.style.border.color = { 255, 0,255,0 }

			local mod_ammo_widget = self._hb_mod_ammo_widget
			mod_ammo_widget.offset[1] = player_ui_offset_x - 25
			mod_ammo_widget.offset[2] = player_ui_offset_y + 43
			mod_ammo_widget.style.ammo_bar.color[1] = mod:get(mod.SETTING_NAMES.PLAYER_AMMO_BAR_ALPHA)
			mod_ammo_widget.style.ammo_bar.size[2] = player_ammo_bar_height
			mod_ammo_widget.style.ammo_bar.offset[1] = 7 + ammo_bar_w_delta/2
			mod_ammo_widget.style.ammo_bar.offset[2] = -24 - player_ammo_bar_height
			mod_ammo_widget.style.ammo_bar.offset[3] = 50

			local ammo_progress = self._hb_mod_ammo_widget.content.ammo_bar.bar_value
			mod_ammo_widget.style.ammo_bar.size[1] = mod.ammo_bar_width * ammo_progress
		end)

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

--- Return if the player needs to reload ranged weapon,
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
			if ammo_extn and (not ammo_extn:ammo_available_immediately()) and (ammo_extn.reload_time > 0.66) and
					(ammo_extn:ammo_count() < ammo_extn:clip_size()) then
				return true,
					ammo_extn:ammo_count() > 0 and ammo_extn:ammo_count() ~= ammo_extn:clip_size(),
					(ammo_extn:is_reloading() or ammo_extn:can_reload())
			end
		end
	end
	return false
end

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

mod.default_ammo_bar_width = 553*0.906
mod.ammo_bar_width = mod.default_ammo_bar_width

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
					local uvs = content.uvs
					uvs[2][2] = ammo_progress
					-- moved this to draw hook, refreshes better
					-- local size = style.size
					-- size[1] = mod.ammo_bar_width * ammo_progress
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
