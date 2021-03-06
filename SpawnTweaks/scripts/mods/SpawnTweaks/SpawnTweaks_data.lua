local mod = get_mod("SpawnTweaks")

local pl = require'pl.import_into'()

local mod_data = {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	allow_rehooking = true,
}

mod.SETTING_NAMES = {
	HORDE_SIZE = "horde_size",
	EVENT_HORDE_SIZE = "event_horde_size",
	DISABLE_PATROLS = "disable_patrols",
	DISABLE_ROAMING_PATROLS = "disable_roaming_patrols",
	DISABLE_FIXED_EVENT_SPECIALS = "fixed_event_specials",
	NO_BOSS_DOOR = "no_boss_door",
	SPAWN_COOLDOWN_MIN = "spawn_cooldown_min",
	SPAWN_COOLDOWN_MAX = "spawn_cooldown_max",
	SAFE_ZONE_DELAY_MIN = "safe_zone_delay_min",
	SAFE_ZONE_DELAY_MAX = "safe_zone_delay_max",
	NO_EMPTY_EVENTS = "no_empty_events",
	MAX_SPECIALS = "max_specials",
	MAX_SAME_SPECIALS = "max_same_specials",
	MAX_ONE_BOSS = "max_one_boss",
	DOUBLE_BOSSES = "double_bosses",
	THREAT_MULTIPLIER = "threat_multiplier",
	MAX_GRUNTS = "max_grunts",
	HORDE_GRUNT_LIMIT = "horde_grunt_limit",
	HORDE_FREQUENCY_MIN = "horde_frequency_min",
	HORDE_FREQUENCY_MAX = "horde_frequency_max",
	AMBIENTS_MULTIPLIER = "ambients_multiplier",
	MORE_AMBIENT_ELITES = "more_ambient_elites",
	NO_TROLL = "no_troll",
	NO_CHAOS_SPAWN = "no_chaos_spawn",
	NO_STORMFIEND = "no_stormfiend",
	NO_MINOTAUR = "no_minotaur",
	HORDE_STARTUP_MIN = "horde_startup_min",
	HORDE_STARTUP_MAX = "horde_startup_max",
	DISABLE_FIXED_SPAWNS = "disable_fixed_spawns",
	BOSSES = "bosses",
	AMBIENTS = "ambients",
	HORDES = "hordes",
	SPECIALS = "specials",
	ALWAYS_SPECIALS = "always_specials",
	SPECIALS_NO_THREAT_DELAY = "specials_no_threat_delay",
	BOSS_DMG_MULTIPLIER = "boss_dmg_multiplier",
	SPECIAL_TO_BOSS_CHANCE = "special_to_boss_chance",
	SPECIALS_TOGGLE_GROUP = "specials_toggle_group",
	BREEDS_TOGGLE_GROUP = "breeds_toggle_group",
	SPECIALS_WEIGHTS_TOGGLE_GROUP = "specials_weights_toggle_group",
	CUSTOM_HORDE_TOGGLE_GROUP = "custom_horde_toggle_group",
	SKAVEN_HORDE_TOGGLE_GROUP = "skaven_horde_toggle_group",
	CHAOS_HORDE_TOGGLE_GROUP = "chaos_horde_toggle_group",
	HORDE_TYPES = "horde_types",
	AMBIENTS_NO_THREAT = "ambients_no_threat",
	CUSTOM_AMBIENTS_TOGGLE_GROUP = "CUSTOM_AMBIENTS_TOGGLE_GROUP",
	SPECIAL_TO_BOSS_CHANCE_ALLOW_BOSS_STACKING = "SPECIAL_TO_BOSS_CHANCE_ALLOW_BOSS_STACKING",
	LORD_DMG_MULTIPLIER = "LORD_DMG_MULTIPLIER",
	BOSS_EVENTS = "BOSS_EVENTS",
	HORDES_BOTH_DIRECTIONS = "HORDES_BOTH_DIRECTIONS",
	AGGRO_PATROLS = "AGGRO_PATROLS",
	DISABLE_BLOC_VECTOR_HORDE = "DISABLE_BLOC_VECTOR_HORDE",
	NO_BOTS = "NO_BOTS",
	THREAT_GROUP = "THREAT_GROUP",
	DISABLE_SPAWNS_GROUP = "DISABLE_SPAWNS_GROUP",
	VERMINHOOD_RADIUS = "VERMINHOOD_RADIUS",
}

mod.BOSSES = {
	DEFAULT = 1,
	DISABLE = 2,
	CUSTOMIZE = 3,
}

mod.AMBIENTS = {
	DEFAULT = 1,
	DISABLE = 2,
	CUSTOMIZE = 3,
}

mod.HORDES = {
	DEFAULT = 1,
	DISABLE = 2,
	CUSTOMIZE = 3,
}

mod.SPECIALS = {
	DEFAULT = 1,
	DISABLE = 2,
	CUSTOMIZE = 3,
}

mod.HORDE_TYPES = {
	DEFAULT = 1,
	CUSTOM = 2,
	SKAVEN = 3,
	CHAOS = 4,
}

mod.BOSS_EVENTS = {
	ONLY_BOSSES = 1,
	ONLY_PATROLS = 2,
	BOTH = 3,
}

mod.VERMINHOOD_MODES = {
	DISABLED = 1,
	SPLIT = 2,
	POOL = 3,
}

local unused_specials = pl.List{
	"chaos_plague_wave_spawner",
	"chaos_tentacle_sorcerer",
	"chaos_tentacle",
	"chaos_plague_sorcerer",

	"pet_rat",
	"pet_pig",
}

