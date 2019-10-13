local mod = get_mod("TrueSoloQoL") -- luacheck: ignore get_mod

mod.SETTING_NAMES = {
	ASSASSIN_TEXT_WARNING = "assassin_text_warning",
	PACKMASTER_TEXT_WARNING = "packmaster_text_warning",
	DONT_RESPAWN_BOTS = "DONT_RESPAWN_BOTS",
	AUTO_KILL_BOTS = "AUTO_KILL_BOTS",
	ASSASSIN_HERO_WARNING = "ASSASSIN_HERO_WARNING",
	DISABLE_LEVEL_INTRO_AUDIO = "DISABLE_LEVEL_INTRO_AUDIO",
	DISABLE_ULT_VOICE_LINE = "DISABLE_ULT_VOICE_LINE",
	DISABLE_MUTATOR_EXPLOSIONS = "DISABLE_MUTATOR_EXPLOSIONS",
	SHOW_BOSS_PATH_PROGRESS = "SHOW_BOSS_PATH_PROGRESS",
	DRAW_BOSS_EVENTS = "DRAW_BOSS_EVENTS",
	DISABLE_FOG = "DISABLE_FOG",
	DISABLE_SUN_SHADOWS = "DISABLE_SUN_SHADOWS",
	DONT_RESTART = "DONT_RESTART",
}

local mod_data = {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
}

mod_data.options_widgets = {
	{
		["setting_name"] = mod.SETTING_NAMES.DONT_RESTART,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("DONT_RESTART"),
		["tooltip"] = mod:localize("DONT_RESTART_T"),
		["default_value"] = false,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.ASSASSIN_TEXT_WARNING,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("assassin_text_warning"),
		["tooltip"] = mod:localize("assassin_text_warning_tooltip"),
		["default_value"] = false,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.PACKMASTER_TEXT_WARNING,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("packmaster_text_warning"),
		["tooltip"] = mod:localize("packmaster_text_warning_tooltip"),
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
	{
		["setting_name"] = mod.SETTING_NAMES.DISABLE_ULT_VOICE_LINE,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("DISABLE_ULT_VOICE_LINE"),
		["tooltip"] = mod:localize("DISABLE_ULT_VOICE_LINE_T"),
		["default_value"] = false,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.DISABLE_MUTATOR_EXPLOSIONS,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("DISABLE_MUTATOR_EXPLOSIONS"),
		["tooltip"] = mod:localize("DISABLE_MUTATOR_EXPLOSIONS_T"),
		["default_value"] = false,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.SHOW_BOSS_PATH_PROGRESS,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("SHOW_BOSS_PATH_PROGRESS"),
		["tooltip"] = mod:localize("SHOW_BOSS_PATH_PROGRESS_T"),
		["default_value"] = false,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.DRAW_BOSS_EVENTS,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("DRAW_BOSS_EVENTS"),
		["tooltip"] = mod:localize("DRAW_BOSS_EVENTS_T"),
		["default_value"] = false,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.DISABLE_FOG,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("DISABLE_FOG"),
		["tooltip"] = mod:localize("DISABLE_FOG_T"),
		["default_value"] = false,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.DISABLE_SUN_SHADOWS,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("DISABLE_SUN_SHADOWS"),
		["tooltip"] = mod:localize("DISABLE_SUN_SHADOWS_T"),
		["default_value"] = false,
	},
}

return mod_data
