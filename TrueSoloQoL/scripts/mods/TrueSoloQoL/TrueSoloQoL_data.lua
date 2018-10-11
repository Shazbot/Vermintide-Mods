local mod = get_mod("TrueSoloQoL") -- luacheck: ignore get_mod

mod.SETTING_NAMES = {
	ASSASSIN_TEXT_WARNING = "assassin_text_warning",
	DONT_RESPAWN_BOTS = "DONT_RESPAWN_BOTS",
	AUTO_KILL_BOTS = "AUTO_KILL_BOTS",
	ASSASSIN_HERO_WARNING = "ASSASSIN_HERO_WARNING",
	DISABLE_LEVEL_INTRO_AUDIO = "DISABLE_LEVEL_INTRO_AUDIO",
}

local mod_data = {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
}

mod_data.options_widgets = {
	{
		["setting_name"] = mod.SETTING_NAMES.ASSASSIN_TEXT_WARNING,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("assassin_text_warning"),
		["tooltip"] = mod:localize("assassin_text_warning_tooltip"),
		["default_value"] = false,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.DONT_RESPAWN_BOTS,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("DONT_RESPAWN_BOTS"),
		["tooltip"] = mod:localize("DONT_RESPAWN_BOTS_T"),
		["default_value"] = false,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.AUTO_KILL_BOTS,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("AUTO_KILL_BOTS"),
		["tooltip"] = mod:localize("AUTO_KILL_BOTS_T"),
		["default_value"] = false,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.ASSASSIN_HERO_WARNING,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("ASSASSIN_HERO_WARNING"),
		["tooltip"] = mod:localize("ASSASSIN_HERO_WARNING_T"),
		["default_value"] = false,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.DISABLE_LEVEL_INTRO_AUDIO,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("DISABLE_LEVEL_INTRO_AUDIO"),
		["tooltip"] = mod:localize("DISABLE_LEVEL_INTRO_AUDIO_T"),
		["default_value"] = false,
	},
}

return mod_data