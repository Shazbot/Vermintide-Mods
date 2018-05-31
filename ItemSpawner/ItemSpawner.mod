return {
	run = function()
		local mod_resources = {
			mod_script = "scripts/mods/ItemSpawner/ItemSpawner",
			mod_data = "scripts/mods/ItemSpawner/ItemSpawner_data",
			mod_localization = "scripts/mods/ItemSpawner/ItemSpawner_localization"
		}
		new_mod("ItemSpawner", mod_resources)
	end,
	packages = {
		"resource_packages/ItemSpawner/ItemSpawner"
	}
}
