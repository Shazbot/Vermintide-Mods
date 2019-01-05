local mod = get_mod("NeuterUltEffects")

--- Overcharge treshold warning pings.
mod:hook(PlayerUnitOverchargeExtension, "hud_sound", function(func, self, event, fp_extension)
	if not mod:get(mod.SETTING_NAMES.MUTE_OVERCHARGE_PINGS) then
		return func(self, event, fp_extension)
	end

	if self.overcharge_warning_critical_sound_event
		and self.overcharge_warning_critical_sound_event == event
	or self.overcharge_warning_low_sound_event
		and self.overcharge_warning_low_sound_event == event
	or self.overcharge_warning_med_sound_event
		and self.overcharge_warning_med_sound_event == event
	or self.overcharge_warning_high_sound_event
		and self.overcharge_warning_high_sound_event == event
	or event == "staff_overcharge_warning_low"
	or event == "staff_overcharge_warning_med"
	or event == "staff_overcharge_warning_high"
	or event == "staff_overcharge_warning_critical"
	then
		return
	end

	return func(self, event, fp_extension)
end)

--- Most elegant way to change HUD flames is changing
--- screen_space_player_camera_reactions
--- but Development.parameter always returns nil
--- so can't just use Development.set_parameter.
mod:hook(Development, "parameter", function(func, param, ...)
	if param == "screen_space_player_camera_reactions" then
		return false
	end
	return func(param, ...)
end)
mod:hook_disable(Development, "parameter")

mod:hook(PlayerUnitOverchargeExtension, "update", function(func, self, unit, input, dt, context, t)
	if mod:get(mod.SETTING_NAMES.HIDE_OVERCHARGE_FLAMES) then
		mod:hook_enable(Development, "parameter")
	end

	func(self, unit, input, dt, context, t)

	mod:hook_disable(Development, "parameter")
end)

--- Hand animations at high heat.
mod:hook(PlayerUnitOverchargeExtension, "get_anim_blend_overcharge", function(func, self)
	if mod:get(mod.SETTING_NAMES.NO_OVERCHARGE_HAND_CHANGES) then
		return 0
	end

	return func(self)
end)
