local mod = get_mod("HideBuffs")

mod.default_ammo_bar_width = 553*0.906
mod.ammo_bar_width = mod.default_ammo_bar_width

mod:hook(EquipmentUI, "update", function(func, self, ...)
	mod:pcall(function()
		self.no_ammo_bar = false
		local inventory_extension = ScriptUnit.extension(Managers.player:local_player().player_unit, "inventory_system")
		local equipment = inventory_extension:equipment()
		local slot_data = equipment.slots["slot_ranged"]
		if slot_data then
			local item_data = slot_data.item_data
			self:_mod_update_ammo(slot_data.left_unit_1p, slot_data.right_unit_1p, BackendUtils.get_item_template(item_data))
		end

		local hotkey_alpha = mod:get(mod.SETTING_NAMES.HIDE_HOTKEYS) and 0 or 255
		for _, widget in ipairs(self._slot_widgets) do
			local style = widget.style
			if style.input_text.text_color[1] ~= hotkey_alpha then
				style.input_text.text_color[1] = hotkey_alpha
				style.input_text_shadow.text_color[1] = hotkey_alpha
				self:_set_widget_dirty(widget)
			end
		end

		-- ammo counter offset
		local ammo_widgets = self._ammo_widgets

		local ammo_counter_offset_x = mod:get(mod.SETTING_NAMES.AMMO_COUNTER_OFFSET_X)
		local ammo_counter_offset_y = mod:get(mod.SETTING_NAMES.AMMO_COUNTER_OFFSET_Y)
		for _, widget in ipairs( ammo_widgets ) do
			widget.offset[1] = ammo_counter_offset_x
			widget.offset[2] = ammo_counter_offset_y
		end
		if mod.force_ammo_dirty then
			for _, widget in pairs(self._ammo_widgets) do
				self:_set_widget_dirty(widget)
			end
			self:set_dirty()
			mod.force_ammo_dirty = false
		end

		local ammo_widgets_by_name = self._ammo_widgets_by_name

		local widgets_by_name = self._widgets_by_name
		local ammo_background_widget = widgets_by_name.ammo_background

		-- ammmo counter bg layer and opacity
		ammo_background_widget.offset[3] = mod:get(mod.SETTING_NAMES.AMMO_COUNTER_BG_LAYER)
		ammo_background_widget.style.texture_id.color[1] = mod:get(mod.SETTING_NAMES.AMMO_COUNTER_BG_OPACITY)

		local ammo_text_clip = ammo_widgets_by_name.ammo_text_clip
		local ammo_clip_font_size = mod:get(mod.SETTING_NAMES.AMMO_COUNTER_AMMO_CLIP_FONT_SIZE)
		ammo_text_clip.style.text.font_size = ammo_clip_font_size
		ammo_text_clip.style.text_shadow.font_size = ammo_clip_font_size
		ammo_text_clip.offset[1] = ammo_counter_offset_x
			+ mod:get(mod.SETTING_NAMES.AMMO_COUNTER_AMMO_CLIP_OFFSET_X)
		ammo_text_clip.offset[2] = ammo_counter_offset_y
			+ mod:get(mod.SETTING_NAMES.AMMO_COUNTER_AMMO_CLIP_OFFSET_Y)

		local ammo_text_remaining = ammo_widgets_by_name.ammo_text_remaining
		local ammo_remaining_font_size = mod:get(mod.SETTING_NAMES.AMMO_COUNTER_AMMO_REMAINING_FONT_SIZE)
		ammo_text_remaining.style.text.font_size = ammo_remaining_font_size
		ammo_text_remaining.style.text_shadow.font_size = ammo_remaining_font_size
		ammo_text_remaining.offset[1] = ammo_counter_offset_x
			+ mod:get(mod.SETTING_NAMES.AMMO_COUNTER_AMMO_REMAINING_OFFSET_X)
		ammo_text_remaining.offset[2] = ammo_counter_offset_y
			+ mod:get(mod.SETTING_NAMES.AMMO_COUNTER_AMMO_REMAINING_OFFSET_Y)

		local ammo_remaining_horizontal_alignment = mod.ALIGNMENTS_LOOKUP[mod:get(mod.SETTING_NAMES.AMMO_COUNTER_AMMO_REMAINING_ALIGNMENT)]
		ammo_text_remaining.style.text.horizontal_alignment = ammo_remaining_horizontal_alignment
		ammo_text_remaining.style.text_shadow.horizontal_alignment = ammo_remaining_horizontal_alignment

		local ammo_clip_horizontal_alignment = mod.ALIGNMENTS_LOOKUP[mod:get(mod.SETTING_NAMES.AMMO_COUNTER_AMMO_CLIP_ALIGNMENT)]
		ammo_text_clip.style.text.horizontal_alignment = ammo_clip_horizontal_alignment
		ammo_text_clip.style.text_shadow.horizontal_alignment = ammo_clip_horizontal_alignment

		local ammo_text_center = ammo_widgets_by_name.ammo_text_center
		local ammo_divider_font_size = mod:get(mod.SETTING_NAMES.AMMO_COUNTER_AMMO_DIVIDER_FONT_SIZE)
		ammo_text_center.style.text.font_size = ammo_divider_font_size
		ammo_text_center.style.text_shadow.font_size = ammo_divider_font_size

		ammo_text_center.offset[1] = ammo_counter_offset_x
			+ mod:get(mod.SETTING_NAMES.AMMO_COUNTER_AMMO_DIVIDER_OFFSET_X)
		ammo_text_center.offset[2] = ammo_counter_offset_y
			+ mod:get(mod.SETTING_NAMES.AMMO_COUNTER_AMMO_DIVIDER_OFFSET_Y)

		ammo_text_center.content.text = mod:get(mod.SETTING_NAMES.AMMO_DIVIDER_TEXT) or "/"

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

		-- reposition the enigneer ult icons
		local using_mini_hud = mod:get(mod.SETTING_NAMES.MINI_HUD_PRESET)
		local hp_bar_delta =
			using_mini_hud and (mod.hp_bar_width - mod.default_hp_bar_width)
			or 0

		local rect_layout_offset = mod.using_rect_player_layout() and 20 or 0
		for i = 1, #self._slot_widgets do
			local slot_widget = self._slot_widgets[i]
			local slot_widget_style = slot_widget.style

			if slot_widget_style.reload_icon then
				slot_widget_style.reload_icon.offset[1] =
					using_mini_hud and -50 + rect_layout_offset + hp_bar_delta/2
					or -37
				slot_widget_style.reload_icon.offset[2] = 21

				slot_widget_style.texture_icon.offset[1] =
					using_mini_hud and -68+8 - rect_layout_offset - hp_bar_delta/2
					or 28
				slot_widget_style.texture_icon.offset[2] = 19.5

				slot_widget_style.texture_selected.offset[1] =
					using_mini_hud and -68 - rect_layout_offset - hp_bar_delta/2
					or 18
				slot_widget_style.texture_selected.offset[2] = 9

				break
			end
		end

		for i = 1, #self._slot_widgets do
			-- keep original offsets cached
			local slot_widget = self._slot_widgets[i]
			if not slot_widget._hb_mod_offset_cache then
				slot_widget._hb_mod_offset_cache = table.clone(slot_widget.offset)
			end

			-- change size
			local item_slot_size = mod:get(mod.SETTING_NAMES.PLAYER_ITEM_SLOTS_SIZE)
			local slot_widget_style = slot_widget.style
			slot_widget_style.texture_icon.texture_size[1] = item_slot_size
			slot_widget_style.texture_icon.texture_size[2] = item_slot_size

			if slot_widget_style.texture_background then
				slot_widget_style.texture_background.texture_size[1] = item_slot_size
				slot_widget_style.texture_background.texture_size[2] = item_slot_size
			end

			if slot_widget_style.texture_highlight then
				slot_widget_style.texture_highlight.texture_size[1] = item_slot_size-4
				slot_widget_style.texture_highlight.texture_size[2] = item_slot_size+6
			end

			if slot_widget_style.texture_selected then
				slot_widget_style.texture_selected.texture_size[1] = item_slot_size-2
				slot_widget_style.texture_selected.texture_size[2] = item_slot_size-18
			end

			if slot_widget_style.texture_frame then
				slot_widget_style.texture_frame.size[1] = item_slot_size+6
				slot_widget_style.texture_frame.size[2] = item_slot_size+6

				local resize_offset = -(item_slot_size - 40)/2
				slot_widget_style.texture_frame.offset[1] = resize_offset
				slot_widget_style.texture_frame.offset[2] = resize_offset
			end
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
				local slot_widget = self._slot_widgets[i]
				slot_widget.offset = table.clone(self._slot_widgets[slot_index]._hb_mod_offset_cache)

				slot_widget.offset[1] = slot_widget.offset[1] + mod:get(mod.SETTING_NAMES.PLAYER_ITEM_SLOTS_OFFSET_X)
				slot_widget.offset[2] = slot_widget.offset[2] + mod:get(mod.SETTING_NAMES.PLAYER_ITEM_SLOTS_OFFSET_Y)
				if mod.using_rect_player_layout() then
					slot_widget.offset[2] = slot_widget.offset[2] + 10
				end

				slot_widget.offset[1] = slot_widget.offset[1] + i*mod:get(mod.SETTING_NAMES.PLAYER_ITEM_SLOTS_SPACING)

				self:_set_widget_dirty(slot_widget)
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

	local player_ui_offset_x = mod:get(mod.SETTING_NAMES.PLAYER_UI_OFFSET_X)
	local player_ui_offset_y = mod:get(mod.SETTING_NAMES.PLAYER_UI_OFFSET_Y)

	-- restore original values when mini_hud gets disabled
	if not mod:get(mod.SETTING_NAMES.MINI_HUD_PRESET)
	and self._mod_static_widget_1_backup
	and self._mod_was_using_mini_hud
	then
		local static_widget_1 = self._static_widgets[1]
		local static_widget_2 = self._widgets_by_name["background_panel_bg"]
		self._mod_was_using_mini_hud = false

		local static_widget_1_backup = self._mod_static_widget_1_backup
		static_widget_1.content = table.clone(static_widget_1_backup.content)
		static_widget_1.offset = table.clone(static_widget_1_backup.offset)
		static_widget_1.scenegraph_id = static_widget_1_backup.scenegraph_id

		local parent_temp = static_widget_1.style.texture_id.parent
		static_widget_1.style.texture_id = table.clone(static_widget_1_backup.texture_id)
		static_widget_1.style.texture_id.parent = parent_temp

		local static_widget_2_backup = self._mod_static_widget_2_backup
		static_widget_2.offset = table.clone(static_widget_2_backup.offset)

		parent_temp = static_widget_2.style.texture_id.parent
		static_widget_2.style.texture_id = table.clone(static_widget_2_backup.texture_id)
		static_widget_2.style.texture_id.parent = parent_temp

		self.ui_scenegraph.slot.position[1] = 149 + player_ui_offset_x
		self.ui_scenegraph.slot.position[2] = 44 + player_ui_offset_y

		--self.ui_scenegraph.background_panel.position[1] = 0 + player_ui_offset_x
		--self.ui_scenegraph.background_panel.position[2] = 0 + player_ui_offset_y

		local background_panel_bg_w = self._widgets_by_name["background_panel_bg"]
		if background_panel_bg_w then
			background_panel_bg_w.content.visible = true
		end
		local background_panel_cog_w = self._widgets_by_name["background_panel"]
		if background_panel_cog_w then
			background_panel_cog_w.content.visible = true
		end
	end

	if self._is_visible then
		if mod:get(mod.SETTING_NAMES.MINI_HUD_PRESET) then
			self._mod_was_using_mini_hud = true
			local using_rect_layout = mod.using_rect_player_layout()
			mod:pcall(function()
				local static_widget_1 = self._static_widgets[1]
				local static_widget_2 = self._widgets_by_name["background_panel_bg"]

				-- cache original values during first draw with mini_hud active
				if not self._mod_static_widget_1_backup then
					self._mod_static_widget_1_backup = {
						content = table.clone(static_widget_1.content),
						offset = table.clone(static_widget_1.offset),
						scenegraph_id = static_widget_1.scenegraph_id,
					}
					local parent_temp = static_widget_1.style.texture_id.parent
					static_widget_1.style.texture_id.parent = nil
					self._mod_static_widget_1_backup.texture_id = table.clone(static_widget_1.style.texture_id)
					static_widget_1.style.texture_id.parent = parent_temp

					self._mod_static_widget_2_backup = {
						offset = table.clone(static_widget_2.offset),
					}

					parent_temp = static_widget_2.style.texture_id.parent
					static_widget_2.style.texture_id.parent = nil
					self._mod_static_widget_2_backup.texture_id = table.clone(static_widget_2.style.texture_id)
					static_widget_2.style.texture_id.parent = parent_temp
				end

				static_widget_1.content.texture_id = "console_hp_bar_frame"
				if not static_widget_1.style.texture_id.size then
					static_widget_1.style.texture_id.size = {}
				end
				static_widget_1.style.texture_id.size[1] = using_rect_layout and 0 or mod.hp_bar_width
				static_widget_1.style.texture_id.size[2] = using_rect_layout and 0 or mod.hp_bar_height
				static_widget_1.offset[1] = -static_widget_1.style.texture_id.size[1]/2 + player_ui_offset_x
				static_widget_1.offset[2] = -49 + player_ui_offset_y
				static_widget_1.offset[3] = 0
				static_widget_1.scenegraph_id = "pivot"

				if not static_widget_2.style.texture_id.size then
					static_widget_2.style.texture_id.size = {}
				end
				static_widget_2.style.texture_id.size[1] = mod.hp_bar_width
				static_widget_2.style.texture_id.size[2] = 36
				static_widget_2.offset[1] = -50 + player_ui_offset_x
				static_widget_2.offset[2] = 20 + player_ui_offset_y

				if not self._hb_mod_widget or mod.was_reloaded then
					self._hb_mod_widget = UIWidget.init(mod.hp_bg_rect_def)
				end
				local hp_bar_rect_w = mod.hp_bar_width - 20 * mod.hp_bar_w_scale
				self._hb_mod_widget.style.hp_bar_rect.size[1] = hp_bar_rect_w
				self._hb_mod_widget.style.hp_bar_rect.size[2] = 21
				self._hb_mod_widget.scenegraph_id = "pivot"
				self._hb_mod_widget.offset[1] = player_ui_offset_x - hp_bar_rect_w/2
				self._hb_mod_widget.offset[2] = player_ui_offset_y - 37
				self._hb_mod_widget.offset[3] = -10

				self.ui_scenegraph.slot.position[1] = 149 + player_ui_offset_x
				self.ui_scenegraph.slot.position[2] = 44 + 15 + player_ui_offset_y

				--self.ui_scenegraph.background_panel.position[1] = 0 + player_ui_offset_x
				--self.ui_scenegraph.background_panel.position[2] = 0 + 10 + player_ui_offset_y

				local background_panel_bg_w = self._widgets_by_name["background_panel_bg"]
				if background_panel_bg_w then
					background_panel_bg_w.content.visible = false
				end
				local background_panel_cog_w = self._widgets_by_name["background_panel"]
				if background_panel_cog_w then
					background_panel_cog_w.content.visible = false
				end

				mod.handle_player_ammo_bar(self)
				mod.handle_player_rect_layout_widget(self)
			end)
		end

		mod.handle_player_numeric_ui(self)

		if self._dirty then
			if self._hb_mod_ammo_widget then
				self:_set_widget_dirty(self._hb_mod_ammo_widget)
			end
			if self._mod_ammo_border then
				self:_set_widget_dirty(self._mod_ammo_border)
			end
			if self._rect_layout_w then
				self:_set_widget_dirty(self._rect_layout_w)
			end
			if self._hb_num_ui_player_widget then
				self:_set_widget_dirty(self._hb_num_ui_player_widget)
			end
		end

		local ui_renderer = self.ui_renderer
		local ui_scenegraph = self.ui_scenegraph
		local input_service = self.input_manager:get_service("ingame_menu")
		local render_settings = self.render_settings
		UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt, nil, render_settings)
		if mod:get(mod.SETTING_NAMES.MINI_HUD_PRESET) then
			local using_rect_layout = mod.using_rect_player_layout()
			-- draw the custom player widget
			if not using_rect_layout and self._hb_mod_widget then
				UIRenderer.draw_widget(ui_renderer, self._hb_mod_widget)
			end
			-- draw the ammo bar widgets
			if mod:get(mod.SETTING_NAMES.PLAYER_AMMO_BAR)
			and not self.no_ammo_bar
			then
				if self._hb_mod_ammo_widget then
					UIRenderer.draw_widget(ui_renderer, self._hb_mod_ammo_widget)
				end
				if self._mod_ammo_border then
					UIRenderer.draw_widget(ui_renderer, self._mod_ammo_border)
				end
			end
			-- draw the numeric ui widget
			if using_rect_layout and self._rect_layout_w then
				UIRenderer.draw_widget(ui_renderer, self._rect_layout_w)
			end
		end
		if self._hb_num_ui_player_widget then
			UIRenderer.draw_widget(ui_renderer, self._hb_num_ui_player_widget)
		end
		UIRenderer.end_pass(ui_renderer)
	end

	return func(self, dt)
end)

