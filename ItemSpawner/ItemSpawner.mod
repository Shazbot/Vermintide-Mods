return {
	run = function()
		local mod = new_mod("ItemSpawner")
		mod:localization("localization/ItemSpawner")
		mod:initialize("scripts/mods/ItemSpawner/ItemSpawner")
	end,
	packages = {
		"resource_packages/ItemSpawner/ItemSpawner"
	}
}
