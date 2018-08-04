local mod = get_mod("InventoryFavorites") -- luacheck: ignore get_mod

local mod_data = {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = false,
	custom_gui_textures = {
	    textures = {
	        "trash",
	        "heart",
	    },
	    ui_renderer_injections = {
	        {
	            "ingame_ui",
	             "materials/InventoryFavorites/trash",
	             "materials/InventoryFavorites/heart",
	        }
	    },
	},
}

return mod_data