mod.all_breeds = table.clone(Breeds)
for breed_name, breed_data in pairs(mod.all_breeds) do
	if unused_specials:contains(breed_name)
	or pl.stringx.lfind(breed_name, "_tutorial")
	or pl.stringx.lfind(breed_name, "_dummy") then
		mod.all_breeds[breed_name] = nil
	else
		breed_data.localized_name = Localize(breed_name)
		if breed_name == "chaos_corruptor_sorcerer" then
			breed_data.localized_name = "Lifeleech Sorcerer"
		end
	end
end

mod.lord_breeds = pl.Map(table.clone(mod.all_breeds))
for breed_name, breed_data in pairs(mod.lord_breeds) do
	if not breed_data.armored_boss_damage_reduction
	and not breed_data.lord_damage_reduction then
		mod.lord_breeds[breed_name] = nil
	end
end

mod.specials_breeds = table.clone(mod.all_breeds)
for breed_name, breed_data in pairs(mod.specials_breeds) do
	if not breed_data.special then
		mod.specials_breeds[breed_name] = nil
	end
end

local breeds_dmg_group_widget = {
	["setting_name"] = mod.SETTING_NAMES.BREEDS_TOGGLE_GROUP,
	["widget_type"] = "checkbox",
	["text"] = mod:localize("breeds_dmg_group"),
	["sub_widgets"] = {},
	["default_value"] = false,
}
breeds_dmg_group_widget.sub_widgets = (function()
	local breed_options = {}
	for breed_name, breed_data in pairs(mod.all_breeds) do
		table.insert(breed_options,
			{
				["setting_name"] = breed_name.."_dmg_toggle",
				["widget_type"] = "numeric",
				["text"] = breed_data.localized_name,
				["tooltip"] =  mod:localize("breed_dmg_multiplier_tooltip")..breed_data.localized_name,
				["range"] = {0, 1000},
				["unit_text"] = "%",
				["default_value"] = 100,
			})
	end
	return breed_options
end)()

local custom_ambients_group_widget = {
	["show_widget_condition"] = {3},
	["setting_name"] = mod.SETTING_NAMES.CUSTOM_AMBIENTS_TOGGLE_GROUP,
	["widget_type"] = "checkbox",
	["text"] = mod:localize("CUSTOM_AMBIENTS_TOGGLE_GROUP"),
	["tooltip"] = mod:localize("CUSTOM_AMBIENTS_TOGGLE_GROUP_tooltip"),
	["sub_widgets"] = {},
	["default_value"] = false,
}
custom_ambients_group_widget.sub_widgets = (function()
	local breed_options = {}
	for breed_name, breed_data in pairs(mod.all_breeds) do
		table.insert(breed_options,
			{
				["setting_name"] = breed_name.."_ambient_weight",
				["widget_type"] = "numeric",
				["text"] = breed_data.localized_name,
				["tooltip"] = "Set spawn weight for "..breed_data.localized_name..".",
				["range"] = {0, 20},
				["default_value"] = 0,
			})
	end
	return breed_options
end)()

local custom_horde_toggle_widget = {
	["show_widget_condition"] = {3},
	["setting_name"] = mod.SETTING_NAMES.CUSTOM_HORDE_TOGGLE_GROUP,
	["widget_type"] = "group",
	["text"] = mod:localize("custom_horde_toggle_group"),
	["tooltip"] = mod:localize("custom_horde_toggle_group_tooltip"),
	["sub_widgets"] = {},
}
local skaven_horde_toggle_widget = {
	["show_widget_condition"] = {3},
	["setting_name"] = mod.SETTING_NAMES.SKAVEN_HORDE_TOGGLE_GROUP,
	["widget_type"] = "checkbox",
	["text"] = mod:localize("skaven_horde_toggle_group"),
	["tooltip"] = mod:localize("skaven_horde_toggle_group_tooltip"),
	["sub_widgets"] = {},
	["default_value"] = false,
}
local chaos_horde_toggle_widget = {
	["show_widget_condition"] = {3},
	["setting_name"] = mod.SETTING_NAMES.CHAOS_HORDE_TOGGLE_GROUP,
	["widget_type"] = "checkbox",
	["text"] = mod:localize("chaos_horde_toggle_group"),
	["tooltip"] = mod:localize("chaos_horde_toggle_group_tooltip"),
	["sub_widgets"] = {},
	["default_value"] = false,
}
local horde_name_lookup = { "custom_horde", "skaven_horde", "chaos_horde"}
for i, horde_toggle_widget in ipairs( { custom_horde_toggle_widget, skaven_horde_toggle_widget, chaos_horde_toggle_widget } ) do
	horde_toggle_widget.sub_widgets = (function()
		local breed_options = {}
		for breed_name, breed_data in pairs(mod.all_breeds) do
			table.insert(breed_options,
				{
					["setting_name"] = breed_name.."_"..horde_name_lookup[i].."_weight",
					["widget_type"] = "numeric",
					["text"] = breed_data.localized_name,
					["tooltip"] = "Set spawn weight for "..breed_data.localized_name..".",
					["range"] = {0, 20},
					["default_value"] = 0,
				})
		end
		return breed_options
	end)()
end

local special_specials = {
	beastmen_standard_bearer_crater = true,
	curse_mutator_sorcerer = true,
	chaos_mutator_sorcerer = true,
}

local specials_toggle_widget = {
	["show_widget_condition"] = {3},
	["setting_name"] = mod.SETTING_NAMES.SPECIALS_TOGGLE_GROUP,
	["widget_type"] = "group",
	["text"] = mod:localize("specials_toggle_group"),
	["sub_widgets"] = {}
}
specials_toggle_widget.sub_widgets = (function()
	local breed_options = {}
	for breed_name, breed_data in pairs(mod.specials_breeds) do
		local default_value = not not special_specials[breed_name]
		table.insert(breed_options,
			{
				["setting_name"] = breed_name.."_toggle",
				["widget_type"] = "checkbox",
				["text"] = breed_data.localized_name,
				["tooltip"] = "Remove "..breed_data.localized_name.." as an elegible spawn.",
				["default_value"] = default_value,
			})
	end
	return breed_options
end)()

