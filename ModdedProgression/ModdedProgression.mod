return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`ModdedProgression` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("ModdedProgression", {
			mod_script       = "scripts/mods/ModdedProgression/ModdedProgression",
			mod_data         = "scripts/mods/ModdedProgression/ModdedProgression_data",
			mod_localization = "scripts/mods/ModdedProgression/ModdedProgression_localization",
		})
	end,
	packages = {
		"resource_packages/ModdedProgression/ModdedProgression",
	},
}