mod.color_black = { 255, 0, 0, 0 }

mod.handle_player_ammo_bar = function(unit_frame_ui)
	local self = unit_frame_ui

	local player_ui_offset_x = mod:get(mod.SETTING_NAMES.PLAYER_UI_OFFSET_X)
	local player_ui_offset_y = mod:get(mod.SETTING_NAMES.PLAYER_UI_OFFSET_Y)

	if not self._hb_mod_ammo_widget then
		self._hb_mod_ammo_widget = UIWidget.init(mod.ammo_widget_def)
	end

	if not self._mod_ammo_border then
		self._mod_ammo_border = UIWidget.init(UIWidgets._mod_create_border("background_panel_bg", false))
		self._mod_ammo_border.style.border.color = { 255, 0, 0, 0 }
	end

	local using_rect_layout = mod.using_rect_player_layout()
	mod.default_ammo_bar_width = using_rect_layout and 553 or 553*0.906
	mod.ammo_bar_width = mod.default_ammo_bar_width * mod.hp_bar_w_scale
	local ammo_bar_w_delta = mod.default_ammo_bar_width - mod.ammo_bar_width

	local mod_ammo_border = self._mod_ammo_border
	local player_ammo_bar_height = mod:get(mod.SETTING_NAMES.PLAYER_AMMO_BAR_HEIGHT)
	mod_ammo_border.offset[1] = -19 + player_ui_offset_x + ammo_bar_w_delta/2
	mod_ammo_border.offset[2] = 18 - player_ammo_bar_height + player_ui_offset_y
	mod_ammo_border.offset[3] = -20
	mod_ammo_border.style.border.size[1] = mod.ammo_bar_width + 2
	if using_rect_layout then
		local width = mod.hp_bar_width - 20 * mod.hp_bar_w_scale + 4
		mod_ammo_border.style.border.size[1] = width + 4
	end
	mod_ammo_border.style.border.size[2] = player_ammo_bar_height + 2
	if using_rect_layout then
		mod_ammo_border.offset[1] = mod_ammo_border.offset[1] - 19
		mod_ammo_border.offset[2] = mod_ammo_border.offset[2] + 3
	end

	if using_rect_layout then
		mod.ammo_bar_width = mod.hp_bar_width * 0.972
		mod_ammo_border.style.border.color = mod.rect_layout_border_color
	else
		mod_ammo_border.style.border.color = mod.color_black
	end

	local mod_ammo_widget = self._hb_mod_ammo_widget
	mod_ammo_widget.offset[1] = player_ui_offset_x - 25
	mod_ammo_widget.offset[2] = player_ui_offset_y + 43
	if using_rect_layout then
		mod_ammo_widget.offset[1] = mod_ammo_widget.offset[1] - 18
		mod_ammo_widget.offset[2] = mod_ammo_widget.offset[2] + 3
	end
	mod_ammo_widget.style.ammo_bar.color[1] = mod:get(mod.SETTING_NAMES.PLAYER_AMMO_BAR_ALPHA)
	mod_ammo_widget.style.ammo_bar.size[2] = player_ammo_bar_height
	mod_ammo_widget.style.ammo_bar.offset[1] = 7 + ammo_bar_w_delta/2
	mod_ammo_widget.style.ammo_bar.offset[2] = -24 - player_ammo_bar_height
	mod_ammo_widget.style.ammo_bar.offset[3] = 50

	local ammo_progress = self._hb_mod_ammo_widget.content.ammo_bar.bar_value
	mod_ammo_widget.style.ammo_bar.size[1] = mod.ammo_bar_width * ammo_progress
