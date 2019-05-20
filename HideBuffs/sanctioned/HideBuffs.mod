return {
	run = function()
		fassert(rawget(_G, "new_mod"), "HideBuffs must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("HideBuffs", {
			mod_script       = "scripts/mods/HideBuffs/HideBuffs",
			mod_data         = "scripts/mods/HideBuffs/HideBuffs_data",
			mod_localization = "scripts/mods/HideBuffs/HideBuffs_localization"
		})
	end,
	packages = {
		"resource_packages/HideBuffs/HideBuffs"
	}
}
