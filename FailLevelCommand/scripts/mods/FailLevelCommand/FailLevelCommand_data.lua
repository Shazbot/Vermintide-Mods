local mod = get_mod("FailLevelCommand") -- luacheck: ignore get_mod

mod.SETTING_NAMES = {
	LOSE_HOTKEY = "LOSE_HOTKEY",
	WIN_HOTKEY = "WIN_HOTKEY",
	RESTART_HOTKEY = "RESTART_HOTKEY",
}

local mod_data = {
	name = "Fail/Win/Restart Level",
	description = mod:localize("mod_description"),
	is_togglable = false,
}
mod_data.options_widgets = {
	{
		["setting_name"] = mod.SETTING_NAMES.LOSE_HOTKEY,
		["widget_type"] = "keybind",
		["text"] = mod:localize("LOSE_HOTKEY"),
		["tooltip"] = mod:localize("LOSE_HOTKEY_T"),
		["default_value"] = {},
		["action"] = "fail_level"
	},
	{
		["setting_name"] = mod.SETTING_NAMES.WIN_HOTKEY,
		["widget_type"] = "keybind",
		["text"] = mod:localize("WIN_HOTKEY"),
		["tooltip"] = mod:localize("WIN_HOTKEY_T"),
		["default_value"] = {},
		["action"] = "win_level"
	},
	{
		["setting_name"] = mod.SETTING_NAMES.RESTART_HOTKEY,
		["widget_type"] = "keybind",
		["text"] = mod:localize("RESTART_HOTKEY"),
		["tooltip"] = mod:localize("RESTART_HOTKEY_T"),
		["default_value"] = {},
		["action"] = "restart_level"
	},
}

return mod_data