local mod = get_mod("HideBuffs")

mod:hook(FatigueUI, "draw", function(func, self, dt)
	local shields = self.shields
	local active_shields = self.active_shields

	local offset = mod:get(mod.SETTING_NAMES.SHIELDS_SPACING)
	local total_width = offset * (active_shields - 1)
	local half_width = total_width / 2

	for i = 1, active_shields, 1 do
		local shield = shields[i]
		mod:pcall(function()
			local shield_style = shield.style
			local width_offet = half_width - offset * (i - 1)
			shield_style.offset[1] = width_offet

			if not shield.offset then
				shield.offset = { 0,0,0 }
			end
			shield.offset[1] = mod:get(mod.SETTING_NAMES.SHIELDS_OFFSET_X)
			shield.offset[2] = mod:get(mod.SETTING_NAMES.SHIELDS_OFFSET_Y)

			local shields_size_adjust = mod:get(mod.SETTING_NAMES.SHIELDS_SIZE_ADJUST)

			shield_style.size[1] = 90 + shields_size_adjust
			shield_style.size[2] = 90 + shields_size_adjust

			shield_style.texture_glow_id.texture_size[1] = 64 + shields_size_adjust
			shield_style.texture_glow_id.texture_size[2] = 64 + shields_size_adjust
		end)
	end

	return func(self, dt)
end)

--- Change shields opacity.
mod:hook_safe(FatigueUI, "start_fade_in", function(self)
	local shields_opacity = mod:get(mod.SETTING_NAMES.SHIELDS_OPACITY)

	if shields_opacity == 255 then
		return
	end

	local active_shields = self.active_shields
	local shields = self.shields

	for i = 1, active_shields, 1 do
		for shield, is_active in pairs( shields[i].animations ) do
			if is_active then
				shield.data_array[5] = shields_opacity
			end
		end
	end
end)
