local mod = get_mod("HideBuffs")

mod.player_ability_ability_effect_left_content_check_fun = function()
	return false
end

mod.player_ability_input_text_content_check_fun = function()
	return not Managers.input:is_device_active("gamepad")
		and not mod:get(mod.SETTING_NAMES.HIDE_HOTKEYS)
end

mod:hook(AbilityUI, "draw", function (func, self, dt)
	-- Assign a new content_check_function for hiding the hotkey.
	for _, pass in ipairs( self._widgets[1].element.passes ) do
		if pass.style_id == "input_text"
		or pass.style_id == "input_text_shadow"
		then
			pass.content_check_function = mod.player_ability_input_text_content_check_fun
		end
	end

	-- Skull opacity.
	local ability_widget_style = self._widgets[1].style
	local skull_opacity = mod:get(mod.SETTING_NAMES.PLAYER_UI_PLAYER_ULT_SKULL_OPACITY)
	ability_widget_style.ability_effect_top_left.color[1] = skull_opacity
	ability_widget_style.ability_effect_top_right.color[1] = skull_opacity
	ability_widget_style.ability_effect_left.color[1] = skull_opacity
	ability_widget_style.ability_effect_right.color[1] = skull_opacity

	if mod:get(mod.SETTING_NAMES.MINI_HUD_PRESET) then
		self._mod_was_in_mini_hud = true

		for _, pass in ipairs( self._widgets[1].element.passes ) do
			if pass.style_id == "ability_effect_left"
				or pass.style_id == "ability_effect_top_left" then
					pass.content_check_function = mod.player_ability_ability_effect_left_content_check_fun
			end
		end

		mod:pcall(function()
			self.ui_scenegraph.ability_root.position[1] = mod:get(mod.SETTING_NAMES.PLAYER_UI_OFFSET_X)
			self.ui_scenegraph.ability_root.position[2] = mod:get(mod.SETTING_NAMES.PLAYER_UI_OFFSET_Y)

			local skull_offsets = { 0, -15 }
			local hp_bar_width = mod.hp_bar_width
			ability_widget_style.ability_effect_left.offset[1] = -hp_bar_width/2 - 50
			ability_widget_style.ability_effect_left.horizontal_alignment = "center"
			ability_widget_style.ability_effect_left.offset[2] = skull_offsets[2]
			ability_widget_style.ability_effect_top_left.horizontal_alignment = "center"
			ability_widget_style.ability_effect_top_left.offset[1] = -hp_bar_width/2 - 50
			ability_widget_style.ability_effect_top_left.offset[2] = skull_offsets[2]

			local skull_right_offset_x =
				hp_bar_width/2 + 40
				+ mod:get(mod.SETTING_NAMES.PLAYER_UI_PLAYER_ULT_SKULL_OFFSET_X)
			local skull_right_offset_y =
				skull_offsets[2]
				+ mod:get(mod.SETTING_NAMES.PLAYER_UI_PLAYER_ULT_SKULL_OFFSET_Y)
			ability_widget_style.ability_effect_right.offset[1] = skull_right_offset_x
			ability_widget_style.ability_effect_right.horizontal_alignment = "center"
			ability_widget_style.ability_effect_right.offset[2] = skull_right_offset_y
			ability_widget_style.ability_effect_top_right.horizontal_alignment = "center"
			ability_widget_style.ability_effect_top_right.offset[1] = skull_right_offset_x
			ability_widget_style.ability_effect_top_right.offset[2] = skull_right_offset_y

			local widget_offset = self._widgets[1].offset
			widget_offset[1] = -1+3
			widget_offset[2] = 17
			local using_rect_layout = mod.using_rect_player_layout()
			if using_rect_layout then
				local ability_bar_height = mod:get(mod.SETTING_NAMES.PLAYER_ULT_BAR_HEIGHT)
				widget_offset[1] = widget_offset[1] + 1
				widget_offset[2] = widget_offset[2] + ability_bar_height/2 + 3
			end
			widget_offset[3] = 60
			local ability_bar_highlight_w = mod.hp_bar_width*(using_rect_layout and 1.04 or 0.95)
			ability_widget_style.ability_bar_highlight.texture_size[1] = ability_bar_highlight_w
			ability_widget_style.ability_bar_highlight.texture_size[2] = 54
			ability_widget_style.ability_bar_highlight.offset[2] = 26 +  mod.ult_bar_offset_y-1
			ability_widget_style.ability_bar_highlight.offset[1] = using_rect_layout and -2 or 0
		end)
	elseif self._mod_was_in_mini_hud then -- restore UI when disabling mini_hud
		self._mod_was_in_mini_hud = false

		self:_set_elements_visible(false)

		self:_create_ui_elements()
		self:set_dirty()

		for _, pass in ipairs( self._widgets[1].element.passes ) do
			if pass.style_id == "ability_effect_left"
				or pass.style_id == "ability_effect_top_left" then
					pass.content_check_function = function (content)
						return not content.parent.on_cooldown
					end
			end
		end

		for _, pass in ipairs( self._widgets[1].element.passes ) do
			if pass.style_id == "input_text"
			or pass.style_id == "input_text_shadow"
			then
				pass.content_check_function = function (content, style) -- luacheck: no unused
					return not Managers.input:is_device_active("gamepad")
						and not mod:get(mod.SETTING_NAMES.HIDE_HOTKEYS)
				end
			end
		end
	end

	return func(self, dt)
end)
