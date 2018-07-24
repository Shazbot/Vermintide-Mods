local mod = get_mod("WeaponKillCounter") -- luacheck: ignore get_mod

local mod_data = {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
}

return mod_data