local specials_weights_toggle_widget = {
	["show_widget_condition"] = {3},
	["setting_name"] = mod.SETTING_NAMES.SPECIALS_WEIGHTS_TOGGLE_GROUP,
	["widget_type"] = "checkbox",
	["text"] = mod:localize("specials_weights_toggle_group"),
	["tooltip"] = mod:localize("specials_weights_toggle_group_tooltip"),
	["default_value"] = false,
	["sub_widgets"] = {},
}
specials_weights_toggle_widget.sub_widgets = (function()
	local breed_options = {}
	for breed_name, breed_data in pairs(mod.specials_breeds) do
		table.insert(breed_options,
			{
				["setting_name"] = breed_name.."_weight",
				["widget_type"] = "numeric",
				["text"] = breed_data.localized_name,
				["tooltip"] = "Set spawn weight for "..breed_data.localized_name..".",
				["range"] = {0, 20},
				["default_value"] = 1,
			})
	end
	return breed_options
end)()

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
	option_widget.tooltip = mod:localize(setting_name.."_T")
	option_widget.sub_widgets = option_widget.sub_widgets or {}
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
		["setting_name"] = mod.SETTING_NAMES.NO_BOTS,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("NO_BOTS"),
		["tooltip"] = mod:localize("NO_BOTS_T"),
		["default_value"] = false,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.THREAT_GROUP,
		["widget_type"] = "group",
		["text"] = mod:localize("THREAT_GROUP"),
		["sub_widgets"] = {
			{
				["setting_name"] = mod.SETTING_NAMES.THREAT_MULTIPLIER,
				["widget_type"] = "numeric",
				["text"] = mod:localize("threat_multiplier"),
				["tooltip"] = mod:localize("threat_multiplier_tooltip"),
				["range"] = {0, 1},
				["decimals_number"] = 1,
				["default_value"] = 1,
			},
			{
				["setting_name"] = mod.SETTING_NAMES.SPECIALS_NO_THREAT_DELAY,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("specials_no_threat_delay"),
				["tooltip"] = mod:localize("specials_no_threat_delay_tooltip"),
				["default_value"] = false,
			},
			{
				["setting_name"] = mod.SETTING_NAMES.AMBIENTS_NO_THREAT,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("ambients_no_threat"),
				["tooltip"] = mod:localize("ambients_no_threat_tooltip"),
				["default_value"] = false,
			},
		},
	},
	{
		["setting_name"] = mod.SETTING_NAMES.ALWAYS_SPECIALS,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("always_specials"),
		["tooltip"] = mod:localize("always_specials_tooltip"),
		["default_value"] = false,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.DISABLE_SPAWNS_GROUP,
		["widget_type"] = "group",
		["text"] = mod:localize("DISABLE_SPAWNS_GROUP"),
		["sub_widgets"] = {
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
				["setting_name"] = mod.SETTING_NAMES.DISABLE_FIXED_EVENT_SPECIALS,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("disable_fixed_event_specials"),
				["tooltip"] = mod:localize("disable_fixed_event_specials_tooltip"),
				["default_value"] = false,
			},
			{
				["setting_name"] = mod.SETTING_NAMES.DISABLE_FIXED_SPAWNS,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("disable_fixed_spawns"),
				["tooltip"] = mod:localize("disable_fixed_spawns_tooltip"),
				["default_value"] = false,
			},
		},
	},
	breeds_dmg_group_widget,
	{
		["setting_name"] = mod.SETTING_NAMES.HORDES,
		["widget_type"] = "dropdown",
		["default_value"] = mod.HORDES.DEFAULT,
		["text"] = mod:localize("hordes"),
		["tooltip"] = mod:localize("hordes_tooltip"),
		["options"] = {
			{ text = mod:localize("default"), value = mod.HORDES.DEFAULT }, --1
			{ text = mod:localize("disable"), value = mod.HORDES.DISABLE }, --2
			{ text = mod:localize("customize"), value = mod.HORDES.CUSTOMIZE }, --3
		},
		["sub_widgets"] = {
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.HORDE_SIZE,
				["widget_type"] = "numeric",
				["text"] = mod:localize("horde_size"),
				["tooltip"] = mod:localize("horde_size_tooltip"),
				["range"] = {0, 300},
				["unit_text"] = "%",
				["default_value"] = 100,
			},
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.EVENT_HORDE_SIZE,
				["widget_type"] = "numeric",
				["text"] = mod:localize("event_horde_size"),
				["tooltip"] = mod:localize("event_horde_size_tooltip"),
				["range"] = {0, 300},
				["unit_text"] = "%",
				["default_value"] = 100,
			},
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.DISABLE_BLOC_VECTOR_HORDE,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("DISABLE_BLOC_VECTOR_HORDE"),
				["tooltip"] = mod:localize("DISABLE_BLOC_VECTOR_HORDE_T"),
				["default_value"] = false,
			},
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.HORDES_BOTH_DIRECTIONS,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("HORDES_BOTH_DIRECTIONS"),
				["tooltip"] = mod:localize("HORDES_BOTH_DIRECTIONS_T"),
				["default_value"] = false,
			},
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.HORDE_FREQUENCY_MIN,
				["widget_type"] = "numeric",
				["text"] = mod:localize("horde_frequency_min"),
				["tooltip"] = mod:localize("horde_frequency_min_tooltip"),
				["range"] = {5, 150},
				["unit_text"] = " sec",
				["default_value"] = 50,
			},
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.HORDE_FREQUENCY_MAX,
				["widget_type"] = "numeric",
				["text"] = mod:localize("horde_frequency_max"),
				["tooltip"] = mod:localize("horde_frequency_max_tooltip"),
				["range"] = {5, 200},
				["unit_text"] = " sec",
				["default_value"] = 100,
			},
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.HORDE_STARTUP_MIN,
				["widget_type"] = "numeric",
				["text"] = mod:localize("horde_startup_min"),
				["tooltip"] = mod:localize("horde_startup_min_tooltip"),
				["range"] = {0, 200},
				["unit_text"] = " sec",
				["default_value"] = 40,
			},
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.HORDE_STARTUP_MAX,
				["widget_type"] = "numeric",
				["text"] = mod:localize("horde_startup_max"),
				["tooltip"] = mod:localize("horde_startup_max_tooltip"),
				["range"] = {0, 250},
				["unit_text"] = " sec",
				["default_value"] = 120,
			},
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.MAX_GRUNTS,
				["widget_type"] = "numeric",
				["text"] = mod:localize("max_grunts"),
				["tooltip"] = mod:localize("max_grunts_tooltip"),
				["range"] = {10, 360},
				["default_value"] = 90,
			},
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.HORDE_GRUNT_LIMIT,
				["widget_type"] = "numeric",
				["text"] = mod:localize("horde_grunt_limit"),
				["tooltip"] = mod:localize("horde_grunt_limit_tooltip"),
				["range"] = {10, 240},
				["default_value"] = 60,
			},
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.HORDE_TYPES,
				["widget_type"] = "dropdown",
				["text"] = mod:localize("horde_types"),
				["tooltip"] = mod:localize("horde_types_tooltip"),
				["options"] = {
					{ text = mod:localize("horde_types_both"), value = mod.HORDE_TYPES.DEFAULT }, --1
					{ text = mod:localize("horde_types_only_custom"), value = mod.HORDE_TYPES.CUSTOM }, --2
					{ text = mod:localize("horde_types_only_skaven"), value = mod.HORDE_TYPES.SKAVEN }, --3
					{ text = mod:localize("horde_types_only_chaos"), value = mod.HORDE_TYPES.CHAOS }, --4
				},
				["sub_widgets"] = {},
			},
			custom_horde_toggle_widget,
			skaven_horde_toggle_widget,
			chaos_horde_toggle_widget,
		},
	},
	{
		["setting_name"] = mod.SETTING_NAMES.SPECIALS,
		["widget_type"] = "dropdown",
		["default_value"] = mod.SPECIALS.DEFAULT,
		["text"] = mod:localize("specials"),
		["tooltip"] = mod:localize("specials_tooltip"),
		["options"] = {
			{ text = mod:localize("default"), value = mod.SPECIALS.DEFAULT }, --1
			{ text = mod:localize("disable"), value = mod.SPECIALS.DISABLE }, --2
			{ text = mod:localize("customize"), value = mod.SPECIALS.CUSTOMIZE }, --3
		},
		["sub_widgets"] = {
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.MAX_SPECIALS,
				["widget_type"] = "numeric",
				["text"] = mod:localize("max_specials"),
				["tooltip"] = mod:localize("max_specials_tooltip"),
				["range"] = {0, 50},
				["default_value"] = 4,
			},
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.MAX_SAME_SPECIALS,
				["widget_type"] = "numeric",
				["text"] = mod:localize("max_same_specials"),
				["tooltip"] = mod:localize("max_same_specials_tooltip"),
				["range"] = {0, 50},
				["default_value"] = 2,
			},
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.SPAWN_COOLDOWN_MIN,
				["widget_type"] = "numeric",
				["text"] = mod:localize("spawn_cooldown_min"),
				["tooltip"] = mod:localize("spawn_cooldown_min_tooltip"),
				["range"] = {0, 150},
				["unit_text"] = " sec",
				["default_value"] = 50,
			},
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.SPAWN_COOLDOWN_MAX,
				["widget_type"] = "numeric",
				["text"] = mod:localize("spawn_cooldown_max"),
				["tooltip"] = mod:localize("spawn_cooldown_max_tooltip"),
				["range"] = {0, 150},
				["unit_text"] = " sec",
				["default_value"] = 90,
			},
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.SAFE_ZONE_DELAY_MIN,
				["widget_type"] = "numeric",
				["text"] = mod:localize("safe_zone_delay_min"),
				["tooltip"] = mod:localize("safe_zone_delay_min_tooltip"),
				["range"] = {0, 100},
				["unit_text"] = " sec",
				["default_value"] = 30,
			},
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.SAFE_ZONE_DELAY_MAX,
				["widget_type"] = "numeric",
				["text"] = mod:localize("safe_zone_delay_max"),
				["tooltip"] = mod:localize("safe_zone_delay_max_tooltip"),
				["range"] = {0, 100},
				["unit_text"] = " sec",
				["default_value"] = 60,
			},
			specials_toggle_widget,
			specials_weights_toggle_widget,
		},
	},
	{
		["setting_name"] = mod.SETTING_NAMES.AMBIENTS,
		["widget_type"] = "dropdown",
		["default_value"] = mod.AMBIENTS.DEFAULT,
		["text"] = mod:localize("ambients"),
		["tooltip"] = mod:localize("ambients_tooltip"),
		["options"] = {
			{ text = mod:localize("default"), value = mod.AMBIENTS.DEFAULT }, --1
			{ text = mod:localize("disable"), value = mod.AMBIENTS.DISABLE }, --2
			{ text = mod:localize("customize"), value = mod.AMBIENTS.CUSTOMIZE }, --3
		},
		["sub_widgets"] = {
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.MORE_AMBIENT_ELITES,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("more_ambient_elites"),
				["tooltip"] = mod:localize("more_ambient_elites_tooltip"),
				["default_value"] = false,
			},
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.AMBIENTS_MULTIPLIER,
				["widget_type"] = "numeric",
				["text"] = mod:localize("ambients_multiplier"),
				["tooltip"] = mod:localize("ambients_multiplier_tooltip"),
				["range"] = {10, 1500},
				["unit_text"] = "%",
				["default_value"] = 100,
			},
			custom_ambients_group_widget,
		},
	},
	{
		["setting_name"] = mod.SETTING_NAMES.BOSSES,
		["widget_type"] = "dropdown",
		["default_value"] = mod.BOSSES.DEFAULT,
		["text"] = mod:localize("bosses"),
		["tooltip"] = mod:localize("bosses_tooltip"),
		["options"] = {
			{ text = mod:localize("default"), value = mod.BOSSES.DEFAULT }, --1
			{ text = mod:localize("disable"), value = mod.BOSSES.DISABLE }, --2
			{ text = mod:localize("customize"), value = mod.BOSSES.CUSTOMIZE }, --3
		},
		["sub_widgets"] = {
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.MAX_ONE_BOSS,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("max_one_boss"),
				["tooltip"] = mod:localize("max_one_boss_tooltip"),
				["default_value"] = false,
			},
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.DOUBLE_BOSSES,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("double_bosses"),
				["tooltip"] = mod:localize("double_bosses_tooltip"),
				["default_value"] = false,
			},
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.NO_TROLL,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("no_troll"),
				["tooltip"] = mod:localize("no_troll_tooltip"),
				["default_value"] = false,
			},
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.NO_CHAOS_SPAWN,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("no_chaos_spawn"),
				["tooltip"] = mod:localize("no_chaos_spawn_tooltip"),
				["default_value"] = false,
			},
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.NO_STORMFIEND,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("no_stormfiend"),
				["tooltip"] = mod:localize("no_stormfiend_tooltip"),
				["default_value"] = false,
			},
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.NO_MINOTAUR,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("no_minotaur"),
				["tooltip"] = mod:localize("no_minotaur_tooltip"),
				["default_value"] = false,
			},
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.NO_EMPTY_EVENTS,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("no_empty_events"),
				["tooltip"] = mod:localize("no_empty_events_tooltip"),
				["default_value"] = false,
				["sub_widgets"] = {
					{
						["setting_name"] = mod.SETTING_NAMES.BOSS_EVENTS,
						["widget_type"] = "dropdown",
						["default_value"] = mod.BOSS_EVENTS.ONLY_BOSSES,
						["text"] = mod:localize("BOSS_EVENTS"),
						["tooltip"] = mod:localize("BOSS_EVENTS_T"),
						["options"] = {
							{ text = mod:localize("BOSS_EVENTS_ONLY_BOSSES"), value = mod.BOSS_EVENTS.ONLY_BOSSES }, --1
							{ text = mod:localize("BOSS_EVENTS_ONLY_PATROLS"), value = mod.BOSS_EVENTS.ONLY_PATROLS }, --2
							{ text = mod:localize("BOSS_EVENTS_BOTH"), value = mod.BOSS_EVENTS.BOTH }, --3
						},
					},
				},
			},
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.AGGRO_PATROLS,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("AGGRO_PATROLS"),
				["tooltip"] = mod:localize("AGGRO_PATROLS_T"),
				["default_value"] = false,
			},
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.NO_BOSS_DOOR,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("no_boss_door"),
				["tooltip"] = mod:localize("no_boss_door_tooltip"),
				["default_value"] = false,
			},
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.BOSS_DMG_MULTIPLIER,
				["widget_type"] = "numeric",
				["text"] = mod:localize("boss_dmg_multiplier"),
				["tooltip"] = mod:localize("boss_dmg_multiplier_tooltip"),
				["range"] = {0, 1000},
				["unit_text"] = "%",
				["default_value"] = 100,
			},
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.LORD_DMG_MULTIPLIER,
				["widget_type"] = "numeric",
				["text"] = mod:localize("LORD_DMG_MULTIPLIER"),
				["tooltip"] = mod:localize("LORD_DMG_MULTIPLIER_T"),
				["range"] = {0, 1000},
				["unit_text"] = "%",
				["default_value"] = 100,
			},
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.SPECIAL_TO_BOSS_CHANCE,
				["widget_type"] = "numeric",
				["text"] = mod:localize("special_to_boss_chance"),
				["tooltip"] = mod:localize("special_to_boss_chance_tooltip"),
				["range"] = {0, 100},
				["unit_text"] = "%",
				["default_value"] = 0,
			},
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.SPECIAL_TO_BOSS_CHANCE_ALLOW_BOSS_STACKING,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("SPECIAL_TO_BOSS_CHANCE_ALLOW_BOSS_STACKING"),
				["tooltip"] = mod:localize("SPECIAL_TO_BOSS_CHANCE_ALLOW_BOSS_STACKING_T"),
				["default_value"] = false,
			},
		},
	},
})

