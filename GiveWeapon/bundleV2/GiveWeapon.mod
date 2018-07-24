return {
	run = function()
		fassert(rawget(_G, "new_mod"), "GiveWeapon must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("GiveWeapon", {
			mod_script       = "scripts/mods/GiveWeapon/GiveWeapon",
			mod_data         = "scripts/mods/GiveWeapon/GiveWeapon_data",
			mod_localization = "scripts/mods/GiveWeapon/GiveWeapon_localization"
		})
	end,
	packages = {
		"resource_packages/GiveWeapon/GiveWeapon"
	}
}
