local mod = get_mod("SpawnTweaks") -- luacheck: ignore get_mod

local mod_data = {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
}

mod.SETTING_NAMES = {
    HORDE_SIZE = "horde_size",
    EVENT_HORDE_SIZE = "event_horde_size",
    DISABLE_AMBIENTS = "disable_ambients",
    DISABLE_PATROLS = "disable_patrols",
    DISABLE_ROAMING_PATROLS = "disable_roaming_patrols",
    DISABLE_TIMED_SPECIALS = "disable_timed_specials",
    DISABLE_FIXED_EVENT_SPECIALS = "fixed_event_specials",
    DISABLE_BOSSES = "disable_bosses",
    NO_BOSS_DOOR = "no_boss_door",
}

mod_data.options_widgets = {
	{
		["setting_name"] = mod.SETTING_NAMES.HORDE_SIZE,
		["widget_type"] = "numeric",
		["text"] = mod:localize("horde_size"),
		["tooltip"] = mod:localize("horde_size_tooltip"),
		["range"] = {0, 300},
		["unit_text"] = "%",
	    ["default_value"] = 100,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.EVENT_HORDE_SIZE,
		["widget_type"] = "numeric",
		["text"] = mod:localize("event_horde_size"),
		["tooltip"] = mod:localize("event_horde_size_tooltip"),
		["range"] = {0, 300},
		["unit_text"] = "%",
	    ["default_value"] = 100,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.DISABLE_AMBIENTS,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("disable_ambients"),
		["tooltip"] = mod:localize("disable_ambients_tooltip"),
		["default_value"] = false,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.DISABLE_PATROLS,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("disable_patrols"),
		["tooltip"] = mod:localize("disable_patrols_tooltip"),
		["default_value"] = false,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.DISABLE_ROAMING_PATROLS,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("disable_roaming_patrols"),
		["tooltip"] = mod:localize("disable_roaming_patrols_tooltip"),
		["default_value"] = false,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.DISABLE_TIMED_SPECIALS,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("disable_timed_specials"),
		["tooltip"] = mod:localize("disable_timed_specials_tooltip"),
		["default_value"] = false,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.DISABLE_FIXED_EVENT_SPECIALS,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("disable_fixed_event_specials"),
		["tooltip"] = mod:localize("disable_fixed_event_specials_tooltip"),
		["default_value"] = false,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.DISABLE_BOSSES,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("disable_bosses"),
		["tooltip"] = mod:localize("disable_bosses_tooltip"),
		["default_value"] = false,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.NO_BOSS_DOOR,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("no_boss_door"),
		["tooltip"] = mod:localize("no_boss_door_tooltip"),
		["default_value"] = false,
	},
}

return mod_data