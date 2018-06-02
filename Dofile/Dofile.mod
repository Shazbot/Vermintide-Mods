return {
	run = function()
		fassert(rawget(_G, "new_mod"), "Dofile must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("Dofile", {
			mod_script       = "scripts/mods/Dofile/Dofile",
			mod_data         = "scripts/mods/Dofile/Dofile_data",
			mod_localization = "scripts/mods/Dofile/Dofile_localization"
		})
	end,
	packages = {
		"resource_packages/Dofile/Dofile"
	}
}
