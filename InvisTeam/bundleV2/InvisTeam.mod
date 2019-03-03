return {
	run = function()
		fassert(rawget(_G, "new_mod"), "InvisTeam must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("InvisTeam", {
			mod_script       = "scripts/mods/InvisTeam/InvisTeam",
			mod_data         = "scripts/mods/InvisTeam/InvisTeam_data",
			mod_localization = "scripts/mods/InvisTeam/InvisTeam_localization"
		})
	end,
	packages = {
		"resource_packages/InvisTeam/InvisTeam"
	}
}