local mutator_options_subs = mod.add_option(
	"MUTATOR_OPTIONS_GROUP",
	{
		["widget_type"] = "group",
	},
	"Mutator Options",
	"Other options for mutators."
)
local local_mutators_subs = mod.add_option(
	"MUTATOR_OPTIONS_GROUP",
	{
		["widget_type"] = "group",
	},
	"Local Mutators",
	"Mutators that work locally per player and are not host controlled."
		.."\nMeaning it won't cause crashes, but works only for those who have it enabled.",
	mutator_options_subs
)

local invisible_teammates_subs = mod.add_option(
	"INVISIBLE_TEAMMATES_MUTATOR",
	{
		["widget_type"] = "checkbox",
	  ["default_value"] = false,
	},
	"Invisible Teammates",
	"Hide your teammates based on distance from the player.",
	local_mutators_subs
)
mod.add_option(
	"INVISIBLE_TEAMMATES_MUTATOR_DISTANCE",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 100},
	  ["default_value"] = 5,
	  ["decimals_number"] = 1,
	},
	"Distance",
	"Distance from the player at which to start hiding teammates.",
	invisible_teammates_subs
)
mod.add_option(
	"INVISIBLE_TEAMMATES_MUTATOR_REVERSE",
	{
		["widget_type"] = "checkbox",
	  ["default_value"] = false,
	},
	"Reverse",
	"Hide teammates that are within distance instead.",
	invisible_teammates_subs
)

