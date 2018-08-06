local mod = get_mod("TrueSoloQoL") -- luacheck: ignore get_mod

mod.SETTING_NAMES = {
	ASSASSIN_STINGER_FIX = "assassin_stinger_fix",
}

mod.ASSASSIN_SOUND_OPTIONS = {
	DEFAULT = 1,
	KRENCH = 2,
	FIXED = 3,
}

local mod_data = {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
}

mod_data.options_widgets = {
	{
		["setting_name"] = mod.SETTING_NAMES.ASSASSIN_STINGER_FIX,
		["widget_type"] = "dropdown",
		["text"] = mod:localize("assassin_stinger_fix"),
		["tooltip"] = mod:localize("assassin_stinger_fix_tooltip"),
		["options"] = {
			{ text = mod:localize("default"), value = mod.ASSASSIN_SOUND_OPTIONS.DEFAULT }, --1
			{ text = mod:localize("custom_sound"), value = mod.ASSASSIN_SOUND_OPTIONS.KRENCH }, --2
			{ text = mod:localize("fixed"), value = mod.ASSASSIN_SOUND_OPTIONS.FIXED }, --3
		},
	},
}

return mod_data