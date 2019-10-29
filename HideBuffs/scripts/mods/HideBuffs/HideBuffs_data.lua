local mod = get_mod("HideBuffs")

local pl = require'pl.import_into'()

mod.SETTING_NAMES = {
	VICTOR_BOUNTYHUNTER_PASSIVE_INFINITE_AMMO_BUFF = "victor_bountyhunter_passive_infinite_ammo_buff",
	GRIMOIRE_HEALTH_DEBUFF = "grimoire_health_debuff",
	MARKUS_HUNTSMAN_PASSIVE_CRIT_AURA_BUFF = "markus_huntsman_passive_crit_aura_buff",
	MARKUS_KNIGHT_PASSIVE_DEFENCE_AURA = "markus_knight_passive_defence_aura",
	KERILLIAN_WAYWATCHER_PASSIVE = "kerillian_waywatcher_passive",
	KERILLIAN_MAIDENGUARD_PASSIVE_STAMINA_REGEN_BUFF = "kerillian_maidenguard_passive_stamina_regen_buff",
	HIDE_SHADE_GRIMOIRE_POWER_BUFF = "HIDE_SHADE_GRIMOIRE_POWER_BUFF",
	HIDE_ZEALOT_HOLY_CRUSADER_BUFF = "HIDE_ZEALOT_HOLY_CRUSADER_BUFF",
	HIDE_WHC_GRIMOIRE_POWER_BUFF = "HIDE_WHC_GRIMOIRE_POWER_BUFF",
	HIDE_FRAMES = "hide_frames",
	HIDE_LEVELS = "hide_levels",
	HIDE_HOTKEYS = "hide_hotkeys",
	NO_TUTORIAL_UI = "no_tutorial_ui",
	NO_MISSION_OBJECTIVE = "no_mission_objective",
	FORCE_DEFAULT_FRAME = "force_default_frame",
	HIDE_PLAYER_PORTRAIT = "hide_player_portrait",
	AMMO_COUNTER_GROUP = "AMMO_COUNTER_GROUP",
	AMMO_COUNTER_OFFSET_X = "AMMO_COUNTER_OFFSET_X",
	AMMO_COUNTER_OFFSET_Y = "AMMO_COUNTER_OFFSET_Y",
	BUFFS_GROUP = "BUFFS_GROUP",
	BUFFS_OFFSET_X = "BUFFS_OFFSET_X",
	BUFFS_OFFSET_Y = "BUFFS_OFFSET_Y",
	CENTERED_BUFFS = "CENTERED_BUFFS",
	CENTERED_BUFFS_REALIGN = "CENTERED_BUFFS_REALIGN",
	REVERSE_BUFF_DIRECTION = "REVERSE_BUFF_DIRECTION",
	BUFFS_FLOW_VERTICALLY = "BUFFS_FLOW_VERTICALLY",
	TEAM_UI_GROUP = "TEAM_UI_GROUP",
	TEAM_UI_OFFSET_X = "TEAM_UI_OFFSET_X",
	TEAM_UI_OFFSET_Y = "TEAM_UI_OFFSET_Y",
	TEAM_UI_SPACING = "TEAM_UI_SPACING",
	TEAM_UI_FLOWS_HORIZONTALLY = "TEAM_UI_FLOWS_HORIZONTALLY",
	HIDE_BUFFS_GROUP = "HIDE_BUFFS_GROUP",
	BUFFS_DISABLE_ALIGN_ANIMATION = "BUFFS_DISABLE_ALIGN_ANIMATION",
	CHAT_GROUP = "CHAT_GROUP",
	CHAT_OFFSET_X = "CHAT_OFFSET_X",
	CHAT_OFFSET_Y = "CHAT_OFFSET_Y",
	HIDE_WEAPON_SLOTS = "HIDE_WEAPON_SLOTS",
	REPOSITION_WEAPON_SLOTS = "REPOSITION_WEAPON_SLOTS",
	TEAM_UI_PORTRAIT_SCALE = "TEAM_UI_PORTRAIT_SCALE",
	TEAM_UI_PORTRAIT_OFFSET_X = "TEAM_UI_PORTRAIT_OFFSET_X",
	TEAM_UI_PORTRAIT_OFFSET_Y = "TEAM_UI_PORTRAIT_OFFSET_Y",
	TEAM_UI_NAME_OFFSET_X = "TEAM_UI_NAME_OFFSET_X",
	TEAM_UI_NAME_OFFSET_Y = "TEAM_UI_NAME_OFFSET_Y",
	SECOND_BUFF_BAR = "SECOND_BUFF_BAR",
	SECOND_BUFF_BAR_OFFSET_X = "SECOND_BUFF_BAR_OFFSET_X",
	SECOND_BUFF_BAR_OFFSET_Y = "SECOND_BUFF_BAR_OFFSET_Y",
	PLAYER_UI_GROUP = "PLAYER_UI_GROUP",
	PLAYER_UI_OFFSET_X = "PLAYER_UI_OFFSET_X",
	PLAYER_UI_OFFSET_Y = "PLAYER_UI_OFFSET_Y",
	PERSISTENT_AMMO_COUNTER = "PERSISTENT_AMMO_COUNTER",
	HIDE_BOSS_HP_BAR = "HIDE_BOSS_HP_BAR",
	PRIORITY_BUFFS_GROUP = "PRIORITY_BUFFS_GROUP",
	HIDE_UI_ELEMENTS_GROUP = "HIDE_UI_ELEMENTS_GROUP",
	UNOBTRUSIVE_FLOATING_OBJECTIVE = "UNOBTRUSIVE_FLOATING_OBJECTIVE",
	UNOBTRUSIVE_MISSION_TOOLTIP = "UNOBTRUSIVE_MISSION_TOOLTIP",
	CHAT_BG_ALPHA = "CHAT_BG_ALPHA",
	AMMO_DIVIDER_TEXT = "AMMO_DIVIDER_TEXT",
}

mod.sorted_priority_buffs = {
	"DMG_POT",
	"SPEED_POT",
	"CDR_POT",
	"SWIFT_SLAYING",
	"HUNTER",
	"BARRAGE",
	"BARKSKIN",
	"TWITCH_BUFFS",
	"KERILLIAN_SHADE_ACTIVATED_ABILITY",
	"MARKUS_HUNTSMAN_ACTIVATED_ABILITY",
	"HUNTSMAN_HS_CRIT_BUFF",
	"HUNTSMAN_HS_RELOAD_SPEED_BUFF",
	"KNIGHT_ULT_BLOCK",
	"KNIGHT_ULT_POWER",
	"KNIGHT_BUILD_MOMENTUM",
	"PACED_STRIKES",
	"MERC_MORE_MERRIER",
	"MERC_BLADE_BARRIER",
	"MERC_REIKLAND_REAPER",
	"BARDIN_RANGER_ACTIVATED_ABILITY",
	"GROMRIL",
	"BARDIN_IRONBREAKER_ACTIVATED_ABILITY",
	"IB_MINERS_RHYTHM",
	"BARDIN_SLAYER_ACTIVATED_ABILITY",
	"SLAYER_TROPHY_HUNTER",
	"SLAYER_MOVING_TARGET",
	"WHC_ULT",
	"WHC_PING_AS",
	"WHC_PING_CRIT",
	"BH_CRIT_PASSIVE",
	"VICTOR_ZEALOT_ACTIVATED_ABILITY",
	"ZEALOT_INVULNERABLE_ACTIVE",
	"ZEALOT_INVULNERABLE_ON_CD",
	"ZEALOT_HOLY_CRUSADER",
	"ZEALOT_FIERY_FAITH",
	"ZEALOT_NO_SURRENDER",
	"BW_TRANQUILITY",
	"BW_WORLD_AFLAME",
	"BW_BURNOUT",
	"UNCHAINED_FEURBACHS_FURY",
	"custom_wounded_buff",
	"custom_dps_timed_buff",
	"custom_dps_buff",
	"custom_dmg_taken_buff",
	"custom_temp_hp_buff",
	"custom_scavenger_buff",
}

