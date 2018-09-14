-- luacheck: globals get_mod WeaponSkins WeaponMaterialSettingsTemplates GearUtils

local mod = get_mod("NoGlow")

mod:hook(GearUtils, "spawn_inventory_unit", function(func, world, hand, third_person_extension_template, unit_name, node_linking_settings, slot_name, item_data, owner_unit_1p, owner_unit_3p, unit_template, extra_extension_data, ammo_percent, material_settings)
	if mod:is_enabled() then
		if not material_settings then
			material_settings = {}
		end
	end
	return func(world, hand, third_person_extension_template, unit_name, node_linking_settings, slot_name, item_data, owner_unit_1p, owner_unit_3p, unit_template, extra_extension_data, ammo_percent, material_settings)
end)

mod:hook(GearUtils, "apply_material_settings", function(func, unit, material_settings)
	material_settings.rune_emissive_color = {
		x=0,
		y=0,
		z=0,
		type="vector3"
	}
	return func(unit, material_settings)
end)
