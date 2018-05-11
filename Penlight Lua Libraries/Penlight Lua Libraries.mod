return {
	run = function()
		local mod = new_mod("Penlight Lua Libraries")
		mod:localization("localization/Penlight Lua Libraries")
		mod:initialize("scripts/mods/Penlight Lua Libraries/Penlight Lua Libraries")
	end,
	packages = {
		"resource_packages/Penlight Lua Libraries/Penlight Lua Libraries"
	}
}
