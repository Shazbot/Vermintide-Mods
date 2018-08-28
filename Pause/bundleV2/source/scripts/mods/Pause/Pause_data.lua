local mod = get_mod("Pause") -- luacheck: ignore get_mod

mod.SETTING_NAMES = {
	HOTKEY = "hotkey",
}

local mod_data = {
	name = "Pause",
	description = mod:localize("mod_description"),
}
mod_data.options_widgets = {
	{
		["setting_name"] = mod.SETTING_NAMES.HOTKEY,
		["widget_type"] = "keybind",
		["text"] = mod:localize("hotkey"),
		["tooltip"] = mod:localize("hotkey_tooltip"),
		["default_value"] = {},
		["action"] = "do_pause"
	},
}

return mod_data