local mod = get_mod("UltReset") -- luacheck: ignore get_mod

mod.SETTING_NAMES = {
	HOTKEY = "hotkey",
}

local mod_data = {
	name = "Ready Ult",
	description = mod:localize("mod_description"),
	is_togglable = true,
}
mod_data.options_widgets = {
	{
		["setting_name"] = mod.SETTING_NAMES.HOTKEY,
		["widget_type"] = "keybind",
		["text"] = mod:localize("hotkey"),
		["tooltip"] = mod:localize("hotkey_tooltip"),
		["default_value"] = {},
		["action"] = "reset_ult"
	},
}

return mod_data