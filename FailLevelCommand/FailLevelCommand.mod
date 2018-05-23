return {
	run = function()
		local mod = new_mod("FailLevelCommand")
		mod:localization("localization/FailLevelCommand")
		mod:initialize("scripts/mods/FailLevelCommand/FailLevelCommand")
	end,
	packages = {
		"resource_packages/FailLevelCommand/FailLevelCommand"
	}
}
