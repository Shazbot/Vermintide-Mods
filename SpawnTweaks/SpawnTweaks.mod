return {
	run = function()
		local mod = new_mod("SpawnTweaks")
		mod:localization("localization/SpawnTweaks")
		mod:initialize("scripts/mods/SpawnTweaks/SpawnTweaks")
	end,
	packages = {
		"resource_packages/SpawnTweaks/SpawnTweaks"
	}
}
