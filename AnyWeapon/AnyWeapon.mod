return {
	run = function()
		fassert(rawget(_G, "new_mod"), "AnyWeapon must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("AnyWeapon", {
			mod_script       = "scripts/mods/AnyWeapon/AnyWeapon",
			mod_data         = "scripts/mods/AnyWeapon/AnyWeapon_data",
			mod_localization = "scripts/mods/AnyWeapon/AnyWeapon_localization"
		})
	end,
	packages = {
		"resource_packages/AnyWeapon/AnyWeapon"
	}
}
