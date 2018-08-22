return {
	run = function()
		fassert(rawget(_G, "new_mod"), "RerollImprovements must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("RerollImprovements", {
			mod_script       = "scripts/mods/RerollImprovements/RerollImprovements",
			mod_data         = "scripts/mods/RerollImprovements/RerollImprovements_data",
			mod_localization = "scripts/mods/RerollImprovements/RerollImprovements_localization"
		})
	end,
	packages = {
		"resource_packages/RerollImprovements/RerollImprovements"
	}
}
