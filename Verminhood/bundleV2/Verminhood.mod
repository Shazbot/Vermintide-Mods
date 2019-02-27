return {
	run = function()
		fassert(rawget(_G, "new_mod"), "Verminhood must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("Verminhood", {
			mod_script       = "scripts/mods/Verminhood/Verminhood",
			mod_data         = "scripts/mods/Verminhood/Verminhood_data",
			mod_localization = "scripts/mods/Verminhood/Verminhood_localization"
		})
	end,
	packages = {
		"resource_packages/Verminhood/Verminhood"
	}
}
