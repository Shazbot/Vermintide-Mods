return {
	run = function()
		local mod_resources = {
			mod_script = "scripts/mods/Penlight Lua Libraries/Penlight Lua Libraries",
			mod_data = "scripts/mods/Penlight Lua Libraries/Penlight Lua Libraries_data",
			mod_localization = "scripts/mods/Penlight Lua Libraries/Penlight Lua Libraries_localization"
		}
		new_mod("Penlight Lua Libraries", mod_resources)
	end,
	packages = {
		"resource_packages/Penlight Lua Libraries/Penlight Lua Libraries"
	}
}