end

mod.handle_player_numeric_ui = function(unit_frame_ui)
	local self = unit_frame_ui

	local player_ui_offset_x = mod:get(mod.SETTING_NAMES.PLAYER_UI_OFFSET_X)
	local player_ui_offset_y = mod:get(mod.SETTING_NAMES.PLAYER_UI_OFFSET_Y)

	-- NumericUI interop.
	-- Display values gotten from Numeric UI on our own widget.
	if not self._hb_num_ui_player_widget then
		self._hb_num_ui_player_widget = UIWidget.init(mod.numeric_ui_player_widget_def)
		self._hb_num_ui_player_widget.scenegraph_id = "pivot"
	end

	local num_ui_widget = self._hb_num_ui_player_widget
	local num_ui_widget_style = num_ui_widget.style

	num_ui_widget.content.health_string = mod.numeric_ui_data.health_string or ""
	num_ui_widget.content.cooldown_string = mod.numeric_ui_data.cooldown_string or ""

	local hp_text_x = mod.hp_bar_width/2 + mod:get(mod.SETTING_NAMES.PLAYER_NUMERIC_UI_HP_OFFSET_X)
	num_ui_widget_style.hp_text.offset[1] = hp_text_x
	num_ui_widget_style.hp_text_shadow.offset[1] = hp_text_x + 2

	local hp_text_y = mod.hp_bar_height/4 + mod:get(mod.SETTING_NAMES.PLAYER_NUMERIC_UI_HP_OFFSET_Y)
	num_ui_widget_style.hp_text.offset[2] = hp_text_y
	num_ui_widget_style.hp_text_shadow.offset[2] = hp_text_y - 2

	num_ui_widget_style.hp_text.offset[3] = 151
	num_ui_widget_style.hp_text_shadow.offset[3] = 150

	local ult_cd_text_x = mod.hp_bar_width/2 + mod:get(mod.SETTING_NAMES.PLAYER_NUMERIC_UI_ULT_CD_OFFSET_X)
	ult_cd_text_x = ult_cd_text_x - 8
	num_ui_widget_style.cooldown_text.offset[1] = ult_cd_text_x
	num_ui_widget_style.cooldown_text_shadow.offset[1] = ult_cd_text_x + 2

	local ult_cd_text_y = mod.hp_bar_height/4 + mod:get(mod.SETTING_NAMES.PLAYER_NUMERIC_UI_ULT_CD_OFFSET_Y)
	ult_cd_text_y = ult_cd_text_y + (self._hb_mod_widget and 0 or 5)
	num_ui_widget_style.cooldown_text.offset[2] = ult_cd_text_y
	num_ui_widget_style.cooldown_text_shadow.offset[2] = ult_cd_text_y - 2

	num_ui_widget_style.cooldown_text.offset[3] = 151-2
	num_ui_widget_style.cooldown_text_shadow.offset[3] = 150-2

	local numeric_ui_font_size = mod:get(mod.SETTING_NAMES.PLAYER_NUMERIC_UI_HP_FONT_SIZE)
	num_ui_widget_style.hp_text.font_size = numeric_ui_font_size
	num_ui_widget_style.hp_text_shadow.font_size = numeric_ui_font_size

	local numeric_ui_ult_font_size = mod:get(mod.SETTING_NAMES.PLAYER_NUMERIC_UI_ULT_CD_FONT_SIZE)
	num_ui_widget_style.cooldown_text.font_size = numeric_ui_ult_font_size
	num_ui_widget_style.cooldown_text_shadow.font_size = numeric_ui_ult_font_size

	num_ui_widget.offset[1] = player_ui_offset_x - mod.hp_bar_width/2
	num_ui_widget.offset[2] = player_ui_offset_y - 59
	if mod:get(mod.SETTING_NAMES.MINI_HUD_PRESET) and self._hb_mod_widget then
		num_ui_widget.offset[1] = self._hb_mod_widget.offset[1]
		num_ui_widget.offset[2] = self._hb_mod_widget.offset[2]
	end
	num_ui_widget.offset[3] = -10
