local mod = get_mod("NeuterUltEffects")

--- No glowing potions.
mod:hook_safe(PickupUnitExtension, "init", function(self)
	if self.unit and self.pickup_name then
		local pickup_settings = AllPickups[self.pickup_name]

		if string.find(pickup_settings.unit_name, "pup_potion")
		and mod:get(mod.SETTING_NAMES.NO_POTION_GLOW)
		and Unit.num_lights(self.unit) > 0
		then
			Light.set_intensity(Unit.light(self.unit, 0), 0)
		end
	end
end)

mod:hook(GearUtils, "spawn_inventory_unit",
function(func, world, hand, item_template, item_units, ...)
	local weapon_unit_3p, ammo_unit_3p, weapon_unit_1p, ammo_unit_1p = func(world, hand, item_template, item_units, ...)

	local weapon_unit_name = item_units[hand .. "_hand_unit"]

	for _, unit in ipairs( { weapon_unit_3p, weapon_unit_1p } ) do
		if unit
		and string.find(weapon_unit_name, "wpn_potion")
		and mod:get(mod.SETTING_NAMES.NO_POTION_GLOW)
		and Unit.num_lights(unit) > 0
		then
			Light.set_intensity(Unit.light(unit, 0), 0)
		end
	end

	return weapon_unit_3p, ammo_unit_3p, weapon_unit_1p, ammo_unit_1p
end)
