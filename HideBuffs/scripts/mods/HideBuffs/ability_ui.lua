local mod = get_mod("HideBuffs")

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