local invisible_enemies_subs = mod.add_option(
	"INVISIBLE_ENEMIES_MUTATOR",
	{
		["widget_type"] = "checkbox",
	  ["default_value"] = false,
	},
	"Invisible Enemies",
	"Hide your enemies based on distance from the player.",
	local_mutators_subs
)
mod.add_option(
	"INVISIBLE_ENEMIES_MUTATOR_DISTANCE",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 100},
	  ["default_value"] = 10,
	  ["decimals_number"] = 1,
	},
	"Distance",
	"Distance from the player at which to start hiding enemies.",
	invisible_enemies_subs
)
mod.add_option(
	"INVISIBLE_ENEMIES_MUTATOR_REVERSE",
	{
		["widget_type"] = "checkbox",
	  ["default_value"] = false,
	},
	"Reverse",
	"Hide enemies that are within distance instead.",
	invisible_enemies_subs
)
mod.add_option(
	"INVISIBLE_ENEMIES_MUTATOR_SHOW_WEAPONS",
	{
		["widget_type"] = "checkbox",
	  ["default_value"] = false,
	},
	"Show Weapons",
	"Don't hide enemy weapons.",
	invisible_enemies_subs
)

mod.add_option(
	"DISABLE_ULT_CD_ON_STRIKE",
	{
		["widget_type"] = "checkbox",
	  ["default_value"] = false,
	},
	"Disable Ult CD On Strike",
	"Disable Ult cooldown reduction when hitting enemies."
		.."\nREQUIRES A CAREER SWITCH TO APPLY CHANGES",
	local_mutators_subs
)
mod.add_option(
	"DISABLE_ULT_CD_ON_GETTING_HIT",
	{
		["widget_type"] = "checkbox",
	  ["default_value"] = false,
	},
	"Disable Ult CD On Getting Hit",
	"Disable Ult cooldown reduction when hit."
		.."\nREQUIRES A CAREER SWITCH TO APPLY CHANGES",
	local_mutators_subs
)

