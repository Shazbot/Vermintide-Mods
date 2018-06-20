return {
	run = function()
		fassert(rawget(_G, "new_mod"), "UltReset must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("UltReset", {
			mod_script       = "scripts/mods/UltReset/UltReset",
			mod_data         = "scripts/mods/UltReset/UltReset_data",
			mod_localization = "scripts/mods/UltReset/UltReset_localization"
		})
	end,
	packages = {
		"resource_packages/UltReset/UltReset"
	}
}
