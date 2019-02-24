return {
	run = function()
		fassert(rawget(_G, "new_mod"), "MaxProperties must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("MaxProperties", {
			mod_script       = "scripts/mods/MaxProperties/MaxProperties",
			mod_data         = "scripts/mods/MaxProperties/MaxProperties_data",
			mod_localization = "scripts/mods/MaxProperties/MaxProperties_localization"
		})
	end,
	packages = {
		"resource_packages/MaxProperties/MaxProperties"
	}
}
