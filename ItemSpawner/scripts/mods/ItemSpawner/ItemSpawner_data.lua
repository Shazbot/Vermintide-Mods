local mod = get_mod("ItemSpawner") -- luacheck: ignore get_mod

mod.SETTING_NAMES = {
	NEXT_PICKUP_HOTKEY = "next_pickup_hotkey",
	PREV_PICKUP_HOTKEY = "prev_pickup_hotkey",
	SPAWN_PICKUP_HOTKEY = "spawn_pickup_hotkey",
}

-- Everything here is optional. You can remove unused parts.
local mod_data = {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
}
mod_data.options_widgets = {
	{
		["setting_name"] = mod.SETTING_NAMES.NEXT_PICKUP_HOTKEY,
		["widget_type"] = "keybind",
		["text"] = mod:localize("next_pickup_hotkey"),
		["tooltip"] = mod:localize("next_pickup_hotkey_tooltip"),
		["default_value"] = {"c", "ctrl"},
		["action"] = "next_pickup"
	},
	{
		["setting_name"] = mod.SETTING_NAMES.PREV_PICKUP_HOTKEY,
		["widget_type"] = "keybind",
		["text"] = mod:localize("prev_pickup_hotkey"),
		["tooltip"] = mod:localize("prev_pickup_hotkey_tooltip"),
		["default_value"] = {"v", "ctrl"},
		["action"] = "prev_pickup"
	},
	{
		["setting_name"] = mod.SETTING_NAMES.SPAWN_PICKUP_HOTKEY,
		["widget_type"] = "keybind",
		["text"] = mod:localize("spawn_pickup_hotkey"),
		["tooltip"] = mod:localize("spawn_pickup_hotkey_tooltip"),
		["default_value"] = {"b", "ctrl"},
		["action"] = "spawn_pickup"
	},
}

return mod_data