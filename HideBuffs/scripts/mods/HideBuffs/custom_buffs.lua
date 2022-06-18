local mod = get_mod("HideBuffs")

BuffTemplates.custom_wounded = {
	buffs = {
				{
					name = "custom_wounded",
					icon = "victor_zealot_bloodlust",
					debuff = true,
					max_stacks = 1,
				}
			}
}
BuffTemplates.custom_scavenger = {
	buffs = {
		{
			name = "custom_scavenger",
			icon = "kerillian_waywatcher_gain_ammo_on_boss_death",
			refresh_durations = true,
			max_stacks = 999,
			duration = mod:get(mod.SETTING_NAMES.PLAYER_UI_CUSTOM_BUFFS_AMMO_DURATION),
		}
	}
}
BuffTemplates.custom_temp_hp = {
	buffs = {
		{
			name = "custom_temp_hp",
			icon = "victor_zealot_regrowth",
			refresh_durations = true,
			max_stacks = 999,
			duration = mod:get(mod.SETTING_NAMES.PLAYER_UI_CUSTOM_BUFFS_TEMP_HP_DURATION),
		}
	}
}
BuffTemplates.custom_dmg_taken = {
	buffs = {
		{
			name = "custom_dmg_taken",
			icon = "markus_knight_max_health",
			refresh_durations = true,
			max_stacks = 999,
			duration = mod:get(mod.SETTING_NAMES.PLAYER_UI_CUSTOM_BUFFS_DMG_TAKEN_DURATION),
		}
	}
}

BuffTemplates.custom_dps = {
	buffs = {
		{
			name = "custom_dps",
			icon = "bardin_slayer_dodge_range",
			max_stacks = 999,
		}
	}
}

BuffTemplates.custom_dps_timed = {
	buffs = {
		{
			name = "custom_dps_timed",
			icon = "bardin_slayer_dodge_range",
			refresh_durations = true,
			max_stacks = 999,
			duration = mod:get(mod.SETTING_NAMES.PLAYER_UI_CUSTOM_BUFFS_DPS_TIMED_DURATION),
		}
	}
}

--- For DPS remember the starting time.
mod.dps_start_t = nil
mod.map_dps_start_t = nil
mod.dps_dmg_sum = 0
mod.map_dps_dmg_sum = 0

--- Remember the buff ids.
mod.custom_dps_buff_id = nil
mod.custom_dps_timed_buff_id = nil

--- Keep track of number of stacks here.
--- Starting value doesn't matter, 100 is for debugging.
mod.buff_stacks = {
	custom_temp_hp = 100,
	custom_scavenger = 100,
	custom_dmg_taken = 100,
	custom_dps = 100,
	custom_dps_timed = 100,
}

--- Style buff widgets of some custom buffs differently.
mod.buff_stacks_styling = {
	custom_temp_hp = {
		stack_count_text_color = { 255, 255, 255, 255 },
		texture_duration_color = { 255, 255, 255, 255 },
	},
	custom_scavenger = {
		stack_count_text_color = { 255, 255, 255, 0 },
		texture_duration_color = { 255, 255, 255, 0 },
	},
	custom_dmg_taken = {
		stack_count_text_color = { 255, 255, 0, 0 },
		texture_duration_color = { 255, 255, 0, 0 },
	},
	custom_dps = {
		stack_count_text_color = { 255, 255, 255, 255 },
		texture_duration_color = { 0, 255, 69, 0 },
	},
	custom_dps_timed = {
		stack_count_text_color = { 255, 255, 255, 255 },
		texture_duration_color = { 255, 255, 69, 0 },
	},
}

mod.buff_ui_remove_buff_hook = function(func, self, index)
	-- if self._active_buffs[index].name == "custom_dps" then
	-- 	mod.custom_dps_buff_id = nil
	-- end
	-- if self._active_buffs[index].name == "custom_dps_timed" then
	-- 	mod.custom_dps_timed_buff_id = nil
	-- end

	-- since buff widgets get reused set everything back to defaults
	local widget = self._active_buff_widgets[index]
	if not widget then return end

	local widget_content = widget.content
	local buff_name = widget_content.name
	if mod.buff_stacks[buff_name] then
		local widget = self._active_buff_widgets[index]
		widget.style.stack_count.text_color = Colors.get_color_table_with_alpha("white", 255)
		widget.style.texture_duration.color = { 150, 255, 255, 255 }
		widget.style.stack_count.horizontal_alignment = "right"
		widget.style.stack_count_shadow.horizontal_alignment = "right"
		widget.style.stack_count.offset[1] = -2
		widget.style.stack_count.offset[2] = 2
		widget.style.stack_count_shadow.offset[1] = 0
		widget.style.stack_count_shadow.offset[2] = 0
	end

	self._active_buff_widgets[index].content._last_stack_count = nil

	return func(self, index)
