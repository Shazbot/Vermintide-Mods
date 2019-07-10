local mod = get_mod("NoGlow")

local mod_data = {
	name = "No Glow On Unique Weapons",
	description = mod:localize("mod_description"),
	is_togglable = true,
	allow_rehooking = true,
}

mod_data.options_widgets = {}

return mod_data
