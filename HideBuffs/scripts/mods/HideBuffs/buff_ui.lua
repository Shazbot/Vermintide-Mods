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

local buff_ui_definitions = local_require("scripts/mods/HideBuffs/buff_ui_definitions")
local BUFF_SIZE = buff_ui_definitions.BUFF_SIZE
local BUFF_SPACING = buff_ui_definitions.BUFF_SPACING
-- CHECK
-- BuffUI._sync_buffs = function (self)
mod:hook(BuffUI, "_sync_buffs", function (func, self)
	local is_buff_order_preserved = mod:get(mod.SETTING_NAMES.BUFFS_PRESERVE_ORDER)

	local player_unit = (self._is_spectator and self._spectated_player_unit) or self._player.player_unit
	local buff_extension = ScriptUnit.has_extension(player_unit, "buff_system")

	local buffs = nil
	if buff_extension then
		buffs = buff_extension:active_buffs()
	end

	local before = nil
	if is_buff_order_preserved and buffs then
		before = pl.List(self._active_buff_widgets):map(function(widget)
			local widget_content = widget.content
			return widget_content.name
		end)
	end

	func(self)

	if is_buff_order_preserved and buffs then
		for _, before_buff in ripairs( before ) do
			local new_index = pl.tablex.find_if(self._active_buff_widgets, function(widget)
					local widget_content = widget.content
					return widget_content.name == before_buff
				end)
			if new_index then
				local shuffled_buff = table.remove(self._active_buff_widgets, new_index)
				table.insert(self._active_buff_widgets, 1, shuffled_buff)
			end
		end
	end

	local in_reverse = mod:get(mod.SETTING_NAMES.REVERSE_BUFF_DIRECTION)
	local are_centered = mod:get(mod.SETTING_NAMES.CENTERED_BUFFS)

	local adjusted_buff_spacing = BUFF_SPACING + mod:get(mod.SETTING_NAMES.BUFFS_ADJUST_SPACING)
	local adjusted_buff_size = {
		BUFF_SIZE[1] + mod:get(mod.SETTING_NAMES.BUFFS_SIZE_ADJUST_X),
		BUFF_SIZE[2] + mod:get(mod.SETTING_NAMES.BUFFS_SIZE_ADJUST_Y),
	}

	local horizontal_spacing = adjusted_buff_size[1] + adjusted_buff_spacing

	local active_buff_widgets = self._active_buff_widgets
	local num_buffs = #active_buff_widgets
	local total_length = num_buffs * horizontal_spacing - adjusted_buff_spacing

	local are_buffs_flowing_vertically = mod:get(mod.SETTING_NAMES.BUFFS_FLOW_VERTICALLY)

	local buff_index = -1
	for i = #active_buff_widgets, 1, -1 do
		buff_index = buff_index + 1

		local widget = active_buff_widgets[i]
		local buffs_direction = in_reverse and -1 or 1

		local widget_offset = widget.offset

		local target_position = buffs_direction * (buff_index - 1) * horizontal_spacing
		if are_centered then
			target_position = target_position
				+ (in_reverse and total_length/2 or -total_length/2)
		end

		widget_offset[1] = are_buffs_flowing_vertically and 0 or target_position
		widget_offset[2] = are_buffs_flowing_vertically and target_position or 0
		widget.element.dirty = true
		self._dirty = true
	end
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
			self._ui_scenegraph.pivot.horizontal_alignment = "center"
			if mod:get(mod.SETTING_NAMES.REVERSE_BUFF_DIRECTION) then
				self._ui_scenegraph.pivot.local_position[1] = -66
			else
				self._ui_scenegraph.pivot.local_position[1] = 0
			end
		else
			self._ui_scenegraph.pivot.horizontal_alignment = "left"
			self._ui_scenegraph.pivot.local_position[1] = 150
		end

		if mod.realign_buff_widgets then
			mod.realign_buff_widgets = false
			self._dirty = true
		end

		local size_adjust_x = mod:get(mod.SETTING_NAMES.BUFFS_SIZE_ADJUST_X)
		local size_adjust_y = mod:get(mod.SETTING_NAMES.BUFFS_SIZE_ADJUST_Y)
		local buffs_alpha = mod:get(mod.SETTING_NAMES.BUFFS_ALPHA)

		for _, widget in ipairs(self._active_buff_widgets) do
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
					style.size[1] = widget.cloned[name].size[1] + size_adjust_x
					style.size[2] = widget.cloned[name].size[2] + size_adjust_y
				end
			end

			local buffs_alpha = buffs_alpha
			widget.style.texture_icon_bg.color[1] = buffs_alpha
			widget.style.texture_frame.color[1] = buffs_alpha
		end

		local buffs_offset_x = mod:get(mod.SETTING_NAMES.BUFFS_OFFSET_X)
		local buffs_offset_y = mod:get(mod.SETTING_NAMES.BUFFS_OFFSET_Y)

		if self._ui_scenegraph.buff_pivot.position[1] ~= buffs_offset_x
		or self._ui_scenegraph.buff_pivot.position[2] ~= buffs_offset_y
		then
			self._ui_scenegraph.buff_pivot.position[1] = buffs_offset_x
			self._ui_scenegraph.buff_pivot.position[2] = buffs_offset_y
			mod.reset_buff_widgets = true
		end

		if mod.reset_buff_widgets then
			mod.reset_buff_widgets = false
			self._dirty = true
		end

		mod.custom_buffs_BuffUI_draw(self)
		mod.buffs_manager_BuffUI_draw(self)
	end)
	return func(self, dt)
end)

--- Disable popups some buffs have.
--- e.g. Paced Strikes, Tranquility
mod:hook(BuffPresentationUI, "draw", function(func, self, ...)
	if mod:get(mod.SETTING_NAMES.SECOND_BUFF_BAR_DISABLE_BUFF_POPUPS) then
		return
	end

	return func(self, ...)
end)
