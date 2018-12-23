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
}

mod.priority_buff_setting_name_to_buff_name = {
	PACED_STRIKES = { "markus_mercenary_passive_proc" },
	KNIGHT_ULT_BLOCK = { "markus_knight_activated_ability_infinite_block" },
	KNIGHT_ULT_POWER = { "markus_knight_activated_ability_damage_buff" },
	GROMRIL = { "bardin_ironbreaker_gromril_armour" },
	WHC_ULT = { "victor_witchhunter_activated_ability_duration" },
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
	KERILLIAN_SHADE_ACTIVATED_ABILITY = { "kerillian_shade_activated_ability" },
	VICTOR_ZEALOT_ACTIVATED_ABILITY = { "victor_zealot_activated_ability" },
	BARDIN_RANGER_ACTIVATED_ABILITY = {
		"bardin_ranger_activated_ability",
		"bardin_ranger_activated_ability_duration",
	},
	BARDIN_IRONBREAKER_ACTIVATED_ABILITY = { "bardin_ironbreaker_activated_ability" },
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
}

local priority_buffs_group_subwidgets = {}
for setting_name, _ in pairs( mod.priority_buff_setting_name_to_buff_name ) do
	mod.SETTING_NAMES[setting_name] = setting_name
	table.insert(priority_buffs_group_subwidgets,
		{
			["setting_name"] = setting_name,
			["widget_type"] = "checkbox",
			["text"] = mod:localize(setting_name),
			["default_value"] = true,
		}
	)
end

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

local custom_buffs_subs = mod.add_option(
	"PLAYER_UI_CUSTOM_BUFFS_GROUP",
	{
		["widget_type"] = "group",
	},
	"Add New Buffs",
	"Add some new custom buffs.",
	player_ui_group.sub_widgets
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
-- mod.add_option(
-- 	"HIDE_HUD_HOTKEY",
-- 	{
-- 		["widget_type"] = "keybind",
-- 		["default_value"] = {},
-- 		["action"] = "hide_hud"
-- 	},
-- 	"Hide HUD Hotkey",
-- 	"Toggle HUD visibility.",
-- 	hide_ui_elements_group.sub_widgets
-- )
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
	"DISABLE_LEVEL_INTRO_AUDIO",
	{
		["widget_type"] = "checkbox",
		["default_value"] = false,
	},
	"Disable Level Intro Audio",
	"Disable Lohner's level intro spiel.",
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
	"Make the ammo bar transparent, 0 being fully invisible.",
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
	5
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
	6
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
	7
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
	8
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
mod.add_option(
	"TEAM_UI_PORTRAIT_ALPHA",
	{
		["widget_type"] = "numeric",
		["range"] = {0, 255},
	    ["default_value"] = 255,
	},
	"Portrait Transparency",
	"Set portrait transparency, 0 is fully transparent.",
	team_ui_group.sub_widgets
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

local priority_buff_bar_group_index = pl.tablex.find_if(mod_data.options_widgets,
	function(option_widget)
		return option_widget.setting_name == mod.SETTING_NAMES.SECOND_BUFF_BAR
	end)
local priority_buff_bar_group = mod_data.options_widgets[priority_buff_bar_group_index]
mod.add_option(
	"SECOND_BUFF_BAR_DISABLE_BUFF_POPUPS",
	{
		["widget_type"] = "checkbox",
	    ["default_value"] = true,
	},
	"Disable Default Buff Popups",
	"Disable the middle-of-screen popups some buffs normally have."
		.."\ne.g. Paced Strikes, Tranquility",
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
	2
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

return mod_data