mod.add_option(
	"RESTART_ON_DEFEAT",
	{
		["widget_type"] = "checkbox",
	  ["default_value"] = false,
	},
	"Restart Map On Defeat",
	"Auto-restarts the map on defeat."
		.."\nTo return to inn with full party you can write /st_win in chat.",
	mutator_options_subs
)

local reverse_twins_subs = mod.add_option(
	"REVERSE_TWINS_MUTATOR",
	{
		["widget_type"] = "checkbox",
	  ["default_value"] = false,
	},
	"Reverse Twins Mutator",
	"Like the twins mutator, but chance to spawn a single higher tier enemy in place.",
	mutator_options_subs
)
mod.add_option(
	"REVERSE_TWINS_MUTATOR_CHANCE",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 100},
		["unit_text"] = "%",
	  ["default_value"] = 50,
	},
	"Spawn Chance",
	"Chance for new enemy to spawn on enemy death.",
	reverse_twins_subs
)
mod.add_option(
	"REVERSE_TWINS_MUTATOR_BOSS_CHANCE",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 100},
		["unit_text"] = "%",
	  ["default_value"] = 25,
	},
	"Boss And Lord Spawn Chance",
	"The second roll if a boss or lord was selected to spawn.",
	reverse_twins_subs
)
mod.add_option(
	"REVERSE_TWINS_MUTATOR_BOMB_RATS",
	{
		["widget_type"] = "checkbox",
	  ["default_value"] = false,
	},
	"Include Bomb Rats",
	"Include bomb rats as a spawnable enemy."
		.."\nOptional due to a very rare engine crash that can happen and that is not something I can fix.",
	reverse_twins_subs
)

mod.add_option(
	"VERMINHOOD_MUTATOR",
	{
		["widget_type"] = "dropdown",
		["default_value"] = mod.VERMINHOOD_MODES.DISABLED,
		["options"] = {
			{ text = mod:localize("disable"), value = mod.VERMINHOOD_MODES.DISABLED }, --1
			{ text = mod:localize("split"), value = mod.VERMINHOOD_MODES.SPLIT }, --2
			{ text = mod:localize("pool"), value = mod.VERMINHOOD_MODES.POOL }, --3
		},
		["sub_widgets"] = {
			{
				["show_widget_condition"] = {2,3},
				["setting_name"] = mod.SETTING_NAMES.VERMINHOOD_RADIUS,
				["widget_type"] = "numeric",
				["range"] = {1, 100},
				["text"] = mod:localize("radius"),
				["tooltip"] = mod:localize("VERMINHOOD_RADIUS_T"),
				["default_value"] = 5,
			},
		},
	},
	"Verminhood Mutator",
	"Star of the sisterhood inspired mutator."
		.."\nSplit splits the damage between enemies evenly."
		.."\nPool gives enemies in the radius a shared hp pool."
		.."\nSo in Split mode an ogre would take even amount of dmg, in Pool mode ogre HP takes majority of the damage."
		.."\nThis by itself makes the game easier all things considered."
		.."\nNeeds testing with other players.",
	mutator_options_subs
)