end

-- CHECK
-- BuffUI._remove_buff = function (self, index)
mod:hook(BuffUI, "_remove_buff", mod.buff_ui_remove_buff_hook)

--- Modify stack_count before drawing, note that it gets reset every time before draw.
--- Also change widget style.
--- Already hooking this in buff_ui, calling it there.
mod.custom_buffs_BuffUI_draw = function(self)
	for _, widget in ipairs(self._active_buff_widgets) do
		local widget_content = widget.content
		local buff_name = widget_content.name

		if buff_name
		and mod.buff_stacks[buff_name]
		then
			widget.style.stack_count.horizontal_alignment = "center"
			widget.style.stack_count_shadow.horizontal_alignment = "center"
			widget.style.stack_count.offset[1] = 4
			widget.style.stack_count.offset[2] = 5
			widget.style.stack_count_shadow.offset[1] = 6
			widget.style.stack_count_shadow.offset[2] = 3
			widget.style.stack_count.text_color = mod.buff_stacks_styling[buff_name].stack_count_text_color
			widget.style.texture_duration.color = mod.buff_stacks_styling[buff_name].texture_duration_color

			local rounded_stacks = mod.buff_stacks[buff_name] and math.round(mod.buff_stacks[buff_name]) or nil -- luacheck: ignore math
			if widget.content.stack_count ~= rounded_stacks
			or widget.content._last_stack_count ~= rounded_stacks then
				widget_content.stack_count = rounded_stacks
				widget.content.stack_count = rounded_stacks
				widget.content._last_stack_count = rounded_stacks

				self._dirty = true
			end
		end
	end
end

--- Modify stacks of a custom buff.
--- If the buff doesn't exist reset it to 0 beforehand.
mod.increase_buff_stacks = function(unit, buff_name, num_stacks)
	if not num_stacks then
		return
	end

	local buff_ext = ScriptUnit.extension(unit, "buff_system")
	if not buff_ext:has_buff_type(buff_name) then
		mod.buff_stacks[buff_name] = 0

		if buff_name == "custom_dps_timed"
		then
			mod.dps_start_t = Managers.time:time("main")
		end
	end
	local id = buff_ext:add_buff(buff_name)
	if id then
		if buff_name == "custom_dps" then
			mod.custom_dps_buff_id = id
		end
		if buff_name == "custom_dps_timed" then
			mod.custom_dps_timed_buff_id = id
		end
	end
	mod.buff_stacks[buff_name] = mod.buff_stacks[buff_name] + num_stacks
end

--- HP hooks.
-- CHECK
-- PlayerUnitHealthExtension.add_heal = function (self, healer_unit, heal_amount, heal_source_name, heal_type)
mod:hook(PlayerUnitHealthExtension, "add_heal", function(func, self, healer_unit, heal_amount, heal_source_name, heal_type)
	if not mod:get(mod.SETTING_NAMES.PLAYER_UI_CUSTOM_BUFFS_TEMP_HP) then
		return func(self, healer_unit, heal_amount, heal_source_name, heal_type)
	end

	local local_player_unit = Managers.player:local_player().player_unit
	if not local_player_unit
	or self.unit ~= local_player_unit
	then
		return func(self, healer_unit, heal_amount, heal_source_name, heal_type)
	end

	local game_object_id = self.health_game_object_id
	local game = self.game
	local temporary_health_before = GameSession.game_object_field(game, game_object_id, "current_temporary_health")

	func(self, healer_unit, heal_amount, heal_source_name, heal_type)

	local temporary_health_after = GameSession.game_object_field(game, game_object_id, "current_temporary_health")

	local temp_hp_delta = temporary_health_after - temporary_health_before
	if temp_hp_delta > 0 then
		mod.increase_buff_stacks(local_player_unit, "custom_temp_hp", temp_hp_delta)
	end
end)

