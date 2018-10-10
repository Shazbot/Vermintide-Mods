local mod = get_mod("NeuterUltEffects")

local pl = require'pl.import_into'()
local stringx = require'pl.stringx'

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

mod_data.options_widgets = pl.List()
mod.localizations = mod.localizations or pl.Map()

mod.add_option = function(setting_name, option_widget, en_text, en_tooltip, group, index)
	mod.SETTING_NAMES[setting_name] = setting_name
	option_widget.setting_name = setting_name
	if en_text then
		mod.localizations[setting_name] = {
			en = en_text
		}
	end
	if en_tooltip then
		mod.localizations[setting_name.."_T"] = {
			en = en_tooltip
		}
	end
	option_widget.text = mod:localize(setting_name)
	if en_tooltip then
		option_widget.tooltip = mod:localize(setting_name.."_T")
	end
	option_widget.sub_widgets = {}
	if not group then
		index = index or #mod_data.options_widgets + 1
		mod_data.options_widgets:insert(index, option_widget)
	else
		index = index or #group + 1
		table.insert(group, index, option_widget)
	end

	return option_widget.sub_widgets
end

mod_data.options_widgets:extend({
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
})

mod.add_option(
	"DISABLE_DAMAGE_TAKEN_FLASH",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Disable Damage Taken Warning",
	"Disable the red flash upon taking damage.",
	nil
)

mod.add_option(
	"DISABLE_PROJECTILE_TRAILS",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Disable Projectile Trails",
	"Disable the white trail that gets left behind by ranged weapon projectiles.",
	nil
)

mod.add_option(
	"NO_POTION_GLOW",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Disable Potion Glow",
	"Disable the glow around potions.",
	nil
)

for _, name in ipairs( { "SLAYER", "HUNTSMAN", "SHADE", "ZEALOT", "RANGER" } ) do
	mod.SETTING_NAMES[name.."_GROUP"] = name.."_GROUP"
	mod.SETTING_NAMES[name.."_GROUP_T"] = name.."_GROUP_T"
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

local potion_filters_subs = mod.add_option(
	"POTION_FILTERS",
	{
		["widget_type"] = "group",
	},
	"Potion Visual Effects",
	"Disable audio or visual effects on potion use.",
	nil
)

local pot_name_lookup = {
	STR_POT = "Strength Potion",
	SPEED_POT = "Speed Potion",
	CDR_POT = "CDR Potion",
}
for _, name in ipairs( { "STR_POT", "SPEED_POT", "CDR_POT" } ) do
	local potion_subs = mod.add_option(
		name.."_GROUP",
		{
			["widget_type"] = "group",
		},
		pot_name_lookup[name],
		nil,
		potion_filters_subs
	)
	for _, effect_type in ipairs( { "VISUAL", "AUDIO" } ) do
		mod.add_option(
			name.."_"..effect_type,
			{
				["widget_type"] = "checkbox",
				["default_value"] = false,
			},
			pot_name_lookup[name].." "..stringx.title(effect_type),
			"Disable "..effect_type:lower().." effects on "..pot_name_lookup[name].." use.",
			potion_subs
		)
	end
end

return mod_data