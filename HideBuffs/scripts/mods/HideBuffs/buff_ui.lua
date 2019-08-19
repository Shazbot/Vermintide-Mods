local mod = get_mod("HideBuffs")

local pl = require'pl.import_into'()

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
	["victor_witchhunter_damage_on_grimoire_picked_up"] =
		mod.SETTING_NAMES.HIDE_WHC_GRIMOIRE_POWER_BUFF,
	["kerillian_shade_damage_on_grimoire_picked_up"] =
		mod.SETTING_NAMES.HIDE_SHADE_GRIMOIRE_POWER_BUFF,
	["victor_zealot_critical_hit_damage_from_passive"] =
		mod.SETTING_NAMES.HIDE_ZEALOT_HOLY_CRUSADER_BUFF,
}

--- Moved this hook to custom_buffs.lua
-- mod:hook(BuffUI, "_add_buff", function (func, self, buff, ...)

local buff_ui_definitions = local_require("scripts/ui/hud_ui/buff_ui_definitions")
local BUFF_SIZE = buff_ui_definitions.BUFF_SIZE
local BUFF_SPACING = buff_ui_definitions.BUFF_SPACING
mod:hook_origin(BuffUI, "_align_widgets", function (self, ...)
	local in_reverse = mod:get(mod.SETTING_NAMES.REVERSE_BUFF_DIRECTION)
	local are_centered = mod:get(mod.SETTING_NAMES.CENTERED_BUFFS)

	local adjusted_buff_spacing = BUFF_SPACING + mod:get(mod.SETTING_NAMES.BUFFS_ADJUST_SPACING)
	local adjusted_buff_size = {
		BUFF_SIZE[1] + mod:get(mod.SETTING_NAMES.BUFFS_SIZE_ADJUST_X),
		BUFF_SIZE[2] + mod:get(mod.SETTING_NAMES.BUFFS_SIZE_ADJUST_Y),
	}

	local horizontal_spacing = adjusted_buff_size[1] + adjusted_buff_spacing

	local num_buffs = #self._active_buffs
	local total_length = num_buffs * horizontal_spacing - adjusted_buff_spacing

	for index, data in ipairs(self._active_buffs) do
		local widget = data.widget
		local widget_offset = widget.offset
		local buffs_direction = in_reverse and -1 or 1
		local target_position = buffs_direction * (index - 1) * horizontal_spacing
		if are_centered then
			target_position = target_position
				+ (in_reverse and total_length/2 or -total_length/2)
		end
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

		if mod:get(mod.SETTING_NAMES.CENTERED_BUFFS)
		and mod:get(mod.SETTING_NAMES.CENTERED_BUFFS_REALIGN)
		then
			self.ui_scenegraph.pivot.horizontal_alignment = "center"
			if mod:get(mod.SETTING_NAMES.REVERSE_BUFF_DIRECTION) then
				self.ui_scenegraph.pivot.local_position[1] = -66
			else
				self.ui_scenegraph.pivot.local_position[1] = 0
			end
		else
			self.ui_scenegraph.pivot.horizontal_alignment = "left"
			self.ui_scenegraph.pivot.local_position[1] = 150
		end

		if mod.realign_buff_widgets then
			mod.realign_buff_widgets = false
			self:_align_widgets()
		end

		for _, data in ipairs(self._active_buffs) do
			local widget = data.widget

			if not widget.cloned then
				widget.cloned = pl.tablex.pairmap(function(k,v)
					local parent_temp = v.parent
					v.parent = nil
					local cloned = table.clone(v)
					v.parent = parent_temp
					return cloned,k end, widget.style)
			end

			for name, style in pairs( widget.style ) do
				if style.size then
					style.size[1] = widget.cloned[name].size[1] + mod:get(mod.SETTING_NAMES.BUFFS_SIZE_ADJUST_X)
					style.size[2] = widget.cloned[name].size[2] + mod:get(mod.SETTING_NAMES.BUFFS_SIZE_ADJUST_Y)
				end
			end

			local buffs_alpha = mod:get(mod.SETTING_NAMES.BUFFS_ALPHA)
			widget.style.texture_icon_bg.color[1] = buffs_alpha
			widget.style.texture_frame.color[1] = buffs_alpha
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

		mod.custom_buffs_BuffUI_draw(self)
		mod.buffs_manager_BuffUI_draw(self)
	end)
	return func(self, dt)
end)

mod:hook(BuffUI, "_sync_buffs", function(func, self, ...)
	if not mod:get(mod.SETTING_NAMES.BUFFS_PRESERVE_ORDER) then
		return func(self, ...)
	end

	local before = pl.List(self._active_buffs):map(function(buff)
			return buff.template.name
		end)

	func(self, ...)

	for _, before_buff in ripairs( before ) do
		local new_index = pl.tablex.find_if(self._active_buffs, function(buff)
				return buff.template.name == before_buff
			end)
		if new_index then
			local shuffled_buff = table.remove(self._active_buffs, new_index)
			table.insert(self._active_buffs, 1, shuffled_buff)
		end
	end

	self:_align_widgets()
end)

--- Disable popups some buffs have.
--- e.g. Paced Strikes, Tranquility
mod:hook(BuffPresentationUI, "draw", function(func, self, ...)
	if mod:get(mod.SETTING_NAMES.SECOND_BUFF_BAR_DISABLE_BUFF_POPUPS) then
		return
	end

	return func(self, ...)
end)
