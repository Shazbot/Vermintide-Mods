local mod = get_mod("HideBuffs")

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
	local anim_progress = math.easeOutCubic(progress, 0, 1) -- luacheck: ignore

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
