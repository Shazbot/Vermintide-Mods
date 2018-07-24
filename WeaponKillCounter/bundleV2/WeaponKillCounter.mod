return {
	run = function()
		local mod_resources = {
			mod_script = "scripts/mods/WeaponKillCounter/WeaponKillCounter",
			mod_data = "scripts/mods/WeaponKillCounter/WeaponKillCounter_data",
			mod_localization = "scripts/mods/WeaponKillCounter/WeaponKillCounter_localization"
		}
		new_mod("WeaponKillCounter", mod_resources)
	end,
	packages = {
		"resource_packages/WeaponKillCounter/WeaponKillCounter"
	}
}
