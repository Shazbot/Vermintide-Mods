return {
	run = function()
		local mod_resources = {
			mod_script = "scripts/mods/FailLevelCommand/FailLevelCommand",
			mod_data = "scripts/mods/FailLevelCommand/FailLevelCommand_data",
			mod_localization = "scripts/mods/FailLevelCommand/FailLevelCommand_localization"
		}
		new_mod("FailLevelCommand", mod_resources)
	end,
	packages = {
		"resource_packages/FailLevelCommand/FailLevelCommand"
	}
}
