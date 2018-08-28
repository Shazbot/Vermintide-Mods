return {
	run = function()
		local mod_resources = {
			mod_script = "scripts/mods/Killbots/Killbots",
			mod_data = "scripts/mods/Killbots/Killbots_data",
			mod_localization = "scripts/mods/Killbots/Killbots_localization"
		}
		new_mod("Killbots", mod_resources)
	end,
	packages = {
		"resource_packages/Killbots/Killbots"
	}
}
