local mod = get_mod("HideBuffs")

local tablex = require'pl.tablex'

mod.teammate_unit_frame_update = function(unit_frame_ui)
	local self = unit_frame_ui
	if self._teammate_custom_widget then -- update important icons
		local teammate_widget_content = self._teammate_custom_widget.content
		local important_icons_enabled = mod:get(mod.SETTING_NAMES.TEAM_UI_ICONS_GROUP)
		self.important_icons_enabled = important_icons_enabled
		if teammate_widget_content.important_icons_enabled ~= important_icons_enabled then
			teammate_widget_content.important_icons_enabled = important_icons_enabled
			self:_set_widget_dirty(self._teammate_custom_widget)
			self:set_dirty()
		end
		if teammate_widget_content.has_natural_bond ~= self.has_natural_bond
		or teammate_widget_content.is_wounded ~= self.is_wounded
		or teammate_widget_content.has_healshare_talent ~= self.has_healshare_talent
		or teammate_widget_content.has_hand_of_shallya ~= self.has_hand_of_shallya
		then
			teammate_widget_content.has_natural_bond = self.has_natural_bond
			teammate_widget_content.is_wounded = self.is_wounded
			teammate_widget_content.has_healshare_talent = self.has_healshare_talent
			teammate_widget_content.has_hand_of_shallya = self.has_hand_of_shallya
			self:_set_widget_dirty(self._teammate_custom_widget)
			self:set_dirty()
		end

		-- NumericUI interop.
		-- NumericUI stores hp and ammo in vanilla widgets content.
		-- So just copy those values to our teammate widget.
		local hp_dynamic = self:_widget_by_feature("health", "dynamic")
		teammate_widget_content.health_string = hp_dynamic.content.health_string or ""

		-- ammo
		local def_dynamic = self:_widget_by_feature("default", "dynamic")
		teammate_widget_content.cooldown_string = def_dynamic.content.cooldown_string or ""
		teammate_widget_content.ammo_string = def_dynamic.content.ammo_string or ""
		teammate_widget_content.ammo_percent = def_dynamic.content.ammo_percent
		teammate_widget_content.ammo_style = def_dynamic.content.ammo_style

		local teammate_widget_style = self._teammate_custom_widget.style
		local ammo_text_x = 80 + mod:get(mod.SETTING_NAMES.TEAM_UI_NUMERIC_UI_AMMO_OFFSET_X)
		teammate_widget_style.ammo_text.offset[1] = ammo_text_x
		teammate_widget_style.ammo_text_shadow.offset[1] = ammo_text_x + 2

		local ammo_text_y = 65 + mod:get(mod.SETTING_NAMES.TEAM_UI_NUMERIC_UI_AMMO_OFFSET_Y)
		teammate_widget_style.ammo_text.offset[2] = ammo_text_y
		teammate_widget_style.ammo_text_shadow.offset[2] = ammo_text_y - 2

		local hp_text_x = 80 + mod:get(mod.SETTING_NAMES.TEAM_UI_NUMERIC_UI_HP_OFFSET_X)
		teammate_widget_style.hp_text.offset[1] = hp_text_x
		teammate_widget_style.hp_text_shadow.offset[1] = hp_text_x + 1

		local hp_text_y = 100 + mod:get(mod.SETTING_NAMES.TEAM_UI_NUMERIC_UI_HP_OFFSET_Y)
		teammate_widget_style.hp_text.offset[2] = hp_text_y
		teammate_widget_style.hp_text_shadow.offset[2] = hp_text_y - 1

		local ult_cd_text_x = 70 + mod:get(mod.SETTING_NAMES.TEAM_UI_NUMERIC_UI_ULT_CD_OFFSET_X)
		teammate_widget_style.cooldown_text.offset[1] = ult_cd_text_x
		teammate_widget_style.cooldown_text_shadow.offset[1] = ult_cd_text_x + 2

		local ult_cd_text_y = 40 + mod:get(mod.SETTING_NAMES.TEAM_UI_NUMERIC_UI_ULT_CD_OFFSET_Y)
		teammate_widget_style.cooldown_text.offset[2] = ult_cd_text_y
		teammate_widget_style.cooldown_text_shadow.offset[2] = ult_cd_text_y - 2

		local numeric_ui_font_size = mod:get(mod.SETTING_NAMES.TEAM_UI_NUMERIC_UI_HP_FONT_SIZE)
		teammate_widget_style.hp_text.font_size = numeric_ui_font_size
		teammate_widget_style.hp_text_shadow.font_size = numeric_ui_font_size
	end

	if not self._hb_mod_cached_character_portrait_size then -- keep the default portrait size cached
		self._hb_mod_cached_character_portrait_size = table.clone(self._default_widgets.default_static.style.character_portrait.size)
	end
	local portrait_scale = mod:get(mod.SETTING_NAMES.TEAM_UI_PORTRAIT_SCALE)/100
	local scaled_character_portrait_size = tablex.map("*", self._hb_mod_cached_character_portrait_size, portrait_scale)
	if mod:get(mod.SETTING_NAMES.TEAM_UI_PORTRAIT_ICONS) ~= mod.PORTRAIT_ICONS.DEFAULT then
		self._default_widgets.default_static.style.character_portrait.size = tablex.map("*", {80,80}, portrait_scale)
	else
		self._default_widgets.default_static.style.character_portrait.size = scaled_character_portrait_size
	end

	local status_icon_dynamic = self:_widget_by_feature("status_icon", "dynamic")
	local status_icon_style = status_icon_dynamic.style
	status_icon_style.portrait_icon.size = tablex.map("*", self._hb_mod_cached_character_portrait_size, portrait_scale)

	local team_ui_portrait_offset_x = mod:get(mod.SETTING_NAMES.TEAM_UI_PORTRAIT_OFFSET_X)
	local team_ui_portrait_offset_y = mod:get(mod.SETTING_NAMES.TEAM_UI_PORTRAIT_OFFSET_Y)

	local portrait_size = status_icon_style.portrait_icon.size
	status_icon_style.portrait_icon.offset[1] = -portrait_size[1]/2 + team_ui_portrait_offset_x
	local delta_y = self._hb_mod_cached_character_portrait_size[2] -
		self._default_widgets.default_static.style.character_portrait.size[2]
	if mod:get(mod.SETTING_NAMES.TEAM_UI_PORTRAIT_ICONS) ~= mod.PORTRAIT_ICONS.DEFAULT then
		delta_y = self._hb_mod_cached_character_portrait_size[2] - scaled_character_portrait_size[2]
	end
	status_icon_style.portrait_icon.offset[2] = delta_y/2 + team_ui_portrait_offset_y

	local def_dynamic_w = self:_widget_by_feature("default", "dynamic")
	local def_dynamic_style = def_dynamic_w.style

	for _, talk_widget_name in ipairs( mod.def_dynamic_widget_names ) do
		def_dynamic_style[talk_widget_name].offset[1] = 60 + team_ui_portrait_offset_x
		def_dynamic_style[talk_widget_name].offset[2] = 30 + team_ui_portrait_offset_y
	end

	local connecting_icon_style = def_dynamic_style.connecting_icon
	connecting_icon_style.offset[1] = -25 + team_ui_portrait_offset_x
	connecting_icon_style.offset[2] = 34 + team_ui_portrait_offset_y

	if not self._hb_mod_adjusted_portraits then
		self._hb_mod_adjusted_portraits = true
		mod.adjust_portrait_size_and_position(self)
	end

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
		local team_ui_name_offset_x = mod:get(mod.SETTING_NAMES.TEAM_UI_NAME_OFFSET_X)
		local team_ui_name_offset_y = mod:get(mod.SETTING_NAMES.TEAM_UI_NAME_OFFSET_Y)

		local def_static_widget_style = def_static_widget.style
		def_static_widget_style.player_name.offset[1] = 0 + team_ui_name_offset_x
		def_static_widget_style.player_name.offset[2] = 110 + team_ui_name_offset_y
		def_static_widget_style.player_name_shadow.offset[1] = 2 + team_ui_name_offset_x
		def_static_widget_style.player_name_shadow.offset[2] = 110 - 2 + team_ui_name_offset_y

		local team_ui_player_name_alignment = mod.ALIGNMENTS_LOOKUP[mod:get(mod.SETTING_NAMES.TEAM_UI_PLAYER_NAME_ALIGNMENT)]
		def_static_widget_style.player_name.horizontal_alignment = team_ui_player_name_alignment
		def_static_widget_style.player_name_shadow.horizontal_alignment = team_ui_player_name_alignment
	end

	-- different hero portraits
	local team_ui_portrait_icons = mod:get(mod.SETTING_NAMES.TEAM_UI_PORTRAIT_ICONS)
	local profile_index = self.profile_index
	if profile_index then
		local profile_data = SPProfiles[profile_index]
		local def_static_content = self:_widget_by_feature("default", "static").content
		local character_portrait = def_static_content.character_portrait
		if not def_static_content.portrait_backup then
			def_static_content.portrait_backup = character_portrait
		end
		local default_portrait = def_static_content.portrait_backup

		if team_ui_portrait_icons == mod.PORTRAIT_ICONS.HERO then
			local hero_icon = UISettings.hero_icons.medium[profile_data.display_name]
			if character_portrait ~= hero_icon then
				mod.set_portrait(self, hero_icon)
			end
		elseif team_ui_portrait_icons == mod.PORTRAIT_ICONS.HATS then
			local careers = profile_data.careers
			local career_index = self.career_index
			if career_index then
				local career_name = careers[career_index].display_name
				local hat_icon = mod.career_name_to_hat_icon[career_name]
				if hat_icon and character_portrait ~= hat_icon then
					mod.set_portrait(self, hat_icon)
				end
			end
		elseif character_portrait ~= default_portrait then
			mod.set_portrait(self, default_portrait)
		end

		-- for testing
		-- self:set_portrait("hero_icon_medium_dwarf_ranger_yellow")
		-- self:set_portrait("icon_wpn_dw_axe_01_t1_dual")
		-- self:set_portrait("icon_ironbreaker_hat_0000")
		-- local widget = self:_widget_by_feature("default", "static")
		-- widget.style.character_portrait.size = {80,80}
		-- widget.style.character_portrait.offset[2] = -15+(108-86)+7
		-- mod.adjust_portrait_size_and_position(self)
	end
