return {
	run = function()
		local mod = new_mod("WinLevelCommand")
		mod:localization("localization/WinLevelCommand")
		mod:initialize("scripts/mods/WinLevelCommand/WinLevelCommand")
	end,
	packages = {
		"resource_packages/WinLevelCommand/WinLevelCommand"
	}
}
