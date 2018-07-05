return {
	run = function()
		fassert(rawget(_G, "new_mod"), "AllHats must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("AllHats", {
			mod_script       = "scripts/mods/AllHats/AllHats",
			mod_data         = "scripts/mods/AllHats/AllHats_data",
			mod_localization = "scripts/mods/AllHats/AllHats_localization"
		})
	end,
	packages = {
		"resource_packages/AllHats/AllHats"
	}
}
