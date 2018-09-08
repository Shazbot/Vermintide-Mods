local mod = get_mod("Dofile") -- luacheck: ignore get_mod

mod.SETTING_NAMES = {
	EXEC_HOTKEY = "exec_hotkey",
}

-- Everything here is optional. You can remove unused parts.
local mod_data = {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	allow_rehooking = true,
}
mod_data.options_widgets = {
	{
		["setting_name"] = mod.SETTING_NAMES.EXEC_HOTKEY,
		["widget_type"] = "keybind",
		["text"] = mod:localize("exec_hotkey"),
		["tooltip"] = mod:localize("exec_hotkey_tooltip"),
		["default_value"] = {"f1"},
		["action"] = "do_exec"
	},
}

return mod_data