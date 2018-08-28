return {
	run = function()
		fassert(rawget(_G, "new_mod"), "RestartLevelCommand must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("RestartLevelCommand", {
			mod_script       = "scripts/mods/RestartLevelCommand/RestartLevelCommand",
			mod_data         = "scripts/mods/RestartLevelCommand/RestartLevelCommand_data",
			mod_localization = "scripts/mods/RestartLevelCommand/RestartLevelCommand_localization"
		})
	end,
	packages = {
		"resource_packages/RestartLevelCommand/RestartLevelCommand"
	}
}
