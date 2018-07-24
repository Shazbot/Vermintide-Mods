return {
	run = function()
		local mod_resources = {
			mod_script = "scripts/mods/InventoryFavorites/InventoryFavorites",
			mod_data = "scripts/mods/InventoryFavorites/InventoryFavorites_data",
			mod_localization = "scripts/mods/InventoryFavorites/InventoryFavorites_localization"
		}
		new_mod("InventoryFavorites", mod_resources)
	end,
	packages = {
		"resource_packages/InventoryFavorites/InventoryFavorites"
	}
}
