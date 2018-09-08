local mod = get_mod("NeuterUltEffects") -- luacheck: ignore get_mod

mod.SETTING_NAMES = {
    WOUNDED = "wounded",
    KNOCKED_DOWN = "knocked_down",
    BLOOD_SPLATTER = "BLOOD_SPLATTER",
    HEALING = "HEALING",
}

local mod_data = {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
}
mod_data.options_widgets = {
	{
		["setting_name"] = mod.SETTING_NAMES.WOUNDED,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("wounded"),
		["tooltip"] = mod:localize("wounded_tooltip"),
		["default_value"] = false,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.KNOCKED_DOWN,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("knocked_down"),
		["tooltip"] = mod:localize("knocked_down_tooltip"),
		["default_value"] = false,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.BLOOD_SPLATTER,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("BLOOD_SPLATTER"),
		["tooltip"] = mod:localize("BLOOD_SPLATTER_T"),
		["default_value"] = false,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.HEALING,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("HEALING"),
		["tooltip"] = mod:localize("HEALING_T"),
		["default_value"] = false,
	},
}

for _, name in ipairs( { "SLAYER", "HUNTSMAN", "SHADE", "ZEALOT", "RANGER" } ) do
	mod.SETTING_NAMES[name.."_GROUP"] = name.."_GROUP"
	mod.SETTING_NAMES[name.."_VISUAL"] = name.."_VISUAL"
	mod.SETTING_NAMES[name.."_AUDIO"] = name.."_AUDIO"
	table.insert(mod_data.options_widgets,
		{
			["setting_name"] = mod.SETTING_NAMES[name.."_GROUP"],
			["widget_type"] = "group",
			["text"] = mod:localize(name.."_GROUP"),
			["tooltip"] = mod:localize(name.."_GROUP_T"),
			["sub_widgets"] = {
				{
					["setting_name"] = mod.SETTING_NAMES[name.."_VISUAL"],
					["widget_type"] = "checkbox",
					["text"] = mod:localize(name.."_VISUAL"),
					["tooltip"] = mod:localize(name.."_VISUAL_T"),
					["default_value"] = false,
				},
				{
					["setting_name"] = mod.SETTING_NAMES[name.."_AUDIO"],
					["widget_type"] = "checkbox",
					["text"] = mod:localize(name.."_AUDIO"),
					["tooltip"] = mod:localize(name.."_AUDIO_T"),
					["default_value"] = false,
				},
			},
		}
	)
end

return mod_data