end

EquipmentUI._mod_update_ammo = function (self, left_hand_wielded_unit, right_hand_wielded_unit, item_template)
	local ammo_extension

	if not item_template.ammo_data then
		self.no_ammo_bar = true
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

	local max_ammo = ammo_extension:max_ammo()
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
			if ammo_extn and (not ammo_extn:ammo_available_immediately()) and (ammo_extn._reload_time > 0.66) and
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

mod.handle_player_rect_layout_widget = function(unit_frame_ui)
	local self = unit_frame_ui

	local player_ui_offset_x = mod:get(mod.SETTING_NAMES.PLAYER_UI_OFFSET_X)
	local player_ui_offset_y = mod:get(mod.SETTING_NAMES.PLAYER_UI_OFFSET_Y)

	if not self._rect_layout_w or mod.was_reloaded then
		self._rect_layout_w = UIWidget.init(mod.rect_player_ui_layout_def)
	end

	local widget = self._rect_layout_w

	local width = mod.hp_bar_width - 20 * mod.hp_bar_w_scale + 4
	local height = mod.hp_bar_height -17
	local hp_bar_bg = widget.style.hp_bar_bg
	hp_bar_bg.size[1] = width
	hp_bar_bg.size[2] = height

	local hp_bar_border = widget.style.hp_bar_border
	hp_bar_border.size[1] = width + 4
	hp_bar_border.size[2] = height + 4
	hp_bar_border.offset[1] = -2
	hp_bar_border.offset[2] = -2

	 hp_bar_border.color = mod.rect_layout_border_color

	-- hp_bar_bg.size = { 0,0 }
	-- hp_bar_border.size = { 0,0 }

	local ability_bar_height = mod:get(mod.SETTING_NAMES.PLAYER_ULT_BAR_HEIGHT)
	local ult_bar_bg = widget.style.ult_bar_bg
	ult_bar_bg.size[1] = width
	ult_bar_bg.size[2] = ability_bar_height + 2

	local ult_bar_border = widget.style.ult_bar_border
	 ult_bar_border.color = mod.rect_layout_border_color
	ult_bar_border.size[1] = width + 4
	ult_bar_border.size[2] = ability_bar_height + 6
	ult_bar_border.offset[1] = -2
	ult_bar_border.offset[2] = -2

	ult_bar_bg.offset[1] = 0
	ult_bar_bg.offset[2] = 50
	if mod.player_ult_offset_y then
		ult_bar_bg.offset[2] = mod.player_ult_offset_y - 2
		ult_bar_border.offset[2] = mod.player_ult_offset_y - 4
	end

	widget.offset[1] = player_ui_offset_x - 37+1
	widget.offset[2] = player_ui_offset_y + 24
end

mod.ut_set_ammo_divider_info = "Replace ammo divider (default is /) with any custom text."
mod.set_ammo_divider = function(...)
	local args={...}
	if #args ~= 0 then
		local new_divider = table.concat(args, " ")
		mod:set(mod.SETTING_NAMES.AMMO_DIVIDER_TEXT, new_divider, true)
		mod.force_ammo_dirty = true
		mod.vmf.save_unsaved_settings_to_file()
	else
		mod:echo("New divider missing! e.g. /ut_set_ammo_divider /")
	end
end
mod:command("ut_set_ammo_divider", mod.ut_set_ammo_divider_info, function(...) mod.set_ammo_divider(...) end)
