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
			max_stacks = 2000,
			duration = 8,
		}
	}
}
BuffTemplates.custom_temp_hp = {
	buffs = {
		{
			name = "custom_temp_hp",
			icon = "victor_zealot_regrowth",
			refresh_durations = true,
			max_stacks = 2000,
			duration = 8,
		}
	}
}
BuffTemplates.custom_dmg_taken = {
	buffs = {
		{
			name = "custom_dmg_taken",
			icon = "markus_knight_max_health",
			refresh_durations = true,
			max_stacks = 10000,
			duration = 8,
		}
	}
}

--- Keep track of number of stacks here.
--- Starting value doesn't matter, 100 is for debugging.
mod.buff_stacks = {
	custom_temp_hp = 100,
	custom_scavenger = 100,
	custom_dmg_taken = 100,
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
}

mod:hook(BuffUI, "_remove_buff", function(func, self, index)
	-- since buff widgets get reused set everything back to defaults
	if mod.buff_stacks[self._active_buffs[index].name] then
		local widget = self._active_buffs[index].widget
		widget.style.stack_count.text_color = Colors.get_color_table_with_alpha("white", 255)
		widget.style.texture_duration.color = { 150, 255, 255, 255 }
		widget.style.stack_count.horizontal_alignment = "right"
		widget.style.stack_count_shadow.horizontal_alignment = "right"
		widget.style.stack_count.offset[1] = -2
		widget.style.stack_count.offset[2] = 2
		widget.style.stack_count_shadow.offset[1] = 0
		widget.style.stack_count_shadow.offset[2] = 0
	end

	self._active_buffs[index].widget.content._last_stack_count = nil

	return func(self, index)
end)

--- Modify stack_count before drawing, note that it gets reset every time before draw.
--- Also change widget style.
--- Already hooking this in buff_ui, calling it there.
mod.custom_buffs_BuffUI_draw = function(self)
	for _, buff_data in ipairs( self._active_buffs ) do
		local buff_name = buff_data.name
		if buff_name
		and mod.buff_stacks[buff_name]
		then
			buff_data.widget.style.stack_count.horizontal_alignment = "center"
			buff_data.widget.style.stack_count_shadow.horizontal_alignment = "center"
			buff_data.widget.style.stack_count.offset[1] = 4
			buff_data.widget.style.stack_count.offset[2] = 5
			buff_data.widget.style.stack_count_shadow.offset[1] = 6
			buff_data.widget.style.stack_count_shadow.offset[2] = 3
			buff_data.widget.style.stack_count.text_color = mod.buff_stacks_styling[buff_name].stack_count_text_color
			buff_data.widget.style.texture_duration.color = mod.buff_stacks_styling[buff_name].texture_duration_color

			if buff_data.widget.content.stack_count ~= mod.buff_stacks[buff_name]
			or buff_data.widget.content._last_stack_count ~= mod.buff_stacks[buff_name] then
				buff_data.stack_count = mod.buff_stacks[buff_name]
				buff_data.widget.content.stack_count = mod.buff_stacks[buff_name]
				buff_data.widget.content._last_stack_count = mod.buff_stacks[buff_name]

				self:_set_widget_dirty(buff_data.widget)
				self:set_dirty()
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
	end
	buff_ext:add_buff(buff_name)
	mod.buff_stacks[buff_name] = mod.buff_stacks[buff_name] + num_stacks
end

--- HP hooks.
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

	local local_player_unit = Managers.player:local_player().player_unit
	if local_player_unit and self.owner_unit == local_player_unit then
		mod.increase_buff_stacks(self.owner_unit, "custom_scavenger", amount)
	end

	return func(self, amount)
end

mod:hook(GenericAmmoUserExtension, "add_ammo_to_reserve", mod.add_ammo_hook)
mod:hook(GenericAmmoUserExtension, "add_ammo", mod.add_ammo_hook)

--- Damage taken hooks.
mod:hook(PlayerUnitHealthExtension, "add_damage", function(func, self, attacker_unit, damage_amount, hit_zone_name, damage_type, ...)
	if not mod:get(mod.SETTING_NAMES.PLAYER_UI_CUSTOM_BUFFS_DMG_TAKEN)
	or damage_type == "temporary_health_degen"
	or damage_amount <= 0
	then
		return func(self, attacker_unit, damage_amount, hit_zone_name, damage_type, ...)
	end

	local local_player_unit = Managers.player:local_player().player_unit
	if local_player_unit and self.player.player_unit == local_player_unit then
		mod.increase_buff_stacks(local_player_unit, "custom_dmg_taken", damage_amount)
	end
	return func(self, attacker_unit, damage_amount, hit_zone_name, damage_type, ...)
end)
