return {
	run = function()
		fassert(rawget(_G, "new_mod"), "NoGlow must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("NoGlow", {
			mod_script       = "scripts/mods/NoGlow/NoGlow",
			mod_data         = "scripts/mods/NoGlow/NoGlow_data",
			mod_localization = "scripts/mods/NoGlow/NoGlow_localization"
		})
	end,
	packages = {
		"resource_packages/NoGlow/NoGlow"
	}
}
