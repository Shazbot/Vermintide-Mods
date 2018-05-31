return {
	run = function()
		local mod_resources = {
			mod_script = "scripts/mods/CustomHUD/CustomHUD",
			mod_data = "scripts/mods/CustomHUD/CustomHUD_data",
			mod_localization = "scripts/mods/CustomHUD/CustomHUD_localization"
		}
		new_mod("CustomHUD", mod_resources)
	end,
	packages = {
		"resource_packages/CustomHUD/CustomHUD"
	}
}
