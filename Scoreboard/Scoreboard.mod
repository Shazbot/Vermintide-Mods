return {
	run = function()
		local mod = new_mod("Scoreboard")
		mod:localization("localization/Scoreboard")
		mod:initialize("scripts/mods/Scoreboard/Scoreboard")
	end,
	packages = {
		"resource_packages/Scoreboard/Scoreboard"
	}
}
