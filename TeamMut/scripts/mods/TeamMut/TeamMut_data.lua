local mod = get_mod("TeamMut")

local mod_data = {
	name = "Team Damage Mutator",
	description = mod:localize("mod_description"),
	is_togglable = true,
	allow_rehooking = true,
}

mod_data.options = {}

return mod_data