--- Ammo hooks.
mod.add_ammo_hook = function(func, self, amount)
	if not mod:get(mod.SETTING_NAMES.PLAYER_UI_CUSTOM_BUFFS_AMMO) then
		return func(self, amount)
	end

	local ammo_before = self:total_remaining_ammo()

	func(self, amount)

	local local_player_unit = Managers.player:local_player().player_unit
	if local_player_unit and self.owner_unit == local_player_unit then
		local ammo_delta = self:total_remaining_ammo() - ammo_before
		if ammo_delta > 0 then
			mod.increase_buff_stacks(self.owner_unit, "custom_scavenger", ammo_delta)
		end
	end
end

-- CHECK
-- GenericAmmoUserExtension.add_ammo_to_reserve = function (self, amount)
-- CHECK
-- GenericAmmoUserExtension.add_ammo = function (self, amount)
mod:hook(GenericAmmoUserExtension, "add_ammo_to_reserve", mod.add_ammo_hook)
mod:hook(GenericAmmoUserExtension, "add_ammo", mod.add_ammo_hook)

mod.reset_custom_buff_counters = function()
	mod.dps_start_t = nil
	mod.map_dps_start_t = nil
	mod.dps_dmg_sum = 0
	mod.map_dps_dmg_sum = 0
end

--- This hook isn't initialized before the
--- local_require("scripts/ui/hud_ui/buff_ui_definitions")
--- in hud_ui/buff_ui
--- so too late to change MAX_NUMBER_OF_BUFFS in buff_ui
--- since it gets assigned to a local.
--- But can be used for local_require below
--- and any other local_require from now on.
mod:hook("local_require", function(func, full_path, ...)
	if full_path == "scripts/mods/HideBuffs/buff_ui_definitions" then
		local buff_ui_definitions = func(full_path, ...)
		local new_max_buffs = mod:get(mod.SETTING_NAMES.MAX_NUMBER_OF_BUFFS)
		local orig_MAX_NUMBER_OF_BUFFS = buff_ui_definitions.MAX_NUMBER_OF_BUFFS
		buff_ui_definitions.MAX_NUMBER_OF_BUFFS = new_max_buffs
		for i = orig_MAX_NUMBER_OF_BUFFS+1, new_max_buffs do
			buff_ui_definitions.buff_widget_definitions[i] =
				table.clone(buff_ui_definitions.buff_widget_definitions[1])
		end
		return buff_ui_definitions
	end

	return func(full_path, ...)
end)

mod:hook(BuffUI, "_add_buff", function(func, self, buff, infinite, end_time)
	mod.buffs_manager_BuffUI_add_buff(buff)

	if mod.bm.is_priority_buff(buff.buff_type)
	or mod.bm.is_hidden_buff(buff.buff_type)
	then
		return false
	end

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

	return func(self, buff, infinite, end_time)
end)

mod.reset_dps_buff = function()
	local local_player_unit =
		Managers.player:local_player()
		and Managers.player:local_player().player_unit

	if not local_player_unit or not Unit.alive(local_player_unit) then
		return
	end

	local buff_ext = ScriptUnit.has_extension(local_player_unit, "buff_system")
	if not buff_ext then
		return
	end

	if buff_ext:has_buff_type("custom_dps")
	and mod.custom_dps_buff_id
	then
		buff_ext:remove_buff(mod.custom_dps_buff_id)
		mod.custom_dps_buff_id = nil
		mod.map_dps_dmg_sum = 0
		mod.map_dps_start_t = nil
	end
end

mod.reset_dps_timed_buff = function()
	local local_player_unit =
		Managers.player:local_player()
		and Managers.player:local_player().player_unit

	if not local_player_unit or not Unit.alive(local_player_unit) then
		return
	end

	local buff_ext = ScriptUnit.has_extension(local_player_unit, "buff_system")
	if not buff_ext then
		return
	end

	if buff_ext:has_buff_type("custom_dps_timed")
	and mod.custom_dps_timed_buff_id
	then
		buff_ext:remove_buff(mod.custom_dps_timed_buff_id)
		mod.custom_dps_timed_buff_id = nil
		mod.dps_dmg_sum = 0
		mod.dps_start_t = nil
	end
end
