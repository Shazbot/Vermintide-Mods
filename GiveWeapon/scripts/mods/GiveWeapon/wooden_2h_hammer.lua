local mod = get_mod("GiveWeapon")

mod:hook(BackendUtils, "get_item_units", function(func, item_data, ...)
	if not mod:get(mod.SETTING_NAMES.FORCE_WOODEN_HAMMER) then
		return func(item_data, ...)
	end

	local units = func(item_data, ...)
	if item_data.item_type == "es_2h_war_hammer"
	and units
	and units.right_hand_unit
	then
		units.right_hand_unit = "units/weapons/player/wpn_empire_2h_hammer_tutorial/wpn_empire_2h_hammer_tut_01"
	end
	return units
end)
