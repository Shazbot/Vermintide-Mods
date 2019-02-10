return {
	run = function()
		fassert(rawget(_G, "new_mod"), "TeamMut must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("TeamMut", {
			mod_script       = "scripts/mods/TeamMut/TeamMut",
			mod_data         = "scripts/mods/TeamMut/TeamMut_data",
			mod_localization = "scripts/mods/TeamMut/TeamMut_localization"
		})
	end,
	packages = {
		"resource_packages/TeamMut/TeamMut"
	}
}
