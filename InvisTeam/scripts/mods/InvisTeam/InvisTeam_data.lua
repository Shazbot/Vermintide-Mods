local mod = get_mod("InvisTeam")

local mod_data = {
	name = "Invisible Teammates Mutator",
	description = mod:localize("mod_description"),
	is_togglable = true,
	allow_rehooking = true,
}

mod.SETTING_NAMES = {}
for _, setting_name in ipairs( {
	"DISTANCE",
} ) do
	mod.SETTING_NAMES[setting_name] = setting_name
end

mod_data.options = {
	widgets = {
		{
		  setting_id      = mod.SETTING_NAMES.DISTANCE,
		  type            = "numeric",
		  default_value   = 5,
		  range           = {0, 100},
		  decimals_number = 1
		},
	},
}

return mod_data
