return {
	run = function()
		local mod_resources = {
			mod_script = "scripts/mods/WeaponSwitch/WeaponSwitch",
			mod_data = "scripts/mods/WeaponSwitch/WeaponSwitch_data",
			mod_localization = "scripts/mods/WeaponSwitch/WeaponSwitch_localization"
		}
		new_mod("WeaponSwitch", mod_resources)
	end,
	packages = {
		"resource_packages/WeaponSwitch/WeaponSwitch"
	}
}
