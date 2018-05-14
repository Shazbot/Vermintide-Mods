return {
	run = function()
		local mod = new_mod("InventoryFavorites")
		mod:localization("localization/InventoryFavorites")
		mod:initialize("scripts/mods/InventoryFavorites/InventoryFavorites")
	end,
	packages = {
		"resource_packages/InventoryFavorites/InventoryFavorites"
	}
}
