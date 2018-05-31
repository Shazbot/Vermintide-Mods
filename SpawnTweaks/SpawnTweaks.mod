return {
	run = function()
		local mod_resources = {
			mod_script = "scripts/mods/SpawnTweaks/SpawnTweaks",
			mod_data = "scripts/mods/SpawnTweaks/SpawnTweaks_data",
			mod_localization = "scripts/mods/SpawnTweaks/SpawnTweaks_localization"
		}
		new_mod("SpawnTweaks", mod_resources)
	end,
	packages = {
		"resource_packages/SpawnTweaks/SpawnTweaks"
	}
}
