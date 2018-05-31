return {
	run = function()
		local mod_resources = {
			mod_script = "scripts/mods/MutatorsSelector/MutatorsSelector",
			mod_data = "scripts/mods/MutatorsSelector/MutatorsSelector_data",
			mod_localization = "scripts/mods/MutatorsSelector/MutatorsSelector_localization"
		}
		new_mod("MutatorsSelector", mod_resources)
	end,
	packages = {
		"resource_packages/MutatorsSelector/MutatorsSelector"
	}
}
