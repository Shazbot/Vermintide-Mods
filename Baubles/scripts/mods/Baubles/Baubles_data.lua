local mod = get_mod("Baubles")

local mod_data = {
	name = "Misc Tweaks",
	description = mod:localize("mod_description"),
	is_togglable = true,
	allow_rehooking = true,
}

mod.SETTING_NAMES = {}
for _, setting_name in ipairs( {
	"PLAYER_HEIGHT",
	"DODGE_DISTANCE"
} ) do
	mod.SETTING_NAMES[setting_name] = setting_name
end

mod_data.options_widgets = {
	{
		["setting_name"] = mod.SETTING_NAMES.PLAYER_HEIGHT,
		["widget_type"] = "numeric",
		["text"] = mod:localize("PLAYER_HEIGHT"),
		["tooltip"] = mod:localize("PLAYER_HEIGHT_T"),
		["range"] = {0, 10},
		["decimals_number"] = 1,
		["default_value"] = 1,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.DODGE_DISTANCE,
		["widget_type"] = "numeric",
		["text"] = mod:localize("DODGE_DISTANCE"),
		["tooltip"] = mod:localize("DODGE_DISTANCE_T"),
		["range"] = {0, 10},
		["decimals_number"] = 1,
		["default_value"] = 1,
	},
}

return mod_data
