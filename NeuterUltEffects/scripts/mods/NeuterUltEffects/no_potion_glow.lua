local mod = get_mod("NeuterUltEffects")

--- No glowing potions.
mod:hook(UnitSpawner, "spawn_network_unit", function(func, self, unit_name, ...)
	local unit, go_id = func(self, unit_name, ...)

	if string.find(unit_name, "pup_potion")
	and mod:get(mod.SETTING_NAMES.NO_POTION_GLOW)
	and Unit.num_lights(unit) > 0
	then
		Light.set_intensity(Unit.light(unit, 0), 0)
	end

	return unit, go_id
end)

mod:hook(GearUtils, "spawn_inventory_unit", function(func, world, hand, third_person_extension_template, unit_name, node_linking_settings, slot_name, item_data, owner_unit_1p, owner_unit_3p, unit_template, extra_extension_data, ammo_percent, material_settings)
	local weapon_unit_3p, ammo_unit_3p, weapon_unit_1p, ammo_unit_1p = func(world, hand, third_person_extension_template, unit_name, node_linking_settings, slot_name, item_data, owner_unit_1p, owner_unit_3p, unit_template, extra_extension_data, ammo_percent, material_settings)

	for _, unit in ipairs( { weapon_unit_3p, weapon_unit_1p } ) do
		if unit
		and string.find(unit_name, "wpn_potion")
		and mod:get(mod.SETTING_NAMES.NO_POTION_GLOW)
		and Unit.num_lights(unit) > 0
		then
			Light.set_intensity(Unit.light(unit, 0), 0)
		end
	end

	return weapon_unit_3p, ammo_unit_3p, weapon_unit_1p, ammo_unit_1p
end)
