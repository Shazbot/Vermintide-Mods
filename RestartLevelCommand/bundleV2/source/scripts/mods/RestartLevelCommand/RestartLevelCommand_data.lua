local mod = get_mod("RestartLevelCommand") -- luacheck: ignore get_mod

mod.SETTING_NAMES = {
	HOTKEY = "hotkey",
}

local mod_data = {
	name = "RestartLevelCommand",
	description = mod:localize("mod_description"),
	is_togglable = false,
}

mod_data.options_widgets = {
	{
		["setting_name"] = mod.SETTING_NAMES.HOTKEY,
		["widget_type"] = "keybind",
		["text"] = mod:localize("hotkey"),
		["tooltip"] = mod:localize("hotkey_tooltip"),
		["default_value"] = {},
		["action"] = "restart_level"
	},
}

return mod_data
