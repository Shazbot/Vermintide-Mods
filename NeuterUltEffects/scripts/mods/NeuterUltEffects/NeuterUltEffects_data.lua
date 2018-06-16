local mod = get_mod("NeuterUltEffects") -- luacheck: ignore get_mod

mod.SETTING_NAMES = {
    WOUNDED = "wounded",
    KNOCKED_DOWN = "knocked_down"
}

local mod_data = {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
}
mod_data.options_widgets = {
	{
		["setting_name"] = mod.SETTING_NAMES.WOUNDED,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("wounded"),
		["tooltip"] = mod:localize("wounded_tooltip"),
		["default_value"] = false,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.KNOCKED_DOWN,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("knocked_down"),
		["tooltip"] = mod:localize("knocked_down_tooltip"),
		["default_value"] = false,
	},
}

return mod_data