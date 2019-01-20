local mod = get_mod("HideBuffs")

mod.player_ability_ability_effect_left_content_check_fun = function()
	return false
end

mod.player_ability_input_text_content_check_fun = function()
	return not mod:get(mod.SETTING_NAMES.HIDE_HOTKEYS)
end

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
	local bar_length = mod.hp_bar_width*0.88
	uvs[2][2] = ability_progress
	size[1] = bar_length * ability_progress
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
			local hp_bar_width = mod.hp_bar_width
			self._widgets[1].style.ability_effect_left.offset[1] = -hp_bar_width/2 - 50
			self._widgets[1].style.ability_effect_left.horizontal_alignment = "center"
			self._widgets[1].style.ability_effect_left.offset[2] = skull_offsets[2]
			self._widgets[1].style.ability_effect_top_left.horizontal_alignment = "center"
			self._widgets[1].style.ability_effect_top_left.offset[1] = -hp_bar_width/2 - 50
			self._widgets[1].style.ability_effect_top_left.offset[2] = skull_offsets[2]

			local skull_right_offset_x =
				hp_bar_width/2 + 40
				+ mod:get(mod.SETTING_NAMES.PLAYER_UI_PLAYER_ULT_SKULL_OFFSET_X)
			local skull_right_offset_y =
				skull_offsets[2]
				+ mod:get(mod.SETTING_NAMES.PLAYER_UI_PLAYER_ULT_SKULL_OFFSET_Y)
			self._widgets[1].style.ability_effect_right.offset[1] = skull_right_offset_x
			self._widgets[1].style.ability_effect_right.horizontal_alignment = "center"
			self._widgets[1].style.ability_effect_right.offset[2] = skull_right_offset_y
			self._widgets[1].style.ability_effect_top_right.horizontal_alignment = "center"
			self._widgets[1].style.ability_effect_top_right.offset[1] = skull_right_offset_x
			self._widgets[1].style.ability_effect_top_right.offset[2] = skull_right_offset_y

			self._widgets[1].offset[1]= -1+3
			self._widgets[1].offset[2]= 17
			self._widgets[1].offset[3]= 60
			local ability_bar_highlight_w = mod.hp_bar_width*0.95
			self._widgets[1].style.ability_bar_highlight.texture_size[1] = ability_bar_highlight_w
			self._widgets[1].style.ability_bar_highlight.texture_size[2] = 54
			self._widgets[1].style.ability_bar_highlight.offset[2] = 26
			self._widgets[1].style.ability_bar_highlight.offset[1] = 0
		end)
	end

	return func(self, dt)
end)
