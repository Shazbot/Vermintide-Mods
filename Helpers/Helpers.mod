return {
	run = function()
		fassert(rawget(_G, "new_mod"), "Helpers must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("Helpers", {
			mod_script       = "scripts/mods/Helpers/Helpers",
			mod_data         = "scripts/mods/Helpers/Helpers_data",
			mod_localization = "scripts/mods/Helpers/Helpers_localization"
		})
	end,
	packages = {
		"resource_packages/Helpers/Helpers"
	}
}