local hp_mutators_subs = mod.add_option(
	"HP_MUTATORS_GROUP",
	{
		["widget_type"] = "group",
	},
	"HP Related",
	"Mutators that address white and green HP."
		.."\nA lot of what made Vermintide 1 different was the lack of white hp, taking even a single hit in V1 mattered."
		.."\nI'm hoping something in that direction can be achieved with some combination of these options.",
	mutator_options_subs
)
mod.add_option(
	"PLAYER_WHITE_HP_GAIN_MULTIPLIER",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 1000},
		["unit_text"] = "%",
		["default_value"] = 100,
	},
	"Player White HP Gain Multiplier",
	"Multiply the amount of white/temp HP players gain."
		.."\nDoesn't affect white hp gained from hp share talent that disables normal healing.",
	hp_mutators_subs
)
mod.add_option(
	"WHITE_HP_DEGEN_AMOUNT",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 15},
	  ["default_value"] = 0.25,
	  ["decimals_number"] = 2,
	},
	"White HP Degen Amount",
	"White HP loss per each degenerating tick."
		.."\nDefault is 0.25.",
	hp_mutators_subs
)
mod.add_option(
	"WHITE_HP_DEGEN_DELAY",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 15},
	  ["default_value"] = 0.5,
	  ["decimals_number"] = 2,
	},
	"White HP Degen Frequency",
	"White HP seconds between degenerating ticks."
		.."\nDefault is 0.5.",
	hp_mutators_subs
)
mod.add_option(
	"WHITE_HP_DEGEN_START",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 15},
	  ["default_value"] = 3,
	  ["decimals_number"] = 1,
	},
	"White HP Degen Start Delay",
	"White HP delay in seconds before starting to degenerate."
		.."\nDefault is 3.",
	hp_mutators_subs
)
mod.add_option(
	"WHITE_HP_TO_GREEN_HP",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 100},
		["unit_text"] = "%",
	  ["default_value"] = 0,
	},
	"White HP Degen To Green HP %%",
	"%% of degenerated White HP to be recieved as Green HP.",
	hp_mutators_subs
)
local lose_green_hp_subs = mod.add_option(
	"LOSE_GREEN_HP_MUTATOR",
	{
		["widget_type"] = "checkbox",
	  ["default_value"] = false,
	},
	"Force Green HP Loss",
	"When you take a hit that temporary HP would cover up, instead also lose some green HP.",
	hp_mutators_subs
)
mod.add_option(
	"LOSE_GREEN_HP_MUTATOR_CHANCE",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 100},
		["unit_text"] = "%",
	  ["default_value"] = 10,
	},
	"HP Loss %%",
	"%% of damage to go to green HP instead of to white HP.",
	lose_green_hp_subs
)

local upscale_breeds_subs = mod.add_option(
	"UPSCALE_BREEDS_MUTATOR",
	{
		["widget_type"] = "checkbox",
	  ["default_value"] = false,
	},
	"Upscale Breeds",
	"Chance to switch enemy type(breed) to a higher tier breed on spawn."
		.."\nKnown issues: can cause enemies to get stuck on some spawn locations.",
	mutator_options_subs
)
mod.add_option(
	"UPSCALE_BREEDS_MUTATOR_CHANCE",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 100},
		["unit_text"] = "%",
	  ["default_value"] = 50,
	},
	"Upscale Chance",
	"Chance for new enemy to be a tier higher.",
	upscale_breeds_subs
)
mod.add_option(
	"UPSCALE_BREEDS_MUTATOR_SUCCESSIVE_CHANCE",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 100},
		["unit_text"] = "%",
	  ["default_value"] = 25,
	},
	"Successive Upscale Chance",
	"After getting upscaled, chance to get upscaled once more.",
	upscale_breeds_subs
)

mod.add_option(
	"SCARY_ELITES_MUTATOR",
	{
		["widget_type"] = "checkbox",
	  ["default_value"] = false,
	},
	"Scary Elites Mutator",
	"Elite enemies are immune to stagger. SV shields are breakable."
		.."\nIncludes: chaos_warrior, skaven_storm_vermin_commander, chaos_raider, skaven_storm_vermin, chaos_berzerker, skaven_storm_vermin_with_shield, skaven_plague_monk.",
	mutator_options_subs
)

mod.add_option(
	"JUICED_SPECIALS_MUTATOR",
	{
		["widget_type"] = "checkbox",
    ["default_value"] = false,
	},
	"Scary Specials Mutator",
	"Make the specials extra scurry.",
	mutator_options_subs
)
mod.add_option(
	"INFINITE_AMMO_MUTATOR",
	{
		["widget_type"] = "checkbox",
    ["default_value"] = false,
	},
	"Infinite Ammo And 0 Heat",
	"Give players infinite ammo and no heat generated.",
	mutator_options_subs
)
mod.add_option(
	"NO_INVIS_MUTATOR",
	{
		["widget_type"] = "checkbox",
    ["default_value"] = false,
	},
	"Disable Invisibility",
	"Disable invisiblity from ults. Need to test with other players.",
	mutator_options_subs
)
mod.add_option(
	"PLAYER_DMG_DEALT_MULTIPLIER",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 1000},
		["unit_text"] = "%",
		["default_value"] = 100,
	},
	"Player Dmg Dealt Multiplier",
	"Multiply the player damage.",
	mutator_options_subs
)
mod.add_option(
	"PLAYER_DMG_TAKEN_MULTIPLIER",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 1000},
		["unit_text"] = "%",
		["default_value"] = 100,
	},
	"Player Dmg Taken Multiplier",
	"Multiply the damage the players take.",
	mutator_options_subs
)
mod.add_option(
	"PLAYER_FF_DMG_MULTIPLIER",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 1000},
		["unit_text"] = "%",
		["default_value"] = 100,
	},
	"Player FF Dmg Multiplier",
	"Multiply the friendly fire damage the players take.",
	mutator_options_subs
)
mod.add_option(
	"PLAYER_ITEM_SLOT_MELEE_DMG_MULTIPLIER",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 1000},
		["unit_text"] = "%",
		["default_value"] = 100,
	},
	"Player Melee Slot Dmg Multiplier",
	"Multiply the damage from melee slot weapons.",
	mutator_options_subs
)
mod.add_option(
	"PLAYER_ITEM_SLOT_RANGED_DMG_MULTIPLIER",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 1000},
		["unit_text"] = "%",
		["default_value"] = 100,
	},
	"Player Ranged Slot Dmg Multiplier",
	"Multiply the damage from ranged slot weapons.",
	mutator_options_subs
)
mod.add_option(
	"PLAYER_ITEM_SLOT_BOMB_DMG_MULTIPLIER",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 1000},
		["unit_text"] = "%",
		["default_value"] = 100,
	},
	"Player Bomb Slot Dmg Multiplier",
	"Multiply the damage from bomb slot weapons.",
	mutator_options_subs
)
mod.add_option(
	"KEEP_GIVING_BOMBS",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Infinite Bombs",
	"Keep giving bombs to players.",
	mutator_options_subs
)
mod.add_option(
	"KEEP_GIVING_FIRE_BOMBS",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Infinite Fire Bombs",
	"Keep giving bombs to players.",
	mutator_options_subs
)
mod.add_option(
	"KEEP_GIVING_STR_POTS",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Infinite Str Potions",
	"Keep giving potions to players.",
	mutator_options_subs
)
mod.add_option(
	"KEEP_GIVING_SPEED_POTS",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Infinite Speed Potions",
	"Keep giving potions to players.",
	mutator_options_subs
)
mod.add_option(
	"KEEP_GIVING_CDR_POTS",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Infinite CDR Potions",
	"Keep giving potions to players.",
	mutator_options_subs
)
mod.add_option(
	"KEEP_GIVING_HP_POTS",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Infinite HP Pots",
	"Keep giving HP pots to players.",
	mutator_options_subs
)
mod.add_option(
	"LORDS_ARENT_DEFENSIVE",
	{
		["widget_type"] = "checkbox",
	  ["default_value"] = false,
	},
	"Lords Don't Spawn Adds",
	"Lords don't enter spawn enemies states, useful if using them in weighted spawning, since their AI can't handle that outside their boss area.",
	mutator_options_subs
)

