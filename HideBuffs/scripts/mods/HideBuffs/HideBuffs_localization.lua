local mod = get_mod("HideBuffs")

local pl = require'pl.import_into'()

mod.localizations = mod.localizations or pl.Map()

mod.localizations:update({
	mod_description = {
		en = "UI Tweaks."
	},
	victor_bountyhunter_passive_infinite_ammo_buff = {
		en = "Bounty Hunter Passive"
	},
	victor_bountyhunter_passive_infinite_ammo_buff_tooltip = {
		en = "Bounty Hunter passive."
	},
	grimoire_health_debuff = {
		en = "Grimoire"
	},
	grimoire_health_debuff_tooltip = {
		en = "Grimoire."
	},
	markus_huntsman_passive_crit_aura_buff = {
		en = "Huntsman Passive Crit Aura"
	},
	markus_huntsman_passive_crit_aura_buff_tooltip = {
		en = "Huntsman passive crit aura."
	},
	markus_knight_passive_defence_aura = {
		en = "Foot Knight Aura"
	},
	markus_knight_passive_defence_aura_tooltip = {
		en = "Foot Knight aura."
	},
	kerillian_waywatcher_passive = {
		en = "Waywatcher Passive"
	},
	kerillian_waywatcher_passive_tooltip = {
		en = "Waywatcher passive."
	},
	kerillian_maidenguard_passive_stamina_regen_buff = {
		en = "Handmaiden Passive"
	},
	kerillian_maidenguard_passive_stamina_regen_buff_tooltip = {
		en = "Handmaiden passive."
	},
	HIDE_WHC_GRIMOIRE_POWER_BUFF = {
		en = "WHC Grimoire Power Buff"
	},
	HIDE_WHC_GRIMOIRE_POWER_BUFF_T = {
		en = "WHC grimoire power buff."
	},
	HIDE_SHADE_GRIMOIRE_POWER_BUFF = {
		en = "Shade Grimoire Power Buff"
	},
	HIDE_SHADE_GRIMOIRE_POWER_BUFF_T = {
		en = "Shade grimoire power buff."
	},
	buffs_group = {
		en = "Buffs Tweaks"
	},
	hide_hotkeys_tooltip = {
		en = "Hide hotkeys."
	},
	hide_hotkeys = {
		en = "Hide Hotkeys"
	},
	hide_levels_T = {
		en = "Hide player levels."
	},
	hide_levels = {
		en = "Hide Player Levels"
	},
	hide_frames_T = {
		en = "Hide portrait frames."
	},
	hide_frames = {
		en = "Hide Portrait Frames"
	},
	no_tutorial_ui = {
		en = "Hide Floating Objective Marker"
	},
	no_tutorial_ui_T = {
		en = "Disable objective markers like \"Set Free\" for dead players."
	},
	no_mission_objective = {
		en = "Hide Mission Objective"
	},
	no_mission_objective_T = {
		en = "Hide the mission objective on top of the screen."
	},
	force_default_frame = {
		en = "Use Default Portrait Frames"
	},
	force_default_frame_tooltip = {
		en = "Always use the default portrait frame."
	},
	hide_player_portrait = {
		en = "Hide Player Portrait"
	},
	hide_player_portrait_tooltip = {
		en = "Hide player portrait at bottom left."
	},
	AMMO_COUNTER_GROUP = {
		en = "Ammo Counter Tweaks"
	},
	AMMO_COUNTER_GROUP_T = {
		en = "Tweaks related to the ammo counter."
	},
	AMMO_COUNTER_OFFSET_X = {
		en = "X Offset"
	},
	AMMO_COUNTER_OFFSET_X_T = {
		en = "Optionally offset on the x axis."
	},
	AMMO_COUNTER_OFFSET_Y = {
		en = "Y Offset"
	},
	AMMO_COUNTER_OFFSET_Y_T = {
		en = "Optionally offset on the y axis."
	},
	BUFFS_GROUP = {
		en = "Buffs Tweaks"
	},
	BUFFS_GROUP_T = {
		en = "Tweaks related to active buffs indicators."
	},
	BUFFS_OFFSET_X = {
		en = "X Offset"
	},
	BUFFS_OFFSET_X_T = {
		en = "Optionally offset on the x axis."
	},
	BUFFS_OFFSET_Y = {
		en = "Y Offset"
	},
	BUFFS_OFFSET_Y_T = {
		en = "Optionally offset on the y axis."
	},
	REVERSE_BUFF_DIRECTION = {
		en = "Reverse Buff Direction"
	},
	REVERSE_BUFF_DIRECTION_T = {
		en = "Make active buffs flow from right to left."
	},
	BUFFS_FLOW_VERTICALLY = {
		en = "Buffs Flow Vertically"
	},
	BUFFS_FLOW_VERTICALLY_T = {
		en = "Make active buffs flow from top to bottom."
	},
	BUFFS_DISABLE_ALIGN_ANIMATION = {
		en = "Disable Align Animation"
	},
	BUFFS_DISABLE_ALIGN_ANIMATION_T = {
		en = "Disable the animation of a new buff sliding into place."
	},
	TEAM_UI_GROUP = {
		en = "Teammate UI Tweaks"
	},
	TEAM_UI_GROUP_T = {
		en = "Tweaks related to the teammate portraits."
	},
	TEAM_UI_OFFSET_X = {
		en = "X Offset"
	},
	TEAM_UI_OFFSET_X_T = {
		en = "Optionally offset on the x axis."
	},
	TEAM_UI_OFFSET_Y = {
		en = "Y Offset"
	},
	TEAM_UI_OFFSET_Y_T = {
		en = "Optionally offset on the y axis."
	},
	TEAM_UI_SPACING = {
		en = "Spacing Between Portraits"
	},
	TEAM_UI_SPACING_T = {
		en = "Change the spacing between portraits. Default is 220."
	},
	HIDE_BUFFS_GROUP = {
		en = "Hide Active Buffs"
	},
	TEAM_UI_FLOWS_HORIZONTALLY = {
		en = "Arrange Horizontally"
	},
	TEAM_UI_FLOWS_HORIZONTALLY_T = {
		en = "Arrange the teammate portraits horizontally."
	},
	CHAT_GROUP = {
		en = "Chat Tweaks"
	},
	CHAT_GROUP_T = {
		en = "Tweaks related to the chat UI."
	},
	CHAT_OFFSET_X = {
		en = "X Offset"
	},
	CHAT_OFFSET_X_T = {
		en = "Optionally offset on the x axis."
	},
	CHAT_OFFSET_Y = {
		en = "Y Offset"
	},
	CHAT_OFFSET_Y_T = {
		en = "Optionally offset on the y axis."
	},
	HIDE_WEAPON_SLOTS = {
		en = "Hide Melee and Ranged Item Slots"
	},
	HIDE_WEAPON_SLOTS_T = {
		en = "Hide the first 2 item slots(melee and ranged weapon)."
	},
	REPOSITION_WEAPON_SLOTS = {
		en = "Reposition Weapon Slots"
	},
	REPOSITION_WEAPON_SLOTS_T = {
		en = "Reposition the visible item slots to the left."
	},
	TEAM_UI_PORTRAIT_SCALE = {
		en = "Portrait Scale"
	},
	TEAM_UI_PORTRAIT_SCALE_T = {
		en = "Scale the portraits."
	},
	TEAM_UI_PORTRAIT_OFFSET_X = {
		en = "Portraits X Offset"
	},
	TEAM_UI_PORTRAIT_OFFSET_X_T = {
		en = "Optionally offset the portraits on the x axis."
	},
	TEAM_UI_PORTRAIT_OFFSET_Y = {
		en = "Portraits Y Offset"
	},
	TEAM_UI_PORTRAIT_OFFSET_Y_T = {
		en = "Optionally offset the portraits on the y axis."
	},
	TEAM_UI_NAME_OFFSET_X = {
		en = "Player Name X Offset"
	},
	TEAM_UI_NAME_OFFSET_X_T = {
		en = "Optionally offset the layer name on the x axis."
	},
	TEAM_UI_NAME_OFFSET_Y = {
		en = "Player Name Y Offset"
	},
	TEAM_UI_NAME_OFFSET_Y_T = {
		en = "Optionally offset the player name on the y axis."
	},
	SECOND_BUFF_BAR = {
		en = "Priority Buff Bar"
	},
	SECOND_BUFF_BAR_T = {
		en = "Add a second buff bar for priority buffs."
			.."\nCustomize below what buffs go into this bar."
	},
	SECOND_BUFF_BAR_OFFSET_X = {
		en = "X Offset"
	},
	SECOND_BUFF_BAR_OFFSET_X_T = {
		en = "Optionally offset the Priority Buff Bar on the x axis."
	},
	SECOND_BUFF_BAR_OFFSET_Y = {
		en = "Y Offset"
	},
	SECOND_BUFF_BAR_OFFSET_Y_T = {
		en = "Optionally offset the Priority Buff Bar on the y axis."
	},
	PLAYER_UI_GROUP = {
		en = "Player UI Tweaks"
	},
	PLAYER_UI_GROUP_T = {
		en = "Tweaks related to the player UI on the bottom of the screen."
	},
	PLAYER_UI_OFFSET_X = {
		en = "X Offset"
	},
	PLAYER_UI_OFFSET_X_T = {
		en = "Optionally offset the Player UI on the x axis."
	},
	PLAYER_UI_OFFSET_Y = {
		en = "Y Offset"
	},
	PLAYER_UI_OFFSET_Y_T = {
		en = "Optionally offset the Player UI on the y axis."
	},
	PERSISTENT_AMMO_COUNTER = {
		en = "Persistent Ammo Counter"
	},
	PERSISTENT_AMMO_COUNTER_T = {
		en = "Keep the ammo counter visible with melee weapon equipped."
			.."\nSame thing as the stand-alone mod version of this option."
	},
	HIDE_BOSS_HP_BAR = {
		en = "Hide Boss HP Bar"
	},
	HIDE_BOSS_HP_BAR_T = {
		en = "Hide the HP bar on Bosses."
	},

	PRIORITY_BUFFS_GROUP = {
		en = "Priority Buffs"
	},
	PRIORITY_BUFFS_GROUP_T = {
		en = "Buffs to show in the Priority Buff Bar."
	},
	HIDE_UI_ELEMENTS_GROUP = {
		en = "Hide UI Elements"
	},
	HIDE_UI_ELEMENTS_GROUP_T = {
		en = "Hide some of the UI elements."
	},
	UNOBTRUSIVE_FLOATING_OBJECTIVE = {
		en = "Unobtrusive Objective Marker"
	},
	UNOBTRUSIVE_FLOATING_OBJECTIVE_T = {
		en = "Make the floating objective marker smaller and always transparent."
	},
	UNOBTRUSIVE_MISSION_TOOLTIP = {
		en = "Unobtrusive Mission Marker"
	},
	UNOBTRUSIVE_MISSION_TOOLTIP_T = {
		en = "Make the floating mission marker smaller and always transparent."
			.."\nUsed for revive warning."
	},

	-- priority buffs
	PACED_STRIKES = {
		en = "Merc Paced Strikes"
	},
	KNIGHT_ULT_BLOCK = {
		en = "Knight Inf Block After Ult"
	},
	KNIGHT_ULT_POWER = {
		en = "Knight Power After Ult"
	},
	WHC_ULT = {
		en = "WHC Ult"
	},
	WHC_PING_AS = {
		en = "WHC Ping AS Buff"
	},
	WHC_PING_CRIT = {
		en = "WHC Ping Crit Buff"
	},
	BW_TRANQUILITY = {
		en = "BW Tranquility Passive"
	},
	BH_CRIT_PASSIVE = {
		en = "BH Crit/Ammo Passive"
	},
	GROMRIL = {
		en = "Gromril Armour"
	},
	SWIFT_SLAYING = {
		en = "Swift Slaying Trait"
	},
	HUNTER = {
		en = "Hunter Trait"
	},
	BARRAGE = {
		en = "Barrage Trait"
	},
	DMG_POT = {
		en = "Strength Potion"
	},
	SPEED_POT = {
		en = "Speed Potion"
	},
	CDR_POT = {
		en = "CDR Potion"
	},
	MARKUS_HUNTSMAN_ACTIVATED_ABILITY = {
		en = "Huntsman Ult"
	},
	KERILLIAN_SHADE_ACTIVATED_ABILITY = {
		en = "Shade Ult"
	},
	VICTOR_ZEALOT_ACTIVATED_ABILITY = {
		en = "Zealot Ult"
	},
	BARDIN_RANGER_ACTIVATED_ABILITY = {
		en = "Ranger Ult"
	},
	BARDIN_IRONBREAKER_ACTIVATED_ABILITY = {
		en = "Ironbreaker Ult"
	},
	BARDIN_SLAYER_ACTIVATED_ABILITY = {
		en = "Slayer Ult"
	},
	HUNTSMAN_HS_CRIT_BUFF = {
		en = "Huntsman Makin' It Look Easy"
	},
	HUNTSMAN_HS_RELOAD_SPEED_BUFF = {
		en = "Huntsman Thrill of the Hunt"
	},

})

return mod.localizations
