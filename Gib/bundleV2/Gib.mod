return {
	run = function()
		fassert(rawget(_G, "new_mod"), "Gib must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("Gib", {
			mod_script       = "scripts/mods/Gib/Gib",
			mod_data         = "scripts/mods/Gib/Gib_data",
			mod_localization = "scripts/mods/Gib/Gib_localization"
		})
	end,
	packages = {
		"resource_packages/Gib/Gib"
	}
}
