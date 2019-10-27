local mod = get_mod("HideBuffs")

--- Starts disabled.
mod:hook("UIAnimation", "init", function(func, fun, table, table_index, from, to, ...) -- luacheck: no unused
	return func(fun, table, table_index, mod.shields_from_opacity, mod.shields_to_opacity, ...)
end)

mod:hook(FatigueUI, "draw", function(func, self, dt)
	-- we're going to still update shields when they're hidden
	-- so they update correctly when always visible
	local player_unit = self.local_player.player_unit
	if not self.active and Unit.alive(player_unit) then
		local status_extension = ScriptUnit.extension(player_unit, "status_system")
		self:update_shields(status_extension, dt)
	end

	local shields = self.shields
	local active_shields = self.active_shields

	local offset = mod:get(mod.SETTING_NAMES.SHIELDS_SPACING)
	local total_width = offset * (active_shields - 1)
	local shields_adjust_size = mod:get(mod.SETTING_NAMES.SHIELDS_SIZE_ADJUST)

	for i = 1, active_shields, 1 do
		local shield = shields[i]
		local shield_style = shield.style
		local width_offset = total_width/2 - offset * (i - 1)
		shield_style.offset[1] = width_offset - shields_adjust_size/2

		if not shield.offset then
			shield.offset = { 0,0,0 }
		end
		shield.offset[1] = mod:get(mod.SETTING_NAMES.SHIELDS_OFFSET_X)
		shield.offset[2] = mod:get(mod.SETTING_NAMES.SHIELDS_OFFSET_Y)

		local shields_size_adjust = shields_adjust_size

		shield_style.size[1] = 90 + shields_size_adjust
		shield_style.size[2] = 90 + shields_size_adjust

		shield_style.texture_glow_id.texture_size[1] = 64 + shields_size_adjust
		shield_style.texture_glow_id.texture_size[2] = 64 + shields_size_adjust
	end

	return func(self, dt)
end)

--- Set shields opacity when faded in or out.
mod:hook(FatigueUI, "start_fade_in", function(func, self)
	mod.shields_to_opacity = mod:get(mod.SETTING_NAMES.SHIELDS_OPACITY)
	mod.shields_from_opacity = mod:get(mod.SETTING_NAMES.SHIELDS_FADED_OPACITY)

	mod:hook_enable("UIAnimation", "init")
	func(self)
	mod:hook_disable("UIAnimation", "init")
end)

mod:hook(FatigueUI, "start_fade_out", function(func, self)
	mod.shields_to_opacity = mod:get(mod.SETTING_NAMES.SHIELDS_FADED_OPACITY)
	mod.shields_from_opacity = mod:get(mod.SETTING_NAMES.SHIELDS_OPACITY)

	mod:hook_enable("UIAnimation", "init")
	func(self)
	mod:hook_disable("UIAnimation", "init")
end)