local pickups_subs = mod.add_option(
	"MAP_PICKUPS_GROUP",
	{
		["widget_type"] = "group",
	},
	"Map Pickups",
	"Change rules for consumables spawning in the level."
)

mod.map_pickups = {
	-- "tome",
	-- "grimoire",
	"cooldown_reduction_potion",
	"all_ammo",
	"first_aid_kit",
	"healing_draught",
	"speed_boost_potion",
	"fire_grenade_t1",
	"fire_grenade_t2",
	"damage_boost_potion",
	"frag_grenade_t1",
	"frag_grenade_t2",
	"all_ammo_small",
	"lamp_oil",
	"explosive_barrel",
	"painting_scrap",
	"ammo_ranger",
	"ammo_ranger_improved",
	"loot_die",
}
local map_pickups_disable_group_subs = mod.add_option(
	"MAP_PICKUPS_DISABLE_GROUP",
	{
		["widget_type"] = "group",
	},
	"Disable Map Pickups",
	"Disable spawning of pickups.",
	pickups_subs
)
mod.add_option(
	"MAP_PICKUPS_REPLACE_DISABLED",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Replace Disabled Pickups",
	"Disabled pickups will be replaced with randomly chosen non-disabled pickups.",
	map_pickups_disable_group_subs
)
for _, pickup_name in ipairs( mod.map_pickups ) do
	local pickup = AllPickups[pickup_name]
	mod.add_option(
		"MAP_PICKUPS_DISABLE_"..pickup_name,
		{
			["widget_type"] = "checkbox",
			["default_value"] = false,
		},
		pickup.hud_description and Localize(pickup.hud_description) or pickup_name,
		"Internal name: "..pickup_name,
		map_pickups_disable_group_subs
	)
end

local specials_group_subs = mod_data.options_widgets[
	pl.tablex.find_if(mod_data.options_widgets,
		function(option_widget)
			return option_widget.setting_name == mod.SETTING_NAMES.SPECIALS
		end)
	].sub_widgets
mod.add_option(
	"ASSASSINS_ALWAYS_FAIL",
	{
		["show_widget_condition"] = {3},
		["widget_type"] = "checkbox",
	  ["default_value"] = false,
	},
	"Assassins Give Up",
	"Assassins will give up after pouncing on a player, for True Solo practice.",
	specials_group_subs
)
mod.add_option(
	"CORRUPTORS_ALWAYS_FAIL",
	{
		["show_widget_condition"] = {3},
		["widget_type"] = "checkbox",
	  ["default_value"] = false,
	},
	"Leeches Always Fail",
	"Leeches will always fail to grab player, for True Solo practice.",
	specials_group_subs
)
mod.add_option(
	"PACKMASTERS_ALWAYS_FAIL",
	{
		["show_widget_condition"] = {3},
		["widget_type"] = "checkbox",
	  ["default_value"] = false,
	},
	"Packmasters Always Fail",
	"Packmasters will always fail to grab player, for True Solo practice.",
	specials_group_subs
)

mod.setting_parents = {}
mod.setting_names_localized = {}
mod.get_defaults = function()
	local defaults = {}
	local function subwidget_search(subwidgets, parents)
		for _, setting_widget in ipairs( subwidgets ) do
			defaults[setting_widget.setting_name] = setting_widget.default_value
			mod.setting_parents[setting_widget.setting_name] = table.clone(parents)
			mod.setting_names_localized[setting_widget.setting_name] = setting_widget.text
			if setting_widget.sub_widgets then
				local new_parents = table.clone(parents)
				table.insert(new_parents, setting_widget.setting_name)
				subwidget_search(setting_widget.sub_widgets, new_parents)
			end
		end
	end

	subwidget_search(mod_data.options_widgets, {})

	return defaults
end
mod.setting_defaults = mod.get_defaults()

mod.is_setting_at_default = function(setting_name)
	return mod:get(mod.SETTING_NAMES[setting_name])
		== mod.setting_defaults[mod.SETTING_NAMES[setting_name]]
end

return mod_data
