return {
	run = function()
		fassert(rawget(_G, "new_mod"), "Baubles must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("Baubles", {
			mod_script       = "scripts/mods/Baubles/Baubles",
			mod_data         = "scripts/mods/Baubles/Baubles_data",
			mod_localization = "scripts/mods/Baubles/Baubles_localization"
		})
	end,
	packages = {
		"resource_packages/Baubles/Baubles"
	}
}
