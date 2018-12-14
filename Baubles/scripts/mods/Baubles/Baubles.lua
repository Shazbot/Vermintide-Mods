local mod = get_mod("Baubles")

mod:hook(PlayerUnitMovementSettings, "get_movement_settings_table", function(func, unit)
	local ret_val = func(unit)
	mod:pcall(function()
		ret_val.dodging.distance_modifier = mod:get(mod.SETTING_NAMES.DODGE_DISTANCE)
		ret_val.dodging.speed_modifier = mod:get(mod.SETTING_NAMES.DODGE_DISTANCE)
	end)
	return ret_val
end)

mod:hook(PlayerUnitFirstPerson, "_player_height_from_name", function(func, ...)
	local ret_val = func(...)
	mod:pcall(function()
		ret_val = ret_val * mod:get(mod.SETTING_NAMES.PLAYER_HEIGHT)
	end)
	return ret_val
end)