mod.priority_buff_setting_name_to_buff_name = {
	PACED_STRIKES = { "markus_mercenary_passive_proc" },
	KNIGHT_ULT_BLOCK = { "markus_knight_activated_ability_infinite_block" },
	KNIGHT_ULT_POWER = { "markus_knight_activated_ability_damage_buff" },
	GROMRIL = { "bardin_ironbreaker_gromril_armour" },
	WHC_ULT = {
		"victor_witchhunter_activated_ability_duration",
		"victor_witchhunter_activated_ability_crit_buff",
	},
	WHC_PING_AS = { "victor_witchhunter_ping_target_attack_speed" },
	WHC_PING_CRIT = { "victor_witchhunter_ping_target_crit_chance" },
	BH_CRIT_PASSIVE = {
		"victor_bountyhunter_passive_crit_buff",
		"victor_bountyhunter_passive_crit_cooldown",
	},
	BW_TRANQUILITY = {
		"sienna_adept_passive",
		"tranquility",
	},
	SWIFT_SLAYING = { "traits_melee_attack_speed_on_crit_proc" },
	HUNTER = {
		"ranged_power_vs_frenzy",
		"ranged_power_vs_large",
		"ranged_power_vs_armored",
		"ranged_power_vs_unarmored",
	},
	BARRAGE = { "consecutive_shot_buff" },
	DMG_POT = { "armor penetration" },
	SPEED_POT = { "movement" },
	CDR_POT = { "cooldown reduction buff" },
	MARKUS_HUNTSMAN_ACTIVATED_ABILITY = { "markus_huntsman_activated_ability" },
	KERILLIAN_SHADE_ACTIVATED_ABILITY = {
		"kerillian_shade_activated_ability",
		"kerillian_shade_activated_ability_duration",
	},
	VICTOR_ZEALOT_ACTIVATED_ABILITY = {
		"victor_zealot_activated_ability",
		"victor_zealot_activated_ability_duration",
	},
	BARDIN_RANGER_ACTIVATED_ABILITY = {
		"bardin_ranger_activated_ability",
		"bardin_ranger_activated_ability_duration",
	},
	BARDIN_IRONBREAKER_ACTIVATED_ABILITY = {
		"bardin_ironbreaker_activated_ability",
		"bardin_ironbreaker_activated_ability_duration",
	},
	BARDIN_SLAYER_ACTIVATED_ABILITY = { "bardin_slayer_activated_ability" },
	HUNTSMAN_HS_CRIT_BUFF = { "markus_huntsman_passive_crit_buff" },
	HUNTSMAN_HS_RELOAD_SPEED_BUFF = { "markus_huntsman_headshots_increase_reload_speed_buff" },
	TWITCH_BUFFS = {
		"twitch_no_overcharge_no_ammo_reloads",
		"twitch_health_regen",
		"twitch_health_degen",
		"twitch_grimoire_health_debuff",
		"twitch_power_boost_dismember",
	},
	BARKSKIN = { "trait_necklace_damage_taken_reduction_buff" },
	custom_dps_timed_buff = { "custom_dps_timed" },
	custom_dps_buff = { "custom_dps" },
	custom_dmg_taken_buff = { "custom_dmg_taken" },
	custom_temp_hp_buff = { "custom_temp_hp" },
	custom_scavenger_buff = { "custom_scavenger" },
	custom_wounded_buff = { "custom_wounded" },
	MERC_MORE_MERRIER = {
		"markus_mercenary_damage_on_enemy_proximity"
	},
	MERC_BLADE_BARRIER = {
		"markus_mercenary_passive_defence"
	},
	MERC_REIKLAND_REAPER = {
		"markus_mercenary_passive_power_level"
	},
	KNIGHT_BUILD_MOMENTUM = {
		"markus_knight_stamina_regen_buff"
	},
	SLAYER_TROPHY_HUNTER = {
		"bardin_slayer_passive_stacking_damage_buff",
		"bardin_slayer_passive_stacking_damage_buff_increased_duration",
	},
	SLAYER_MOVING_TARGET = {
		"bardin_slayer_passive_stacking_defence_buff"
	},
	IB_MINERS_RHYTHM = {
		"bardin_ironbreaker_regen_stamina_on_charged_attacks_buff"
	},
	ZEALOT_INVULNERABLE_ACTIVE = {
		"victor_zealot_invulnerability_on_lethal_damage_taken"
	},
	ZEALOT_INVULNERABLE_ON_CD = {
		"victor_zealot_invulnerability_cooldown"
	},
	ZEALOT_HOLY_CRUSADER = {
		"victor_zealot_critical_hit_damage_from_passive"
	},
	ZEALOT_FIERY_FAITH = {
		"victor_zealot_passive_damage"
	},
	ZEALOT_NO_SURRENDER = {
		"victor_zealot_damage_on_enemy_proximity"
	},
	BW_WORLD_AFLAME = {
		"sienna_adept_damage_on_enemy_proximity"
	},
	BW_BURNOUT = {
		"sienna_adept_ability_trail_double"
	},
	UNCHAINED_FEURBACHS_FURY = {
		"sienna_unchained_stamina_regen"
	},

}

local priority_buffs_default_disabled = {
	custom_dps_timed_buff = true,
	custom_dps_buff = true,
	custom_dmg_taken_buff = true,
	custom_temp_hp_buff = true,
	custom_scavenger_buff = true,
	custom_wounded_buff = true,
	MERC_MORE_MERRIER = true,
	MERC_REIKLAND_REAPER = true,
	MERC_BLADE_BARRIER = true,
	KNIGHT_BUILD_MOMENTUM = true,
	SLAYER_TROPHY_HUNTER = true,
	SLAYER_MOVING_TARGET = true,
	IB_MINERS_RHYTHM = true,
	ZEALOT_INVULNERABLE_ACTIVE = true,
	ZEALOT_INVULNERABLE_ON_CD = true,
	ZEALOT_HOLY_CRUSADER = true,
	ZEALOT_FIERY_FAITH = true,
	ZEALOT_NO_SURRENDER = true,
	BW_WORLD_AFLAME = true,
	UNCHAINED_FEURBACHS_FURY = true,
}

local priority_buffs_group_subwidgets = {}
for _, setting_name in ipairs( mod.sorted_priority_buffs ) do
	mod.SETTING_NAMES[setting_name] = setting_name
	table.insert(priority_buffs_group_subwidgets,
		{
			["setting_name"] = setting_name,
			["widget_type"] = "checkbox",
			["text"] = mod:localize(setting_name),
			["default_value"] = not priority_buffs_default_disabled[setting_name],
		}
	)
end

mod.ALIGNMENTS = {
	TOP = 1,
	BOTTOM = 2,
	LEFT = 3,
	RIGHT = 4,
	CENTER = 5,
}
mod.ALIGNMENTS_LOOKUP = {
	"top",
	"bottom",
	"left",
	"right",
	"center",
}
mod.PORTRAIT_ICONS = {
	DEFAULT = 1,
	HERO = 2,
	HATS = 3,
}

