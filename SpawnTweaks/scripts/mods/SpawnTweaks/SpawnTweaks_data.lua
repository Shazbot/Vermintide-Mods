local mod = get_mod("SpawnTweaks")

local pl = require'pl.import_into'()

local mod_data = {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
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
		table.insert(breed_options,
			{
				["setting_name"] = breed_name.."_toggle",
				["widget_type"] = "checkbox",
				["text"] = breed_data.localized_name,
				["tooltip"] = "Remove "..breed_data.localized_name.." as an elegible spawn.",
				["default_value"] = false,
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

mod_data.options_widgets = {
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
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.ALWAYS_SPECIALS,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("always_specials"),
				["tooltip"] = mod:localize("always_specials_tooltip"),
				["default_value"] = false,
			},
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.SPECIALS_NO_THREAT_DELAY,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("specials_no_threat_delay"),
				["tooltip"] = mod:localize("specials_no_threat_delay_tooltip"),
				["default_value"] = false,
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
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.AMBIENTS_NO_THREAT,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("ambients_no_threat"),
				["tooltip"] = mod:localize("ambients_no_threat_tooltip"),
				["default_value"] = false,
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
				["setting_name"] = mod.SETTING_NAMES.NO_EMPTY_EVENTS,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("no_empty_events"),
				["tooltip"] = mod:localize("no_empty_events_tooltip"),
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
	{
		["setting_name"] = mod.SETTING_NAMES.THREAT_MULTIPLIER,
		["widget_type"] = "numeric",
		["text"] = mod:localize("threat_multiplier"),
		["tooltip"] = mod:localize("threat_multiplier_tooltip"),
		["range"] = {0, 1},
		["decimals_number"] = 1,
		["default_value"] = 1,
	},
}

mod.get_defaults = function()
	local defaults = {}
	local function subwidget_search(subwidgets)
		for _, setting_widget in ipairs( subwidgets ) do
			defaults[setting_widget.setting_name] = setting_widget.default_value
			if setting_widget.sub_widgets then
				subwidget_search(setting_widget.sub_widgets)
			end
		end
	end

	subwidget_search(mod_data.options_widgets)

	return defaults
end
mod.setting_defaults = mod.get_defaults()

return mod_data