end

mod.teammate_unit_frame_draw = function(unit_frame_ui)
	local self = unit_frame_ui
	local team_ui_ammo_bar_enabled = mod:get(mod.SETTING_NAMES.TEAM_UI_AMMO_BAR)

	-- adjust loadout dynamic offset(item slots)
	local loadout_dynamic = self._equipment_widgets.loadout_dynamic
	loadout_dynamic.offset[1] = -15 + mod:get(mod.SETTING_NAMES.TEAM_UI_ITEM_SLOTS_OFFSET_X)
	loadout_dynamic.offset[2] = -121 + mod:get(mod.SETTING_NAMES.TEAM_UI_ITEM_SLOTS_OFFSET_Y)

	if team_ui_ammo_bar_enabled then
		loadout_dynamic.offset[2] = loadout_dynamic.offset[2] - 8
	end

	local start_x = -35
	local item_spacing = mod:get(mod.SETTING_NAMES.TEAM_UI_ITEM_SLOTS_SPACING)
	local item_size = mod:get(mod.SETTING_NAMES.TEAM_UI_ITEM_SLOTS_SIZE) + 4

	for i = 1, 3 do
		loadout_dynamic.style["item_slot_"..i].offset[1] = start_x+2.5+item_spacing*(i-1)
		loadout_dynamic.style["item_slot_"..i].size[1] = item_size-4
		loadout_dynamic.style["item_slot_"..i].size[2] = item_size-4

		for _, item_slot_name in ipairs( mod.item_slot_widgets ) do
			loadout_dynamic.style[item_slot_name..i].offset[1] = start_x+item_spacing*(i-1)
			loadout_dynamic.style[item_slot_name..i].size[1] = item_size
			loadout_dynamic.style[item_slot_name..i].size[2] = item_size
		end
	end

	local hp_bar_scale_x = mod:get(mod.SETTING_NAMES.TEAM_UI_HP_BAR_SCALE_WIDTH) / 100
	local hp_bar_scale_y = mod:get(mod.SETTING_NAMES.TEAM_UI_HP_BAR_SCALE_HEIGHT) / 100
	mod.hp_bar_size = { 92*hp_bar_scale_x, 9*hp_bar_scale_y }
	local hp_bar_size = mod.hp_bar_size

	local static_w_style = self:_widget_by_feature("default", "static").style
	static_w_style.ability_bar_bg.size = { hp_bar_size[1], 5*hp_bar_scale_y }

	local ability_bar_delta_y = 5*hp_bar_scale_y - 5
	local delta_x = hp_bar_size[1] - 92
	local delta_y = hp_bar_size[2] - 9
	mod.hp_bar_delta_y = delta_y

	static_w_style.hp_bar_bg.size[1] = 100 + delta_x
	static_w_style.hp_bar_bg.size[2] = 17 + delta_y + ability_bar_delta_y

	static_w_style.hp_bar_fg.size[1] = 100 + delta_x
	static_w_style.hp_bar_fg.size[2] = 24 + delta_y + ability_bar_delta_y

	static_w_style.ability_bar_bg.size[1] = 92 + delta_x
	static_w_style.ability_bar_bg.size[2] = 5*hp_bar_scale_y

	local hp_bar_offset_x = mod:get(mod.SETTING_NAMES.TEAM_UI_HP_BAR_OFFSET_X)
	local hp_bar_offset_y = mod:get(mod.SETTING_NAMES.TEAM_UI_HP_BAR_OFFSET_Y)
	mod.hp_bar_offset_x = hp_bar_offset_x
	mod.hp_bar_offset_y = hp_bar_offset_y

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

	hp_dynamic_style.total_health_bar.size[1] = hp_bar_size[1]
	hp_dynamic_style.total_health_bar.size[2] = hp_bar_size[2]
	hp_dynamic_style.hp_bar.size[1] = hp_bar_size[1]
	hp_dynamic_style.hp_bar.size[2] = hp_bar_size[2]
	hp_dynamic_style.grimoire_bar.size[1] = hp_bar_size[1]
	hp_dynamic_style.grimoire_bar.size[2] = hp_bar_size[2]

	hp_dynamic_style.hp_bar_highlight.offset[1] = -50 + hp_bar_offset_x
	hp_dynamic_style.hp_bar_highlight.offset[2] = -32 + hp_bar_offset_y

	hp_dynamic_style.grimoire_debuff_divider.size[1] = 3
	hp_dynamic_style.grimoire_debuff_divider.size[2] = 28 + delta_y

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

	self._teammate_custom_widget.style.hp_bar_fg.size[1] = 100 + delta_x
	self._teammate_custom_widget.style.hp_bar_fg.size[2] = 24 + delta_y + ability_bar_delta_y

	self._teammate_custom_widget.style.hp_bar_fg.offset[1] = -62 + hp_bar_offset_x
	self._teammate_custom_widget.style.hp_bar_fg.offset[2] = -37 + hp_bar_offset_y - delta_y + ability_bar_delta_y

	mod.team_ammo_bar_length = 92 + delta_x

	local ammo_bar_w = 92 + delta_x
	local ammo_bar_h = 5*hp_bar_scale_y
	self._teammate_custom_widget.style.ammo_bar.size[1] = ammo_bar_w
	self._teammate_custom_widget.style.ammo_bar.size[2] = ammo_bar_h

	self._teammate_custom_widget.style.ammo_bar_bg.size[1] = ammo_bar_w
	self._teammate_custom_widget.style.ammo_bar_bg.size[2] = ammo_bar_h

	local ammo_bar_offset_x = -59 + hp_bar_offset_x
	local ammo_bar_offset_y = -35 + hp_bar_offset_y - delta_y + ability_bar_delta_y
	self._teammate_custom_widget.style.ammo_bar.offset[1] = ammo_bar_offset_x
	self._teammate_custom_widget.style.ammo_bar.offset[2] = ammo_bar_offset_y

	self._teammate_custom_widget.style.ammo_bar_bg.offset[1] = ammo_bar_offset_x
	self._teammate_custom_widget.style.ammo_bar_bg.offset[2] = ammo_bar_offset_y

	local important_icons_offset_x = mod:get(mod.SETTING_NAMES.TEAM_UI_ICONS_OFFSET_X)
	local important_icons_offset_y = mod:get(mod.SETTING_NAMES.TEAM_UI_ICONS_OFFSET_Y)
	local icons_start_offset_x = 44
	local icons_start_offset_y = -31
	local custom_widget_style = self._teammate_custom_widget.style

	local icons_offset_x = icons_start_offset_x + delta_x + hp_bar_offset_x + important_icons_offset_x
	local icons_offset_y = icons_start_offset_y + hp_bar_offset_y + delta_y/2 + important_icons_offset_y

	custom_widget_style.icon_natural_bond.offset[1] = icons_offset_x
	custom_widget_style.icon_natural_bond.offset[2] = icons_offset_y

	local teammate_icons_alpha = mod:get(mod.SETTING_NAMES.TEAM_UI_ICONS_ALPHA)
	custom_widget_style.icon_natural_bond.color[1] = teammate_icons_alpha

	custom_widget_style.frame_natural_bond.offset[1] = custom_widget_style.icon_natural_bond.offset[1] - 2
	custom_widget_style.frame_natural_bond.offset[2] = custom_widget_style.icon_natural_bond.offset[2] - 2

	local next_icon_offset = (self.has_natural_bond and 30 or 0)

	custom_widget_style.icon_hand_of_shallya.offset[1] = icons_offset_x + next_icon_offset
	custom_widget_style.icon_hand_of_shallya.offset[2] = icons_offset_y
	custom_widget_style.icon_hand_of_shallya.color[1] = teammate_icons_alpha

	custom_widget_style.frame_hand_of_shallya.offset[1] = custom_widget_style.icon_hand_of_shallya.offset[1] - 2
	custom_widget_style.frame_hand_of_shallya.offset[2] = custom_widget_style.icon_hand_of_shallya.offset[2] - 2

	next_icon_offset = next_icon_offset + (self.has_hand_of_shallya and 30 or 0)

	custom_widget_style.icon_healshare_talent.offset[1] = icons_offset_x + next_icon_offset
	custom_widget_style.icon_healshare_talent.offset[2] = icons_offset_y
	custom_widget_style.icon_healshare_talent.color[1] = teammate_icons_alpha

	next_icon_offset = next_icon_offset + (self.has_healshare_talent and 28 or 0)

	custom_widget_style.icon_is_wounded.offset[1] = icons_offset_x + next_icon_offset - 10
	custom_widget_style.icon_is_wounded.offset[2] = icons_offset_y - 10

	custom_widget_style.frame_is_wounded.offset[1] = custom_widget_style.icon_is_wounded.offset[1] - 2 + 10
	custom_widget_style.frame_is_wounded.offset[2] = custom_widget_style.icon_is_wounded.offset[2] - 2 + 10
	custom_widget_style.frame_is_wounded.size[1] = 0

	next_icon_offset = next_icon_offset + (self.is_wounded and 30 or 0)

	if self.important_icons_enabled then
		def_dynamic_w.style.ammo_indicator.offset[1] = def_dynamic_w.style.ammo_indicator.offset[1] + next_icon_offset
	end
end