local mod_data = {
	name = "UI Tweaks",
	description = mod:localize("mod_description"),
	is_togglable = true,
	allow_rehooking = true,
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
	option_widget.tooltip = mod:localize(setting_name.."_T")
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
		["setting_name"] = mod.SETTING_NAMES.FORCE_DEFAULT_FRAME,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("force_default_frame"),
		["tooltip"] = mod:localize("force_default_frame_tooltip"),
		["default_value"] = false,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.UNOBTRUSIVE_FLOATING_OBJECTIVE,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("UNOBTRUSIVE_FLOATING_OBJECTIVE"),
		["tooltip"] = mod:localize("UNOBTRUSIVE_FLOATING_OBJECTIVE_T"),
		["default_value"] = false,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.UNOBTRUSIVE_MISSION_TOOLTIP,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("UNOBTRUSIVE_MISSION_TOOLTIP"),
		["tooltip"] = mod:localize("UNOBTRUSIVE_MISSION_TOOLTIP_T"),
		["default_value"] = false,
	},
	{
		["setting_name"] = mod.SETTING_NAMES.HIDE_UI_ELEMENTS_GROUP,
		["widget_type"] = "group",
		["text"] = mod:localize("HIDE_UI_ELEMENTS_GROUP"),
		["tooltip"] = mod:localize("HIDE_UI_ELEMENTS_GROUP_T"),
		["sub_widgets"] = {},
	},
	{
		["setting_name"] = mod.SETTING_NAMES.CHAT_GROUP,
		["widget_type"] = "group",
		["text"] = mod:localize("CHAT_GROUP"),
		["tooltip"] = mod:localize("CHAT_GROUP_T"),
		["sub_widgets"] = {
			{
				["setting_name"] = mod.SETTING_NAMES.CHAT_OFFSET_X,
				["widget_type"] = "numeric",
				["text"] = mod:localize("CHAT_OFFSET_X"),
				["tooltip"] = mod:localize("CHAT_OFFSET_X_T"),
				["range"] = {-2500, 2500},
				["unit_text"] = "px",
				["default_value"] = 0,
			},
			{
				["setting_name"] = mod.SETTING_NAMES.CHAT_OFFSET_Y,
				["widget_type"] = "numeric",
				["text"] = mod:localize("CHAT_OFFSET_Y"),
				["tooltip"] = mod:localize("CHAT_OFFSET_Y_T"),
				["range"] = {-2500, 2500},
				["unit_text"] = "px",
				["default_value"] = 0,
			},
			{
				["setting_name"] = mod.SETTING_NAMES.CHAT_BG_ALPHA,
				["widget_type"] = "numeric",
				["text"] = mod:localize("CHAT_BG_ALPHA"),
				["tooltip"] = mod:localize("CHAT_BG_ALPHA_T"),
				["range"] = {0, 255},
				["default_value"] = 255,
			},
		},
	},
	{
		["setting_name"] = mod.SETTING_NAMES.AMMO_COUNTER_GROUP,
		["widget_type"] = "group",
		["text"] = mod:localize("AMMO_COUNTER_GROUP"),
		["tooltip"] = mod:localize("AMMO_COUNTER_GROUP_T"),
		["sub_widgets"] = {
			{
				["setting_name"] = mod.SETTING_NAMES.PERSISTENT_AMMO_COUNTER,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("PERSISTENT_AMMO_COUNTER"),
				["tooltip"] = mod:localize("PERSISTENT_AMMO_COUNTER_T"),
				["default_value"] = true,
			},
			{
				["setting_name"] = mod.SETTING_NAMES.AMMO_COUNTER_OFFSET_X,
				["widget_type"] = "numeric",
				["text"] = mod:localize("AMMO_COUNTER_OFFSET_X"),
				["tooltip"] = mod:localize("AMMO_COUNTER_OFFSET_X_T"),
				["range"] = {-2500, 2500},
				["unit_text"] = "px",
				["default_value"] = 0,
			},
			{
				["setting_name"] = mod.SETTING_NAMES.AMMO_COUNTER_OFFSET_Y,
				["widget_type"] = "numeric",
				["text"] = mod:localize("AMMO_COUNTER_OFFSET_Y"),
				["tooltip"] = mod:localize("AMMO_COUNTER_OFFSET_Y_T"),
				["range"] = {-2500, 2500},
				["unit_text"] = "px",
				["default_value"] = 0,
			},
		},
	},
	{
		["setting_name"] = mod.SETTING_NAMES.BUFFS_GROUP,
		["widget_type"] = "group",
		["text"] = mod:localize("BUFFS_GROUP"),
		["tooltip"] = mod:localize("BUFFS_GROUP_T"),
		["sub_widgets"] = {
			{
				["setting_name"] = mod.SETTING_NAMES.CENTERED_BUFFS,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("CENTERED_BUFFS"),
				["tooltip"] = mod:localize("CENTERED_BUFFS_T"),
				["default_value"] = false,
				["sub_widgets"] = {
					{
						["setting_name"] = mod.SETTING_NAMES.CENTERED_BUFFS_REALIGN,
						["widget_type"] = "checkbox",
						["text"] = mod:localize("CENTERED_BUFFS_REALIGN"),
						["tooltip"] = mod:localize("CENTERED_BUFFS_REALIGN_T"),
						["default_value"] = false,
					},
				},
			},
			{
				["setting_name"] = mod.SETTING_NAMES.REVERSE_BUFF_DIRECTION,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("REVERSE_BUFF_DIRECTION"),
				["tooltip"] = mod:localize("REVERSE_BUFF_DIRECTION_T"),
				["default_value"] = false,
			},
			{
				["setting_name"] = mod.SETTING_NAMES.BUFFS_FLOW_VERTICALLY,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("BUFFS_FLOW_VERTICALLY"),
				["tooltip"] = mod:localize("BUFFS_FLOW_VERTICALLY_T"),
				["default_value"] = false,
			},
			{
				["setting_name"] = mod.SETTING_NAMES.BUFFS_DISABLE_ALIGN_ANIMATION,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("BUFFS_DISABLE_ALIGN_ANIMATION"),
				["tooltip"] = mod:localize("BUFFS_DISABLE_ALIGN_ANIMATION_T"),
				["default_value"] = false,
			},
			{
				["setting_name"] = mod.SETTING_NAMES.BUFFS_OFFSET_X,
				["widget_type"] = "numeric",
				["text"] = mod:localize("BUFFS_OFFSET_X"),
				["tooltip"] = mod:localize("BUFFS_OFFSET_X_T"),
				["range"] = {-2500, 2500},
				["unit_text"] = "px",
				["default_value"] = 0,
			},
			{
				["setting_name"] = mod.SETTING_NAMES.BUFFS_OFFSET_Y,
				["widget_type"] = "numeric",
				["text"] = mod:localize("BUFFS_OFFSET_Y"),
				["tooltip"] = mod:localize("BUFFS_OFFSET_Y_T"),
				["range"] = {-2500, 2500},
				["unit_text"] = "px",
				["default_value"] = 0,
			},
		},
	},
	{
		["setting_name"] = mod.SETTING_NAMES.SECOND_BUFF_BAR,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("SECOND_BUFF_BAR"),
		["tooltip"] = mod:localize("SECOND_BUFF_BAR_T"),
		["default_value"] = true,
		["sub_widgets"] = {
			{
				["setting_name"] = mod.SETTING_NAMES.SECOND_BUFF_BAR_OFFSET_X,
				["widget_type"] = "numeric",
				["text"] = mod:localize("SECOND_BUFF_BAR_OFFSET_X"),
				["tooltip"] = mod:localize("SECOND_BUFF_BAR_OFFSET_X_T"),
				["range"] = {-2500, 2500},
				["unit_text"] = "px",
				["default_value"] = 0,
			},
			{
				["setting_name"] = mod.SETTING_NAMES.SECOND_BUFF_BAR_OFFSET_Y,
				["widget_type"] = "numeric",
				["text"] = mod:localize("SECOND_BUFF_BAR_OFFSET_Y"),
				["tooltip"] = mod:localize("SECOND_BUFF_BAR_OFFSET_Y_T"),
				["range"] = {-2500, 2500},
				["unit_text"] = "px",
				["default_value"] = 0,
			},
			{
				["setting_name"] = mod.SETTING_NAMES.PRIORITY_BUFFS_GROUP,
				["widget_type"] = "group",
				["text"] = mod:localize("PRIORITY_BUFFS_GROUP"),
				["tooltip"] = mod:localize("PRIORITY_BUFFS_GROUP_T"),
				["sub_widgets"] = priority_buffs_group_subwidgets
			},
		},
	},
	{
		["setting_name"] = mod.SETTING_NAMES.HIDE_BUFFS_GROUP,
		["widget_type"] = "group",
		["text"] = mod:localize("HIDE_BUFFS_GROUP"),
		["sub_widgets"] = {
			{
				["setting_name"] = mod.SETTING_NAMES.VICTOR_BOUNTYHUNTER_PASSIVE_INFINITE_AMMO_BUFF,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("victor_bountyhunter_passive_infinite_ammo_buff"),
				["tooltip"] = mod:localize("victor_bountyhunter_passive_infinite_ammo_buff_tooltip"),
				["default_value"] = false,
			},
			{
				["setting_name"] = mod.SETTING_NAMES.GRIMOIRE_HEALTH_DEBUFF,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("grimoire_health_debuff"),
				["tooltip"] = mod:localize("grimoire_health_debuff_tooltip"),
				["default_value"] = false,
			},
			{
				["setting_name"] = mod.SETTING_NAMES.MARKUS_HUNTSMAN_PASSIVE_CRIT_AURA_BUFF,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("markus_huntsman_passive_crit_aura_buff"),
				["tooltip"] = mod:localize("markus_huntsman_passive_crit_aura_buff_tooltip"),
				["default_value"] = false,
			},
			{
				["setting_name"] = mod.SETTING_NAMES.MARKUS_KNIGHT_PASSIVE_DEFENCE_AURA,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("markus_knight_passive_defence_aura"),
				["tooltip"] = mod:localize("markus_knight_passive_defence_aura_tooltip"),
				["default_value"] = false,
			},
			{
				["setting_name"] = mod.SETTING_NAMES.KERILLIAN_WAYWATCHER_PASSIVE,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("kerillian_waywatcher_passive"),
				["tooltip"] = mod:localize("kerillian_waywatcher_passive_tooltip"),
				["default_value"] = false,
			},
			{
				["setting_name"] = mod.SETTING_NAMES.KERILLIAN_MAIDENGUARD_PASSIVE_STAMINA_REGEN_BUFF ,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("kerillian_maidenguard_passive_stamina_regen_buff"),
				["tooltip"] = mod:localize("kerillian_maidenguard_passive_stamina_regen_buff_tooltip"),
				["default_value"] = false,
			},
			{
				["setting_name"] = mod.SETTING_NAMES.HIDE_WHC_GRIMOIRE_POWER_BUFF ,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("HIDE_WHC_GRIMOIRE_POWER_BUFF"),
				["tooltip"] = mod:localize("HIDE_WHC_GRIMOIRE_POWER_BUFF_T"),
				["default_value"] = false,
			},
			{
				["setting_name"] = mod.SETTING_NAMES.HIDE_SHADE_GRIMOIRE_POWER_BUFF ,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("HIDE_SHADE_GRIMOIRE_POWER_BUFF"),
				["tooltip"] = mod:localize("HIDE_SHADE_GRIMOIRE_POWER_BUFF_T"),
				["default_value"] = false,
			},
			{
				["setting_name"] = mod.SETTING_NAMES.HIDE_ZEALOT_HOLY_CRUSADER_BUFF ,
				["widget_type"] = "checkbox",
				["text"] = mod:localize("HIDE_ZEALOT_HOLY_CRUSADER_BUFF"),
				["tooltip"] = mod:localize("HIDE_ZEALOT_HOLY_CRUSADER_BUFF_T"),
				["default_value"] = false,
			},
		},
	},
})

local player_ui_group =
{
	["setting_name"] = mod.SETTING_NAMES.PLAYER_UI_GROUP,
	["widget_type"] = "group",
	["text"] = mod:localize("PLAYER_UI_GROUP"),
	["tooltip"] = mod:localize("PLAYER_UI_GROUP_T"),
	["sub_widgets"] = {
		{
			["setting_name"] = mod.SETTING_NAMES.HIDE_PLAYER_PORTRAIT,
			["widget_type"] = "checkbox",
			["text"] = mod:localize("hide_player_portrait"),
			["tooltip"] = mod:localize("hide_player_portrait_tooltip"),
			["default_value"] = false,
		},
		{
			["setting_name"] = mod.SETTING_NAMES.HIDE_HOTKEYS,
			["widget_type"] = "checkbox",
			["text"] = mod:localize("hide_hotkeys"),
			["tooltip"] = mod:localize("hide_hotkeys_tooltip"),
			["default_value"] = true,
		},
		{
			["setting_name"] = mod.SETTING_NAMES.PLAYER_UI_OFFSET_X,
			["widget_type"] = "numeric",
			["text"] = mod:localize("PLAYER_UI_OFFSET_X"),
			["tooltip"] = mod:localize("PLAYER_UI_OFFSET_X_T"),
			["range"] = {-2500, 2500},
			["unit_text"] = "px",
			["default_value"] = 0,
		},
		{
			["setting_name"] = mod.SETTING_NAMES.PLAYER_UI_OFFSET_Y,
			["widget_type"] = "numeric",
			["text"] = mod:localize("PLAYER_UI_OFFSET_Y"),
			["tooltip"] = mod:localize("PLAYER_UI_OFFSET_Y_T"),
			["range"] = {-2500, 2500},
			["unit_text"] = "px",
			["default_value"] = 0,
		},
	},
}
mod_data.options_widgets:insert(8, player_ui_group)

