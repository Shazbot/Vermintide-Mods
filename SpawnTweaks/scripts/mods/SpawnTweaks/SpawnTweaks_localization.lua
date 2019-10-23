local mod = get_mod("SpawnTweaks")

local pl = require'pl.import_into'()

mod.localizations = mod.localizations or pl.Map()

mod.localizations:update({
	mod_name = {
		en = "Spawn Tweaks"
	},
	mod_description = {
		en = "Change stuff."
	},
	THREAT_GROUP = {
		en = "Threat and Intensity"
	},
	DISABLE_SPAWNS_GROUP = {
		en = "Disable Spawns"
	},
	horde_size = {
		en = "Horde Size"
	},
	horde_size_tooltip = {
		en = "Set horde size."
	},
	event_horde_size = {
		en = "Event Horde Size"
	},
	event_horde_size_tooltip = {
		en = "Set event horde size."
	},
	disable_patrols = {
		en = "Disable Patrols"
	},
	disable_patrols_tooltip = {
		en = "Disable the big Stormvermin and Chaos Warrior patrols."
	},
	disable_fixed_event_specials = {
		en = "Disable Fixed Event Specials"
	},
	disable_fixed_event_specials_tooltip = {
		en = "Disable scripted specials spawns in map events."
	},
	disable_fixed_spawns = {
		en = "Disable Fixed Spawns"
	},
	disable_fixed_spawns_tooltip = {
		en = "Disable fixed map spawns. (e.g. Empire in Flames 2 chaos warriors at the gates)"
	},
	disable_roaming_patrols = {
		en = "Disable Roaming Patrols"
	},
	disable_roaming_patrols_tooltip = {
		en = "Disable small ambient roaming patrols."
	},
	bosses = {
		en = "Bosses"
	},
	bosses_tooltip = {
		en = "Disable bosses from map triggers completely or customize boss-related options."
	},
	ambients = {
		en = "Ambients"
	},
	ambients_tooltip = {
		en = "Disable or customize the ambient, static map spawns."
	},
	hordes = {
		en = "Hordes"
	},
	hordes_tooltip = {
		en = "Disable or customize horde-related options."
	},
	specials = {
		en = "Specials"
	},
	specials_tooltip = {
		en = "Disable or customize timed specials-related options."
	},
	default = {
		en = "Default"
	},
	disable = {
		en = "Disable"
	},
	radius = {
		en = "Radius"
	},
	VERMINHOOD_RADIUS_T = {
		en = "Radius around the enemy to select the enemies from."
	},
	split = {
		en = "Split"
	},
	pool = {
		en = "Pool HP"
	},
	customize = {
		en = "Customize"
	},
	no_boss_door = {
		en = "No Boss Doors"
	},
	no_boss_door_tooltip = {
		en = "Disable boss barriers."
	},
	boss_dmg_multiplier = {
		en = "Damage To Bosses Multiplier"
	},
	boss_dmg_multiplier_tooltip = {
		en = "Multiplies damage all players do to bosses."
	},
	special_to_boss_chance = {
		en = "Replace Special With Boss Chance"
	},
	special_to_boss_chance_tooltip = {
		en = "Chance for a spawned special to be a boss instead."
	},
	SPECIAL_TO_BOSS_CHANCE_ALLOW_BOSS_STACKING = {
		en = "Replace Special With Boss Chance Always Active"
	},
	SPECIAL_TO_BOSS_CHANCE_ALLOW_BOSS_STACKING_T = {
		en = "Special to boss chance checks if a boss is already alive to keep things fair."
			.."\nEnable to skip this check, allowing bosses to stack up."
	},
	spawn_cooldown_min = {
		en = "Min Cooldown For New Special"
	},
	spawn_cooldown_min_tooltip = {
		en = "Minimal cooldown for a new special to spawn. Game randomly chooses between min and max."
			.."\nDefault is 50."
	},
	spawn_cooldown_max = {
		en = "Max Cooldown For New Special"
	},
	spawn_cooldown_max_tooltip = {
		en = "Maximal cooldown for a new special to spawn. Game randomly chooses between min and max."
			.."\nDefault is 90."
	},
	safe_zone_delay_min = {
		en = "Min Delay After Leaving Safe Zone"
	},
	horde_startup_min = {
		en = "Horde Initial Map Delay Min"
	},
	horde_startup_min_tooltip = {
		en = "Minimal delay after start of the map for the first horde to appear."
			.."\nDefault is 40."
	},
	horde_startup_max = {
		en = "Horde Initial Map Delay Max"
	},
	horde_startup_max_tooltip = {
		en = "Maximal delay after start of the map for the first horde to appear."
			.."\nDefault is 120."
	},
	safe_zone_delay_min_tooltip = {
		en = "Minimal delay after start of the map and when timed specials start to spawn."
			.."\nDefault is 30."
	},
	safe_zone_delay_max = {
		en = "Max Delay After Leaving Safe Zone"
	},
	safe_zone_delay_max_tooltip = {
		en = "Maximal delay after start of the map and when timed specials start to spawn."
			.."\nDefault is 60."
	},
	always_specials = {
		en = "Keep Spawning Timed Specials During Events"
	},
	always_specials_tooltip = {
		en = "Some events disable timed specials spawning, choose to keep them always spawning."
	},
	specials_no_threat_delay = {
		en = "Specials Ignore Threat"
	},
	specials_no_threat_delay_tooltip = {
		en = "Keep spawning specials even when threat (what the game uses to calculate current intensity for dynamic difficulty scaling) is high."
	},
	max_one_boss = {
		en = "Only One Random Boss"
	},
	max_one_boss_tooltip = {
		en = "Limit random bosses to 1 per level."
	},
	double_bosses = {
		en = "Double Bosses"
	},
	double_bosses_tooltip = {
		en = "Spawn 2 non-duplicate bosses instead of 1."
	},
	no_empty_events = {
		en = "No Empty Boss Triggers"
	},
	no_empty_events_tooltip = {
		en = "All boss map triggers will spawn bosses."
	},
	max_specials = {
		en = "Max Specials"
	},
	max_specials_tooltip = {
		en = "Maximum number of specials alive at the same time."
			.."\nDefault is 4."
	},
	max_same_specials = {
		en = "Max Of Same Special"
	},
	max_same_specials_tooltip = {
		en = "Maximum number of duplicate specials alive at the same time."
			.."\nDefault is 2."
	},
	horde_frequency_min = {
		en = "Min Horde Cooldown"
	},
	horde_frequency_min_tooltip = {
		en = "Min bound of horde cooldown. Game chooses between those two for time of next horde."
			.."\nDefault is 50."
	},
	horde_frequency_max = {
		en = "Max Horde Cooldown"
	},
	horde_frequency_max_tooltip = {
		en = "Max bound of horde cooldown. Game chooses between those two for time of next horde."
			.."\nDefault is 100."
	},
	threat_multiplier = {
		en = "Threat And Intensity Multiplier"
	},
	threat_multiplier_tooltip = {
		en = "Decrease global threat and intensity level so the game increases spawn rates."
			.."\nDefault is 1."
	},
	max_grunts = {
		en = "Max Horde Trash"
	},
	max_grunts_tooltip = {
		en = "Max horde trash alive, stops spawning new trash if this number is hit."
			.."\nDefault is 90."
	},
	horde_grunt_limit = {
		en = "Max Trash Limiting Horde Start"
	},
	horde_grunt_limit_tooltip = {
		en = "Cutoff for number of trash alive that prevents a new wave or horde to start."
			.."\nDefault is 60."
	},
	more_ambient_elites = {
		en = "More Ambient Elites"
	},
	more_ambient_elites_tooltip = {
		en = "Spawn more elite ambients instead of ambient trash."
	},
	ambients_multiplier = {
		en = "Ambient Spawn Amount"
	},
	ambients_multiplier_tooltip = {
		en = "Change amount of ambient spawns."
	},
	no_troll = {
		en = "No Troll"
	},
	no_troll_tooltip = {
		en = "Replace troll with another random boss."
	},
	no_chaos_spawn = {
		en = "No Chaos Spawn"
	},
	no_chaos_spawn_tooltip = {
		en = "Replace Chaos Spawn with another random boss."
	},
	no_stormfiend = {
		en = "No Stormfiend"
	},
	no_stormfiend_tooltip = {
		en = "Replace Stormfiend with another random boss."
	},
	no_minotaur = {
		en = "No Minotaur"
	},
	no_minotaur_tooltip = {
		en = "Replace Minotaur with another random boss."
	},
	save_preset_command_description = {
		en = "Save current Spawn Tweaks options into a preset!"
	},
	load_preset_command_description = {
		en = "Load a Spawn Tweaks preset."
	},
	delete_preset_command_description = {
		en = "Delete a Spawn Tweaks preset."
	},
	dump_settings_command_description = {
		en = "Dump Spawn Tweaks settings to a file in launcher folder."
	},
	specials_toggle_group = {
		en = "Disable Specials By Type"
	},
	breeds_dmg_group = {
		en = "Breeds Dmg Taken Multipliers"
	},
	breed_dmg_multiplier_tooltip = {
		en = "Multiplies damage all players do to "
	},
	reset_breed_dmg_description = {
		en = "Reset all damage taken for breeds to 100."
	},
	specials_weights_toggle_group = {
		en = "Use Weighted Spawning Rules"
	},
	specials_weights_toggle_group_tooltip = {
		en = "If enabled use weighted probability to control spawning of specials.\n"..
			"A special of weight 10 is 10x more likely to spawn compared to a special with weight 1.\n"..
			"Can be combined with \"Disable Specials By Type\".\n"..
			"Already queued specials will still spawn before you see any changes.\n"..
			"Ignores max of same breed limit."
	},
	custom_horde_toggle_group = {
		en = "Custom Horde Weights"
	},
	chaos_horde_toggle_group = {
		en = "Chaos Horde Weights"
	},
	skaven_horde_toggle_group = {
		en = "Skaven Horde Weights"
	},
	horde_types = {
		en = "Horde Types"
	},
	horde_types_tooltip = {
		en = "Specify what types of hordes you want."
			.."\nChanging skaven=>chaos and vice versa requires map restart or passing a race switch map trigger."
	},
	horde_types_both = {
		en = "Chaos And Skaven"
	},
	horde_types_only_chaos = {
		en = "Only Chaos"
	},
	horde_types_only_skaven = {
		en = "Only Skaven"
	},
	horde_types_only_custom = {
		en = "Only Custom"
	},
	chaos_horde_toggle_group_tooltip = {
		en = "Use a custom skaven horde makeup with weights.\n"..
			"e.g. having Plague Monks at 1 and Stormvermin at 1 will make a 50/50 horde."
			.."\nAVOID USING MINI-BOSSES LIKE RAT OGRE AND AVOID THE GREY SEER AND DEATHRATTLER"
	},
	skaven_horde_toggle_group_tooltip = {
		en = "Use a custom skaven horde makeup with weights.\n"..
			"e.g. having Plague Monks at 1 and Stormvermin at 1 will make a 50/50 horde."
			.."\nAVOID USING MINI-BOSSES LIKE RAT OGRE AND AVOID THE GREY SEER AND DEATHRATTLER"
	},
	custom_horde_toggle_group_tooltip = {
		en = "Specify horde makeup with weights.\n"..
			"e.g. having Plague Monks at 1 and Stormvermin at 1 will make a 50/50 horde."
			.."\nAVOID USING MINI-BOSSES LIKE RAT OGRE AND AVOID THE GREY SEER AND DEATHRATTLER"
	},
	ambients_no_threat = {
		en = "Ambients Ignore Threat",
	},
	ambients_no_threat_tooltip = {
		en = "Make ambient mini-patrols keep spawning at high threat.",
	},
	CUSTOM_AMBIENTS_TOGGLE_GROUP = {
		en = "Weighted Ambient Makeup",
	},
	CUSTOM_AMBIENTS_TOGGLE_GROUP_tooltip = {
		en = "Specify ambient makeup with weights."
			.."\ne.g. having Plague Monks at 1 and Stormvermin at 1 will make a 50/50 ambient split."
			.."\nSome breeds could cause crashes, don't have the time to test."
			.."\nIgnores More Ambient Elites.",
	},
	LORD_DMG_MULTIPLIER = {
		en = "Damage To Lords Multiplier",
	},
	LORD_DMG_MULTIPLIER_T = {
		en = "Multiplies damage all players do to lords(big bosses).",
	},
	BOSS_EVENTS = {
		en = "Possible Events",
	},
	BOSS_EVENTS_T = {
		en = "Choose between possible events to trigger.",
	},
	BOSS_EVENTS_ONLY_BOSSES = {
		en = "Only Bosses",
	},
	BOSS_EVENTS_ONLY_PATROLS = {
		en = "Only Patrols",
	},
	BOSS_EVENTS_BOTH = {
		en = "Both",
	},
	HORDES_BOTH_DIRECTIONS = {
		en = "From Both Directions",
	},
	HORDES_BOTH_DIRECTIONS_T = {
		en = "Hordes will be spawned from both directions.",
	},
	AGGRO_PATROLS = {
		en = "Patrols Start Aggroed",
	},
	AGGRO_PATROLS_T = {
		en = "Patrols will aggro on spawn.",
	},
	DISABLE_BLOC_VECTOR_HORDE = {
		en = "Disable Blob Vector Hordes",
	},
	DISABLE_BLOC_VECTOR_HORDE_T = {
		en = "There are ambush hordes and 2 types of vector hordes: normal and blob."
			.."\nBlob vector horde doesn't support changing composition and direction."
			.."\nSo this option replaces blob vector hordes with normal vector hordes.",
	},
	NO_BOTS = {
		en = "Disable Bots",
	},
	NO_BOTS_T = {
		en = "Start the map without bots.",
	},
})

return mod.localizations
