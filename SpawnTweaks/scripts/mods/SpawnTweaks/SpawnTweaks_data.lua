local mod = get_mod("SpawnTweaks") -- luacheck: ignore get_mod

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
	HORDE_STARTUP_MIN = "horde_startup_min",
	HORDE_STARTUP_MAX = "horde_startup_max",
	DISABLE_FIXED_SPAWNS = "disable_fixed_spawns",
	BOSSES = "bosses",
	AMBIENTS = "ambients",
	HORDES = "hordes",
	SPECIALS = "specials",
	ALWAYS_SPECIALS = "always_specials",
	BOSS_DMG_MULTIPLIER = "boss_dmg_multiplier",
	SPECIAL_TO_BOSS_CHANCE = "special_to_boss_chance",
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
	{
		["setting_name"] = mod.SETTING_NAMES.HORDES,
		["widget_type"] = "dropdown",
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
		},
	},
	{
		["setting_name"] = mod.SETTING_NAMES.SPECIALS,
		["widget_type"] = "dropdown",
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
				["range"] = {0, 30},
				["default_value"] = 4,
			},
			{
				["show_widget_condition"] = {3},
				["setting_name"] = mod.SETTING_NAMES.MAX_SAME_SPECIALS,
				["widget_type"] = "numeric",
				["text"] = mod:localize("max_same_specials"),
				["tooltip"] = mod:localize("max_same_specials_tooltip"),
				["range"] = {0, 30},
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
		},
	},
	{
		["setting_name"] = mod.SETTING_NAMES.AMBIENTS,
		["widget_type"] = "dropdown",
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
		},
	},
	{
		["setting_name"] = mod.SETTING_NAMES.BOSSES,
		["widget_type"] = "dropdown",
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
				["setting_name"] = mod.SETTING_NAMES.SPECIAL_TO_BOSS_CHANCE,
				["widget_type"] = "numeric",
				["text"] = mod:localize("special_to_boss_chance"),
				["tooltip"] = mod:localize("special_to_boss_chance_tooltip"),
				["range"] = {0, 100},
				["unit_text"] = "%",
				["default_value"] = 0,
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

return mod_data