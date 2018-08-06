return {
	run = function()
		fassert(rawget(_G, "new_mod"), "InfiniteAmmo must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("InfiniteAmmo", {
			mod_script       = "scripts/mods/InfiniteAmmo/InfiniteAmmo",
			mod_data         = "scripts/mods/InfiniteAmmo/InfiniteAmmo_data",
			mod_localization = "scripts/mods/InfiniteAmmo/InfiniteAmmo_localization"
		})
	end,
	packages = {
		"resource_packages/InfiniteAmmo/InfiniteAmmo"
	}
}
