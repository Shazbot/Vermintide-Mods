return {
	run = function()
		local mod_resources = {
			mod_script = "scripts/mods/Scoreboard/Scoreboard",
			mod_data = "scripts/mods/Scoreboard/Scoreboard_data",
			mod_localization = "scripts/mods/Scoreboard/Scoreboard_localization"
		}
		new_mod("Scoreboard", mod_resources)
	end,
	packages = {
		"resource_packages/Scoreboard/Scoreboard"
	}
}