mod.add_option(
	"PLAYER_UI_WIDTH_SCALE",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 500},
		["unit_text"] = "%",
		["default_value"] = 100,
	},
	"Player UI Width Scale",
	"Scale the player UI.",
	player_ui_group.sub_widgets,
	3
)
mod.add_option(
	"PLAYER_UI_PLAYER_PORTRAIT_OFFSET_X",
	{
		["widget_type"] = "numeric",
		["range"] = {-500, 2500},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Player Portrait Offset X",
	"Optionally offset the player portrait on the x axis.",
	player_ui_group.sub_widgets,
	2
)
mod.add_option(
	"PLAYER_UI_PLAYER_PORTRAIT_OFFSET_Y",
	{
		["widget_type"] = "numeric",
		["range"] = {-500, 2000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Player Portrait Offset Y",
	"Optionally offset the player portrait on the y axis.",
	player_ui_group.sub_widgets,
	3
)
mod.add_option(
	"PLAYER_UI_PLAYER_ULT_SKULL_OFFSET_X",
	{
		["widget_type"] = "numeric",
		["range"] = {-1000, 1000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Player Charged Ult Skull Offset X",
	"Optionally offset the ult-is-ready skull on the x axis.",
	player_ui_group.sub_widgets,
	4
)
mod.add_option(
	"PLAYER_UI_PLAYER_ULT_SKULL_OFFSET_Y",
	{
		["widget_type"] = "numeric",
		["range"] = {-1000, 1000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Player Charged Ult Skull Offset Y",
	"Optionally offset the ult-is-ready skull on the y axis.",
	player_ui_group.sub_widgets,
	5
)
mod.add_option(
	"PLAYER_UI_PLAYER_ULT_SKULL_OPACITY",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 255},
		["default_value"] = 255,
	},
	"Player Charged Ult Skull Opacity",
	"Change the ult-is-ready skull opacity, 0 is fully transparent.",
	player_ui_group.sub_widgets,
	6
)

local show_clip_using_overcharge_subs = mod.add_option(
	"PLAYER_UI_SHOW_CLIP_USING_OVERCHARGE",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Show Ammo Using Heat Bar",
	"Show ammo in clip using the heat/overcharge bar."
		.."\nDoesn't show on weapons with 1 ammo clips like bows.",
	player_ui_group.sub_widgets,
	1
)
mod.add_option(
	"PLAYER_UI_SHOW_CLIP_USE_GREY_COLOR",
	{
		["widget_type"] = "checkbox",
		["default_value"] = true,
	},
	"Use Grey Color",
	"Use grey instead of the default orange heat bar color.",
	show_clip_using_overcharge_subs
)
mod.add_option(
	"PLAYER_UI_SHOW_CLIP_ON_LONG_RELOAD_WEAPONS",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Show On Long Reload Weapons",
	"Show on 1 ammo clip weapons with long reload, like handgun.",
	show_clip_using_overcharge_subs
)

local player_item_slots_subs = mod.add_option(
	"PLAYER_ITEM_SLOTS_GROUP",
	{
		["widget_type"] = "group",
	},
	"Item Slots",
	"Tweaks related to the player item slots.",
	player_ui_group.sub_widgets
)
table.insert(player_item_slots_subs,
	{
		["setting_name"] = mod.SETTING_NAMES.HIDE_WEAPON_SLOTS,
		["widget_type"] = "checkbox",
		["text"] = mod:localize("HIDE_WEAPON_SLOTS"),
		["tooltip"] = mod:localize("HIDE_WEAPON_SLOTS_T"),
		["default_value"] = false,
		["sub_widgets"] = {
			{
				["setting_name"] = mod.SETTING_NAMES.REPOSITION_WEAPON_SLOTS,
				["widget_type"] = "numeric",
				["text"] = mod:localize("REPOSITION_WEAPON_SLOTS"),
				["tooltip"] = mod:localize("REPOSITION_WEAPON_SLOTS_T"),
				["range"] = {-2, 0},
				["unit_text"] = " slots",
				["default_value"] = -1,
			},
		},
	}
)
mod.add_option(
	"PLAYER_ITEM_SLOTS_OFFSET_X",
	{
		["widget_type"] = "numeric",
		["range"] = {-1000, 1000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Offset X",
	"Optionally offset the player item slots on the x axis.",
	player_item_slots_subs
)
mod.add_option(
	"PLAYER_ITEM_SLOTS_OFFSET_Y",
	{
		["widget_type"] = "numeric",
		["range"] = {-1000, 1000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Offset Y",
	"Optionally offset the player item slots on the y axis.",
	player_item_slots_subs
)
mod.add_option(
	"PLAYER_ITEM_SLOTS_SIZE",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 300},
		["unit_text"] = "px",
		["default_value"] = 40,
	},
	"Size",
	"Size of the item slots.\nDefault is 40.",
	player_item_slots_subs
)
mod.add_option(
	"PLAYER_ITEM_SLOTS_SPACING",
	{
		["widget_type"] = "numeric",
		["range"] = {-500, 500},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Adjust Spacing",
	"Adjust the spacing between item slots.",
	player_item_slots_subs
)

local player_numeric_ui_group_subs = mod.add_option(
	"PLAYER_NUMERIC_UI_GROUP",
	{
		["widget_type"] = "group",
	},
	"Numeric UI",
	"Show hp and ammo values from the Numeric UI mod.",
	player_ui_group.sub_widgets
)
mod.add_option(
	"PLAYER_NUMERIC_UI_HP_OFFSET_X",
	{
		["widget_type"] = "numeric",
		["range"] = {-1000, 1000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"HP Offset X",
	"Optionally offset the HP on the x axis.",
	player_numeric_ui_group_subs
)
mod.add_option(
	"PLAYER_NUMERIC_UI_HP_OFFSET_Y",
	{
		["widget_type"] = "numeric",
		["range"] = {-1000, 1000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"HP Offset Y",
	"Optionally offset the HP on the y axis.",
	player_numeric_ui_group_subs
)
mod.add_option(
	"PLAYER_NUMERIC_UI_HP_FONT_SIZE",
	{
		["widget_type"] = "numeric",
		["range"] = {10, 40},
		["default_value"] = 17,
	},
	"HP Font Size",
	"Set HP font size."
		.."\nDefault is 17.",
	player_numeric_ui_group_subs
)
mod.add_option(
	"PLAYER_NUMERIC_UI_ULT_CD_OFFSET_X",
	{
		["widget_type"] = "numeric",
		["range"] = {-1000, 1000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Ult CD Offset X",
	"Optionally offset the ult timer on the x axis.",
	player_numeric_ui_group_subs
)
mod.add_option(
	"PLAYER_NUMERIC_UI_ULT_CD_OFFSET_Y",
	{
		["widget_type"] = "numeric",
		["range"] = {-1000, 1000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Ult CD Offset Y",
	"Optionally offset the ult timer on the y axis.",
	player_numeric_ui_group_subs
)
mod.add_option(
	"PLAYER_NUMERIC_UI_ULT_CD_FONT_SIZE",
	{
		["widget_type"] = "numeric",
		["range"] = {10, 40},
		["default_value"] = 16,
	},
	"Ult CD Font Size",
	"Set ult timer font size."
		.."\nDefault is 16.",
	player_numeric_ui_group_subs
)

local buffs_group_index = pl.tablex.find_if(mod_data.options_widgets,
	function(option_widget)
		return option_widget.setting_name == mod.SETTING_NAMES.BUFFS_GROUP
	end)
local buffs_group = mod_data.options_widgets[buffs_group_index]

mod.add_option(
	"MAX_NUMBER_OF_BUFFS",
	{
		["widget_type"] = "numeric",
		["range"] = {1, 30},
		["default_value"] = 5,
	},
	"Max Active Buffs",
	"Max number of active buffs to show on the UI."
		.."\nDefault is 5.",
	buffs_group.sub_widgets
)

local custom_buffs_subs = mod.add_option(
	"PLAYER_UI_CUSTOM_BUFFS_GROUP",
	{
		["widget_type"] = "group",
	},
	"Add New Buffs",
	"Add some new custom buffs."
		.."\nI advise increasing the Max Active Buffs option to have enough available buff slots.",
	buffs_group.sub_widgets
)

mod.add_option(
	"PLAYER_UI_CUSTOM_BUFFS_WOUNDED",
	{
		["widget_type"] = "checkbox",
		["default_value"] = true,
	},
	"Buff For Death's Door",
	"Show a buff when about to die.",
	custom_buffs_subs
)

local custom_buffs_subwidgets = {}
custom_buffs_subwidgets.PLAYER_UI_CUSTOM_BUFFS_AMMO =
	mod.add_option(
		"PLAYER_UI_CUSTOM_BUFFS_AMMO",
		{
			["widget_type"] = "checkbox",
			["default_value"] = false,
		},
		"Buff For Gained Ammo",
		"Show a buff that tracks ammo gained.",
		custom_buffs_subs
	)

custom_buffs_subwidgets.PLAYER_UI_CUSTOM_BUFFS_TEMP_HP =
	mod.add_option(
		"PLAYER_UI_CUSTOM_BUFFS_TEMP_HP",
		{
			["widget_type"] = "checkbox",
			["default_value"] = false,
		},
		"Buff For Gained Temp HP",
		"Show a buff that tracks temp HP gained.",
		custom_buffs_subs
	)

custom_buffs_subwidgets.PLAYER_UI_CUSTOM_BUFFS_DMG_TAKEN =
	mod.add_option(
		"PLAYER_UI_CUSTOM_BUFFS_DMG_TAKEN",
		{
			["widget_type"] = "checkbox",
			["default_value"] = false,
		},
		"Buff For Recent Damage Taken",
		"Show a buff that tracks temp recent damage taken.",
		custom_buffs_subs
	)

local custom_buffs_dps_subwidgets =
	mod.add_option(
		"PLAYER_UI_CUSTOM_BUFFS_DPS",
		{
			["widget_type"] = "checkbox",
			["default_value"] = false,
		},
		"Buff For Tracking DPS",
		"Show a buff that tracks dps through the whole map.",
		custom_buffs_subs
	)
mod.add_option(
	"PLAYER_UI_CUSTOM_BUFFS_DPS_HOTKEY",
	{
		["widget_type"] = "keybind",
		["default_value"] = {},
		["action"] = "reset_dps_buff"
	},
	"Reset DPS Hotkey",
	"Reset the DPS counter.",
	custom_buffs_dps_subwidgets
)

custom_buffs_subwidgets.PLAYER_UI_CUSTOM_BUFFS_DPS_TIMED =
	mod.add_option(
		"PLAYER_UI_CUSTOM_BUFFS_DPS_TIMED",
		{
			["widget_type"] = "checkbox",
			["default_value"] = false,
		},
		"Buff For Tracking Temporary DPS",
		"Show a buff that tracks dps throughout the duration.",
		custom_buffs_subs
	)
mod.add_option(
	"PLAYER_UI_CUSTOM_BUFFS_DPS_TIMED_HOTKEY",
	{
		["widget_type"] = "keybind",
		["default_value"] = {},
		["action"] = "reset_dps_timed_buff"
	},
	"Reset Temporary DPS Hotkey",
	"Reset the temporary DPS counter.",
	custom_buffs_subwidgets.PLAYER_UI_CUSTOM_BUFFS_DPS_TIMED
)

for setting_name, subwidgets in pairs( custom_buffs_subwidgets ) do
	mod.add_option(
		setting_name.."_DURATION",
		{
			["widget_type"] = "numeric",
			["range"] = {1, 120},
			["unit_text"] = "sec",
			["default_value"] = 15,
		},
		"Buff Duration",
		"Duration before the buff disappears.",
		subwidgets
	)
end

mod.add_option(
	"BUFFS_ADJUST_SPACING",
	{
		["widget_type"] = "numeric",
		["range"] = {-8, 300},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Adjust Buff Spacing",
	"Adjust the amount of empty space between buffs.",
	buffs_group.sub_widgets,
	1
)

mod.add_option(
	"BUFFS_SIZE_ADJUST_X",
	{
		["widget_type"] = "numeric",
		["range"] = {-30, 200},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Buff Width Adjustment",
	"Change the buff icon width.",
	buffs_group.sub_widgets,
	1
)
mod.add_option(
	"BUFFS_SIZE_ADJUST_Y",
	{
		["widget_type"] = "numeric",
		["range"] = {-30, 200},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Buff Height Adjustment",
	"Change the buff icon height.",
	buffs_group.sub_widgets,
	1
)

mod.add_option(
	"BUFFS_ALPHA",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 255},
		["default_value"] = 255,
	},
	"Buff Icon Opacity",
	"Adjust buff icon transparency, 0 is fully transparent.",
	buffs_group.sub_widgets,
	1
)

mod.add_option(
	"BUFFS_PRESERVE_ORDER",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Preserve Buff Order",
	"When a new buff appears or a buff gets refreshed try to preserve existing order of buffs."
		.."\nSo a new buff will always appear at the end.",
	buffs_group.sub_widgets,
	1
)

mod.add_option(
	"SECOND_BUFF_BAR_DISABLE_BUFF_POPUPS",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Disable Default Buff Popups",
	"Disable the middle-of-screen popups some buffs normally have."
		.."\ne.g. Paced Strikes, Tranquility",
	buffs_group.sub_widgets,
	1
)

mod.add_option(
	"SHOW_BUFFS_MANAGER_UI",
	{
		["widget_type"] = "checkbox",
		["default_value"] = true,
	},
	"Show Buff Manager UI",
	"Show a UI widget that allows you to hide or move buffs to the priority bar."
		.."\nYou can see it in upper right when you open the chat."
		.."\nThe Buff Manager works by tracking all the buffs that get applied to you."
		.."\nNote that to see changes to a buff the buff needs to get reapplied.",
	buffs_group.sub_widgets,
	1
)

local ammo_counter_group_index = pl.tablex.find_if(mod_data.options_widgets,
	function(option_widget)
		return option_widget.setting_name == mod.SETTING_NAMES.AMMO_COUNTER_GROUP
	end)
local ammo_counter_group = mod_data.options_widgets[ammo_counter_group_index]
mod.add_option(
	"SHOW_RELOAD_REMINDER",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Show Reload Reminder",
	"Change color of ammo in clip to red when ranged weapon not reloaded.",
	ammo_counter_group.sub_widgets,
	1
)
mod.add_option(
	"AMMO_COUNTER_BG_OPACITY",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 255},
		["default_value"] = 200,
	},
	"Background Opacity",
	"Change the opacity of the background texture, 0 is fully transparent."
		.."\nDefault is 200.",
	ammo_counter_group.sub_widgets
)
mod.add_option(
	"AMMO_COUNTER_BG_LAYER",
	{
		["widget_type"] = "numeric",
		["range"] = {-100, 100},
		["default_value"] = 0,
	},
	"Background Layer Index",
	"Change the layer index of the background texture, for example lower it to put it behind the HP bar."
		.."\nDefault is 0.",
	ammo_counter_group.sub_widgets
)
mod.add_option(
	"AMMO_COUNTER_AMMO_CLIP_FONT_SIZE",
	{
		["widget_type"] = "numeric",
		["range"] = {10, 100},
		["default_value"] = 72,
	},
	"Clip Ammo Font Size",
	"Set font size of ammo in clip."
		.."\nDefault is 72.",
	ammo_counter_group.sub_widgets
)
mod.add_option(
	"AMMO_COUNTER_AMMO_CLIP_ALIGNMENT",
	{
		["widget_type"] = "dropdown",
		["default_value"] = mod.ALIGNMENTS.RIGHT,
		["options"] = {
			{ text = mod:localize("right"), value = mod.ALIGNMENTS.RIGHT },
			{ text = mod:localize("left"), value = mod.ALIGNMENTS.LEFT },
			{ text = mod:localize("center"), value = mod.ALIGNMENTS.CENTER },
		},
	},
	"Clip Ammo Alignment",
	"Change the horizontal alignment of ammo in clip.",
	ammo_counter_group.sub_widgets
)
mod.add_option(
	"AMMO_COUNTER_AMMO_CLIP_OFFSET_X",
	{
		["widget_type"] = "numeric",
		["range"] = {-2000, 2000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Clip Ammo Offset X",
	"Optionally offset the current ammo in clip on the x axis.",
	ammo_counter_group.sub_widgets
)
mod.add_option(
	"AMMO_COUNTER_AMMO_CLIP_OFFSET_Y",
	{
		["widget_type"] = "numeric",
		["range"] = {-2000, 2000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Clip Ammo Offset Y",
	"Optionally offset the current ammo in clip on the y axis.",
	ammo_counter_group.sub_widgets
)
mod.add_option(
	"AMMO_COUNTER_AMMO_REMAINING_FONT_SIZE",
	{
		["widget_type"] = "numeric",
		["range"] = {10, 100},
		["default_value"] = 40,
	},
	"Remaining Ammo Font Size",
	"Set font size of remaining ammo."
		.."\nDefault is 40.",
	ammo_counter_group.sub_widgets
)
mod.add_option(
	"AMMO_COUNTER_AMMO_REMAINING_ALIGNMENT",
	{
		["widget_type"] = "dropdown",
		["default_value"] = mod.ALIGNMENTS.LEFT,
		["options"] = {
			{ text = mod:localize("left"), value = mod.ALIGNMENTS.LEFT },
			{ text = mod:localize("right"), value = mod.ALIGNMENTS.RIGHT },
			{ text = mod:localize("center"), value = mod.ALIGNMENTS.CENTER },
		},
	},
	"Remaining Ammo Alignment",
	"Change the horizontal alignment of the remaining ammo.",
	ammo_counter_group.sub_widgets
)
mod.add_option(
	"AMMO_COUNTER_AMMO_REMAINING_OFFSET_X",
	{
		["widget_type"] = "numeric",
		["range"] = {-2000, 2000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Remaining Ammo Offset X",
	"Optionally offset the remaining ammo on the x axis.",
	ammo_counter_group.sub_widgets
)
mod.add_option(
	"AMMO_COUNTER_AMMO_REMAINING_OFFSET_Y",
	{
		["widget_type"] = "numeric",
		["range"] = {-2000, 2000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Remaining Ammo Offset Y",
	"Optionally offset the remaining ammo on the y axis.",
	ammo_counter_group.sub_widgets
)
mod.add_option(
	"AMMO_COUNTER_AMMO_DIVIDER_FONT_SIZE",
	{
		["widget_type"] = "numeric",
		["range"] = {10, 100},
		["default_value"] = 40,
	},
	"Ammo Divider Font Size",
	"Set font size of the ammo divider."
		.."\nDefault is 40."
		.."\nYou can also use /ut_set_ammo_divider to change it from /.",
	ammo_counter_group.sub_widgets
)
mod.add_option(
	"AMMO_COUNTER_AMMO_DIVIDER_OFFSET_X",
	{
		["widget_type"] = "numeric",
		["range"] = {-2000, 2000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Ammo Divider Offset X",
	"Optionally offset the ammo divider on the x axis."
		.."\nYou can also use /ut_set_ammo_divider to change it from /.",
	ammo_counter_group.sub_widgets
)
mod.add_option(
	"AMMO_COUNTER_AMMO_DIVIDER_OFFSET_Y",
	{
		["widget_type"] = "numeric",
		["range"] = {-2000, 2000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Ammo Divider Offset Y",
	"Optionally offset the ammo divider on the y axis."
		.."\nYou can also use /ut_set_ammo_divider to change it from /.",
	ammo_counter_group.sub_widgets
)

local shields_subs = mod.add_option(
	"SHIELDS_GROUP",
	{
		["widget_type"] = "group",
	},
	"Stamina Shields Tweaks",
	"Tweaks related to the stamina shields UI.",
	nil,
	ammo_counter_group_index+1
)
mod.add_option(
	"SHIELDS_OFFSET_X",
	{
		["widget_type"] = "numeric",
		["range"] = {-2000, 2000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Offset X",
	"Optionally offset on the x axis.",
	shields_subs
)
mod.add_option(
	"SHIELDS_OFFSET_Y",
	{
		["widget_type"] = "numeric",
		["range"] = {-2000, 2000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Offset Y",
	"Optionally offset on the y axis.",
	shields_subs
)
mod.add_option(
	"SHIELDS_SIZE_ADJUST",
	{
		["widget_type"] = "numeric",
		["range"] = {-50, 200},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Adjust Shields Size",
	"Adjust the size of stamina shields.",
	shields_subs
)
mod.add_option(
	"SHIELDS_SPACING",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 500},
		["unit_text"] = "px",
		["default_value"] = 30,
	},
	"Spacing Between Shields",
	"Adjust the spacing between stamina shields."
		.."\nDefault is 30.",
	shields_subs
)
mod.add_option(
	"SHIELDS_OPACITY",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 255},
		["default_value"] = 255,
	},
	"Opacity",
	"Adjust shields opacity, 0 is fully transparent."
		.."\nDefault is 255."
		.."\nSet both opacities to the same value to have no fade-in/out.",
	shields_subs
)
mod.add_option(
	"SHIELDS_FADED_OPACITY",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 255},
		["default_value"] = 0,
	},
	"Faded Opacity",
	"Adjust shields opacity when faded out, 0 is fully transparent."
		.."\nDefault is 0."
		.."\nSet both opacities to the same value to disable fade-in/out.",
	shields_subs
)

local hide_ui_elements_group_index = pl.tablex.find_if(mod_data.options_widgets,
	function(option_widget)
		return option_widget.setting_name == mod.SETTING_NAMES.HIDE_UI_ELEMENTS_GROUP
	end)
local hide_ui_elements_group = mod_data.options_widgets[hide_ui_elements_group_index]
mod.add_option(
	"HIDE_HUD_WHEN_INSPECTING",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Hide HUD When Inspecting Hero",
	"Hide the HUD when inspecting hero. Also hides outlines.",
	hide_ui_elements_group.sub_widgets,
	1
)
mod.add_option(
	"HIDE_HUD_HOTKEY",
	{
		["widget_type"] = "keybind",
		["default_value"] = {},
		["action"] = "hide_hud"
	},
	"Hide HUD Hotkey",
	"Toggle HUD visibility.",
	hide_ui_elements_group.sub_widgets
)
mod.add_option(
	mod.SETTING_NAMES.NO_TUTORIAL_UI,
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	nil,
	nil,
	hide_ui_elements_group.sub_widgets
)
mod.add_option(
	mod.SETTING_NAMES.NO_MISSION_OBJECTIVE,
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	nil,
	nil,
	hide_ui_elements_group.sub_widgets
)
mod.add_option(
	mod.SETTING_NAMES.HIDE_FRAMES,
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	nil,
	nil,
	hide_ui_elements_group.sub_widgets
)
mod.add_option(
	mod.SETTING_NAMES.HIDE_LEVELS,
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	nil,
	nil,
	hide_ui_elements_group.sub_widgets
)
mod.add_option(
	mod.SETTING_NAMES.HIDE_BOSS_HP_BAR,
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	nil,
	nil,
	hide_ui_elements_group.sub_widgets
)
mod.add_option(
	"HIDE_PICKUP_OUTLINES",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Hide Pickup Outlines",
	"Hides the white outline around pickups."
		.."\nChanging this won't affect already spawned objects.",
	hide_ui_elements_group.sub_widgets
)
mod.add_option(
	"HIDE_OTHER_OUTLINES",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Hide Objective Outlines",
	"Hides the white outline around objectives."
		.."\nChanging this won't affect already spawned objects.",
	hide_ui_elements_group.sub_widgets
)
mod.add_option(
	"HIDE_NEW_AREA_TEXT",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Hide New Area Popup",
	"Hide location name popup when entering new location.",
	hide_ui_elements_group.sub_widgets
)
mod.add_option(
	"HIDE_LOADING_SCREEN_TIPS",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Hide Level Intro Tips",
	"Hide the tips on the map loading screen.",
	hide_ui_elements_group.sub_widgets
)
mod.add_option(
	"HIDE_LOADING_SCREEN_SUBTITLES",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Hide Level Intro Subtitles",
	"Hide the subtitles on the map loading screen.",
	hide_ui_elements_group.sub_widgets
)
mod.add_option(
	"DISABLE_LEVEL_INTRO_AUDIO",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Disable Level Intro Audio",
	"Disable Lohner's level intro spiel.",
	hide_ui_elements_group.sub_widgets
)
mod.add_option(
	"DISABLE_OLESYA_UBERSREIK_AUDIO",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Disable Olesya Ubersreik Audio",
	"Disable Olesya's lines in the Ubersreik maps.",
	hide_ui_elements_group.sub_widgets
)
mod.add_option(
	"HIDE_WAITING_FOR_RESCUE",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Hide Waiting For Rescue Message",
	"Hide the message when waiting to get rescued.",
	hide_ui_elements_group.sub_widgets
)
mod.add_option(
	"HIDE_TWITCH_MODE_ON_ICON",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Hide Twitch Mode Icon",
	"Hide the Twitch logo and connected icon in lower right when using Twitch mode.",
	hide_ui_elements_group.sub_widgets
)
mod.add_option(
	"STOP_WHITE_HP_FLASHING",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Stop White HP Flashing",
	"Stop flashing the temporary HP.",
	hide_ui_elements_group.sub_widgets
)

local mini_hud_preset_subs = mod.add_option(
	"MINI_HUD_PRESET",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Mini HUD Preset",
	"Use console HP bar while keeping the rest of the PC UI elements."
		.."\nWorks only with the Controller HUD Layout option disabled!"
		.."\nDISABLING AND RETURNING TO NORMAL HUD STATE REQUIRES GAME RESTART",
	nil,
	1
)
mod.add_option(
	"PLAYER_RECT_LAYOUT",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Rectangular Layout",
	"Ditch the texture and use a rectangular layout."
	.."\nDoesn't support width scaling currently."
	.."\nGoing to add a way to rearrange order of HP/ammo/ult bars, and black background behind ammo bar.",
	mini_hud_preset_subs
)
mod.add_option(
	"PLAYER_ULT_BAR_HEIGHT",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 11},
		["unit_text"] = "px",
		["default_value"] = 9,
	},
	"Ult Bar Height",
	"Height of the ult bar in pixels.",
	mini_hud_preset_subs
)

local player_ammo_bar_subs = mod.add_option(
	"PLAYER_AMMO_BAR",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Player Ammo Bar",
	"Add an ammo bar for the player.",
	mini_hud_preset_subs
)

mod.add_option(
	"PLAYER_AMMO_BAR_HEIGHT",
	{
		["widget_type"] = "numeric",
		["range"] = {1, 8},
		["unit_text"] = "px",
		["default_value"] = 2,
	},
	"Height",
	"Height of the ammo bar in pixels.",
	player_ammo_bar_subs
)

mod.add_option(
	"PLAYER_AMMO_BAR_ALPHA",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 255},
		["default_value"] = 255,
	},
	"Transparency",
	"Make the ammo bar transparent, 0 being completely invisible.",
	player_ammo_bar_subs
)

local team_ui_group =
{
	["setting_name"] = mod.SETTING_NAMES.TEAM_UI_GROUP,
	["widget_type"] = "group",
	["text"] = mod:localize("TEAM_UI_GROUP"),
	["tooltip"] = mod:localize("TEAM_UI_GROUP_T"),
	["sub_widgets"] = {
		{
			["setting_name"] = mod.SETTING_NAMES.TEAM_UI_FLOWS_HORIZONTALLY,
			["widget_type"] = "checkbox",
			["text"] = mod:localize("TEAM_UI_FLOWS_HORIZONTALLY"),
			["tooltip"] = mod:localize("TEAM_UI_FLOWS_HORIZONTALLY_T"),
			["default_value"] = false,
		},
		{
			["setting_name"] = mod.SETTING_NAMES.TEAM_UI_OFFSET_X,
			["widget_type"] = "numeric",
			["text"] = mod:localize("TEAM_UI_OFFSET_X"),
			["tooltip"] = mod:localize("TEAM_UI_OFFSET_X_T"),
			["range"] = {-2500, 2500},
			["unit_text"] = "px",
			["default_value"] = 0,
		},
		{
			["setting_name"] = mod.SETTING_NAMES.TEAM_UI_OFFSET_Y,
			["widget_type"] = "numeric",
			["text"] = mod:localize("TEAM_UI_OFFSET_Y"),
			["tooltip"] = mod:localize("TEAM_UI_OFFSET_Y_T"),
			["range"] = {-2500, 2500},
			["unit_text"] = "px",
			["default_value"] = 0,
		},
		{
			["setting_name"] = mod.SETTING_NAMES.TEAM_UI_SPACING,
			["widget_type"] = "numeric",
			["text"] = mod:localize("TEAM_UI_SPACING"),
			["tooltip"] = mod:localize("TEAM_UI_SPACING_T"),
			["range"] = {0, 2000},
			["unit_text"] = "px",
			["default_value"] = 220,
		},
		{
			["setting_name"] = mod.SETTING_NAMES.TEAM_UI_PORTRAIT_SCALE,
			["widget_type"] = "numeric",
			["text"] = mod:localize("TEAM_UI_PORTRAIT_SCALE"),
			["tooltip"] = mod:localize("TEAM_UI_PORTRAIT_SCALE_T"),
			["range"] = {0, 300},
			["unit_text"] = "%",
			["default_value"] = 100,
		},
		{
			["setting_name"] = mod.SETTING_NAMES.TEAM_UI_PORTRAIT_OFFSET_X,
			["widget_type"] = "numeric",
			["text"] = mod:localize("TEAM_UI_PORTRAIT_OFFSET_X"),
			["tooltip"] = mod:localize("TEAM_UI_PORTRAIT_OFFSET_X_T"),
			["range"] = {-2500, 2500},
			["unit_text"] = "px",
			["default_value"] = 0,
		},
		{
			["setting_name"] = mod.SETTING_NAMES.TEAM_UI_PORTRAIT_OFFSET_Y,
			["widget_type"] = "numeric",
			["text"] = mod:localize("TEAM_UI_PORTRAIT_OFFSET_Y"),
			["tooltip"] = mod:localize("TEAM_UI_PORTRAIT_OFFSET_Y_T"),
			["range"] = {-2500, 2500},
			["unit_text"] = "px",
			["default_value"] = 0,
		},
		{
			["setting_name"] = mod.SETTING_NAMES.TEAM_UI_NAME_OFFSET_X,
			["widget_type"] = "numeric",
			["text"] = mod:localize("TEAM_UI_NAME_OFFSET_X"),
			["tooltip"] = mod:localize("TEAM_UI_NAME_OFFSET_X_T"),
			["range"] = {-2500, 2500},
			["unit_text"] = "px",
			["default_value"] = 0,
		},
		{
			["setting_name"] = mod.SETTING_NAMES.TEAM_UI_NAME_OFFSET_Y,
			["widget_type"] = "numeric",
			["text"] = mod:localize("TEAM_UI_NAME_OFFSET_Y"),
			["tooltip"] = mod:localize("TEAM_UI_NAME_OFFSET_Y_T"),
			["range"] = {-2500, 2500},
			["unit_text"] = "px",
			["default_value"] = 0,
		},
	},
}
mod_data.options_widgets:insert(11, team_ui_group)

local team_ui_ammo_bar_group = mod.add_option(
	"TEAM_UI_AMMO_BAR",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Ammo Bar",
	"Add an ammo bar to teammate UI.",
	team_ui_group.sub_widgets,
	1
)
mod.add_option(
	"TEAM_UI_AMMO_SHOW_HEAT",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Show Heat",
	"Show wizard/drake generated heat on the bar.",
	team_ui_ammo_bar_group
)
mod.add_option(
	"TEAM_UI_AMMO_HIDE_INDICATOR",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Hide Ammo Indicator",
	"Hide the default teammate yellow/red ammo indicator.",
	team_ui_ammo_bar_group
)

mod.add_option(
	"TEAM_UI_KEEP_AMMO_ICON_VISIBLE",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Always Show Ammo Status Icon",
	"Always keep the teammate yellow/red ammo status icon visible.",
	team_ui_group.sub_widgets,
	2
)

mod.add_option(
	"TEAM_UI_PORTRAIT_ICONS",
	{
		["widget_type"] = "dropdown",
		["default_value"] = mod.PORTRAIT_ICONS.DEFAULT,
		["options"] = {
			{ text = mod:localize("default"), value = mod.PORTRAIT_ICONS.DEFAULT },
			{ text = mod:localize("hero"), value = mod.PORTRAIT_ICONS.HERO },
			{ text = mod:localize("hats"), value = mod.PORTRAIT_ICONS.HATS },
		},
	},
	"Change Portraits",
	"Change teammate portraits.\nHero uses hero icons, Hats uses hat icons.",
	team_ui_group.sub_widgets,
	14
)
mod.add_option(
	"TEAM_UI_PORTRAIT_ALPHA",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 255},
		["default_value"] = 255,
	},
	"Portrait Transparency",
	"Set portrait transparency, 0 is fully transparent.",
	team_ui_group.sub_widgets,
	15
)
mod.add_option(
	"TEAM_UI_PLAYER_NAME_ALIGNMENT",
	{
		["widget_type"] = "dropdown",
		["default_value"] = mod.ALIGNMENTS.CENTER,
		["options"] = {
			{ text = mod:localize("center"), value = mod.ALIGNMENTS.CENTER },
			{ text = mod:localize("left"), value = mod.ALIGNMENTS.LEFT },
			{ text = mod:localize("right"), value = mod.ALIGNMENTS.RIGHT },
		},
	},
	"Player Name Alignment",
	"Change the horizontal alignment of a player's name.",
	team_ui_group.sub_widgets,
	16
)
mod.add_option(
	"TEAM_UI_PLAYER_NAME_FONT_SIZE",
	{
		["widget_type"] = "numeric",
		["range"] = {10, 40},
		["default_value"] = 18,
	},
	"Player Name Font Size",
	"Set the player name font size."
		.."\nDefault is 18.",
	team_ui_group.sub_widgets,
	17
)
mod.add_option(
	"TEAM_UI_PLAYER_NAME_OPACITY",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 255},
		["default_value"] = 255,
	},
	"Player Name Opacity",
	"Set the player name opacity."
		.."\nDefault is 255.",
	team_ui_group.sub_widgets,
	18
)
mod.add_option(
	"TEAM_UI_HP_BAR_SCALE_WIDTH",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 500},
		["unit_text"] = "%",
		["default_value"] = 100,
	},
	"HP Bar Width Scale",
	"Scale the width of the HP Bar.",
	team_ui_group.sub_widgets,
	10
)
mod.add_option(
	"TEAM_UI_HP_BAR_SCALE_HEIGHT",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 500},
		["unit_text"] = "%",
		["default_value"] = 100,
	},
	"HP Bar Height Scale",
	"Scale the height of the HP Bar.",
	team_ui_group.sub_widgets,
	11
)
mod.add_option(
	"TEAM_UI_HP_BAR_OFFSET_X",
	{
		["widget_type"] = "numeric",
		["range"] = {-1000, 1000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"HP Bar Offset X",
	"Optionally offset the HP bar on the x axis.",
	team_ui_group.sub_widgets,
	12
)
mod.add_option(
	"TEAM_UI_HP_BAR_OFFSET_Y",
	{
		["widget_type"] = "numeric",
		["range"] = {-1000, 1000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"HP Bar Offset Y",
	"Optionally offset the HP bar on the y axis.",
	team_ui_group.sub_widgets,
	13
)
local team_ui_item_slots_subs = mod.add_option(
	"TEAM_UI_ITEM_SLOTS_GROUP",
	{
		["widget_type"] = "group",
	},
	"Item Slots",
	"Tweaks related to the teammate item slots.",
	team_ui_group.sub_widgets
)
mod.add_option(
	"TEAM_UI_ITEM_SLOTS_VERTICAL_FLOW",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Flow Vertically",
	"Make item slots flow vertically.",
	team_ui_item_slots_subs
)
mod.add_option(
	"TEAM_UI_ITEM_SLOTS_ALPHA",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 255},
		["default_value"] = 100,
	},
	"Opacity",
	"Adjust opacity of empty item slots."
		.."\nDefault is 100.",
	team_ui_item_slots_subs
)
mod.add_option(
	"TEAM_UI_ITEM_SLOTS_FILLED_ALPHA",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 255},
		["default_value"] = 255,
	},
	"Filled Slot Opacity",
	"Adjust opacity of non-empty item slots."
		.."\nDefault is 255.",
	team_ui_item_slots_subs
)
mod.add_option(
	"TEAM_UI_ITEM_SLOTS_OFFSET_X",
	{
		["widget_type"] = "numeric",
		["range"] = {-1000, 1000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Offset X",
	"Optionally offset the item slots on the x axis.",
	team_ui_item_slots_subs
)
mod.add_option(
	"TEAM_UI_ITEM_SLOTS_OFFSET_Y",
	{
		["widget_type"] = "numeric",
		["range"] = {-1000, 1000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Offset Y",
	"Optionally offset the item slots on the y axis.",
	team_ui_item_slots_subs
)
mod.add_option(
	"TEAM_UI_ITEM_SLOTS_SIZE",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 100},
		["unit_text"] = "px",
		["default_value"] = 25,
	},
	"Size",
	"Size of the item slots.\nDefault is 25.",
	team_ui_item_slots_subs
)
mod.add_option(
	"TEAM_UI_ITEM_SLOTS_SPACING",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 300},
		["unit_text"] = "px",
		["default_value"] = 35,
	},
	"Spacing",
	"Distance between slots.\nDefault is 35.",
	team_ui_item_slots_subs
)

local teammate_important_icons_subs = mod.add_option(
	"TEAM_UI_ICONS_GROUP",
	{
		["widget_type"] = "checkbox",
		["default_value"] = true,
	},
	"Important Icons",
	"Show icons for Hand of Shallya, Natural Bond, the healshare talent(icon is a hp pot), and when a player is on death's door.",
	team_ui_group.sub_widgets
)
mod.add_option(
	"TEAM_UI_ICONS_OFFSET_X",
	{
		["widget_type"] = "numeric",
		["range"] = {-1000, 1000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Offset X",
	"Optionally offset the icons on the x axis.",
	teammate_important_icons_subs
)
mod.add_option(
	"TEAM_UI_ICONS_OFFSET_Y",
	{
		["widget_type"] = "numeric",
		["range"] = {-1000, 1000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Offset Y",
	"Optionally offset the icons on the y axis.",
	teammate_important_icons_subs
)
mod.add_option(
	"TEAM_UI_ICONS_ALPHA",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 255},
		["default_value"] = 200,
	},
	"Transparency",
	"Adjust icon transparency, 0 being completely invisible.",
	teammate_important_icons_subs
)
mod.add_option(
	"TEAM_UI_ICONS_HAND_OF_SHALLYA",
	{
		["widget_type"] = "checkbox",
		["default_value"] = true,
	},
	"Show Hand of Shallya Icon",
	"Show an icon for Hand of Shallya.",
	teammate_important_icons_subs
)
mod.add_option(
	"TEAM_UI_ICONS_HEALSHARE",
	{
		["widget_type"] = "checkbox",
		["default_value"] = true,
	},
	"Show Heal Share Talent Icon",
	"Show an icon for the heal share talent.",
	teammate_important_icons_subs
)
mod.add_option(
	"TEAM_UI_ICONS_NATURAL_BOND",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Show Natural Bond Icon",
	"Show an icon for Natural Bond.",
	teammate_important_icons_subs
)

local team_ui_numeric_ui_group_subs = mod.add_option(
	"TEAM_UI_NUMERIC_UI_GROUP",
	{
		["widget_type"] = "group",
	},
	"Numeric UI",
	"Show hp and ammo values from the Numeric UI mod.",
	team_ui_group.sub_widgets,
	2
)
mod.add_option(
	"TEAM_UI_NUMERIC_UI_HP_OFFSET_X",
	{
		["widget_type"] = "numeric",
		["range"] = {-1000, 1000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"HP Offset X",
	"Optionally offset the HP on the x axis.",
	team_ui_numeric_ui_group_subs
)
mod.add_option(
	"TEAM_UI_NUMERIC_UI_HP_OFFSET_Y",
	{
		["widget_type"] = "numeric",
		["range"] = {-1000, 1000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"HP Offset Y",
	"Optionally offset the HP on the y axis.",
	team_ui_numeric_ui_group_subs
)
mod.add_option(
	"TEAM_UI_NUMERIC_UI_HP_FONT_SIZE",
	{
		["widget_type"] = "numeric",
		["range"] = {10, 40},
		["default_value"] = 17,
	},
	"HP Font Size",
	"Set HP font size."
		.."\nDefault is 17.",
	team_ui_numeric_ui_group_subs
)
mod.add_option(
	"TEAM_UI_NUMERIC_UI_AMMO_OFFSET_X",
	{
		["widget_type"] = "numeric",
		["range"] = {-1000, 1000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Ammo Offset X",
	"Optionally offset the ammo on the x axis.",
	team_ui_numeric_ui_group_subs
)
mod.add_option(
	"TEAM_UI_NUMERIC_UI_AMMO_OFFSET_Y",
	{
		["widget_type"] = "numeric",
		["range"] = {-1000, 1000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Ammo Offset Y",
	"Optionally offset the ammo on the y axis.",
	team_ui_numeric_ui_group_subs
)
mod.add_option(
	"TEAM_UI_NUMERIC_UI_AMMO_FONT_SIZE",
	{
		["widget_type"] = "numeric",
		["range"] = {10, 40},
		["default_value"] = 22,
	},
	"Ammo Font Size",
	"Set ammo counter font size."
		.."\nDefault is 22.",
	team_ui_numeric_ui_group_subs
)
mod.add_option(
	"TEAM_UI_NUMERIC_UI_ULT_CD_OFFSET_X",
	{
		["widget_type"] = "numeric",
		["range"] = {-1000, 1000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Ult CD Offset X",
	"Optionally offset the ult timer on the x axis.",
	team_ui_numeric_ui_group_subs
)
mod.add_option(
	"TEAM_UI_NUMERIC_UI_ULT_CD_OFFSET_Y",
	{
		["widget_type"] = "numeric",
		["range"] = {-1000, 1000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Ult CD Offset Y",
	"Optionally offset the ult timer on the y axis.",
	team_ui_numeric_ui_group_subs
)
mod.add_option(
	"TEAM_UI_NUMERIC_UI_ULT_CD_FONT_SIZE",
	{
		["widget_type"] = "numeric",
		["range"] = {10, 40},
		["default_value"] = 16,
	},
	"Ult CD Font Size",
	"Set ult timer font size."
		.."\nDefault is 16.",
	team_ui_numeric_ui_group_subs
)

local priority_buff_bar_group_index = pl.tablex.find_if(mod_data.options_widgets,
	function(option_widget)
		return option_widget.setting_name == mod.SETTING_NAMES.SECOND_BUFF_BAR
	end)
local priority_buff_bar_group = mod_data.options_widgets[priority_buff_bar_group_index]
mod.add_option(
	"PRIORITY_BUFFS_PRESERVE_ORDER",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Preserve Buff Order",
	"When a new buff appears or a buff gets refreshed try to preserve existing order of buffs."
		.."\nSo a new buff will always appear at the end.",
	priority_buff_bar_group.sub_widgets,
	1
)
mod.add_option(
	"PRIORITY_BUFFS_DISABLE_ALIGN_ANIMATION",
	{
		["widget_type"] = "checkbox",
		["default_value"] = true,
	},
	"Disable Align Animation",
	"Disable the animation of a new buff sliding into place.",
	priority_buff_bar_group.sub_widgets,
	1
)
mod.add_option(
	"SECOND_BUFF_BAR_SIZE_ADJUST_X",
	{
		["widget_type"] = "numeric",
		["range"] = {-30, 200},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Buff Width Adjustment",
	"Change the buff icon width.",
	priority_buff_bar_group.sub_widgets,
	5
)
mod.add_option(
	"SECOND_BUFF_BAR_SIZE_ADJUST_Y",
	{
		["widget_type"] = "numeric",
		["range"] = {-30, 200},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Buff Height Adjustment",
	"Change the buff icon height.",
	priority_buff_bar_group.sub_widgets,
	6
)
mod.add_option(
	"SECOND_BUFF_BAR_SIZE_ALPHA",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 255},
		["default_value"] = 255,
	},
	"Buff Icon Opacity",
	"Adjust buff icon transparency, 0 is fully transparent.",
	priority_buff_bar_group.sub_widgets,
	7
)

mod.add_option(
	"FASTER_CHEST_OPENING",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Faster Chest Opening",
	"Make the chest opening animations faster.",
	nil,
	2
)

local other_elements_subs = mod.add_option(
	"OTHER_ELEMENTS_GROUP",
	{
		["widget_type"] = "group",
	},
	"Other UI Elements",
	"Tweaks related to any other UI elements."
)
mod.add_option(
	"OTHER_ELEMENTS_SUBTITLES_OFFSET_X",
	{
		["widget_type"] = "numeric",
		["range"] = {-1000, 1000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Subtitles Offset X",
	"Optionally offset the subtitles on the x axis.",
	other_elements_subs
)
mod.add_option(
	"OTHER_ELEMENTS_SUBTITLES_OFFSET_Y",
	{
		["widget_type"] = "numeric",
		["range"] = {-1000, 1000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Subtitles Offset Y",
	"Optionally offset the subtitles on the y axis.",
	other_elements_subs
)
mod.add_option(
	"OTHER_ELEMENTS_HEAT_BAR_OFFSET_X",
	{
		["widget_type"] = "numeric",
		["range"] = {-1000, 1000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Heat Bar Offset X",
	"Optionally offset the heat bar on the x axis.",
	other_elements_subs
)
mod.add_option(
	"OTHER_ELEMENTS_HEAT_BAR_OFFSET_Y",
	{
		["widget_type"] = "numeric",
		["range"] = {-1000, 1000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Heat Bar Offset Y",
	"Optionally offset the heat bar on the y axis.",
	other_elements_subs
)
mod.add_option(
	"OTHER_ELEMENTS_TWITCH_VOTE_OFFSET_X",
	{
		["widget_type"] = "numeric",
		["range"] = {-1500, 1500},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Twitch Vote UI Offset X",
	"Optionally offset the Twitch voting UI on the x axis.",
	other_elements_subs
)
mod.add_option(
	"OTHER_ELEMENTS_TWITCH_VOTE_OFFSET_Y",
	{
		["widget_type"] = "numeric",
		["range"] = {-1000, 2000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Twitch Vote UI Offset Y",
	"Optionally offset the Twitch voting UI on the y axis.",
	other_elements_subs
)
mod.add_option(
	"OTHER_ELEMENTS_BOSS_HP_BAR_OFFSET_X",
	{
		["widget_type"] = "numeric",
		["range"] = {-2000, 2000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Boss HP Bar Offset X",
	"Optionally offset the Boss HP Bar on the x axis.",
	other_elements_subs
)
mod.add_option(
	"OTHER_ELEMENTS_BOSS_HP_BAR_OFFSET_Y",
	{
		["widget_type"] = "numeric",
		["range"] = {-2000, 2000},
		["unit_text"] = "px",
		["default_value"] = 0,
	},
	"Boss HP Bar Offset Y",
	"Optionally offset the Boss HP Bar on the y axis.",
	other_elements_subs
)

local show_presets_subs = mod.add_option(
	"SHOW_PRESETS_UI",
	{
		["widget_type"] = "checkbox",
	  ["default_value"] = true,
	},
	"Show Presets UI",
	"Whether to show the presets UI in the keep.",
	nil,
	1
)
mod.add_option(
	"SHOW_PRESETS_UI_OUTSIDE_KEEP",
	{
		["widget_type"] = "checkbox",
	  ["default_value"] = false,
	},
	"Show Outside Keep",
	"Show during normal maps.",
	show_presets_subs
)

mod.add_option(
	"SHOW_PRESETS_ADDED_WELCOME_MSG",
	{
		["widget_type"] = "checkbox",
		["default_value"] = true,
	},
	"Show Welcome Message",
	"Show the welcome message in chat.",
	nil,
	1
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

return mod_data
