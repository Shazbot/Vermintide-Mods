local mod = get_mod("ExecLua")

local mod_data = {
	name = "Execute Lua Ingame",
	description = mod:localize("mod_description"),
	is_togglable = true,
	allow_rehooking = true,
}

mod_data.options = {}

return mod_data
