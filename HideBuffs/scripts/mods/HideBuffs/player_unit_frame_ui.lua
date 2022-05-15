local mod = get_mod("HideBuffs")

mod.player_unit_frame_update = function(unit_frame_ui)
	local self = unit_frame_ui

	if mod.force_player_unit_frame_dirty then
		mod.force_player_unit_frame_dirty = false

		for _, widget in pairs(self._widgets) do
			self:_set_widget_dirty(widget)
		end
		self:set_dirty()
	end

	-- change portrait texture_size for PORTRAIT_ICONS
	local character_portrait = self._default_widgets.default_static.style.character_portrait
	if not self._hb_mod_cached_character_portrait_texture_size then -- keep the default portrait texture_size cached
		if character_portrait.texture_size then
			self._hb_mod_cached_character_portrait_texture_size = table.clone(character_portrait.texture_size)
		else
			-- default texture_size is missing if not using console definitions
			-- so just set the default values
			self._hb_mod_cached_character_portrait_texture_size = { 86, 108 }
		end
	end

	if not character_portrait.texture_size then
		character_portrait.texture_size = {}
	end
	if mod:get(mod.SETTING_NAMES.TEAM_UI_PORTRAIT_ICONS) ~= mod.PORTRAIT_ICONS.DEFAULT then
		character_portrait.texture_size[1] = 80
		character_portrait.texture_size[2] = 80
	else
		character_portrait.texture_size[1] = self._hb_mod_cached_character_portrait_texture_size[1]
		character_portrait.texture_size[2] = self._hb_mod_cached_character_portrait_texture_size[2]
	end

	-- hide player portrait
	local hide_player_portrait = mod:get(mod.SETTING_NAMES.HIDE_PLAYER_PORTRAIT)
	local status_icon_widget = self:_widget_by_feature("status_icon", "dynamic")
	local status_icon_widget_content = status_icon_widget.content
	if (hide_player_portrait and status_icon_widget_content.visible)
	or (hide_player_portrait and status_icon_widget_content.visible == nil)
	or (not hide_player_portrait and not status_icon_widget_content.visible)
	then
		status_icon_widget_content.visible = not hide_player_portrait
		self:_set_widget_dirty(status_icon_widget)
	end

	local player_portrait_x = mod:get(mod.SETTING_NAMES.PLAYER_UI_PLAYER_PORTRAIT_OFFSET_X)
	local player_portrait_y = mod:get(mod.SETTING_NAMES.PLAYER_UI_PLAYER_PORTRAIT_OFFSET_Y)
	status_icon_widget.offset[1] = player_portrait_x
	status_icon_widget.offset[2] = player_portrait_y

	local def_static_widget = self:_widget_by_feature("default", "static")
	local def_static_widget_content = def_static_widget.content
	if (hide_player_portrait and def_static_widget_content.visible)
	or (hide_player_portrait and def_static_widget_content.visible == nil)
	or (not hide_player_portrait and not def_static_widget_content.visible)
	then
		def_static_widget_content.visible = not hide_player_portrait
		self:_set_widget_dirty(def_static_widget)
	end

	def_static_widget.offset[1] = player_portrait_x
	def_static_widget.offset[2] = player_portrait_y

	local portrait_widget = self._portrait_widgets.portrait_static
	local portrait_widget_content = portrait_widget.content
	if (hide_player_portrait and portrait_widget_content.visible)
	or (hide_player_portrait and portrait_widget_content.visible == nil)
	or (not hide_player_portrait and not portrait_widget_content.visible)
	then
		portrait_widget_content.visible = not hide_player_portrait
		self:_set_widget_dirty(portrait_widget)
	end

	portrait_widget.offset[1] = player_portrait_x
	portrait_widget.offset[2] = player_portrait_y

	-- reposition the "needs help" icon that goes over the portrait
	local def_dynamic = self:_widget_by_feature("default", "dynamic")
	def_dynamic.style.portrait_icon.offset[1] = player_portrait_x
	def_dynamic.style.portrait_icon.offset[2] = player_portrait_y

	-- NumericUI interop.
	-- NumericUI stores hp and ammo in vanilla widgets content.
	-- So just copy those values to our teammate widget.
	local hp_dynamic = self:_widget_by_feature("health", "dynamic")
	mod.numeric_ui_data.health_string = hp_dynamic.content.health_string or ""
	mod.numeric_ui_data.cooldown_string = hp_dynamic.content.cooldown_string or ""

	-- ammo
	mod.numeric_ui_data.ammo_string = def_dynamic.content.ammo_string or ""
	mod.numeric_ui_data.ammo_percent = def_dynamic.content.ammo_percent
	mod.numeric_ui_data.ammo_style = def_dynamic.content.ammo_style
end

mod.using_rect_player_layout = function()
	return mod:get(mod.SETTING_NAMES.PLAYER_RECT_LAYOUT)
end

mod.get_ult_bar_width_scale = function()
	return mod.using_rect_player_layout() and 0.97 or 0.88
end

