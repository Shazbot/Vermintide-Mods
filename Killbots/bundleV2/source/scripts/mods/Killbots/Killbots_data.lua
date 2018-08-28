local mod = get_mod("Killbots") -- luacheck: ignore get_mod

mod.SETTING_NAMES = {
	HOTKEY = "hotkey",
}

local mod_data = {
	name = "Killbots",
	description = mod:localize("mod_description"),
}
mod_data.options_widgets = {
	{
		["setting_name"] = mod.SETTING_NAMES.HOTKEY,
		["widget_type"] = "keybind",
		["text"] = mod:localize("hotkey"),
		["tooltip"] = mod:localize("hotkey_tooltip"),
		["default_value"] = {},
		["action"] = "kill_bots"
	},
}

return mod_data