mod.player_unit_frame_draw = function(unit_frame_ui)
	local self = unit_frame_ui

	-- disable width scaling with rect layout
	local hp_bar_width_scale = mod.using_rect_player_layout() and 1 or mod:get(mod.SETTING_NAMES.PLAYER_UI_WIDTH_SCALE)/100
	mod.hp_bar_width = mod.default_hp_bar_width * hp_bar_width_scale
	mod.ult_bar_width = mod.hp_bar_width * mod.get_ult_bar_width_scale()
	mod.hp_bar_w_scale = mod.hp_bar_width / mod.default_hp_bar_width

	self.ui_scenegraph.pivot.position[1] = mod:get(mod.SETTING_NAMES.PLAYER_UI_OFFSET_X)
	self.ui_scenegraph.pivot.position[2] = mod:get(mod.SETTING_NAMES.PLAYER_UI_OFFSET_Y)

	if mod:get(mod.SETTING_NAMES.MINI_HUD_PRESET) then
		local ability_dynamic = self._ability_widgets.ability_dynamic

		ability_dynamic.element.passes[1].content_change_function = mod.player_ability_dynamic_content_change_fun

		local ability_bar_height = mod:get(mod.SETTING_NAMES.PLAYER_ULT_BAR_HEIGHT)

		if ability_dynamic.style.ability_bar.size then
			ability_dynamic.style.ability_bar.size[2] = ability_bar_height
			ability_dynamic.offset[1] = 0
			ability_dynamic.offset[2] = 16 + 3 - ability_bar_height + ability_bar_height/2
			ability_dynamic.offset[3] = 50
			ability_dynamic.style.ability_bar.offset[1] = -mod.ult_bar_width/2

			if mod.using_rect_player_layout() then
				ability_dynamic.offset[1] = ability_dynamic.offset[1] + 1
				ability_dynamic.offset[2] = ability_dynamic.offset[2] + ability_bar_height/2 + 3 + mod.ult_bar_offset_y
			end

			mod.player_ult_offset_y = ability_dynamic.offset[2]
		end

		local hp_dynamic = self._health_widgets.health_dynamic
		local hp_dynamic_style = hp_dynamic.style
		hp_dynamic_style.grimoire_debuff_divider.offset[3] = 200
		if not mod.def_style then
			mod.def_style = {}
			for w_name, style in pairs( hp_dynamic_style ) do
				mod.def_style[w_name] = style.size
			end
		end

		local hp_bar_width = mod.hp_bar_width - 18 * mod.hp_bar_w_scale

		hp_dynamic_style.total_health_bar.size[1] = hp_bar_width
		hp_dynamic_style.total_health_bar.size[2] = mod.hp_bar_height - 18

		hp_dynamic_style.hp_bar_highlight.size[1] = hp_bar_width
		hp_dynamic_style.hp_bar_highlight.size[2] = mod.hp_bar_height - 8

		hp_dynamic_style.hp_bar.size[1] = hp_bar_width
		hp_dynamic_style.hp_bar.size[2] = mod.hp_bar_height - 18

		for _, pass in ipairs( hp_dynamic.element.passes ) do
			if pass.style_id == "grimoire_debuff_divider" then
				pass.content_change_function = mod.player_grimoire_debuff_divider_content_change_fun
			end
			if pass.style_id == "grimoire_bar" then
				pass.content_change_function = mod.player_grimoire_bar_content_change_fun
			end
		end
		hp_dynamic_style.grimoire_bar.size[2] = 18
		local grimoire_debuff_divider_size = hp_dynamic_style.grimoire_debuff_divider.size
		grimoire_debuff_divider_size[1] = 21
		grimoire_debuff_divider_size[2] = 36

		local total_health_bar_style = hp_dynamic_style.total_health_bar
		total_health_bar_style.offset[1] = -hp_dynamic_style.total_health_bar.size[1]/2
		total_health_bar_style.offset[2] = 35
		total_health_bar_style.offset[3] = -6

		local hp_bar_style = hp_dynamic_style.hp_bar
		hp_bar_style.offset[1] = -hp_dynamic_style.hp_bar.size[1]/2
		hp_bar_style.offset[2] = 35
		hp_bar_style.offset[3] = -5

		local hp_bar_highlight_style = hp_dynamic_style.hp_bar_highlight
		hp_bar_highlight_style.offset[1] = -hp_dynamic_style.hp_bar.size[1]/2
		hp_bar_highlight_style.offset[2] = 35 - 4
		hp_bar_highlight_style.offset[3] = -5 + 3
	else
		local hp_dynamic = self._health_widgets.health_dynamic
		local hp_dynamic_style = hp_dynamic.style

		local total_health_bar_style = hp_dynamic_style.total_health_bar
		total_health_bar_style.offset[2] = 10

		local hp_bar_style = hp_dynamic_style.hp_bar
		hp_bar_style.offset[2] = 10

		local hp_bar_highlight_style = hp_dynamic_style.hp_bar_highlight
		hp_bar_highlight_style.offset[2] = 10 - 4

		local ability_dynamic = self._ability_widgets.ability_dynamic
		ability_dynamic.offset[2] = 0
	end
end
